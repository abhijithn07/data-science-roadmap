"""NutriTrack Phase 3 - Retrieval Augmented Generation (RAG) nutrition assistant.

This module is the engine behind the AI Assistant page. It does three things:

1. Builds a small knowledge base of plain text facts from the same SQLite
   database the rest of the app uses (USDA foods, NHANES diabetes insights, and
   the Phase 2 model card). Nothing is invented here; every fact is read or
   computed from the real data.
2. Retrieves the most relevant facts for a user question using TF-IDF cosine
   similarity. For a few hundred short documents this is fast, has no heavy
   dependencies, and is easy to explain.
3. Sends the question together with the retrieved facts to a Groq hosted model,
   with a strict system prompt that tells the model to answer only from those
   facts, cite them, and never give a medical diagnosis.

The Groq call is the only part that needs the network and an API key. If the key
is missing the app falls back to showing the retrieved facts on their own, so the
page still demonstrates retrieval without a key.
"""

from __future__ import annotations

import json
import os
import re
import sqlite3
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# Default Groq model. Groq deprecated llama-3.3-70b-versatile and
# llama-3.1-8b-instant for free and developer tier use on 17 June 2026, so the
# default here is the recommended replacement. Swap this one line for
# 'openai/gpt-oss-120b' for higher quality, or another id from
# https://api.groq.com/openai/v1/models
DEFAULT_MODEL = "openai/gpt-oss-20b"

SYSTEM_PROMPT = (
    "You are NutriTrack Assistant, a helpful nutrition and diabetes awareness "
    "assistant. The Context block below holds facts drawn from the NutriTrack "
    "data (USDA foods and the NHANES survey). Use the context as your primary "
    "source: when it answers the question, base your answer on it and cite the "
    "facts you use with their bracket numbers, for example [2]. When the context "
    "does not fully cover the question, you may answer from general, well "
    "established nutrition knowledge, and make clear that this part is general "
    "guidance rather than something from the NutriTrack data. When the user "
    "lists foods with amounts and asks for totals (calories, protein, and so "
    "on), call the calculate_meal tool instead of doing the arithmetic yourself. "
    "Estimate grams for counts and scoops, for example 5 almonds is about 6 "
    "grams, 1 scoop of protein powder is about 30 grams, 1 medium banana is "
    "about 118 grams, and 350 ml of milk is about 360 grams. Keep answers short "
    "and clear. You are not a doctor: never give a diagnosis, and when a question "
    "is about someone's personal health, remind them to see a qualified "
    "professional. Do not use em dashes."
)


# --------------------------------------------------------------------------- #
# 1. Build the knowledge base from the database
# --------------------------------------------------------------------------- #
def _num(value, digits: int = 1) -> str:
    """Format a number, or return 'not reported' for missing values."""
    if value is None or (isinstance(value, float) and np.isnan(value)):
        return "not reported"
    return f"{value:,.{digits}f}"


def _food_documents(conn: sqlite3.Connection) -> list[dict]:
    foods = pd.read_sql_query("SELECT * FROM foods ORDER BY food_name", conn)
    docs = []
    for _, r in foods.iterrows():
        text = (
            f"Food: {r['food_name']}. Nutrition per 100 grams: "
            f"{_num(r['calories'], 0)} kcal, {_num(r['protein'])} g protein, "
            f"{_num(r['carbs'])} g carbohydrate, {_num(r['fat'])} g fat, "
            f"{_num(r['fiber'])} g fiber, {_num(r['sugar'])} g sugar, "
            f"{_num(r['sodium'], 0)} mg sodium."
        )
        docs.append({"text": text, "source": f"USDA food: {r['food_name']}"})
    return docs


