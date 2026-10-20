class FwiIndices {
  final double ffmc;
  final double dmc;
  final double dc;
  final double isi;
  final double bui;
  final double fwi;

  FwiIndices({
    required this.ffmc,
    required this.dmc,
    required this.dc,
    required this.isi,
    required this.bui,
    required this.fwi,
  });

  factory FwiIndices.fromJson(Map<String, dynamic> json) {
    return FwiIndices(
      ffmc: (json['ffmc'] as num?)?.toDouble() ?? 75.0,
      dmc: (json['dmc'] as num?)?.toDouble() ?? 25.0,
      dc: (json['dc'] as num?)?.toDouble() ?? 150.0,
      isi: (json['isi'] as num?)?.toDouble() ?? 6.0,
      bui: (json['bui'] as num?)?.toDouble() ?? 30.0,
      fwi: (json['fwi'] as num?)?.toDouble() ?? 12.0,
    );
  }
}

class RiskDriver {
  final String factor;
  final String value;
  final String impact;
  final String explanation;

  RiskDriver({
    required this.factor,
    required this.value,
    required this.impact,
    required this.explanation,
  });

  factory RiskDriver.fromJson(Map<String, dynamic> json) {
    return RiskDriver(
      factor: json['factor']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      impact: json['impact']?.toString() ?? 'Moderate',
      explanation: json['explanation']?.toString() ?? '',
    );
  }
}

class SafetyRecommendation {
  final String icon;
  final String title;
  final String description;

  SafetyRecommendation({
    required this.icon,
    required this.title,
    required this.description,
  });

  factory SafetyRecommendation.fromJson(Map<String, dynamic> json) {
    return SafetyRecommendation(
      icon: json['icon']?.toString() ?? 'info',
      title: json['title']?.toString() ?? 'Safety Alert',
      description: json['description']?.toString() ?? '',
    );
  }
}

class RiskPrediction {
  final int riskScore;
  final double riskProbability;
  final String riskCategory;
  final String riskColor;
  final int severityRank;
  final bool isDemoMode;
  final double temperature;
  final double relativeHumidity;
  final double windSpeed;
  final double rain;
  final FwiIndices fwi;
  final List<RiskDriver> riskDrivers;
  final List<SafetyRecommendation> recommendations;
  final String modelName;
  final String validation;

  RiskPrediction({
    required this.riskScore,
    required this.riskProbability,
    required this.riskCategory,
    required this.riskColor,
    required this.severityRank,
    required this.isDemoMode,
    required this.temperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.rain,
    required this.fwi,
    required this.riskDrivers,
    required this.recommendations,
    required this.modelName,
    required this.validation,
  });

  factory RiskPrediction.fromJson(Map<String, dynamic> json) {
    final inputs = (json['inputs'] as Map<String, dynamic>?) ?? {};
    final fwiMap = (json['fwi_indices'] as Map<String, dynamic>?) ?? {};
    final ref = (json['model_reference'] as Map<String, dynamic>?) ?? {};
    final driversList = (json['risk_drivers'] as List<dynamic>?)
            ?.map((e) => RiskDriver.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final recsList = (json['recommendations'] as List<dynamic>?)
            ?.map((e) => SafetyRecommendation.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return RiskPrediction(
      riskScore: (json['risk_score'] as num?)?.toInt() ?? 50,
      riskProbability: (json['risk_probability'] as num?)?.toDouble() ?? 0.5,
      riskCategory: json['risk_category']?.toString() ?? 'Moderate',
      riskColor: json['risk_color']?.toString() ?? '#F59E0B',
      severityRank: (json['severity_rank'] as num?)?.toInt() ?? 2,
      isDemoMode: json['is_demo_mode'] as bool? ?? false,
      temperature: (inputs['temperature'] as num?)?.toDouble() ?? 25.0,
      relativeHumidity: (inputs['relative_humidity'] as num?)?.toDouble() ?? 45.0,
      windSpeed: (inputs['wind_speed'] as num?)?.toDouble() ?? 15.0,
      rain: (inputs['rain'] as num?)?.toDouble() ?? 0.0,
      fwi: FwiIndices.fromJson(fwiMap),
      riskDrivers: driversList,
      recommendations: recsList,
      modelName: ref['model_name']?.toString() ?? 'Random Forest Classifier',
      validation: ref['validation']?.toString() ?? 'Stratified Cross-Validation',
    );
  }
}
