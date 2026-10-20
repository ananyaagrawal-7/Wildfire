"""
WildFire AI - Backend API Integration and Unit Tests
"""

import unittest
import json
from backend.app import create_app

class WildFireAPITestCase(unittest.TestCase):
    def setUp(self):
        self.app = create_app()
        self.app.config["TESTING"] = True
        self.client = self.app.test_client()

    def test_health_check(self):
        resp = self.client.get("/api/health")
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertEqual(data["status"], "healthy")
        self.assertIn("ml_model_loaded", data)

    def test_weather_endpoint(self):
        resp = self.client.get("/api/weather?lat=37.7749&lon=-122.4194")
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertIn("current", data)
        self.assertIn("temperature", data["current"])
        self.assertIn("relative_humidity", data["current"])

    def test_hotspots_endpoint(self):
        resp = self.client.get("/api/hotspots?lat=34.05&lon=-118.25&radius=80")
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertIn("hotspots", data)
        self.assertIn("hotspots_count", data)

    def test_predict_post_custom_weather(self):
        # Extreme fire conditions (High Temp, Low Humidity, High Wind, Zero Rain)
        payload = {
            "temperature": 40.0,
            "relative_humidity": 14.0,
            "wind_speed": 35.0,
            "rain": 0.0
        }
        resp = self.client.post(
            "/api/predict",
            data=json.dumps(payload),
            content_type="application/json"
        )
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertIn("risk_score", data)
        self.assertIn("risk_category", data)
        self.assertIn(data["risk_category"], ["High", "Very High", "Extreme"])
        self.assertTrue(data["risk_score"] >= 60)

    def test_predict_post_low_risk(self):
        # Cool, rainy, calm conditions
        payload = {
            "temperature": 12.0,
            "relative_humidity": 88.0,
            "wind_speed": 6.0,
            "rain": 12.0
        }
        resp = self.client.post(
            "/api/predict",
            data=json.dumps(payload),
            content_type="application/json"
        )
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertIn(data["risk_category"], ["Low", "Moderate"])
        self.assertTrue(data["risk_score"] < 40)

    def test_predict_get_coordinates(self):
        resp = self.client.get("/api/predict?lat=34.05&lon=-118.25")
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertIn("risk_score", data)
        self.assertIn("fwi_indices", data)

    def test_trends_endpoint(self):
        resp = self.client.get("/api/trends?lat=34.05&lon=-118.25")
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertIn("monthly_distribution", data)
        self.assertEqual(len(data["monthly_distribution"]), 12)

    def test_model_info_endpoint(self):
        resp = self.client.get("/api/model-info")
        self.assertEqual(resp.status_code, 200)
        data = resp.get_json()
        self.assertIn("feature_importances", data)
        self.assertIn("metrics", data)


if __name__ == "__main__":
    unittest.main()
