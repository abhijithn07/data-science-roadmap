"""NutriTrack Phase 1 Streamlit app. Reads cleaned real data from SQLite only."""

import sqlite3
from datetime import date
from pathlib import Path

import pandas as pd
import plotly.express as px
import streamlit as st

DB_PATH = Path(__file__).parent / "database" / "nutritrack.db"
NUTRIENTS = ["calories", "protein", "carbs", "fat", "fiber", "sugar", "sodium"]

BRAND = "#0f6e5c"
PALETTE = ["#0f6e5c", "#e8833a", "#e0567a", "#3a9d7a", "#c45bbd", "#5a7fa8", "#1f2d28"]
NUTRIENT_COLOR = {
    "calories": "#1f2d28", "protein": "#0f6e5c", "carbs": "#e8833a", "fat": "#e0567a",
    "fiber": "#3a9d7a", "sugar": "#c45bbd", "sodium": "#5a7fa8",
}

st.set_page_config(page_title="NutriTrack", page_icon="🥗", layout="wide")


def apply_theme():
    st.markdown(
        """
        <style>
        @import url('https://fonts.googleapis.com/css2?family=Sora:wght@500;600;700&family=Inter:wght@400;500;600&display=swap');
        :root{
          --brand:#0f6e5c; --brand-d:#0a4d41; --accent:#e8833a;
          --canvas:#f4f7f5; --ink:#16241f; --muted:#6b837b; --card:#ffffff; --line:#e3ebe7;
        }
        .stApp{ background:var(--canvas); }
        .stApp, .stApp p, .stApp label, .stApp span, .stApp div{
          font-family:'Inter',-apple-system,sans-serif; color:var(--ink);
        }
        h1,h2,h3,h4{ font-family:'Sora',sans-serif !important; letter-spacing:-.02em; font-weight:700; }
        /* Keep Streamlit's Material icons rendering as glyphs, not as their text names */
        [data-testid="stIconMaterial"], .material-symbols-rounded, .material-icons, span[class*="material-symbols"]{
          font-family:'Material Symbols Rounded','Material Symbols Outlined','Material Icons' !important;
        }
        section[data-testid="stSidebar"]{ background:linear-gradient(180deg,var(--brand-d),var(--brand)); }
        section[data-testid="stSidebar"] *{ color:#eaf3f0 !important; }
        section[data-testid="stSidebar"] h1{ color:#ffffff !important; font-size:1.45rem; }
        .nt-hero{
          background:linear-gradient(120deg,var(--brand),#13836e); color:#fff;
          padding:24px 30px; border-radius:18px; margin-bottom:20px;
          box-shadow:0 10px 30px rgba(15,110,92,.18);
        }
        .nt-hero h1{ color:#fff !important; margin:0; font-size:2rem; }
        .nt-hero p{ color:#d8ece6 !important; margin:.45rem 0 0; font-size:1.02rem; }
        .nt-grid{ display:grid; grid-template-columns:repeat(auto-fit,minmax(150px,1fr)); gap:14px; margin:6px 0 8px; }
        .nt-tile{
          background:var(--card); border:1px solid var(--line); border-radius:14px;
          padding:14px 16px; border-top:4px solid var(--brand); box-shadow:0 2px 10px rgba(16,40,33,.05);
        }
        .nt-tile .k{ font-size:.7rem; letter-spacing:.09em; text-transform:uppercase; color:var(--muted); }
        .nt-tile .v{ font-family:'Sora',sans-serif; font-size:1.45rem; font-weight:600; margin-top:4px; color:var(--ink); }
        .nt-tile .v.muted{ font-size:1rem; color:var(--muted); font-weight:500; }
        .stButton>button, .stForm button{
          background:var(--brand); color:#fff !important; border:none; border-radius:10px;
          font-weight:600; padding:.5rem 1.2rem;
        }
        .stButton>button:hover, .stForm button:hover{ background:var(--accent); }
        .nt-eyebrow{ font-size:.72rem; letter-spacing:.14em; text-transform:uppercase; color:var(--accent); font-weight:600; margin-bottom:2px; }
        </style>
        """,
        unsafe_allow_html=True,
    )


def hero(title, subtitle):
    st.markdown(f"<div class='nt-hero'><h1>{title}</h1><p>{subtitle}</p></div>", unsafe_allow_html=True)