def _nhanes_documents(conn: sqlite3.Connection) -> list[dict]:
    df = pd.read_sql_query("SELECT * FROM nhanes", conn)
    docs: list[dict] = []

    # Overall prevalence
    prev = df["diabetes_indicator"].dropna()
    docs.append({
        "text": (
            f"In the cleaned NHANES 2017-2018 sample of {len(df):,} respondents, "
            f"about {prev.mean() * 100:.1f} percent report diabetes. The target is "
            f"imbalanced, which is why the Phase 2 model is judged on precision, "
            f"recall, and F1 rather than accuracy alone."
        ),
        "source": "NHANES insight: overall diabetes prevalence",
    })

    # Prevalence by age group
    ages = df.dropna(subset=["age", "diabetes_indicator"]).copy()
    bins = [0, 30, 45, 60, 200]
    labels = ["Under 30", "30 to 44", "45 to 59", "60 and over"]
    ages["age_group"] = pd.cut(ages["age"], bins=bins, labels=labels, right=False)
    by_age = ages.groupby("age_group", observed=True)["diabetes_indicator"].mean() * 100
    age_txt = "; ".join(f"{grp}: {val:.1f} percent" for grp, val in by_age.items())
    docs.append({
        "text": f"Diabetes prevalence rises steeply with age in the NHANES sample. By age group: {age_txt}.",
        "source": "NHANES insight: diabetes prevalence by age group",
    })

    # Prevalence by BMI category
    bmi = df.dropna(subset=["bmi", "diabetes_indicator"]).copy()
    bmi_bins = [0, 18.5, 25, 30, 200]
    bmi_labels = ["Underweight", "Normal", "Overweight", "Obese"]
    bmi["bmi_cat"] = pd.cut(bmi["bmi"], bins=bmi_bins, labels=bmi_labels, right=False)
    by_bmi = bmi.groupby("bmi_cat", observed=True)["diabetes_indicator"].mean() * 100
    bmi_txt = "; ".join(f"{grp}: {val:.1f} percent" for grp, val in by_bmi.items())
    docs.append({
        "text": f"Diabetes prevalence rises with body mass index in the NHANES sample. By BMI category: {bmi_txt}.",
        "source": "NHANES insight: diabetes prevalence by BMI category",
    })

    # Correlations with diabetes
    corr_cols = ["glucose", "age", "bmi", "physical_activity"]
    corrs = df[corr_cols + ["diabetes_indicator"]].corr()["diabetes_indicator"].drop("diabetes_indicator")
    corr_txt = "; ".join(f"{name}: r = {val:.2f}" for name, val in corrs.items())
    docs.append({
        "text": (
            f"Correlation of factors with the diabetes indicator in the NHANES sample "
            f"(association, not causation): {corr_txt}. Glucose is the strongest signal, "
            f"followed by age and BMI."
        ),
        "source": "NHANES insight: feature correlations with diabetes",
    })

    # Glucose missingness caveat
    miss = df["glucose"].isna().mean() * 100
    docs.append({
        "text": (
            f"Fasting glucose is measured only on the fasting subsample, so it is missing "
            f"for about {miss:.0f} percent of NHANES respondents. NutriTrack uses glucose "
            f"only to define the training label, never as a model input, so the tool works "
            f"as a screener that needs no blood test."
        ),
        "source": "NHANES insight: glucose missingness",
    })
    return docs


def _reference_documents() -> list[dict]:
    return [
        {
            "text": (
                "American Diabetes Association fasting glucose cut points, used by NutriTrack "
                "to build its risk label: below 100 mg/dL is normal (Low risk), 100 to 125 "
                "mg/dL is prediabetes (Medium risk), and 126 mg/dL or above is in the diabetes "
                "range (High risk)."
            ),
            "source": "Reference: ADA fasting glucose thresholds",
        },
        {
            "text": (
                "Body mass index categories: underweight is below 18.5, normal is 18.5 to under "
                "25, overweight is 25 to under 30, and obese is 30 or above. BMI is weight in "
                "kilograms divided by height in metres squared."
            ),
            "source": "Reference: BMI categories",
        },
        {
            "text": (
                "NutriTrack Phase 2 model card. The model is a tuned Random Forest that predicts "
                "a three class diabetes risk (Low, Medium, High) from ten non glucose features: "
                "age, gender, BMI, physical activity, and daily diet (calories, protein, carbs, "
                "fat, fiber, sugar). On the held out test set it reaches about 0.54 accuracy and "
                "0.54 weighted F1. Because it predicts a lab defined label from lifestyle alone, "
                "moderate accuracy is expected. It is an educational screener, not a diagnosis."
            ),
            "source": "NutriTrack Phase 2 model card",
        },
    ]


