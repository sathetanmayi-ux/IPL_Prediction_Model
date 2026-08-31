# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

IPL Prediction Model — a Streamlit Machine Learning app covering IPL 2008–2026 ball-by-ball data (283,678 deliveries, 1,193 matches).

## Running the App

```bash
# Start Streamlit app
streamlit run app.py

# Train all ML models
py train.py
```

Models must be trained before predictions work in the UI. The training pipeline writes `.joblib` files (ML) to `models/`.

## Architecture

### Entry Points
- `app.py` — Streamlit landing page
- `train.py` — end-to-end pipeline: load → feature engineering → Elo → ML training → SHAP analysis

### Source Layout (`src/`)
| Module | Responsibility |
|--------|---------------|
| `src/data/loader.py` | Load `config.yaml` and raw `IPL.csv`; normalize team names and season strings |
| `src/data/features.py` | Build match-level, ball-level, score-prediction, and player feature frames |
| `src/data/elo.py` | Per-ball Elo ratings for batsmen and bowlers (K=32, start=1500) |
| `src/models/match_winner.py` | Train XGBoost / LightGBM / Random Forest / Ensemble classifiers |
| `src/models/score_predictor.py` | Train XGBoost and RF regressors for final-score prediction |
| `src/utils/helpers.py` | Theme CSS, project-root resolution |

### Pages (`pages/`)
Numbered Streamlit pages loaded automatically from the `pages/` directory:
`01_home`, `02_history`, `03_match_prediction`, `04_score_prediction`, `06_player_profiles`, `08_team_optimizer`, `09_algo_lab`

### Data Flow
1. Raw: `data/raw/IPL.csv` (ball-by-ball)
2. Processed: `data/processed/features.parquet` (match-level), `score_features.parquet` (delivery-level), `elo_ratings.csv`
3. Models: `models/match_winner_{xgboost,lightgbm,random_forest,ensemble}.joblib`, `score_{xgboost,random_forest}.joblib`

## Configuration

**All paths, hyperparameters, and column names are in `config.yaml`** — never hardcode them in source files. Load via `src.data.loader.load_config()`.
