# WildFire AI — Android Wildfire Risk Prediction and Detection
> **B.Tech Data Science (2nd Year Capstone Project)**  
> An end-to-end intelligent environmental monitoring and wildfire risk assessment system combining **Flutter/Dart**, **Python/Flask**, **Scikit-Learn Random Forest ML**, **NASA FIRMS Satellite Sensing**, and **Open-Meteo Meteorology**.

---

## 📌 Project Overview
WildFire AI empowers communities, emergency services, and forestry teams with proactive early-warning analytics before combustion spreads out of control. It bridges physics-based fire weather models with supervised machine learning and near real-time orbital observations.

### Core Capabilities:
1. **Machine Learning Risk Prediction**: Computes a calibrated wildfire risk score ($0-100\%$) and category (*Low, Moderate, High, Very High, Extreme*) using a trained **Scikit-Learn Random Forest Classifier** evaluated against the **Canadian Forest Fire Weather Index (FWI)** benchmark.
2. **Satellite Active Fire Hotspots**: Integrates **NASA FIRMS (Fire Information for Resource Management System)** to map active thermal anomalies observed by **VIIRS** (Suomi NPP & NOAA-20) and **MODIS** (Terra & Aqua) satellites with Fire Radiative Power (MW) and Kelvin brightness temperatures.
3. **Live Meteorological Telemetry**: Fetches hourly and 7-day environmental observations from **Open-Meteo API** (ambient temperature, relative humidity, sustained wind speed, wind gusts, and precipitation).
4. **Historical Fire Analytics**: Provides 12-month seasonality trends, multi-year historical fire incidence statistics, and Pearson correlation matrices for academic research defense.
5. **Actionable Emergency Protocols**: Dynamic defensible perimeter guidelines, burn bans, interactive evacuation Go-Bag checklist, and 1-tap emergency hotline dials ($112$, $101$, $1078$, $1926$).

---

## 🏗️ System Architecture

```
                    ┌─────────────────────────┐
                    │      Open-Meteo API     │ (Free, Real-Time Meteorology)
                    └────────────┬────────────┘
                                 │
┌─────────────────────────┐      │      ┌─────────────────────────┐
│     NASA FIRMS API      ├──────┼─────►│    Python Flask REST    │
│   (MODIS & VIIRS NRT)   │      │      │    Backend (Port 5000)  │
└─────────────────────────┘      │      └────────────┬────────────┘
                                 ▼                   │
                    ┌─────────────────────────┐      │
                    │   Canadian FWI System   │      │  JSON REST API
                    │ (FFMC, DMC, DC, ISI,    │      │  (CORS Enabled)
                    │  BUI & Weather Vectors) │      │
                    └────────────┬────────────┘      │
                                 │                   ▼
                    ┌────────────▼────────────┐  ┌─────────────────────────┐
                    │  Scikit-Learn Random    │  │   Flutter Android App   │
                    │  Forest Classifier      │◄─┤   (com.wildfire.ai)     │
                    │  (150 trees, ROC 0.80)  │  │  Dark Forest UI & OSM   │
                    └─────────────────────────┘  └─────────────────────────┘
```

---

## 🧠 Machine Learning Pipeline Specifications

The wildfire risk classifier predicts the probability of ignition and fire escalation based on empirical fire weather equations and meteorological features:

### Input Feature Vector ($9$ Parameters):
1. `temperature`: Ambient 2m temperature (°C)
2. `relative_humidity`: Relative atmospheric humidity (%)
3. `wind_speed`: Sustained 10m wind velocity (km/h)
4. `rain`: 24-hour accumulated precipitation (mm)
5. `ffmc`: **Fine Fuel Moisture Code** ($0-101$) — Moisture content of surface litter and cured fine fuels.
6. `dmc`: **Duff Moisture Code** ($1-150+$) — Moisture content of moderate-depth organic duff layers.
7. `dc`: **Drought Code** ($15-800+$) — Deep soil organic moisture deficit rating seasonal drought.
8. `isi`: **Initial Spread Index** ($0-50+$) — Forward propagation velocity combining wind velocity and FFMC.
9. `bui`: **Buildup Index** ($1-180+$) — Total combustible biomass fuel volume available.

