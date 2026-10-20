import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../models/risk_prediction.dart';
import '../state/app_state.dart';
import '../widgets/disclaimer_banner.dart';

class AlertsScreen extends StatefulWidget {
  final AppState appState;

  const AlertsScreen({super.key, required this.appState});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final Map<String, bool> _checklist = {
    'Government ID cards, insurance policies & deeds in waterproof pouch': false,
    '3-Day supply of non-perishable food and bottled drinking water (3L/person)': false,
    'Prescription medications, first-aid kit & medical equipment': false,
    'N95 / P100 respirator masks for wildfire particulate & smoke inhalation': false,
    'Portable battery power banks, flashlight & NOAA weather radio': false,
    'Sturdy work boots, long cotton pants & leather gloves': false,
    'Vehicle fuel tank kept above 75% capacity': false,
    'Pet food, leash, carrier & vaccination records': false,
  };

  Future<void> _callEmergencyNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showCopyDialog(number);
      }
    } catch (_) {
      _showCopyDialog(number);
    }
  }

  void _showCopyDialog(String number) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied emergency hotline $number to clipboard'),
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        final prediction = widget.appState.prediction;
        final score = prediction?.riskScore ?? 50;
        final category = prediction?.riskCategory ?? 'Moderate';
        final riskColor = AppColors.getRiskColorForScore(score);
        final recommendations = prediction?.recommendations ?? [];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: const Text(
              'Alerts & Safety Guidelines',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: AppColors.primary),
                tooltip: 'Copy Wildfire Bulletin',
                onPressed: () {
                  final text = 'WILDFIRE AI BULLETIN for ${widget.appState.currentLocationName}:\n'
                      'Risk Level: $category ($score/100)\n'
                      'Temp: ${prediction?.temperature ?? 28}°C, Humidity: ${prediction?.relativeHumidity ?? 40}%\n'
                      'Active Hotspots nearby: ${widget.appState.hotspots?.hotspotsCount ?? 0}\n'
                      'Educational Prototype (B.Tech Data Science Project)';
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Wildfire safety bulletin copied to clipboard'),
                      backgroundColor: AppColors.surfaceElevated,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Current Emergency Risk Alert Banner
                _buildAlertBanner(score, category, riskColor),
                const SizedBox(height: 18),

                // 2. Dynamic Safety Recommendations
                _buildRecommendationsSection(recommendations, riskColor),
                const SizedBox(height: 20),

                // 3. Emergency Hotline Fast Dials
                _buildEmergencyHotlines(),
                const SizedBox(height: 20),

                // 4. Evacuation Preparedness Go-Bag Checklist
                _buildGoBagChecklist(),
                const SizedBox(height: 16),

                // 5. Academic Disclaimer
                const DisclaimerBanner(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertBanner(int score, String category, Color riskColor) {
    final isSevere = score >= 75;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: riskColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: riskColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSevere ? Icons.warning_rounded : Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS: ${category.toUpperCase()} WILDFIRE RISK',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: riskColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Monitoring Zone: ${widget.appState.currentLocationName}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              Text(
                '$score/100',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: riskColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          Text(
            isSevere
                ? 'CRITICAL ALERT: Atmospheric conditions (high temperature, depleted fuel moisture, and wind dynamics) favor extreme fire behavior and rapid forward spread velocity. Evacuation readiness is advised.'
                : 'ADVISORY: Moderate environmental factors present. Exercise vigilance with outdoor heat sources and adhere to local forestry department burn notifications.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(List<SafetyRecommendation> recs, Color riskColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Targeted Safety Directives',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Action items based on current environmental drying indices:',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        if (recs.isEmpty)
          const Text(
            'No immediate severe advisories active for this area.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          )
        else
          ...recs.map((rec) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderHighlight, width: 1),
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rec.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.35,
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

  Widget _buildEmergencyHotlines() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Indian Emergency Action Contacts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'One-tap direct dial to Indian civil protection, forest rangers, and disaster response forces:',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildHotlineButton(
                title: 'National Emergency (India)',
                number: '112',
                icon: Icons.emergency_rounded,
                color: AppColors.riskVeryHigh,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildHotlineButton(
                title: 'Fire & Rescue Service',
                number: '101',
                icon: Icons.fire_truck_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildHotlineButton(
                title: 'NDMA / NDRF Disaster Force',
                number: '1078',
                icon: Icons.shield_rounded,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildHotlineButton(
                title: 'Van Vibhag (Forest Dept)',
                number: '1926',
                icon: Icons.forest_rounded,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHotlineButton({
    required String title,
    required String number,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _callEmergencyNumber(number),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoBagChecklist() {
    final completedCount = _checklist.values.where((v) => v).length;
    final totalCount = _checklist.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

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
                'Evacuation Go-Bag Checklist',
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
                child: Text(
                  '$completedCount of $totalCount Ready',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 14),

          ..._checklist.keys.map((item) {
            final isChecked = _checklist[item] ?? false;
            return InkWell(
              onTap: () {
                setState(() {
                  _checklist[item] = !isChecked;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Icon(
                      isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      color: isChecked ? AppColors.primary : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 12,
                          color: isChecked ? AppColors.textMuted : AppColors.textPrimary,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
