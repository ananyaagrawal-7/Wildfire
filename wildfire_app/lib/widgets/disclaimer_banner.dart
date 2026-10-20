import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DisclaimerBanner extends StatelessWidget {
  final bool compact;

  const DisclaimerBanner({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: const Row(
          children: [
            Icon(Icons.school_outlined, color: AppColors.primary, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'B.Tech Data Science Academic Prototype • Not official emergency notification',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderHighlight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Academic & Educational Early-Warning Notice',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• Predicted Risk: Evaluated via Random Forest ML model using Canadian Fire Weather Index equations on meteorological inputs.\n'
            '• Observed Hotspots: NASA FIRMS VIIRS/MODIS satellite thermal infrared detections (subject to orbit pass latency ~3-6h).\n'
            '• Disclaimer: Developed for a 2nd-year B.Tech Data Science capstone. Does not replace emergency evacuation broadcasts by local civil protection authorities.',
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