### Training Strategy & Data Leakage Prevention:
- **Reproducible Pipeline**: `backend/training/train.py`
- **Data Splitting**: **Stratified 80/20 Train-Test Split** ($2,000$ training samples, $500$ held-out test samples).
- **Leakage Prevention**: `StandardScaler` is fitted exclusively on the training partition and transformed onto the test partition.
- **Cross-Validation**: 5-Fold Stratified Cross-Validation on the training split.
- **Model Parameters**: `RandomForestClassifier(n_estimators=150, max_depth=12, class_weight='balanced', random_state=42)`

### Model Evaluation Results:
| Metric | Value | Interpretation |
|---|---|---|
| **Test Accuracy** | **71.20%** | Robust classification across imbalanced fire occurrence classes |
| **Test Precision** | **46.67%** | Conservative early-warning threshold minimizing missed fire events |
| **Test Recall (Sensitivity)** | **63.64%** | Successfully catches ~2/3 of hazardous wildfire conditions |
| **Test F1-Score** | **53.85%** | Harmonic balance between precision and sensitivity |
| **Test ROC-AUC** | **0.7863** | Strong discriminative ability between safe and fire-prone weather |
| **5-Fold CV ROC-AUC** | **0.7994 (±0.0201)** | Highly stable cross-fold generalizability without overfitting |

### Gini Feature Importances:
1. **Fine Fuel Moisture Code (FFMC)**: **28.09%** (Primary fuel ignition driver)
2. **Relative Humidity**: **14.00%** (Atmospheric drying rate)
3. **Buildup Index (BUI)**: **12.30%** (Available fuel biomass)
4. **Duff Moisture Code (DMC)**: **9.31%** (Duff layer dryness)
5. **Ambient Temperature**: **9.27%** (Fuel preheating energy)
6. **Drought Code (DC)**: **8.95%** (Long-term soil drought)
7. **Wind Speed**: **8.23%** (Oxygenation and ember spotting)
8. **24h Rainfall**: **5.50%** (Fuel re-saturation)
9. **Initial Spread Index (ISI)**: **4.35%** (Rate of spread)

---

## 📱 Mobile Application Design

The mobile interface is built with **Flutter 3.47** adhering to modern environmental telemetry aesthetics:
- **Color Palette**: Dark Forest-Green (`#0C1410`, `#13221A`), Charcoal Surface (`#1B2F24`), Pine Accent Border (`#284334`), Radiant Amber-Orange (`#FF7A00`), and Risk Severity Indicators.
- **Screens**:
  1. **Splash Screen**: Animated pulsing flame emblem, project branding, automated health verification.
  2. **Onboarding Screen**: 3-step feature tour detailing Satellite Sensors, ML Engine, and Early Warnings.
  3. **Home Dashboard Screen**: Monitored region selector, live weather overview cards, animated circular **Wildfire Risk Gauge** ($0-100$), primary risk driver pills, and nearby active satellite hotspots count.
  4. **Interactive Map Screen**: OpenStreetMap (`flutter_map`) with dual layers:
     - **Predicted Risk Zone**: Semi-transparent radial danger overlay scaled by ML risk probability.
     - **Observed Satellite Hotspots**: NASA FIRMS active fire markers with interactive bottom sheets showing Fire Radiative Power (MW), Brightness (Kelvin), detection confidence, and satellite sensor details.
     - **Tap-To-Inspect**: Tap anywhere on earth to predict risk for that coordinate.
  5. **Risk Analysis Screen**: Meteorological variables breakdown, Canadian FWI components (FFMC, DMC, DC, ISI, BUI), 12-hour hourly forecast line chart (`fl_chart`), 12-month seasonality bar chart, and Gini feature importance bars.
  6. **Alerts & Safety Screen**: Dynamic danger directives, emergency hotlines ($112$, $101$, $1078$, $1926$), interactive 8-item evacuation Go-Bag checklist, and one-tap bulletin sharing.
  7. **About & Academic Screen**: Complete technical specs, ML metrics table, data source attributions, and dynamic backend IP reconfiguration modal.