def nutrient_tiles(values):
    cells = []
    for name in NUTRIENTS:
        unit = "kcal" if name == "calories" else ("mg" if name == "sodium" else "g")
        value = values.get(name)
        if pd.isna(value):
            body = "<div class='v muted'>Not reported</div>"
        else:
            body = f"<div class='v'>{value:,.1f} <span style='font-size:.95rem;color:var(--muted)'>{unit}</span></div>"
        cells.append(
            f"<div class='nt-tile' style='border-top-color:{NUTRIENT_COLOR[name]}'>"
            f"<div class='k'>{name.title()}</div>{body}</div>"
        )
    st.markdown(f"<div class='nt-grid'>{''.join(cells)}</div>", unsafe_allow_html=True)


def stat_tiles(items):
    cells = [f"<div class='nt-tile'><div class='k'>{label}</div><div class='v'>{value}</div></div>"
             for label, value in items]
    st.markdown(f"<div class='nt-grid'>{''.join(cells)}</div>", unsafe_allow_html=True)


def style_fig(fig, height=360):
    fig.update_layout(
        template="plotly_white", height=height, margin=dict(l=10, r=10, t=54, b=10),
        font=dict(family="Inter, sans-serif", color="#16241f"),
        title_font=dict(family="Sora, sans-serif", size=18, color="#16241f"),
        colorway=PALETTE, paper_bgcolor="rgba(0,0,0,0)", plot_bgcolor="rgba(0,0,0,0)",
    )
    fig.update_xaxes(gridcolor="#e3ebe7", zeroline=False)
    fig.update_yaxes(gridcolor="#e3ebe7", zeroline=False)
    return fig


def connect():
    return sqlite3.connect(DB_PATH)


def require_database():
    if not DB_PATH.exists():
        st.error("Database not found. Run all cells in notebooks/NutriTrack_Phase1_Analysis.ipynb first.")
        st.stop()
    with connect() as conn:
        tables = {row[0] for row in conn.execute("SELECT name FROM sqlite_master WHERE type='table'")}
    if not {"foods", "nhanes"}.issubset(tables):
        st.error("The database is from the old build. Run the rebuilt Phase 1 notebook to create foods and nhanes tables.")
        st.stop()


def initialize_app_tables():
    with connect() as conn:
        conn.execute("""CREATE TABLE IF NOT EXISTS profiles (
            id INTEGER PRIMARY KEY CHECK (id = 1), name TEXT, age INTEGER, gender TEXT,
            height REAL, weight REAL, calorie_goal REAL, protein_goal REAL,
            carbs_goal REAL, fat_goal REAL)""")
        conn.execute("""CREATE TABLE IF NOT EXISTS meal_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT, log_date TEXT NOT NULL,
            meal_type TEXT NOT NULL, fdc_id INTEGER NOT NULL, food_name TEXT NOT NULL,
            grams REAL NOT NULL, calories REAL, protein REAL, carbs REAL, fat REAL,
            fiber REAL, sugar REAL, sodium REAL)""")


@st.cache_data
def load_foods():
    with connect() as conn:
        return pd.read_sql_query("SELECT * FROM foods ORDER BY food_name", conn)


@st.cache_data
def load_nhanes():
    with connect() as conn:
        return pd.read_sql_query("SELECT * FROM nhanes", conn)


def load_profile():
    with connect() as conn:
        row = conn.execute("SELECT * FROM profiles WHERE id = 1").fetchone()
        columns = [item[1] for item in conn.execute("PRAGMA table_info(profiles)")]
    return dict(zip(columns, row)) if row else {}


def load_meals(log_date=None):
    query = "SELECT * FROM meal_log"
    params = []
    if log_date:
        query += " WHERE log_date = ?"
        params.append(str(log_date))
    query += " ORDER BY id DESC"
    with connect() as conn:
        return pd.read_sql_query(query, conn, params=params)


def scaled_nutrition(food_row, grams):
    factor = grams / 100.0
    return {name: (food_row[name] * factor if pd.notna(food_row[name]) else None) for name in NUTRIENTS}


require_database()
initialize_app_tables()
apply_theme()
foods = load_foods()
nhanes = load_nhanes()


def page_home():
    hero("NutriTrack", "Nutrition tracking and diabetes-awareness analysis using "
                       "real USDA Foundation Foods and NHANES 2017–2018 data.")
    diabetes = nhanes["diabetes_indicator"].dropna()
    stat_tiles([
        ("USDA Foundation Foods", f"{len(foods):,}"),
        ("NHANES respondents", f"{len(nhanes):,}"),
        ("Self-reported diabetes", f"{diabetes.mean() * 100:.1f}%" if len(diabetes) else "Not available"),
    ])
    st.markdown("<div class='nt-eyebrow'>What you can do</div>", unsafe_allow_html=True)
    st.markdown(
        "- **Food Search** — look up any food's nutrition per serving.\n"
        "- **Meal Logger** — record meals and build a daily log.\n"
        "- **Nutrition Dashboard** — explore food and diabetes-risk patterns.\n"
        "- **Daily Nutrition Calculator** — compare intake against your goals."
    )
    st.info("Educational use only. NutriTrack does not diagnose diabetes or replace medical care.")


