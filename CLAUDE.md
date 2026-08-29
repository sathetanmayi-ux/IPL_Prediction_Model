# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

IPL Prediction Model — a Streamlit ML + Deep Learning app covering IPL 2008–2026 ball-by-ball data (283,678 deliveries, 1,193 matches). The codebase lives at `d:\IPL\ipl_prediction_model\`.

## Running the App

```bash
cd d:\IPL\ipl_prediction_model

# Start Streamlit app
streamlit run app.py

# Train all models (ML + DL, ~30 min with GPU)
py train.py

# Train ML models only (~1.1 min, skips 5 DL models)
py train.py --skip-dl
```

Models must be trained before predictions work in the UI. The training pipeline writes `.joblib` files (ML) and `.h5` files (DL) to `models/`.

## Architecture

### Entry Points
- `app.py` — Streamlit landing page; sets `KERAS_BACKEND=jax` and applies the dark theme
- `train.py` — end-to-end pipeline: load → feature engineering → Elo → ML training → DL training

### Source Layout (`src/`)
| Module | Responsibility |
|--------|---------------|
| `src/data/loader.py` | Load `config.yaml` and raw `IPL.csv`; normalize team names and season strings |
| `src/data/features.py` | Build match-level, ball-level, score-prediction, over-sequence, and player feature frames |
| `src/data/elo.py` | Per-ball Elo ratings for batsmen and bowlers (K=32, start=1500) |
| `src/models/match_winner.py` | Train XGBoost / LightGBM / Random Forest / Ensemble classifiers |
| `src/models/score_predictor.py` | Train XGBoost and RF regressors for final-score prediction |
| `src/deep_learning/{lstm,gru,transformer,cnn,autoencoder}.py` | One DL model per file; all use Keras/TensorFlow |
| `src/matchup/engine.py` | Batsman-vs-bowler composite matchup score (SR + dismissal% + economy + form) |
| `src/utils/helpers.py` | Theme CSS, project-root resolution |

### Pages (`pages/`)
Numbered Streamlit pages loaded automatically from the `pages/` directory:
`01_home`, `02_history`, `03_match_prediction`, `04_score_prediction`, `05_matchup`, `06_players`, `07_deep_learning`, `08_team_optimizer`, `09_algo_lab`

### Data Flow
1. Raw: `data/raw/IPL.csv` (ball-by-ball)
2. Processed: `data/processed/features.parquet` (match-level), `score_features.parquet` (delivery-level), `ball_features.parquet` (80 engineered cols), `elo_ratings.csv`
3. Models: `models/match_winner_{xgboost,lightgbm,random_forest,ensemble}.joblib`, `score_{xgboost,random_forest}.joblib`, DL models as `.h5`

## Configuration

**All paths, hyperparameters, and column names are in `config.yaml`** — never hardcode them in source files. Load via `src.data.loader.load_config()`.

Key config sections: `paths`, `columns`, `phases` (powerplay/middle/death over ranges), `team_aliases`, `elo`, `models`, `deep_learning`, `ui`.

## Key Domain Decisions

- **Team name normalization** is applied during load: `"Delhi Daredevils" → "Delhi Capitals"`, `"Kings XI Punjab" → "Punjab Kings"`, `"Royal Challengers Bangalore" → "Royal Challengers Bengaluru"`, etc.
- **Season normalization**: `"2007/08" → 2008`, `"2009/10" → 2010`
- **Elo scoring**: sixes award +1.5 raw score, fours +0.75; per-ball update with K=32
- **Matchup score** formula: `M(X→Y) = 0.30×SR + 0.30×(1−dismissal%) + 0.20×economy + 0.20×form`
- Only innings 1 and 2 (no super-overs) are used after cleaning
- All sklearn/XGBoost/LightGBM models are trained with named DataFrames to suppress warnings
