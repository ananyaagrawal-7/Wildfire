import 'package:flutter/foundation.dart';

class ApiConstants {
  // Default host determination
  // Android Emulator: 10.0.2.2 points to host PC localhost
  // Windows / Web / Physical Device: 127.0.0.1 or LAN IP
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    } else {
      return 'http://127.0.0.1:5000/api';
    }
  }

  // Endpoints
  static const String endpointHealth = '/health';
  static const String endpointWeather = '/weather';
  static const String endpointHotspots = '/hotspots';
  static const String endpointPredict = '/predict';
  static const String endpointTrends = '/trends';
  static const String endpointModelInfo = '/model-info';

  // Open-Meteo direct fallback if backend server is offline
  static const String openMeteoDirectUrl = 'https://api.open-meteo.com/v1/forecast';
}