---

## 🚀 Execution & Setup Instructions

### 1. Prerequisites
- **Python**: 3.10+ (tested on Python 3.14)
- **Flutter**: 3.24+ (tested on Flutter 3.47.7, Dart 3.13.5)
- **Java OpenJDK**: 17 or 21 (tested with Temurin-21)
- **Android SDK**: Build tools & Platform SDK installed

---

### 2. Backend Setup & Training

```powershell
# Navigate to project root
cd "c:\Users\anany\Desktop\wildfire ai"

# Install Python requirements
python -m pip install -r backend/requirements.txt

# Run ML Training Pipeline (Trains Random Forest and generates model artifacts)
python backend/training/train.py

# Run Backend Automated Unit & Integration Tests
python -m unittest backend/tests/test_api.py

# Start Flask REST API Server (Listening on http://0.0.0.0:5000)
python backend/app.py
```

---

### 3. Launching the Flutter Android App

```powershell
# In a new terminal, navigate to the Flutter project
cd "c:\Users\anany\Desktop\wildfire ai\wildfire_app"

# Verify dependencies and static analysis
flutter pub get
flutter analyze
flutter test

# Launch on Android Emulator or Connected Device:
flutter run

# To specify device explicitly:
flutter run -d emulator-5554
# or for Web preview:
flutter run -d chrome
```

---

### 4. Generating Android APK

```powershell
cd "c:\Users\anany\Desktop\wildfire ai\wildfire_app"

# Generate Debug APK
flutter build apk --debug

# The generated APK is located at:
# wildfire_app/build/app/outputs/flutter-apk/app-debug.apk

# Generate Optimized Release APK
flutter build apk --release
```

---

## 📡 REST API Documentation

Base URL: `http://localhost:5000/api` (or `http://10.0.2.2:5000/api` inside Android Emulator)

| Method | Endpoint | Query / Body Params | Description |
|---|---|---|---|
| `GET` | `/api/health` | None | Returns backend status and ML model loaded flag |
| `GET` | `/api/weather` | `lat`, `lon` | Real-time Open-Meteo weather and hourly forecasts |
| `GET` | `/api/hotspots` | `lat`, `lon`, `radius` | NASA FIRMS satellite fire hotspots near coordinate |
| `GET` | `/api/predict` | `lat`, `lon` | End-to-end weather fetch + Random Forest risk inference |
| `POST` | `/api/predict` | JSON (`temperature`, `relative_humidity`, `wind_speed`, `rain`) | Custom parameters ML risk inference |
| `GET` | `/api/trends` | `lat`, `lon` | 12-month seasonality trends, annual patterns, correlations |
| `GET` | `/api/model-info`| None | Model architecture, hyperparameters, CV metrics, importances |

---

## 🛡️ Safety & Academic Prototype Disclaimer
> **IMPORTANT NOTICE**:  
> **WildFire AI** is an academic research and engineering prototype developed for a second-year **B.Tech Data Science project**.
> - **Predicted Risk vs Observed Hotspots**: Predicted risk is an algorithmic forecast based on atmospheric conditions and fuel moisture indices. Observed hotspots are historical orbital passes from NASA FIRMS satellites that reflect thermal radiation with a latency of $3$ to $6$ hours.
> - **Educational Use Only**: This application does not replace official governmental emergency evacuation orders, civil defense sirens, or local forestry alerts. In an actual wildfire emergency, always follow official directions issued by local emergency authorities.