def page_profile():
    hero("User Profile", "Set your details and daily goals — used by the calculator.")
    profile = load_profile()
    with st.form("profile"):
        name = st.text_input("Name", profile.get("name", ""))
        c1, c2 = st.columns(2)
        age = c1.number_input("Age", 18, 120, int(profile.get("age", 30)))
        gender = c2.selectbox("Gender", ["Female", "Male"], index=1 if profile.get("gender") == "Male" else 0)
        height = c1.number_input("Height (cm)", 100.0, 250.0, float(profile.get("height", 170.0)))
        weight = c2.number_input("Weight (kg)", 30.0, 300.0, float(profile.get("weight", 70.0)))
        calorie_goal = c1.number_input("Daily calorie goal", 500.0, 6000.0, float(profile.get("calorie_goal", 2000.0)), 50.0)
        protein_goal = c2.number_input("Daily protein goal (g)", 10.0, 500.0, float(profile.get("protein_goal", 75.0)))
        carbs_goal = c1.number_input("Daily carbohydrate goal (g)", 10.0, 1000.0, float(profile.get("carbs_goal", 275.0)))
        fat_goal = c2.number_input("Daily fat goal (g)", 10.0, 500.0, float(profile.get("fat_goal", 70.0)))
        submitted = st.form_submit_button("Save profile")
    if submitted:
        with connect() as conn:
            conn.execute("""INSERT OR REPLACE INTO profiles
                (id,name,age,gender,height,weight,calorie_goal,protein_goal,carbs_goal,fat_goal)
                VALUES (1,?,?,?,?,?,?,?,?,?)""",
                (name, age, gender, height, weight, calorie_goal, protein_goal, carbs_goal, fat_goal))
        st.success("Profile saved.")


def select_food(key_prefix):
    search = st.text_input("Search food", placeholder="Example: almonds", key=f"{key_prefix}_search")
    matches = foods[foods["food_name"].str.contains(search, case=False, na=False)] if search else foods.head(100)
    if matches.empty:
        st.warning("No matching USDA Foundation Food found. Try a simpler term, like a single ingredient.")
        return None
    name = st.selectbox("Select food", matches["food_name"].tolist(), key=f"{key_prefix}_food")
    return matches.loc[matches["food_name"].eq(name)].iloc[0]


def macro_chart(values):
    chart = pd.DataFrame({"Nutrient": ["Protein", "Carbs", "Fat"],
                          "Grams": [values["protein"], values["carbs"], values["fat"]]})
    fig = px.bar(chart, x="Grams", y="Nutrient", orientation="h", color="Nutrient",
                 color_discrete_map={"Protein": "#0f6e5c", "Carbs": "#e8833a", "Fat": "#e0567a"},
                 title="Macronutrient breakdown")
    fig.update_layout(showlegend=False)
    st.plotly_chart(style_fig(fig, 300), width="stretch")


def page_food_search():
    hero("Food Search", "Real USDA Foundation Foods, measured per 100 g and scaled to your serving.")
    row = select_food("search")
    if row is None:
        return
    grams = st.number_input("Amount (grams)", 1.0, 5000.0, 100.0, 1.0)
    values = scaled_nutrition(row, grams)
    st.markdown(f"<div class='nt-eyebrow'>Nutrition · {grams:g} g</div>", unsafe_allow_html=True)
    st.subheader(row["food_name"])
    nutrient_tiles(values)
    macro_chart(values)


def page_meal_logger():
    hero("Meal Logger", "Record what you eat. Entries roll up into your daily totals.")
    c1, c2 = st.columns(2)
    selected_date = c1.date_input("Date", date.today())
    meal_type = c2.selectbox("Meal", ["Breakfast", "Lunch", "Dinner", "Snack"])
    row = select_food("logger")
    grams = st.number_input("Amount (grams)", 1.0, 5000.0, 100.0, 1.0, key="logger_grams")
    if row is not None:
        values = scaled_nutrition(row, grams)
        nutrient_tiles(values)
        if st.button("Add to meal log"):
            with connect() as conn:
                conn.execute("""INSERT INTO meal_log
                    (log_date,meal_type,fdc_id,food_name,grams,calories,protein,carbs,fat,fiber,sugar,sodium)
                    VALUES (?,?,?,?,?,?,?,?,?,?,?,?)""",
                    (str(selected_date), meal_type, int(row["fdc_id"]), row["food_name"], grams, *[values[n] for n in NUTRIENTS]))
            st.success("Meal added.")
    meals = load_meals(selected_date)
    st.markdown("<div class='nt-eyebrow'>Logged meals</div>", unsafe_allow_html=True)
    if meals.empty:
        st.info("Nothing logged for this date yet. Add a food above to get started.")
    else:
        st.dataframe(meals[["meal_type", "food_name", "grams", "calories", "protein"]],
                     width="stretch", hide_index=True)


