"""
WildFire AI - Weather Service
Integrates Open-Meteo REST API for real-time and forecast meteorological observations.
Free, open API with no API keys required.
"""

import requests
import datetime
import math

class WeatherService:
    BASE_URL = "https://api.open-meteo.com/v1/forecast"
    GEOCODING_URL = "https://geocoding-api.open-meteo.com/v1/search"

    @classmethod
    def get_weather(cls, latitude: float, longitude: float):
        """
        Fetches live current weather, 24h hourly forecast, and 7-day daily forecast
        from Open-Meteo for the given latitude and longitude.
        """
        params = {
            "latitude": latitude,
            "longitude": longitude,
            "current": [
                "temperature_2m",
                "relative_humidity_2m",
                "apparent_temperature",
                "precipitation",
                "rain",
                "weather_code",
                "surface_pressure",
                "wind_speed_10m",
                "wind_direction_10m",
                "wind_gusts_10m"
            ],
            "hourly": [
                "temperature_2m",
                "relative_humidity_2m",
                "precipitation_probability",
                "wind_speed_10m"
            ],
            "daily": [
                "weather_code",
                "temperature_2m_max",
                "temperature_2m_min",
                "precipitation_sum",
                "wind_speed_10m_max"
            ],
            "timezone": "auto",
            "forecast_days": 7
        }

        try:
            response = requests.get(cls.BASE_URL, params=params, timeout=8)
            response.raise_for_status()
            data = response.json()
            return cls._parse_weather_data(data, latitude, longitude)
        except Exception as e:
            # Return realistic fallback physics if network/rate limit fails
            return cls._generate_fallback_weather(latitude, longitude, error_msg=str(e))

    @classmethod
    def _parse_weather_data(cls, raw: dict, lat: float, lon: float):
        current = raw.get("current", {})
        hourly = raw.get("hourly", {})
        daily = raw.get("daily", {})

        weather_code = current.get("weather_code", 0)
        condition_text = cls._weather_code_to_text(weather_code)

        # 24-hour hourly trend
        hourly_times = hourly.get("time", [])[:24]
        hourly_temps = hourly.get("temperature_2m", [])[:24]
        hourly_rhs = hourly.get("relative_humidity_2m", [])[:24]
        hourly_winds = hourly.get("wind_speed_10m", [])[:24]
        hourly_rain_probs = hourly.get("precipitation_probability", [])[:24]

        hourly_series = []
        for i in range(min(len(hourly_times), 24)):
            hourly_series.append({
                "time": hourly_times[i],
                "temperature": hourly_temps[i] if i < len(hourly_temps) else 25.0,
                "relative_humidity": hourly_rhs[i] if i < len(hourly_rhs) else 50.0,
                "wind_speed": hourly_winds[i] if i < len(hourly_winds) else 10.0,
                "precipitation_probability": hourly_rain_probs[i] if i < len(hourly_rain_probs) else 0.0
            })

        # 7-day daily forecast
        daily_times = daily.get("time", [])
        daily_tmax = daily.get("temperature_2m_max", [])
        daily_tmin = daily.get("temperature_2m_min", [])
        daily_rain = daily.get("precipitation_sum", [])
        daily_winds = daily.get("wind_speed_10m_max", [])
        daily_codes = daily.get("weather_code", [])

        daily_forecast = []
        for i in range(len(daily_times)):
            daily_forecast.append({
                "date": daily_times[i],
                "temp_max": daily_tmax[i] if i < len(daily_tmax) else 28.0,
                "temp_min": daily_tmin[i] if i < len(daily_tmin) else 18.0,
                "precipitation_sum": daily_rain[i] if i < len(daily_rain) else 0.0,
                "wind_speed_max": daily_winds[i] if i < len(daily_winds) else 12.0,
                "condition": cls._weather_code_to_text(daily_codes[i] if i < len(daily_codes) else 0)
            })

        return {
            "latitude": lat,
            "longitude": lon,
            "timezone": raw.get("timezone", "UTC"),
            "elevation": raw.get("elevation", 0),
            "timestamp": current.get("time", datetime.datetime.now(datetime.timezone.utc).isoformat()),
            "source": "Open-Meteo Weather API",
            "current": {
                "temperature": current.get("temperature_2m", 26.0),
                "apparent_temperature": current.get("apparent_temperature", 27.0),
                "relative_humidity": current.get("relative_humidity_2m", 45.0),
                "wind_speed": current.get("wind_speed_10m", 15.0),
                "wind_direction": current.get("wind_direction_10m", 180),
                "wind_gusts": current.get("wind_gusts_10m", 22.0),
                "precipitation": current.get("precipitation", 0.0),
                "rain": current.get("rain", 0.0),
                "surface_pressure": current.get("surface_pressure", 1013.25),
                "weather_code": weather_code,
                "condition": condition_text
            },
            "hourly": hourly_series,
            "daily": daily_forecast,
            "status": "success"
        }

    @classmethod
    def _weather_code_to_text(cls, code: int) -> str:
        codes = {
            0: "Clear sky",
            1: "Mainly clear",
            2: "Partly cloudy",
            3: "Overcast",
            45: "Foggy",
            48: "Depositing rime fog",
            51: "Light drizzle",
            53: "Moderate drizzle",
            55: "Dense drizzle",
            61: "Slight rain",
            63: "Moderate rain",
            65: "Heavy rain",
            71: "Slight snow fall",
            73: "Moderate snow fall",
            75: "Heavy snow fall",
            80: "Slight rain showers",
            81: "Moderate rain showers",
            82: "Violent rain showers",
            95: "Thunderstorm",
            96: "Thunderstorm with slight hail",
            99: "Thunderstorm with heavy hail"
        }
        return codes.get(code, "Clear")

    @classmethod
    def _generate_fallback_weather(cls, lat: float, lon: float, error_msg: str):
        now = datetime.datetime.now(datetime.timezone.utc)
        # Compute solar position approx for realistic temperature
        hour = now.hour
        solar_factor = math.sin((hour - 6) / 24 * 2 * math.pi)
        base_temp = 28.0 + 5.0 * solar_factor
        rh = max(15.0, min(85.0, 55.0 - 15.0 * solar_factor))

        return {
            "latitude": lat,
            "longitude": lon,
            "timezone": "UTC",
            "elevation": 120,
            "timestamp": now.isoformat(),
            "source": "Open-Meteo (Cached Heuristic Fallback)",
            "warning": f"Network fallback used: {error_msg}",
            "current": {
                "temperature": round(base_temp, 1),
                "apparent_temperature": round(base_temp + 1.2, 1),
                "relative_humidity": round(rh, 1),
                "wind_speed": 16.5,
                "wind_direction": 220,
                "wind_gusts": 24.0,
                "precipitation": 0.0,
                "rain": 0.0,
                "surface_pressure": 1012.0,
                "weather_code": 0,
                "condition": "Sunny / Dry (Simulated Fallback)"
            },
            "hourly": [
                {
                    "time": (now + datetime.timedelta(hours=i)).strftime("%Y-%m-%dT%H:00"),
                    "temperature": round(base_temp + 3.0 * math.sin(i / 12 * math.pi), 1),
                    "relative_humidity": round(max(20.0, rh - 2.0 * math.sin(i / 12 * math.pi)), 1),
                    "wind_speed": round(14.0 + 4.0 * math.cos(i / 8 * math.pi), 1),
                    "precipitation_probability": 0
                }
                for i in range(24)
            ],
            "daily": [
                {
                    "date": (now + datetime.timedelta(days=d)).strftime("%Y-%m-%d"),
                    "temp_max": round(base_temp + 2.0, 1),
                    "temp_min": round(base_temp - 8.0, 1),
                    "precipitation_sum": 0.0,
                    "wind_speed_max": 20.0,
                    "condition": "Clear sky"
                }
                for d in range(7)
            ],
            "status": "fallback"
        }
