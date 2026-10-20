import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/disclaimer_banner.dart';

class AboutScreen extends StatefulWidget {
  final AppState appState;

  const AboutScreen({super.key, required this.appState});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  void _showApiConfigDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.appState.apiBaseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        title: const Text(
          'Configure Backend REST API',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set the host IP address where your Python Flask server is running:\n'
              '• Android Emulator: http://10.0.2.2:5000/api\n'
              '• Physical Device (Wi-Fi): http://<PC-LAN-IP>:5000/api\n'
              '• Web / Desktop: http://127.0.0.1:5000/api',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceElevated,
                hintText: 'http://10.0.2.2:5000/api',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              widget.appState.updateApiBaseUrl(controller.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Updated backend API endpoint'),
                  backgroundColor: AppColors.surfaceElevated,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
            ),
            child: const Text('Save & Reconnect'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        final info = widget.appState.modelInfo;
        final metrics = info?['metrics'] as Map<String, dynamic>? ?? {};

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: const Text(
              'About & Project Specifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Brand Card
                _buildProjectBrandCard(),
                const SizedBox(height: 16),

                // Academic Information Card
                _buildAcademicCard(),
                const SizedBox(height: 16),

                // Machine Learning Model Details
                _buildModelArchitectureCard(metrics),
                const SizedBox(height: 16),

                // Data Sources Attribution Card
                _buildDataSourcesCard(),
                const SizedBox(height: 16),

                // Backend Host Configuration Tile
                _buildBackendConfigTile(context),
                const SizedBox(height: 16),

                // Full Disclaimer Banner
                const DisclaimerBanner(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectBrandCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: const Row(
        children: [
          AppLogo(size: 64, showBadge: true, showAura: false),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'WildFire AI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '• INDIA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF9933),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'India Forest Fire Early-Warning & Detection',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Version 1.0.0 • Production Candidate',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Academic Project Context',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '• Degree Program: Bachelor of Technology (B.Tech) in Data Science\n'
            '• Academic Year: 2nd Year Capstone Demonstration\n'
            '• Core Competencies Demonstrated:\n'
            '  - Supervised Machine Learning with Scikit-Learn\n'
            '  - Geospatial Telemetry & Satellite Data Integration\n'
            '  - RESTful Microservice Architecture with Python Flask\n'
            '  - Cross-Platform Native Mobile Development with Flutter & Dart\n'
            '  - Explainable AI (XAI) with Gini Feature Importances',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildModelArchitectureCard(Map<String, dynamic> metrics) {
    final acc = (metrics['test_accuracy'] as num?)?.toDouble() ?? 0.712;
    final prec = (metrics['test_precision'] as num?)?.toDouble() ?? 0.467;
    final rec = (metrics['test_recall'] as num?)?.toDouble() ?? 0.636;
    final f1 = (metrics['test_f1_score'] as num?)?.toDouble() ?? 0.538;
    final roc = (metrics['test_roc_auc'] as num?)?.toDouble() ?? 0.7863;
    final cvRoc = (metrics['cv_mean_roc_auc'] as num?)?.toDouble() ?? 0.7994;

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
          const Row(
            children: [
              Icon(Icons.memory_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Machine Learning Model Specifications',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Model: Balanced Random Forest Classifier (150 trees, max depth 12)\n'
            'Training Strategy: Stratified 80/20 Train-Test Split (2,500 samples), 5-Fold Cross-Validation, StandardScaler normalization without data leakage.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),

          // Metrics Grid
          Row(
            children: [
              Expanded(child: _buildMetricPill('Test Accuracy', '${(acc * 100).toStringAsFixed(1)}%')),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricPill('Recall (Sensitivity)', '${(rec * 100).toStringAsFixed(1)}%')),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricPill('Precision', '${(prec * 100).toStringAsFixed(1)}%')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildMetricPill('F1-Score', f1.toStringAsFixed(3))),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricPill('Test ROC-AUC', roc.toStringAsFixed(4))),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricPill('5-Fold CV AUC', cvRoc.toStringAsFixed(4))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourcesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Data Sources & Attributions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '• NASA FIRMS (Fire Information for Resource Management System):\n'
            '  Thermal infrared active fire observations from VIIRS (Suomi NPP & NOAA-20) and MODIS (Aqua & Terra) satellites. ESDIS / LANCE.\n\n'
            '• Open-Meteo Weather API:\n'
            '  Open-source meteorological forecasts, solar radiation, humidity, and wind vector feeds. Seamless access with zero rate limits.\n\n'
            '• Canadian Forest Fire Weather Index (FWI) System:\n'
            '  Standardized empirical fuel moisture stratification formulas by the Canadian Forest Service.\n\n'
            '• OpenStreetMap:\n'
            '  Cartography and map tiles © OpenStreetMap contributors under ODbL.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildBackendConfigTile(BuildContext context) {
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
              const Row(
                children: [
                  Icon(Icons.settings_ethernet_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Backend REST API Endpoint',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showApiConfigDialog(context),
                child: const Text('Edit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            widget.appState.apiBaseUrl,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Status: ${widget.appState.backendStatusText}',
            style: TextStyle(
              fontSize: 11,
              color: widget.appState.isBackendConnected ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
