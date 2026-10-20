"""
WildFire AI - Backend Configuration
"""

import os
from dotenv import load_dotenv

# Load .env file
load_dotenv()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(BASE_DIR, "models")

class Config:
    HOST = os.getenv("FLASK_HOST", "0.0.0.0")
    PORT = int(os.getenv("FLASK_PORT", 5000))
    DEBUG = os.getenv("FLASK_DEBUG", "True").lower() in ("true", "1", "yes")

    # NASA FIRMS API Key (Optional - get free key from https://firms.modaps.eosdis.nasa.gov/api/map_key)
    FIRMS_MAP_KEY = os.getenv("FIRMS_MAP_KEY", "")

    # Paths to ML artifacts
    MODEL_PATH = os.path.join(MODELS_DIR, "wildfire_model.joblib")
    SCALER_PATH = os.path.join(MODELS_DIR, "scaler.joblib")
    METADATA_PATH = os.path.join(MODELS_DIR, "model_metadata.json")

    # External APIs
    OPEN_METEO_BASE_URL = "https://api.open-meteo.com/v1/forecast"
    NASA_FIRMS_BASE_URL = "https://firms.modaps.eosdis.nasa.gov/api/area/csv"