def build_corpus(db_path: Path) -> list[dict]:
    """Build the full list of knowledge documents from the database."""
    with sqlite3.connect(db_path) as conn:
        docs = _food_documents(conn) + _nhanes_documents(conn)
    docs += _reference_documents()
    for i, d in enumerate(docs):
        d["id"] = i
    return docs


# --------------------------------------------------------------------------- #
# 2. TF-IDF retriever
# --------------------------------------------------------------------------- #
class Retriever:
    """Ranks knowledge documents against a query with TF-IDF cosine similarity."""

    def __init__(self, corpus: list[dict]):
        self.corpus = corpus
        self.vectorizer = TfidfVectorizer(stop_words="english", ngram_range=(1, 2))
        self.matrix = self.vectorizer.fit_transform([d["text"] for d in corpus])

    def retrieve(self, query: str, k: int = 4) -> list[dict]:
        q = self.vectorizer.transform([query])
        scores = cosine_similarity(q, self.matrix)[0]
        top = np.argsort(scores)[::-1][:k]
        return [{**self.corpus[i], "score": float(scores[i])} for i in top if scores[i] > 0]


# --------------------------------------------------------------------------- #
# 3. Groq generation
# --------------------------------------------------------------------------- #
def get_api_key(explicit: str | None = None) -> str | None:
    """Resolve the Groq API key from an explicit value, env var, or st.secrets."""
    if explicit:
        return explicit
    key = os.getenv("GROQ_API_KEY")
    if key:
        return key
    try:  # optional: read from .streamlit/secrets.toml when running in Streamlit
        import streamlit as st
        return st.secrets.get("GROQ_API_KEY")
    except Exception:
        return None


def build_context_block(contexts: list[dict]) -> str:
    return "\n".join(f"[{i + 1}] {c['text']}" for i, c in enumerate(contexts))


def answer(question: str, contexts: list[dict], api_key: str,
           model: str = DEFAULT_MODEL, db_path: Path | None = None) -> dict:
    """Answer a question, grounded in context, with an optional meal calculator.

    Returns {"text": str, "calculation": dict | None}. When db_path is given the
    model can call the calculate_meal tool; the arithmetic runs in Python against
    the foods table, not in the model.
    """
    from groq import Groq

    client = Groq(api_key=api_key)
    context_block = build_context_block(contexts)
    user_content = (
        f"Context:\n{context_block}\n\n"
        f"Question: {question}\n\n"
        f"Answer using the context above where it helps, and cite the facts you use."
    )
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": user_content},
    ]
    kwargs = dict(model=model, messages=messages, temperature=0.2, max_tokens=800)
    if db_path is not None:
        kwargs["tools"] = [MEAL_TOOL]

    response = client.chat.completions.create(**kwargs)
    msg = response.choices[0].message
    calculation = None

    if getattr(msg, "tool_calls", None):
        messages.append(msg)  # the assistant turn that requested the tool
        for tc in msg.tool_calls:
            if tc.function.name == "calculate_meal" and db_path is not None:
                try:
                    args = json.loads(tc.function.arguments)
                except (ValueError, TypeError):
                    args = {"items": []}
                calculation = calculate_meal(args.get("items", []), db_path)
                messages.append({
                    "role": "tool",
                    "tool_call_id": tc.id,
                    "content": json.dumps(calculation),
                })
        follow_up = client.chat.completions.create(
            model=model, messages=messages, temperature=0.2, max_tokens=800)
        text = (follow_up.choices[0].message.content or "").strip()
    else:
        text = (msg.content or "").strip()

    return {"text": text, "calculation": calculation}


def answer_with_groq(question: str, contexts: list[dict], api_key: str,
                     model: str = DEFAULT_MODEL) -> str:
    """Backwards-compatible wrapper that returns just the answer text."""
    return answer(question, contexts, api_key, model)["text"]


# --------------------------------------------------------------------------- #
# 4. Meal calculator (a Python tool the model can call)
# --------------------------------------------------------------------------- #
CALC_NUTRIENTS = ["calories", "protein", "carbs", "fat", "fiber", "sugar", "sodium"]
_DERIVATIVES = {"milk", "butter", "flour", "juice", "oil", "powder", "cream", "sauce"}

