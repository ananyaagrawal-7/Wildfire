import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../models/weather_data.dart';
import '../models/risk_prediction.dart';
import '../models/historical_trend.dart';
import '../state/app_state.dart';
import '../widgets/fwi_metric_tile.dart';
import '../widgets/disclaimer_banner.dart';

class RiskAnalysisScreen extends StatelessWidget {
  final AppState appState;

  const RiskAnalysisScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final weather = appState.weather;
        final prediction = appState.prediction;
        final trends = appState.trends;
        final fwi = prediction?.fwi;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: const Text(
              'Environmental Risk Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                onPressed: appState.refreshAll,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Regional Header
                _buildRegionHeader(),
                const SizedBox(height: 16),

                // Environmental Meteorological Parameters Breakdown
                _buildMeteorologicalSection(weather?.current),
                const SizedBox(height: 20),

                // Canadian Forest Fire Weather Index (FWI) Components
                if (fwi != null) ...[
                  _buildFwiSection(fwi),
                  const SizedBox(height: 20),
                ],

                // 24-Hour Temperature & Humidity Forecast Chart
                if (weather != null && weather.hourly.isNotEmpty) ...[
                  _buildHourlyProjectionChart(weather.hourly),
                  const SizedBox(height: 20),
                ],

                // 12-Month Historical Fire Season Trends Chart
                if (trends != null && trends.monthlyDistribution.isNotEmpty) ...[
                  _buildMonthlyTrendsChart(trends),
                  const SizedBox(height: 20),
                ],

                // Random Forest Feature Importance (Academic Explainability)
                _buildFeatureImportanceSection(appState.modelInfo),
                const SizedBox(height: 20),

                // Pearson Correlation Analysis
                if (trends != null && trends.correlations.isNotEmpty) ...[
                  _buildCorrelationsSection(trends.correlations),
                  const SizedBox(height: 16),
                ],

                // Academic Disclaimer
                const DisclaimerBanner(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegionHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.currentLocationName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Telemetry Lat: ${appState.currentLatitude.toStringAsFixed(3)}°, Lon: ${appState.currentLongitude.toStringAsFixed(3)}°',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeteorologicalSection(CurrentWeather? cur) {
    if (cur == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Atmospheric Telemetry',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Real-time inputs supplied to the Random Forest inference pipeline:',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildParamCard(
                title: 'Ambient Temp',
                value: '${cur.temperature.toStringAsFixed(1)} °C',
                sub: 'Feels like ${cur.apparentTemperature.toStringAsFixed(1)}°',
                icon: Icons.thermostat_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildParamCard(
                title: 'Relative Humidity',
                value: '${cur.relativeHumidity.toStringAsFixed(0)} %',
                sub: cur.relativeHumidity < 30 ? 'Critically Dry' : 'Moderate',
                icon: Icons.water_drop_rounded,
                color: cur.relativeHumidity < 30 ? AppColors.riskVeryHigh : AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildParamCard(
                title: 'Wind Velocity',
                value: '${cur.windSpeed.toStringAsFixed(1)} km/h',
                sub: 'Gusts up to ${cur.windGusts.toStringAsFixed(1)} km/h',
                icon: Icons.air_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildParamCard(
                title: '24h Precipitation',
                value: '${cur.rain.toStringAsFixed(1)} mm',
                sub: cur.rain == 0 ? 'Cumulative deficit' : 'Moisture added',
                icon: Icons.grain_rounded,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParamCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildFwiSection(FwiIndices fwi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Canadian Fire Weather Index (FWI) Components',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Standard international metrics representing fuel moisture strata and rate of spread:',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        FwiMetricTile(
          acronym: 'FFMC',
          fullName: 'Fine Fuel Moisture Code',
          value: fwi.ffmc,
          maxValue: 101.0,
          description: 'Moisture content of surface litter and cured grass. >88 indicates severe ease of ignition.',
          riskLevel: fwi.ffmc >= 88 ? 'EXTREME' : (fwi.ffmc >= 80 ? 'HIGH' : 'MODERATE'),
          riskColor: fwi.ffmc >= 88 ? AppColors.riskVeryHigh : (fwi.ffmc >= 80 ? AppColors.riskHigh : AppColors.success),
        ),

        FwiMetricTile(
          acronym: 'DMC',
          fullName: 'Duff Moisture Code',
          value: fwi.dmc,
          maxValue: 150.0,
          description: 'Moisture of medium-depth organic duff layers (5-10 cm deep). Elevated in dry spells.',
          riskLevel: fwi.dmc >= 60 ? 'HIGH' : (fwi.dmc >= 30 ? 'MODERATE' : 'LOW'),
          riskColor: fwi.dmc >= 60 ? AppColors.riskHigh : AppColors.info,
        ),

        FwiMetricTile(
          acronym: 'DC',
          fullName: 'Drought Code',
          value: fwi.dc,
          maxValue: 800.0,
          description: 'Deep, compact soil layer dryness rating long-term seasonal drought effects.',
          riskLevel: fwi.dc >= 400 ? 'SEVERE' : (fwi.dc >= 200 ? 'MODERATE' : 'LOW'),
          riskColor: fwi.dc >= 400 ? AppColors.riskVeryHigh : AppColors.textSecondary,
        ),

        FwiMetricTile(
          acronym: 'ISI',
          fullName: 'Initial Spread Index',
          value: fwi.isi,
          maxValue: 40.0,
          description: 'Combines wind speed and FFMC to model front propagation velocity immediately following ignition.',
          riskLevel: fwi.isi >= 14 ? 'HIGH SPREAD' : (fwi.isi >= 8 ? 'MODERATE' : 'LOW'),
          riskColor: fwi.isi >= 14 ? AppColors.riskVeryHigh : AppColors.warning,
        ),

        FwiMetricTile(
          acronym: 'BUI',
          fullName: 'Buildup Index',
          value: fwi.bui,
          maxValue: 180.0,
          description: 'Total combustible biomass volume available to sustain ongoing flame front.',
          riskLevel: fwi.bui >= 60 ? 'ELEVATED' : 'STABLE',
          riskColor: fwi.bui >= 60 ? AppColors.primary : AppColors.info,
        ),
      ],
    );
  }

  Widget _buildHourlyProjectionChart(List<HourlyForecast> hourly) {
    final spotsTemp = <FlSpot>[];
    final spotsRh = <FlSpot>[];

    for (int i = 0; i < hourly.take(12).length; i++) {
      spotsTemp.add(FlSpot(i.toDouble(), hourly[i].temperature));
      spotsRh.add(FlSpot(i.toDouble(), hourly[i].relativeHumidity));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '12-Hour Forecast Dynamics',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  _buildLegendDot(AppColors.primary, 'Temp (°C)'),
                  const SizedBox(width: 12),
                  _buildLegendDot(AppColors.info, 'Humidity (%)'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Inverse relationship between midday temperature peaks and plummeting fuel humidity:',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),

          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: AppColors.border,
                    strokeWidth: 0.8,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, meta) => Text(
                        val.toInt().toString(),
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < hourly.length) {
                          final timeStr = hourly[idx].time;
                          final hour = timeStr.contains('T')
                              ? timeStr.split('T').last.substring(0, 2)
                              : '$idx h';
                          return Text(
                            '$hour:00',
                            style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Temperature line
                  LineChartBarData(
                    spots: spotsTemp,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.8,
                    dotData: const FlDotData(show: false),
                  ),
                  // Humidity line
                  LineChartBarData(
                    spots: spotsRh,
                    isCurved: true,
                    color: AppColors.info,
                    barWidth: 2.5,
                    dashArray: [5, 4],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendsChart(HistoricalTrendReport trends) {
    final list = trends.monthlyDistribution;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Wildfire Seasonality',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Peak: ${trends.peakSeason}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Historical fire frequency patterns across the ${trends.hemisphere} Hemisphere:',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),

          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: AppColors.border,
                    strokeWidth: 0.8,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (val, meta) => Text(
                        val.toInt().toString(),
                        style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < list.length) {
                          return Text(
                            list[idx].month.substring(0, 1),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: list[idx].seasonPhase.contains('Peak')
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: list[idx].seasonPhase.contains('Peak')
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(list.length, (i) {
                  final item = list[i];
                  final isPeak = item.seasonPhase.contains('Peak');
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: item.fireIncidents.toDouble(),
                        color: isPeak ? AppColors.primary : AppColors.surfaceElevated,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureImportanceSection(Map<String, dynamic>? modelInfo) {
    final rawImportances = modelInfo?['feature_importances'] as Map<String, dynamic>? ?? {
      'ffmc': 28.09,
      'relative_humidity': 14.00,
      'bui': 12.30,
      'dmc': 9.31,
      'temperature': 9.27,
      'dc': 8.95,
      'wind_speed': 8.23,
      'rain': 5.50,
      'isi': 4.35,
    };

    final labels = {
      'ffmc': 'Fine Fuel Moisture (FFMC)',
      'relative_humidity': 'Relative Humidity',
      'bui': 'Buildup Index (BUI)',
      'dmc': 'Duff Moisture (DMC)',
      'temperature': 'Ambient Temperature',
      'dc': 'Drought Code (DC)',
      'wind_speed': 'Wind Velocity',
      'rain': '24h Precipitation',
      'isi': 'Initial Spread Index (ISI)',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Random Forest Feature Importance',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Gini Importance',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Relative statistical contribution of each environmental feature in the trained ML model:',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          ...rawImportances.entries.map((entry) {
            final val = (entry.value as num).toDouble();
            final name = labels[entry.key] ?? entry.key;
            final isTop = val > 12.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isTop ? FontWeight.w700 : FontWeight.w500,
                          color: isTop ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${val.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isTop ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: val / 30.0,
                      backgroundColor: AppColors.surfaceElevated,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isTop ? AppColors.primary : AppColors.borderHighlight,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCorrelationsSection(List<FeatureCorrelation> correlations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'B.Tech Project Correlation Matrix',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pearson correlation r between individual features and wildfire incidence:',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          ...correlations.map((c) {
            final isPositive = c.correlation > 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    c.feature,
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                  Row(
                    children: [
                      Text(
                        c.relationship,
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.info.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${isPositive ? "+" : ""}${c.correlation.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isPositive ? AppColors.primary : AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
