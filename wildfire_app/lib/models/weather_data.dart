class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final double relativeHumidity;
  final double windSpeed;
  final int windDirection;
  final double windGusts;
  final double precipitation;
  final double rain;
  final double surfacePressure;
  final int weatherCode;
  final String condition;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.windDirection,
    required this.windGusts,
    required this.precipitation,
    required this.rain,
    required this.surfacePressure,
    required this.weatherCode,
    required this.condition,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 25.0,
      apparentTemperature: (json['apparent_temperature'] as num?)?.toDouble() ?? 26.0,
      relativeHumidity: (json['relative_humidity'] as num?)?.toDouble() ?? 45.0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 12.0,
      windDirection: (json['wind_direction'] as num?)?.toInt() ?? 180,
      windGusts: (json['wind_gusts'] as num?)?.toDouble() ?? 18.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      rain: (json['rain'] as num?)?.toDouble() ?? 0.0,
      surfacePressure: (json['surface_pressure'] as num?)?.toDouble() ?? 1013.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      condition: json['condition']?.toString() ?? 'Clear',
    );
  }
}

class HourlyForecast {
  final String time;
  final double temperature;
  final double relativeHumidity;
  final double windSpeed;
  final double precipitationProbability;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.precipitationProbability,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time']?.toString() ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 20.0,
      relativeHumidity: (json['relative_humidity'] as num?)?.toDouble() ?? 50.0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 10.0,
      precipitationProbability: (json['precipitation_probability'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailyForecast {
  final String date;
  final double tempMax;
  final double tempMin;
  final double precipitationSum;
  final double windSpeedMax;
  final String condition;

  DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationSum,
    required this.windSpeedMax,
    required this.condition,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['date']?.toString() ?? '',
      tempMax: (json['temp_max'] as num?)?.toDouble() ?? 28.0,
      tempMin: (json['temp_min'] as num?)?.toDouble() ?? 16.0,
      precipitationSum: (json['precipitation_sum'] as num?)?.toDouble() ?? 0.0,
      windSpeedMax: (json['wind_speed_max'] as num?)?.toDouble() ?? 15.0,
      condition: json['condition']?.toString() ?? 'Clear',
    );
  }
}

class WeatherReport {
  final double latitude;
  final double longitude;
  final String timezone;
  final String timestamp;
  final String source;
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final String status;

  WeatherReport({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.timestamp,
    required this.source,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.status,
  });

  factory WeatherReport.fromJson(Map<String, dynamic> json) {
    final curMap = (json['current'] as Map<String, dynamic>?) ?? {};
    final hourlyList = (json['hourly'] as List<dynamic>?)
            ?.map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final dailyList = (json['daily'] as List<dynamic>?)
            ?.map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return WeatherReport(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone']?.toString() ?? 'UTC',
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      source: json['source']?.toString() ?? 'Open-Meteo',
      current: CurrentWeather.fromJson(curMap),
      hourly: hourlyList,
      daily: dailyList,
      status: json['status']?.toString() ?? 'success',
    );
  }
}