def page_dashboard():
    hero("Nutrition Dashboard", "Patterns across the USDA food catalog and the NHANES population.")
    st.markdown("<div class='nt-eyebrow'>Food catalog</div>", unsafe_allow_html=True)
    c1, c2 = st.columns(2)
    c1.plotly_chart(style_fig(px.histogram(foods, x="calories", nbins=40,
                    title="Calorie distribution", color_discrete_sequence=[BRAND])), width="stretch")
    top = foods.nlargest(10, "protein").sort_values("protein")
    fig_top = px.bar(top, x="protein", y="food_name", orientation="h",
                     title="Top 10 high-protein foods", color="protein", color_continuous_scale="Teal")
    fig_top.update_layout(coloraxis_showscale=False)
    c2.plotly_chart(style_fig(fig_top), width="stretch")

    st.markdown("<div class='nt-eyebrow'>Diabetes insights</div>", unsafe_allow_html=True)
    health = nhanes.dropna(subset=["diabetes_indicator"]).copy()
    health["bmi_category"] = pd.cut(health["bmi"], [0, 18.5, 25, 30, float("inf")],
                                    labels=["Underweight", "Normal", "Overweight", "Obese"])
    rate = health.groupby("bmi_category", observed=True)["diabetes_indicator"].mean().mul(100).reset_index()
    c3, c4 = st.columns(2)
    fig_rate = px.bar(rate, x="bmi_category", y="diabetes_indicator",
                      title="Diabetes rate by BMI category (%)", color="diabetes_indicator", color_continuous_scale="Teal")
    fig_rate.update_layout(coloraxis_showscale=False)
    c3.plotly_chart(style_fig(fig_rate), width="stretch")
    fig_glu = px.scatter(health, x="age", y="glucose", color="diabetes_indicator",
                         title="Age vs glucose", opacity=0.5, color_continuous_scale=["#3a9d7a", "#e0567a"])
    c4.plotly_chart(style_fig(fig_glu), width="stretch")


def page_calculator():
    hero("Daily Nutrition Calculator", "Your logged intake against your goals for the day.")
    selected_date = st.date_input("Date", date.today(), key="calculator_date")
    meals = load_meals(selected_date)
    if meals.empty:
        st.info("No meals logged for this date. Add some in the Meal Logger to see your totals.")
        return
    totals = meals[NUTRIENTS].sum(min_count=1).to_dict()
    nutrient_tiles(totals)
    profile = load_profile()
    goals = {"calories": profile.get("calorie_goal"), "protein": profile.get("protein_goal"),
             "carbs": profile.get("carbs_goal"), "fat": profile.get("fat_goal")}
    rows = [{"nutrient": key.title(), "consumed": totals[key], "goal": value}
            for key, value in goals.items() if value]
    c1, c2 = st.columns(2)
    if rows:
        goal_df = pd.DataFrame(rows)
        fig = px.bar(goal_df, x="nutrient", y=["consumed", "goal"], barmode="group",
                     title="Intake vs goals", color_discrete_sequence=["#0f6e5c", "#e8833a"])
        c1.plotly_chart(style_fig(fig), width="stretch")
    fig_meal = px.pie(meals, names="meal_type", values="calories", hole=0.5,
                      title="Calories by meal", color_discrete_sequence=PALETTE)
    c2.plotly_chart(style_fig(fig_meal), width="stretch")
    st.markdown("<div class='nt-eyebrow'>Today's meals</div>", unsafe_allow_html=True)
    st.dataframe(meals[["meal_type", "food_name", "grams"] + NUTRIENTS], width="stretch", hide_index=True)


PAGES = {"Home": page_home, "User Profile": page_profile, "Food Search": page_food_search,
         "Meal Logger": page_meal_logger, "Nutrition Dashboard": page_dashboard,
         "Daily Nutrition Calculator": page_calculator}
st.sidebar.title("🥗 NutriTrack")
PAGES[st.sidebar.radio("Menu", list(PAGES))]()