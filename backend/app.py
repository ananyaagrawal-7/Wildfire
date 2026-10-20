"""
WildFire AI - Flask REST API Backend
B.Tech Data Science Academic Project

Endpoints:
  GET  /api/health      - System health status and model readiness
  GET  /api/weather     - Live weather observations via Open-Meteo
  GET  /api/hotspots    - Active satellite fire hotspots via NASA FIRMS
  POST /api/predict     - Random Forest wildfire risk inference
  GET  /api/predict     - Automated end-to-end weather fetch + ML prediction
  GET  /api/trends      - Historical fire season trends & analytics
  GET  /api/model-info  - ML model architecture, metrics, and feature importances
"""

import os
import json
from flask import Flask, request, jsonify
from flask_cors import CORS

from backend.config import Config
from backend.services.weather_service import WeatherService
from backend.services.firms_service import FirmsService
from backend.services.ml_service import MLService
from backend.services.historical_service import HistoricalService


def create_app():
    app = Flask(__name__)
    CORS(app, resources={r"/api/*": {"origins": "*"}})

    # Initialize ML Service
    ml_service = MLService(
        model_path=Config.MODEL_PATH,
        scaler_path=Config.SCALER_PATH,
        metadata_path=Config.METADATA_PATH
    )

    # ----------------------------------------------------
    # 1. Health Check
    # ----------------------------------------------------
    @app.route("/api/health", methods=["GET"])
    def health_check():
        return jsonify({
            "status": "healthy",
            "service": "WildFire AI Backend API",
            "version": "1.0.0",
            "project": "B.Tech Data Science Wildfire Risk Prediction & Detection",
            "ml_model_loaded": ml_service.is_ready,
            "firms_key_configured": bool(Config.FIRMS_MAP_KEY)
        }), 200

    # ----------------------------------------------------
    # 2. Weather Endpoint (Open-Meteo)
    # ----------------------------------------------------
    @app.route("/api/weather", methods=["GET"])
    def get_weather():
        try:
            lat = float(request.args.get("lat", 29.3803))  # Default: Nainital, Uttarakhand, India
            lon = float(request.args.get("lon", 79.4636))
        except (ValueError, TypeError):
            return jsonify({
                "status": "error",
                "message": "Invalid latitude or longitude query parameters."
            }), 400

        weather_data = WeatherService.get_weather(lat, lon)
        return jsonify(weather_data), 200

    # ----------------------------------------------------
    # 3. Fire Observations / Hotspots (NASA FIRMS)
    # ----------------------------------------------------
    @app.route("/api/hotspots", methods=["GET"])
    def get_hotspots():
        try:
            lat = float(request.args.get("lat", 29.3803))  # Default: Nainital, Uttarakhand, India
            lon = float(request.args.get("lon", 79.4636))
            radius = float(request.args.get("radius", 100.0))
            radius = max(10.0, min(500.0, radius))
        except (ValueError, TypeError):
            return jsonify({
                "status": "error",
                "message": "Invalid lat, lon, or radius query parameters."
            }), 400

        hotspot_data = FirmsService.get_hotspots(
            lat=lat,
            lon=lon,
            radius_km=radius,
            map_key=Config.FIRMS_MAP_KEY
        )
        return jsonify(hotspot_data), 200

    # ----------------------------------------------------
    # 4. ML Risk Prediction (POST)
    # ----------------------------------------------------
    @app.route("/api/predict", methods=["POST"])
    def predict_risk_post():
        data = request.get_json(silent=True) or {}

        # Can accept custom weather parameters directly, or lat/lon to auto-fetch
        if "temperature" in data and "relative_humidity" in data:
            try:
                temp = float(data["temperature"])
                rh = float(data["relative_humidity"])
                wind = float(data.get("wind_speed", 15.0))
                rain = float(data.get("rain", 0.0))
                ffmc = float(data["ffmc"]) if "ffmc" in data and data["ffmc"] is not None else None
                dmc = float(data["dmc"]) if "dmc" in data and data["dmc"] is not None else None
                dc = float(data["dc"]) if "dc" in data and data["dc"] is not None else None
                isi = float(data["isi"]) if "isi" in data and data["isi"] is not None else None
                bui = float(data["bui"]) if "bui" in data and data["bui"] is not None else None

                prediction = ml_service.predict_risk(
                    temperature=temp,
                    relative_humidity=rh,
                    wind_speed=wind,
                    rain=rain,
                    ffmc=ffmc,
                    dmc=dmc,
                    dc=dc,
                    isi=isi,
                    bui=bui
                )
                return jsonify(prediction), 200
            except (ValueError, TypeError) as e:
                return jsonify({
                    "status": "error",
                    "message": f"Invalid numerical inputs: {e}"
                }), 400

        elif "latitude" in data and "longitude" in data:
            try:
                lat = float(data["latitude"])
                lon = float(data["longitude"])
            except (ValueError, TypeError):
                return jsonify({"status": "error", "message": "Invalid coordinates."}), 400

            weather = WeatherService.get_weather(lat, lon)
            current = weather.get("current", {})
            prediction = ml_service.predict_risk(
                temperature=current.get("temperature", 28.0),
                relative_humidity=current.get("relative_humidity", 40.0),
                wind_speed=current.get("wind_speed", 16.0),
                rain=current.get("rain", 0.0)
            )
            prediction["location"] = {"latitude": lat, "longitude": lon}
            prediction["weather_snapshot"] = current
            return jsonify(prediction), 200

        else:
            return jsonify({
                "status": "error",
                "message": "Request body must contain either ('temperature', 'relative_humidity') or ('latitude', 'longitude')."
            }), 400

    # ----------------------------------------------------
    # 5. ML Risk Prediction (GET - Automated by Coordinates)
    # ----------------------------------------------------
    @app.route("/api/predict", methods=["GET"])
    def predict_risk_get():
        try:
            lat = float(request.args.get("lat", 29.3803))  # Default: Nainital, Uttarakhand, India
            lon = float(request.args.get("lon", 79.4636))
        except (ValueError, TypeError):
            return jsonify({"status": "error", "message": "Invalid lat or lon query parameter."}), 400

        # 1. Fetch live weather
        weather = WeatherService.get_weather(lat, lon)
        current = weather.get("current", {})

        # 2. Predict with ML model
        prediction = ml_service.predict_risk(
            temperature=current.get("temperature", 27.0),
            relative_humidity=current.get("relative_humidity", 45.0),
            wind_speed=current.get("wind_speed", 15.0),
            rain=current.get("rain", 0.0)
        )
        prediction["location"] = {"latitude": lat, "longitude": lon}
        prediction["weather_snapshot"] = current
        return jsonify(prediction), 200

    # ----------------------------------------------------
    # 6. Historical Trends
    # ----------------------------------------------------
    @app.route("/api/trends", methods=["GET"])
    def get_trends():
        try:
            lat = float(request.args.get("lat", 29.3803))
            lon = float(request.args.get("lon", 79.4636))
        except (ValueError, TypeError):
            return jsonify({"status": "error", "message": "Invalid coordinates."}), 400

        trends = HistoricalService.get_regional_trends(lat, lon)
        return jsonify(trends), 200

    # ----------------------------------------------------
    # 7. Model Metadata / Academic Project Info
    # ----------------------------------------------------
    @app.route("/api/model-info", methods=["GET"])
    def get_model_info():
        if ml_service.metadata:
            return jsonify(ml_service.metadata), 200
        elif os.path.exists(Config.METADATA_PATH):
            with open(Config.METADATA_PATH, "r") as f:
                data = json.load(f)
            return jsonify(data), 200
        else:
            return jsonify({
                "status": "warning",
                "message": "Metadata file not found. Please train model using backend/training/train.py",
                "model_status": "demo_fallback"
            }), 404

    return app


if __name__ == "__main__":
    app = create_app()
    print("=" * 60)
    print("WildFire AI Backend REST API Server")
    print(f"Listening on http://{Config.HOST}:{Config.PORT}")
    print("Available endpoints:")
    print("  - GET  /api/health")
    print("  - GET  /api/weather?lat=..&lon=..")
    print("  - GET  /api/hotspots?lat=..&lon=..&radius=..")
    print("  - GET  /api/predict?lat=..&lon=..")
    print("  - POST /api/predict")
    print("  - GET  /api/trends?lat=..&lon=..")
    print("  - GET  /api/model-info")
    print("=" * 60)
    app.run(host=Config.HOST, port=Config.PORT, debug=Config.DEBUG)
