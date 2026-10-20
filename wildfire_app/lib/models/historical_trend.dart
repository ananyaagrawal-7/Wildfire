class MonthlyTrend {
  final String month;
  final int monthIndex;
  final int fireIncidents;
  final double areaBurnedKAcres;
  final double avgTempC;
  final double avgHumidityPercent;
  final String seasonPhase;

  MonthlyTrend({
    required this.month,
    required this.monthIndex,
    required this.fireIncidents,
    required this.areaBurnedKAcres,
    required this.avgTempC,
    required this.avgHumidityPercent,
    required this.seasonPhase,
  });

  factory MonthlyTrend.fromJson(Map<String, dynamic> json) {
    return MonthlyTrend(
      month: json['month']?.toString() ?? '',
      monthIndex: (json['month_index'] as num?)?.toInt() ?? 1,
      fireIncidents: (json['fire_incidents'] as num?)?.toInt() ?? 10,
      areaBurnedKAcres: (json['area_burned_k_acres'] as num?)?.toDouble() ?? 1.0,
      avgTempC: (json['avg_temp_c'] as num?)?.toDouble() ?? 20.0,
      avgHumidityPercent: (json['avg_humidity_percent'] as num?)?.toDouble() ?? 50.0,
      seasonPhase: json['season_phase']?.toString() ?? 'Moderate',
    );
  }
}

class AnnualTrend {
  final int year;
  final int totalFires;
  final int acresBurned;
  final int severityIndex;

  AnnualTrend({
    required this.year,
    required this.totalFires,
    required this.acresBurned,
    required this.severityIndex,
  });

  factory AnnualTrend.fromJson(Map<String, dynamic> json) {
    return AnnualTrend(
      year: (json['year'] as num?)?.toInt() ?? 2026,
      totalFires: (json['total_fires'] as num?)?.toInt() ?? 400,
      acresBurned: (json['acres_burned'] as num?)?.toInt() ?? 50000,
      severityIndex: (json['severity_index'] as num?)?.toInt() ?? 70,
    );
  }
}

class FeatureCorrelation {
  final String feature;
  final double correlation;
  final String relationship;

  FeatureCorrelation({
    required this.feature,
    required this.correlation,
    required this.relationship,
  });

  factory FeatureCorrelation.fromJson(Map<String, dynamic> json) {
    return FeatureCorrelation(
      feature: json['feature']?.toString() ?? '',
      correlation: (json['correlation_with_fire'] as num?)?.toDouble() ?? 0.0,
      relationship: json['relationship']?.toString() ?? '',
    );
  }
}

class HistoricalTrendReport {
  final double latitude;
  final double longitude;
  final String hemisphere;
  final String peakSeason;
  final List<MonthlyTrend> monthlyDistribution;
  final List<AnnualTrend> annualTrends;
  final List<FeatureCorrelation> correlations;
  final String academicInsight;

  HistoricalTrendReport({
    required this.latitude,
    required this.longitude,
    required this.hemisphere,
    required this.peakSeason,
    required this.monthlyDistribution,
    required this.annualTrends,
    required this.correlations,
    required this.academicInsight,
  });

  factory HistoricalTrendReport.fromJson(Map<String, dynamic> json) {
    final mList = (json['monthly_distribution'] as List<dynamic>?)
            ?.map((e) => MonthlyTrend.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final aList = (json['annual_trends'] as List<dynamic>?)
            ?.map((e) => AnnualTrend.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final cList = (json['correlations'] as List<dynamic>?)
            ?.map((e) => FeatureCorrelation.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return HistoricalTrendReport(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      hemisphere: json['hemisphere']?.toString() ?? 'Northern',
      peakSeason: json['peak_season']?.toString() ?? 'June – September',
      monthlyDistribution: mList,
      annualTrends: aList,
      correlations: cList,
      academicInsight: json['academic_insight']?.toString() ?? '',
    );
  }
}
