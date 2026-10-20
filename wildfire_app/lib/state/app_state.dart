import 'package:flutter/foundation.dart';
import '../models/location_preset.dart';
import '../models/weather_data.dart';
import '../models/fire_hotspot.dart';
import '../models/risk_prediction.dart';
import '../models/historical_trend.dart';
import '../services/wildfire_api_service.dart';
import '../services/preferences_service.dart';

class AppState extends ChangeNotifier {
  final WildfireApiService apiService = WildfireApiService();

  // Location State
  LocationPreset _currentPreset = LocationPreset.presets[0];
  double _currentLatitude = LocationPreset.presets[0].latitude;
  double _currentLongitude = LocationPreset.presets[0].longitude;
  String _currentLocationName = LocationPreset.presets[0].name;
  String _currentRegion = LocationPreset.presets[0].region;
  bool _isCustomLocation = false;

  // Data State
  WeatherReport? _weather;
  HotspotsReport? _hotspots;
  RiskPrediction? _prediction;
  HistoricalTrendReport? _trends;
  Map<String, dynamic>? _modelInfo;

  // Loading & Error States
  bool _isLoading = false;
  String? _errorMessage;
  bool _isBackendConnected = false;
  String _backendStatusText = 'Checking backend...';

  // Getters
  LocationPreset get currentPreset => _currentPreset;
  double get currentLatitude => _currentLatitude;
  double get currentLongitude => _currentLongitude;
  String get currentLocationName => _currentLocationName;
  String get currentRegion => _currentRegion;
  bool get isCustomLocation => _isCustomLocation;

  WeatherReport? get weather => _weather;
  HotspotsReport? get hotspots => _hotspots;
  RiskPrediction? get prediction => _prediction;
  HistoricalTrendReport? get trends => _trends;
  Map<String, dynamic>? get modelInfo => _modelInfo;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBackendConnected => _isBackendConnected;
  String get backendStatusText => _backendStatusText;
  String get apiBaseUrl => apiService.baseUrl;

  AppState() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Check custom API URL
    final customUrl = await PreferencesService.getCustomApiUrl();
    if (customUrl != null && customUrl.isNotEmpty) {
      apiService.setBaseUrl(customUrl);
    }

    // Restore selected preset
    final presetIdx = await PreferencesService.getSelectedPresetIndex();
    if (presetIdx >= 0 && presetIdx < LocationPreset.presets.length) {
      _currentPreset = LocationPreset.presets[presetIdx];
      _currentLatitude = _currentPreset.latitude;
      _currentLongitude = _currentPreset.longitude;
      _currentLocationName = _currentPreset.name;
      _currentRegion = _currentPreset.region;
    }

    await checkBackendHealth();
    await refreshAll();
  }

  Future<void> checkBackendHealth() async {
    final health = await apiService.checkHealth();
    if (health['status'] == 'healthy') {
      _isBackendConnected = true;
      _backendStatusText = 'Connected to Flask ML Engine';
    } else {
      _isBackendConnected = false;
      _backendStatusText = 'Standby Mode (Local Physics / Heuristic Engine Active)';
    }
    notifyListeners();
  }

  Future<void> refreshAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Parallel execution for high responsiveness
      final results = await Future.wait([
        apiService.fetchWeather(_currentLatitude, _currentLongitude),
        apiService.fetchHotspots(_currentLatitude, _currentLongitude),
        apiService.fetchPrediction(_currentLatitude, _currentLongitude),
        apiService.fetchTrends(_currentLatitude, _currentLongitude),
        apiService.fetchModelInfo(),
      ]);

      _weather = results[0] as WeatherReport;
      _hotspots = results[1] as HotspotsReport;
      _prediction = results[2] as RiskPrediction;
      _trends = results[3] as HistoricalTrendReport;
      _modelInfo = results[4] as Map<String, dynamic>;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Could not load updated wildfire observations: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectPreset(LocationPreset preset, int index) async {
    _currentPreset = preset;
    _currentLatitude = preset.latitude;
    _currentLongitude = preset.longitude;
    _currentLocationName = preset.name;
    _currentRegion = preset.region;
    _isCustomLocation = false;
    await PreferencesService.setSelectedPresetIndex(index);
    await refreshAll();
  }

  Future<void> setCustomLocation(double lat, double lon, {String? name, String? region}) async {
    _currentLatitude = lat;
    _currentLongitude = lon;
    _currentLocationName = name ?? 'Custom Pinned Coordinate';
    _currentRegion = region ?? 'Lat: ${lat.toStringAsFixed(3)}, Lon: ${lon.toStringAsFixed(3)}';
    _isCustomLocation = true;
    await refreshAll();
  }

  Future<void> updateApiBaseUrl(String newUrl) async {
    apiService.setBaseUrl(newUrl);
    await PreferencesService.setCustomApiUrl(newUrl);
    await checkBackendHealth();
    await refreshAll();
  }
}