MEAL_TOOL = {
    "type": "function",
    "function": {
        "name": "calculate_meal",
        "description": (
            "Calculate the total nutrition of a meal from its ingredients. Call this "
            "whenever the user lists foods with amounts and wants totals such as calories, "
            "protein, or carbs. Convert every ingredient to grams before passing it in, "
            "estimating grams for counts and scoops (for example 5 almonds is about 6 "
            "grams, 1 scoop of protein powder is about 30 grams, 1 medium banana is about "
            "118 grams, 350 ml of milk is about 360 grams)."
        ),
        "parameters": {
            "type": "object",
            "properties": {
                "items": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "food": {"type": "string",
                                     "description": "food name to look up, e.g. 'almonds'"},
                            "grams": {"type": "number",
                                      "description": "amount of this food in grams"},
                        },
                        "required": ["food", "grams"],
                    },
                }
            },
            "required": ["items"],
        },
    },
}


def _food_tokens(text: str) -> list[str]:
    words = re.findall(r"[a-z]+", text.lower())
    return [w[:-1] if len(w) > 3 and w.endswith("s") else w for w in words]


def _match_food(query: str, foods: pd.DataFrame):
    """Best matching food row for a free-text name, or None if nothing fits.

    Prefers the query word as the leading term and avoids derivative products
    (so 'almonds' matches the raw nut, not 'Almond butter' or 'Flour, almond').
    """
    q = _food_tokens(query)
    if not q:
        return None
    best, best_score = None, 0.0
    for _, row in foods.iterrows():
        ft = _food_tokens(row["food_name"])
        if not ft:
            continue
        score = 0.0
        for qt in q:
            if qt in ft:
                idx = ft.index(qt)
                score += (3.0 if idx == 0 else 2.0) + 1.0 / (1 + idx)
        if (set(ft) & _DERIVATIVES) - set(q):
            score -= 2.5
        score -= 0.02 * len(ft)  # prefer shorter, more generic names on ties
        if score > best_score:
            best, best_score = row, score
    return best if best_score >= 2.0 else None


def calculate_meal(items: list[dict], db_path: Path) -> dict:
    """Look up each ingredient in the foods table, scale to grams, and sum.

    All arithmetic happens here in Python, not in the language model. Returns a
    per-item breakdown, the summed totals, and any ingredients that were not found
    in the USDA foundation foods.
    """
    with sqlite3.connect(db_path) as conn:
        cols = ", ".join(["food_name"] + CALC_NUTRIENTS)
        foods = pd.read_sql_query(f"SELECT {cols} FROM foods", conn)

    out_items, not_found = [], []
    totals = {n: 0.0 for n in CALC_NUTRIENTS}
    for it in items:
        name = str(it.get("food", "")).strip()
        try:
            grams = float(it.get("grams", 0))
        except (ValueError, TypeError):
            grams = 0.0
        match = _match_food(name, foods)
        if match is None:
            not_found.append(name)
            continue
        factor = grams / 100.0
        scaled = {}
        for n in CALC_NUTRIENTS:
            v = match[n]
            if pd.notna(v):
                sv = round(float(v) * factor, 1)
                scaled[n] = sv
                totals[n] += sv
            else:
                scaled[n] = None
        out_items.append({"input": name, "matched": str(match["food_name"]),
                          "grams": grams, **scaled})

    totals = {n: round(v, 1) for n, v in totals.items()}
    return {"items": out_items, "totals": totals, "not_found": not_found}


def retrieval_only_answer(contexts: list[dict]) -> str:
    """Fallback when no API key is set: present the retrieved facts directly."""
    if not contexts:
        return ("I could not find anything relevant in the NutriTrack knowledge base for that "
                "question. Try asking about a specific food or about diabetes risk factors.")
    lines = ["No Groq API key is set, so here are the most relevant facts from the "
             "NutriTrack data (retrieval only, no generated answer):", ""]
    lines += [f"[{i + 1}] {c['text']}" for i, c in enumerate(contexts)]
    return "\n".join(lines)