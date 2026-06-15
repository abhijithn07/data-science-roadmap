# NutriTrack

**Nutrition tracking and diabetes-awareness analytics built on real public health data.**

NutriTrack combines real **USDA Foundation Foods** nutrition measurements with the real
**NHANES 2017-2018** national health survey to let users look up food nutrition, log meals,
track daily intake against personal goals, and explore how factors such as glucose, BMI,
age, and physical activity relate to diabetes in a national sample.

This repository contains **Phase 1**: the full data pipeline, a complete exploratory data
analysis (EDA) notebook, and a working Streamlit application. Phases 2 and 3 are planned
(see Roadmap).

> Educational project only. NutriTrack does not diagnose diabetes and is not a substitute
> for medical advice.

---

## What it does

A Jupyter notebook cleans the raw USDA and NHANES files, performs EDA, and writes two clean
tables to a SQLite database. A read-only Streamlit application then reads that database and
serves six pages:

1. **Home** - project summary and headline dataset statistics.
2. **User Profile** - set personal details and daily nutrition goals.
3. **Food Search** - search the USDA catalog and view nutrition scaled to any serving size.
4. **Meal Logger** - record meals and build a daily log.
5. **Nutrition Dashboard** - food-catalog and diabetes-risk visualizations.
6. **Daily Nutrition Calculator** - compare logged intake against your goals.

---

## Data sources

| Source | File(s) | Notes |
|--------|---------|-------|
| USDA FoodData Central, Foundation Foods | `food.csv`, `food_nutrient.csv`, `nutrient.csv` | Laboratory-measured nutrition per 100 g. You download these once (see Setup). |
| NHANES 2017-2018 (CDC) | `DEMO_J`, `BMX_J`, `GLU_J`, `DIQ_J`, `PAQ_J`, `DR1TOT_J` (.XPT) | Demographics, body measures, glucose, diabetes questionnaire, physical activity, and diet. **Auto-downloaded** by the notebook. |

After cleaning, the database holds **328 USDA Foundation Foods** and **9,254 NHANES
respondents**.

---

## Tech stack

Python, Pandas, NumPy, Plotly, Seaborn, missingno, SQLite, Streamlit, and Jupyter.
Phase 2 will add scikit-learn; Phase 3 will add a retrieval-augmented LLM.

---

## Project structure

```
Project/
├── app.py                              # Streamlit application (6 pages)
├── requirements.txt
├── README.md
├── .gitignore
├── .streamlit/
│   └── config.toml                     # Application theme
├── notebooks/
│   └── NutriTrack_Phase1_Analysis.ipynb  # Cleaning + EDA + diabetes insights
├── data/
│   ├── raw/
│   │   ├── usda/                        # USDA Foundation Foods CSVs (you provide)
│   │   └── nhanes/                      # NHANES .XPT files (auto-downloaded)
│   └── processed/                       # foods.csv, nhanes.csv (generated)
└── database/
    └── nutritrack.db                    # SQLite database (generated)
```

Generated files (`database/*.db`, `data/processed/*.csv`) and the auto-downloaded NHANES
`.XPT` files are intentionally excluded from git; they are rebuilt by running the notebook.

---

## Setup

The commands below are for Windows. On macOS or Linux, activate the environment with
`source .venv/bin/activate` instead.

1. **Create and activate a virtual environment**

   ```
   python -m venv .venv
   .venv\Scripts\activate
   ```

2. **Install dependencies**

   ```
   python -m pip install -r requirements.txt
   ```

3. **Download the USDA Foundation Foods data** (one time)

   Download the **Foundation Foods** CSV package from USDA FoodData Central
   (https://fdc.nal.usda.gov/download-datasets.html), unzip it, and place the CSV files
   (including `food.csv`, `food_nutrient.csv`, and `nutrient.csv`) under
   `data/raw/usda/`. The notebook searches that folder recursively, so any subfolder layout
   works. The NHANES files download automatically, so you do not need to fetch them
   manually.

---

## How to run

**Step 1: Build the database** (run this before the app)

Open the notebook and run all cells:

```
python -m jupyter notebook
```

Then open `notebooks/NutriTrack_Phase1_Analysis.ipynb` and run every cell. The final cell
writes `database/nutritrack.db` and prints `foods: 328 | nhanes: 9254`. A verification cell
confirms the tables were stored.

**Step 2: Launch the application**

```
python -m streamlit run app.py
```

The app opens at `http://localhost:8501`. If you ever see "Database not found," it means
Step 1 has not been run in this environment yet.

> Tip: On Windows, prefer `python -m streamlit ...` and `python -m jupyter ...`. Running the
> bare `streamlit` or `jupyter` command can fail if the Scripts folder is not on your PATH.

---

## Analysis highlights

The EDA notebook covers the full workflow: structure and summary statistics, central
tendency and dispersion, a missing-value diagnosis with before/after imputation, skewness,
a missingno completeness check, class balance, a scatter matrix, a seaborn pair plot, and a
z-score / empirical-rule check. Each output is followed by a written interpretation.

Key descriptive findings (associations, not causation):

- Diabetes is most associated with **glucose** (r = 0.56), then **age** (0.36) and **BMI** (0.23).
- Prevalence rises steeply with age (0.6% under 30 to 28.5% at 60+) and BMI (0.3% underweight to 18.9% obese).
- The diabetes target is **imbalanced** (about 10% positive), which guides the Phase 2 evaluation strategy.
- Glucose is strongly right-skewed and missing for about 69% of respondents, because it is measured only on the fasting subsample.

---

## Data notes and limitations

- Associations are unadjusted and **not causal**.
- The sample includes all ages, so children are present in the "No diabetes" group.
- Diet and diagnosis are self-reported.
- NHANES survey weights and strata are **not applied**, so figures are sample-level
  estimates rather than nationally representative ones.

---

## Roadmap

- **Phase 1 (complete):** data pipeline, EDA, and Streamlit application.
- **Phase 2 (planned):** diabetes-prediction model on the cleaned NHANES table, using a
  train/test split, cross-validation, and imbalance-aware metrics (precision, recall, ROC-AUC).
- **Phase 3 (planned):** a retrieval-augmented generative-AI nutrition assistant.

---

## Author

Abhijith Nallana. Academic capstone project, USF Muma College of Business.
