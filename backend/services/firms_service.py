"""
WildFire AI - NASA FIRMS Satellite Fire Service
Integrates NASA Fire Information for Resource Management System (FIRMS)
active fire observations from VIIRS and MODIS satellites.
"""

import requests
import datetime
import math
import csv
import io
import random
from typing import List, Dict, Any

class FirmsService:
    BASE_URL = "https://firms.modaps.eosdis.nasa.gov/api/area/csv"

    @classmethod
    def get_hotspots(cls, lat: float, lon: float, radius_km: float = 100.0, map_key: str = "") -> Dict[str, Any]:
        """
        Retrieves active fire hotspots near the given coordinates.
        Uses live NASA FIRMS API if map_key is provided, otherwise falls back to
        realistic high-fidelity satellite fire observations with transparent attribution.
        """
        # If API key provided, attempt live NASA FIRMS query
        if map_key and len(map_key.strip()) > 8:
            try:
                live_data = cls._fetch_live_firms(lat, lon, radius_km, map_key.strip())
                if live_data:
                    return live_data
            except Exception as e:
                print(f"[FIRMS] Live API query failed: {e}. Falling back to demonstration feed.")

        # Heuristic / high-fidelity educational demonstration satellite feed
        return cls._generate_realistic_hotspots(lat, lon, radius_km)

    @classmethod
    def _fetch_live_firms(cls, lat: float, lon: float, radius_km: float, map_key: str) -> Dict[str, Any]:
        # Calculate bounding box
        deg_lat = radius_km / 111.0
        deg_lon = radius_km / (111.0 * math.cos(math.radians(lat)) + 1e-6)
        
        min_lon = max(-180.0, lon - deg_lon)
        min_lat = max(-90.0, lat - deg_lat)
        max_lon = min(180.0, lon + deg_lon)
        max_lat = min(90.0, lat + deg_lat)

        bbox_str = f"{min_lon:.3f},{min_lat:.3f},{max_lon:.3f},{max_lat:.3f}"
        # Source: VIIRS_SNPP_NRT, 1 day window
        url = f"{cls.BASE_URL}/{map_key}/VIIRS_SNPP_NRT/{bbox_str}/1"

        resp = requests.get(url, timeout=10)
        resp.raise_for_status()

        reader = csv.DictReader(io.StringIO(resp.text))
        hotspots = []
        for row in reader:
            try:
                h_lat = float(row.get("latitude", 0))
                h_lon = float(row.get("longitude", 0))
                dist = cls._haversine_distance(lat, lon, h_lat, h_lon)
                if dist <= radius_km:
                    hotspots.append({
                        "id": f"firms_{row.get('latitude')}_{row.get('longitude')}_{row.get('acq_time')}",
                        "latitude": h_lat,
                        "longitude": h_lon,
                        "distance_km": round(dist, 1),
                        "brightness_kelvin": float(row.get("bright_ti4", row.get("brightness", 330.0))),
                        "frp_mw": float(row.get("frp", 12.5)),
                        "confidence": row.get("confidence", "nominal"),
                        "satellite": row.get("satellite", "Suomi NPP"),
                        "instrument": row.get("instrument", "VIIRS"),
                        "acquisition_date": row.get("acq_date", datetime.date.today().isoformat()),
                        "acquisition_time": row.get("acq_time", "1200"),
                        "daynight": row.get("daynight", "D"),
                        "status": "active"
                    })
            except Exception:
                continue

        hotspots.sort(key=lambda x: x["distance_km"])

        return {
            "source": "NASA FIRMS (Live Satellite VIIRS/MODIS)",
            "attribution": "NASA Earth Science Data and Information System (ESDIS) / LANCE FIRMS",
            "is_live_api": True,
            "center": {"latitude": lat, "longitude": lon},
            "radius_km": radius_km,
            "hotspots_count": len(hotspots),
            "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "satellite_delay_note": "NASA FIRMS detections reflect satellite overpasses (MODIS/VIIRS) with ~3-6 hour latency.",
            "hotspots": hotspots
        }

    @classmethod
    def _generate_realistic_hotspots(cls, lat: float, lon: float, radius_km: float) -> Dict[str, Any]:
        """
        Produces realistic active fire hotspots in the geographic region for educational demonstrations
        and testing when no live NASA API key is supplied.
        """
        # Seed pseudo-random generator deterministically based on coordinates & current day
        # so consecutive reloads in the same region return stable, consistent hotspots
        today_str = datetime.date.today().isoformat()
        seed_val = int(abs(lat * 100) + abs(lon * 100)) + int(datetime.date.today().strftime("%Y%m%d"))
        rng = random.Random(seed_val)

        # Decide hotspot count based on geography and pseudo-stochastic probability
        # Higher density in fire-prone belts (latitudes 20 to 50 N/S)
        abs_lat = abs(lat)
        is_fire_prone = (20.0 <= abs_lat <= 55.0) or (-35.0 <= lat <= -10.0)
        base_count = rng.randint(2, 6) if is_fire_prone else rng.randint(0, 3)

        now = datetime.datetime.now(datetime.timezone.utc)
        hotspots = []

        for i in range(base_count):
            # Distance from center: between 4km and radius_km
            dist = rng.uniform(4.5, radius_km * 0.85)
            angle = rng.uniform(0, 2 * math.pi)

            # Convert dist/angle to lat/lon delta
            d_lat = (dist * math.cos(angle)) / 111.0
            d_lon = (dist * math.sin(angle)) / (111.0 * math.cos(math.radians(lat)) + 1e-6)

            h_lat = round(lat + d_lat, 4)
            h_lon = round(lon + d_lon, 4)

            # Fire Radiative Power (MW) and Brightness (Kelvin)
            frp = round(rng.uniform(8.5, 95.0), 1)
            bright_k = round(rng.uniform(325.0, 378.0), 1)
            conf_percent = rng.randint(70, 98)
            conf_label = "high" if conf_percent > 85 else "nominal"

            sat = rng.choice(["Suomi NPP (VIIRS)", "NOAA-20 (VIIRS)", "Aqua (MODIS)", "Terra (MODIS)"])
            instrument = "VIIRS" if "VIIRS" in sat else "MODIS"
            hours_ago = rng.randint(1, 8)
            acq_dt = now - datetime.timedelta(hours=hours_ago, minutes=rng.randint(0, 59))

            hotspots.append({
                "id": f"hotspot_{i+1}_{int(abs(h_lat*100))}_{int(abs(h_lon*100))}",
                "latitude": h_lat,
                "longitude": h_lon,
                "distance_km": round(dist, 1),
                "brightness_kelvin": bright_k,
                "frp_mw": frp,
                "confidence": conf_label,
                "confidence_percent": conf_percent,
                "satellite": sat,
                "instrument": instrument,
                "acquisition_date": acq_dt.strftime("%Y-%m-%d"),
                "acquisition_time": acq_dt.strftime("%H:%M UTC"),
                "daynight": "D" if 6 <= acq_dt.hour <= 18 else "N",
                "status": "active"
            })

        hotspots.sort(key=lambda x: x["distance_km"])

        return {
            "source": "NASA FIRMS (Satellite Active Fire Feed - Educational Demo)",
            "attribution": "NASA ESDIS / LANCE FIRMS Format Specifications",
            "is_live_api": False,
            "center": {"latitude": lat, "longitude": lon},
            "radius_km": radius_km,
            "hotspots_count": len(hotspots),
            "timestamp": now.isoformat(),
            "satellite_delay_note": "Satellite detections reflect MODIS/VIIRS overpasses with ~3-6 hour latency. Educational demonstration mode active.",
            "hotspots": hotspots
        }

    @staticmethod
    def _haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculates great-circle distance in kilometers."""
        r = 6371.0  # Earth radius in km
        phi1, phi2 = math.radians(lat1), math.radians(lat2)
        d_phi = math.radians(lat2 - lat1)
        d_lambda = math.radians(lon2 - lon1)

        a = math.sin(d_phi / 2.0) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(d_lambda / 2.0) ** 2
        c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
        return r * c
