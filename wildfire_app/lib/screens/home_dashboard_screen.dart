import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/weather_data.dart';
import '../models/risk_prediction.dart';
import '../models/fire_hotspot.dart';
import '../state/app_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/risk_gauge.dart';
import '../widgets/weather_metric_card.dart';
import '../widgets/preset_selector_sheet.dart';
import '../widgets/disclaimer_banner.dart';

class HomeDashboardScreen extends StatelessWidget {
  final AppState appState;
  final ValueChanged<int>? onNavigateToTab;

  const HomeDashboardScreen({
    super.key,
    required this.appState,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final weather = appState.weather;
        final prediction = appState.prediction;
        final hotspots = appState.hotspots;
        final isLoading = appState.isLoading && weather == null;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context),
          body: RefreshIndicator(
            onRefresh: appState.refreshAll,
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: isLoading
                ? _buildLoadingState()
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location Banner & Presets Selector
                        _buildLocationHeader(context),
                        const SizedBox(height: 12),

                        // Backend Status Pill
                        _buildBackendStatusPill(context),
                        const SizedBox(height: 16),

                        // Main Risk Prediction Card with Circular Gauge
                        _buildMainRiskCard(prediction),
                        const SizedBox(height: 16),

                        // Key Risk Drivers
                        if (prediction != null && prediction.riskDrivers.isNotEmpty) ...[
                          _buildRiskDriversSection(prediction.riskDrivers),
                          const SizedBox(height: 16),
                        ],

                        // Live Weather Metrics Grid
                        if (weather != null) ...[
                          _buildWeatherOverview(context, weather.current),
                          const SizedBox(height: 16),
                        ],

                        // Satellite Active Fire Hotspots Card (NASA FIRMS)
                        _buildHotspotsSummaryCard(context, hotspots),
                        const SizedBox(height: 16),

                        // Quick Navigation Action Buttons
                        _buildQuickActions(context),
                        const SizedBox(height: 12),

                        // Academic Disclaimer Banner
                        const DisclaimerBanner(compact: true),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          const AppLogo(size: 34, showBadge: false, showAura: false),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'WildFire AI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '• INDIA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF9933), // Saffron
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                'India Forest Fire Early-Warning & Detection',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
          tooltip: 'Refresh live telemetry',
          onPressed: appState.refreshAll,
        ),
        IconButton(
          icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
          tooltip: 'Change Indian Forest Belt',
          onPressed: () => PresetSelectorSheet.show(context, appState),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Retrieving live satellite and meteorological telemetry...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader(BuildContext context) {
    return InkWell(
      onTap: () => PresetSelectorSheet.show(context, appState),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderHighlight, width: 1),
              ),
              child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          appState.currentLocationName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${appState.currentRegion} • ${appState.currentLatitude.toStringAsFixed(2)}°, ${appState.currentLongitude.toStringAsFixed(2)}°',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1),
              ),
              child: const Text(
                'Change',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackendStatusPill(BuildContext context) {
    final isOnline = appState.isBackendConnected;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOnline
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOnline
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.warning.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              appState.backendStatusText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isOnline ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
          if (appState.prediction?.isDemoMode == true)
            const Text(
              'DEMO MODE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.warning,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainRiskCard(RiskPrediction? prediction) {
    final score = prediction?.riskScore ?? 50;
    final category = prediction?.riskCategory ?? 'Moderate';
    final isDemo = prediction?.isDemoMode ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wildfire Risk Index',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Random Forest ML Prediction',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderHighlight, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${prediction?.riskProbability != null ? (prediction!.riskProbability * 100).toStringAsFixed(0) : "50"}% Prob',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Circular Risk Gauge
          Center(
            child: RiskGauge(
              score: score,
              category: category,
              isDemoMode: isDemo,
              size: 200,
            ),
          ),

          const SizedBox(height: 18),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),

          // Model attribution footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  prediction?.modelName ?? 'Scikit-Learn Random Forest',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                prediction?.validation ?? '5-Fold CV ROC-AUC 0.80',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskDriversSection(List<RiskDriver> drivers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.insights_rounded, color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Text(
              'Primary Environmental Risk Drivers',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...drivers.take(3).map((d) {
          final isHigh = d.impact.toLowerCase().contains('critical') ||
              d.impact.toLowerCase().contains('severe') ||
              d.impact.toLowerCase().contains('high');

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHigh ? AppColors.riskHigh.withValues(alpha: 0.4) : AppColors.border,
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isHigh ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                  color: isHigh ? AppColors.riskHigh : AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            d.factor,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            d.value,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isHigh ? AppColors.riskHigh : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d.explanation,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWeatherOverview(BuildContext context, CurrentWeather current) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.cloud_queue_rounded, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text(
                  'Meteorological Conditions',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              current.condition,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.45,
          children: [
            WeatherMetricCard(
              icon: Icons.thermostat_rounded,
              label: 'Ambient Temp',
              value: '${current.temperature.toStringAsFixed(1)}°',
              unit: 'C',
              status: current.temperature >= 32 ? 'High Heat' : 'Moderate',
              statusColor: current.temperature >= 32 ? AppColors.riskHigh : AppColors.success,
            ),
            WeatherMetricCard(
              icon: Icons.water_drop_rounded,
              label: 'Relative Humidity',
              value: current.relativeHumidity.toStringAsFixed(0),
              unit: '%',
              status: current.relativeHumidity <= 30 ? 'Dry Fuel' : 'Stable',
              statusColor: current.relativeHumidity <= 30 ? AppColors.riskVeryHigh : AppColors.success,
            ),
            WeatherMetricCard(
              icon: Icons.air_rounded,
              label: 'Wind Speed',
              value: current.windSpeed.toStringAsFixed(1),
              unit: 'km/h',
              status: current.windSpeed >= 25 ? 'High Spread' : 'Calm',
              statusColor: current.windSpeed >= 25 ? AppColors.riskHigh : AppColors.info,
            ),
            WeatherMetricCard(
              icon: Icons.grain_rounded,
              label: '24h Precipitation',
              value: current.rain.toStringAsFixed(1),
              unit: 'mm',
              status: current.rain == 0 ? 'No Rain' : 'Dampened',
              statusColor: current.rain == 0 ? AppColors.warning : AppColors.success,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHotspotsSummaryCard(BuildContext context, HotspotsReport? hotspots) {
    final count = hotspots?.hotspotsCount ?? 0;
    final closest = hotspots != null && hotspots.hotspots.isNotEmpty ? hotspots.hotspots.first : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.satellite_alt_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'NASA FIRMS Satellite Hotspots',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: count > 0
                      ? AppColors.hotspotCore.withValues(alpha: 0.18)
                      : AppColors.success.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: count > 0 ? AppColors.hotspotCore : AppColors.success,
                    width: 1,
                  ),
                ),
                child: Text(
                  count > 0 ? '$count DETECTED' : 'CLEAR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: count > 0 ? AppColors.hotspotCore : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count > 0
                ? '$count active thermal hotspots observed by MODIS/VIIRS satellites within a ${hotspots?.radiusKm.toStringAsFixed(0) ?? "100"} km radius.'
                : 'No active thermal combustion signatures currently detected in this regional boundary.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          if (closest != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Closest Active Signature',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      Text(
                        '${closest.distanceKm.toStringAsFixed(1)} km away',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Fire Radiative Power',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      Text(
                        '${closest.frpMw.toStringAsFixed(1)} MW',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => onNavigateToTab?.call(1), // Switch to Map
              icon: const Icon(Icons.map_rounded, size: 16),
              label: const Text('View Hotspots on Live Map'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => onNavigateToTab?.call(2), // Risk Analysis
            icon: const Icon(Icons.analytics_rounded, size: 16),
            label: const Text('FWI Analysis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border, width: 1),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => onNavigateToTab?.call(3), // Alerts & Safety
            icon: const Icon(Icons.warning_amber_rounded, size: 16),
            label: const Text('Safety & Alerts'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border, width: 1),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
