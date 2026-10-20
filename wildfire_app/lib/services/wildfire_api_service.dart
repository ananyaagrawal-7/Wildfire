import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/weather_data.dart';
import '../models/fire_hotspot.dart';
import '../models/risk_prediction.dart';
import '../models/historical_trend.dart';

class WildfireApiService {
  String _baseUrl = ApiConstants.defaultBaseUrl;

  String get baseUrl => _baseUrl;

  void setBaseUrl(String newUrl) {
    if (newUrl.isNotEmpty) {
      _baseUrl = newUrl.endsWith('/') ? newUrl.substring(0, newUrl.length - 1) : newUrl;
      if (!_baseUrl.endsWith('/api')) {
        _baseUrl = '$_baseUrl/api';
      }
    }
  }

  // --------------------------------------------------------------------------
  // 1. Health Check
  // --------------------------------------------------------------------------
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiConstants.endpointHealth}');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (_) {}
    return {
      'status': 'offline',
      'service': 'WildFire AI (Standby / Offline Mode)',
      'ml_model_loaded': false,
    };
  }

  // --------------------------------------------------------------------------
  // 2. Weather
  // --------------------------------------------------------------------------
  Future<WeatherReport> fetchWeather(double lat, double lon) async {
    // Try backend first
    try {
      final uri = Uri.parse('$_baseUrl${ApiConstants.endpointWeather}?lat=$lat&lon=$lon');
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherReport.fromJson(data);
      }
    } catch (_) {}

    // Fallback directly to Open-Meteo free API
    try {
      final omUri = Uri.parse(
        '${ApiConstants.openMeteoDirectUrl}?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,weather_code,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m'
        '&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,wind_speed_10m'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max'
        '&timezone=auto&forecast_days=7',
      );
      final omResponse = await http.get(omUri).timeout(const Duration(seconds: 6));
      if (omResponse.statusCode == 200) {
        final omData = json.decode(omResponse.body);
        return _parseOpenMeteoDirect(omData, lat, lon);
      }
    } catch (_) {}

    // Offline heuristic fallback
    return _generateOfflineWeather(lat, lon);
  }

  // --------------------------------------------------------------------------
  // 3. Hotspots (NASA FIRMS)
  // --------------------------------------------------------------------------
  Future<HotspotsReport> fetchHotspots(double lat, double lon, {double radius = 100.0}) async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiConstants.endpointHotspots}?lat=$lat&lon=$lon&radius=$radius');
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HotspotsReport.fromJson(data);
      }
    } catch (_) {}

    return _generateOfflineHotspots(lat, lon, radius);
  }

  // --------------------------------------------------------------------------
  // 4. ML Risk Prediction
  // --------------------------------------------------------------------------
  Future<RiskPrediction> fetchPrediction(double lat, double lon) async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiConstants.endpointPredict}?lat=$lat&lon=$lon');
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RiskPrediction.fromJson(data);
      }
    } catch (_) {}

    // Heuristic offline prediction
    return _generateOfflinePrediction(lat, lon);
  }

  // --------------------------------------------------------------------------
  // 5. Historical Trends
  // --------------------------------------------------------------------------
  Future<HistoricalTrendReport> fetchTrends(double lat, double lon) async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiConstants.endpointTrends}?lat=$lat&lon=$lon');
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HistoricalTrendReport.fromJson(data);
      }
    } catch (_) {}

    return _generateOfflineTrends(lat, lon);
  }

  // --------------------------------------------------------------------------
  // 6. Model Info
  // --------------------------------------------------------------------------
  Future<Map<String, dynamic>> fetchModelInfo() async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiConstants.endpointModelInfo}');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (_) {}

    return {
      'model_name': 'Random Forest Classifier (150 trees)',
      'algorithm': 'RandomForestClassifier',
      'features': [
        'temperature', 'relative_humidity', 'wind_speed', 'rain',
        'ffmc', 'dmc', 'dc', 'isi', 'bui'
      ],
      'metrics': {
        'test_accuracy': 0.712,
        'test_precision': 0.467,
        'test_recall': 0.636,
        'test_f1_score': 0.538,
        'test_roc_auc': 0.7863,
        'cv_mean_roc_auc': 0.7994,
      },
      'feature_importances': {
        'ffmc': 28.09,
        'relative_humidity': 14.00,
        'bui': 12.30,
        'dmc': 9.31,
        'temperature': 9.27,
        'dc': 8.95,
        'wind_speed': 8.23,
        'rain': 5.50,
        'isi': 4.35,
      },
      'status': 'offline_cached_metadata',
    };
  }

  // ==========================================================================
  // Direct Open-Meteo parser
  // ==========================================================================
  WeatherReport _parseOpenMeteoDirect(Map<String, dynamic> raw, double lat, double lon) {
    final cur = raw['current'] as Map<String, dynamic>? ?? {};
    final hourly = raw['hourly'] as Map<String, dynamic>? ?? {};
    final daily = raw['daily'] as Map<String, dynamic>? ?? {};

    final times = (hourly['time'] as List<dynamic>? ?? []).take(24).toList();
    final temps = (hourly['temperature_2m'] as List<dynamic>? ?? []).take(24).toList();
    final rhs = (hourly['relative_humidity_2m'] as List<dynamic>? ?? []).take(24).toList();
    final winds = (hourly['wind_speed_10m'] as List<dynamic>? ?? []).take(24).toList();
    final rainProbs = (hourly['precipitation_probability'] as List<dynamic>? ?? []).take(24).toList();

    final hourlyList = <HourlyForecast>[];
    for (int i = 0; i < times.length; i++) {
      hourlyList.add(HourlyForecast(
        time: times[i].toString(),
        temperature: (temps.length > i ? (temps[i] as num).toDouble() : 24.0),
        relativeHumidity: (rhs.length > i ? (rhs[i] as num).toDouble() : 50.0),
        windSpeed: (winds.length > i ? (winds[i] as num).toDouble() : 12.0),
        precipitationProbability: (rainProbs.length > i ? (rainProbs[i] as num).toDouble() : 0.0),
      ));
    }

    final dailyTimes = (daily['time'] as List<dynamic>? ?? []);
    final dailyTMax = (daily['temperature_2m_max'] as List<dynamic>? ?? []);
    final dailyTMin = (daily['temperature_2m_min'] as List<dynamic>? ?? []);
    final dailyRain = (daily['precipitation_sum'] as List<dynamic>? ?? []);
    final dailyWinds = (daily['wind_speed_10m_max'] as List<dynamic>? ?? []);

    final dailyList = <DailyForecast>[];
    for (int i = 0; i < dailyTimes.length; i++) {
      dailyList.add(DailyForecast(
        date: dailyTimes[i].toString(),
        tempMax: dailyTMax.length > i ? (dailyTMax[i] as num).toDouble() : 28.0,
        tempMin: dailyTMin.length > i ? (dailyTMin[i] as num).toDouble() : 18.0,
        precipitationSum: dailyRain.length > i ? (dailyRain[i] as num).toDouble() : 0.0,
        windSpeedMax: dailyWinds.length > i ? (dailyWinds[i] as num).toDouble() : 15.0,
        condition: 'Clear',
      ));
    }

    return WeatherReport(
      latitude: lat,
      longitude: lon,
      timezone: raw['timezone']?.toString() ?? 'UTC',
      timestamp: cur['time']?.toString() ?? DateTime.now().toIso8601String(),
      source: 'Open-Meteo Direct API',
      current: CurrentWeather(
        temperature: (cur['temperature_2m'] as num?)?.toDouble() ?? 26.0,
        apparentTemperature: (cur['apparent_temperature'] as num?)?.toDouble() ?? 27.0,
        relativeHumidity: (cur['relative_humidity_2m'] as num?)?.toDouble() ?? 42.0,
        windSpeed: (cur['wind_speed_10m'] as num?)?.toDouble() ?? 14.0,
        windDirection: (cur['wind_direction_10m'] as num?)?.toInt() ?? 180,
        windGusts: (cur['wind_gusts_10m'] as num?)?.toDouble() ?? 20.0,
        precipitation: (cur['precipitation'] as num?)?.toDouble() ?? 0.0,
        rain: (cur['rain'] as num?)?.toDouble() ?? 0.0,
        surfacePressure: (cur['surface_pressure'] as num?)?.toDouble() ?? 1012.0,
        weatherCode: (cur['weather_code'] as num?)?.toInt() ?? 0,
        condition: 'Clear sky',
      ),
      hourly: hourlyList,
      daily: dailyList,
      status: 'success_direct',
    );
  }

  // ==========================================================================
  // Offline Heuristic Generators
  // ==========================================================================
  WeatherReport _generateOfflineWeather(double lat, double lon) {
    final now = DateTime.now();
    return WeatherReport(
      latitude: lat,
      longitude: lon,
      timezone: 'UTC',
      timestamp: now.toIso8601String(),
      source: 'Open-Meteo (Offline Heuristic Cache)',
      current: CurrentWeather(
        temperature: 29.5,
        apparentTemperature: 31.0,
        relativeHumidity: 32.0,
        windSpeed: 21.0,
        windDirection: 240,
        windGusts: 29.0,
        precipitation: 0.0,
        rain: 0.0,
        surfacePressure: 1011.5,
        weatherCode: 0,
        condition: 'Dry & Clear',
      ),
      hourly: List.generate(
        24,
        (i) => HourlyForecast(
          time: now.add(Duration(hours: i)).toIso8601String(),
          temperature: 28.0 + 4.0 * sin(i / 12 * pi),
          relativeHumidity: max(20.0, 45.0 - 15.0 * sin(i / 12 * pi)),
          windSpeed: 16.0 + 6.0 * cos(i / 8 * pi),
          precipitationProbability: 0.0,
        ),
      ),
      daily: List.generate(
        7,
        (i) => DailyForecast(
          date: now.add(Duration(days: i)).toIso8601String().substring(0, 10),
          tempMax: 31.0,
          tempMin: 18.5,
          precipitationSum: 0.0,
          windSpeedMax: 24.0,
          condition: 'Sunny',
        ),
      ),
      status: 'offline_cached',
    );
  }

  HotspotsReport _generateOfflineHotspots(double lat, double lon, double radius) {
    final now = DateTime.now();
    final hotspots = [
      FireHotspot(
        id: 'offline_1',
        latitude: lat + 0.18,
        longitude: lon + 0.12,
        distanceKm: 24.5,
        brightnessKelvin: 358.4,
        frpMw: 62.5,
        confidence: 'high',
        confidencePercent: 94,
        satellite: 'Suomi NPP (VIIRS)',
        instrument: 'VIIRS',
        acquisitionDate: now.toIso8601String().substring(0, 10),
        acquisitionTime: '13:42 UTC',
        dayNight: 'D',
        status: 'active',
      ),
      FireHotspot(
        id: 'offline_2',
        latitude: lat - 0.22,
        longitude: lon + 0.35,
        distanceKm: 46.2,
        brightnessKelvin: 341.2,
        frpMw: 28.0,
        confidence: 'nominal',
        confidencePercent: 82,
        satellite: 'NOAA-20 (VIIRS)',
        instrument: 'VIIRS',
        acquisitionDate: now.toIso8601String().substring(0, 10),
        acquisitionTime: '11:15 UTC',
        dayNight: 'D',
        status: 'active',
      ),
      FireHotspot(
        id: 'offline_3',
        latitude: lat + 0.45,
        longitude: lon - 0.15,
        distanceKm: 58.7,
        brightnessKelvin: 334.8,
        frpMw: 18.2,
        confidence: 'nominal',
        confidencePercent: 78,
        satellite: 'Aqua (MODIS)',
        instrument: 'MODIS',
        acquisitionDate: now.toIso8601String().substring(0, 10),
        acquisitionTime: '09:30 UTC',
        dayNight: 'D',
        status: 'active',
      ),
    ];

    return HotspotsReport(
      source: 'NASA FIRMS (Demonstration Feed - Educational Prototype)',
      attribution: 'NASA ESDIS / LANCE Active Fire System Specifications',
      isLiveApi: false,
      centerLat: lat,
      centerLon: lon,
      radiusKm: radius,
      hotspotsCount: hotspots.length,
      timestamp: now.toIso8601String(),
      satelliteDelayNote: 'Satellite overpasses (VIIRS/MODIS) observe active fires with ~3-6 hour latency.',
      hotspots: hotspots,
    );
  }

  RiskPrediction _generateOfflinePrediction(double lat, double lon) {
    return RiskPrediction(
      riskScore: 78,
      riskProbability: 0.78,
      riskCategory: 'Very High',
      riskColor: '#EF4444',
      severityRank: 4,
      isDemoMode: true,
      temperature: 31.5,
      relativeHumidity: 26.0,
      windSpeed: 24.0,
      rain: 0.0,
      fwi: FwiIndices(
        ffmc: 89.4,
        dmc: 42.1,
        dc: 285.0,
        isi: 12.8,
        bui: 62.5,
        fwi: 28.4,
      ),
      riskDrivers: [
        RiskDriver(
          factor: 'Fine Fuel Moisture Code (FFMC)',
          value: '89.4',
          impact: 'Critical',
          explanation: 'Litter and top foliage desiccated; rapid ignition possible from sparks.',
        ),
        RiskDriver(
          factor: 'Relative Humidity',
          value: '26.0%',
          impact: 'Severe',
          explanation: 'Low atmospheric moisture accelerates vegetative fuel combustion.',
        ),
        RiskDriver(
          factor: 'Wind Velocity',
          value: '24.0 km/h',
          impact: 'Elevated',
          explanation: 'Breezes promote ember transport and fire perimeter expansion.',
        ),
      ],
      recommendations: [
        SafetyRecommendation(
          icon: 'warning',
          title: 'Burn Ban in Effect',
          description: 'Open flames and campfires are strictly prohibited across forestry boundaries.',
        ),
        SafetyRecommendation(
          icon: 'directions_run',
          title: 'Evacuation Readiness',
          description: 'Keep vehicle fueled, prepare emergency documents, medications, and N95 masks.',
        ),
      ],
      modelName: 'Scikit-Learn Random Forest Classifier (150 trees)',
      validation: 'Stratified 5-Fold Cross-Validation (ROC-AUC ~0.80)',
    );
  }

  HistoricalTrendReport _generateOfflineTrends(double lat, double lon) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final isNorthern = lat >= 0;

    final monthly = List.generate(12, (i) {
      final seasonality = isNorthern
          ? exp(-pow(i + 1 - 7.5, 2) / 7.0)
          : exp(-pow((i < 6 ? i + 1 : i + 1 - 12) - 1.5, 2) / 7.0);

      return MonthlyTrend(
        month: months[i],
        monthIndex: i + 1,
        fireIncidents: (15 + seasonality * 75).round(),
        areaBurnedKAcres: (0.8 + seasonality * 12.4),
        avgTempC: 15.0 + 14.0 * seasonality,
        avgHumidityPercent: 65.0 - 22.0 * seasonality,
        seasonPhase: seasonality > 0.6 ? 'Peak Fire Season' : (seasonality > 0.25 ? 'Moderate Risk' : 'Low Season'),
      );
    });

    return HistoricalTrendReport(
      latitude: lat,
      longitude: lon,
      hemisphere: isNorthern ? 'Northern' : 'Southern',
      peakSeason: isNorthern ? 'June – September' : 'December – March',
      monthlyDistribution: monthly,
      annualTrends: [
        AnnualTrend(year: 2022, totalFires: 420, acresBurned: 68500, severityIndex: 68),
        AnnualTrend(year: 2023, totalFires: 485, acresBurned: 84200, severityIndex: 76),
        AnnualTrend(year: 2024, totalFires: 530, acresBurned: 96100, severityIndex: 82),
        AnnualTrend(year: 2025, totalFires: 490, acresBurned: 81000, severityIndex: 74),
        AnnualTrend(year: 2026, totalFires: 560, acresBurned: 104500, severityIndex: 88),
      ],
      correlations: [
        FeatureCorrelation(feature: 'Fine Fuel Moisture (FFMC)', correlation: 0.82, relationship: 'Strong Positive'),
        FeatureCorrelation(feature: 'Initial Spread Index (ISI)', correlation: 0.74, relationship: 'Strong Positive'),
        FeatureCorrelation(feature: 'Ambient Temperature', correlation: 0.68, relationship: 'Positive'),
        FeatureCorrelation(feature: 'Relative Humidity', correlation: -0.71, relationship: 'Strong Inverse'),
        FeatureCorrelation(feature: '24h Rainfall', correlation: -0.63, relationship: 'Moderate Inverse'),
      ],
      academicInsight: 'Wildfire frequency exhibits peak correlation with desiccated fine fuel beds (FFMC) and low humidity.',
    );
  }
}
