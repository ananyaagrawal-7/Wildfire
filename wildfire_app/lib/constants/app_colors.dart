import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds: Dark Forest Green and Charcoal
  static const Color background = Color(0xFF0C1410);       // Darkest forest-charcoal
  static const Color surface = Color(0xFF13221A);          // Deep pine card surface
  static const Color surfaceElevated = Color(0xFF1B2F24);  // Elevated card
  static const Color border = Color(0xFF284334);           // Muted pine border
  static const Color borderHighlight = Color(0xFF385E4A);  // Border focus

  // Primary Accent: Warm Radiant Fire Orange
  static const Color primary = Color(0xFFFF7A00);          // Warm Amber Orange
  static const Color primaryLight = Color(0xFFFF9E43);     // Soft Flame
  static const Color primaryDark = Color(0xFFD66000);      // Deep Burnt Orange

  // Risk Palette
  static const Color riskLow = Color(0xFF10B981);          // Emerald Green
  static const Color riskModerate = Color(0xFFF59E0B);     // Amber Gold
  static const Color riskHigh = Color(0xFFF97316);         // Bright Orange
  static const Color riskVeryHigh = Color(0xFFEF4444);     // Fiery Crimson
  static const Color riskExtreme = Color(0xFFB91C1C);      // Deep Ruby Fire

  // Hotspot Marker Colors
  static const Color hotspotCore = Color(0xFFFF2A00);
  static const Color hotspotGlow = Color(0x66FF5500);

  // Text & Typography
  static const Color textPrimary = Color(0xFFF3F7F5);      // Crisp Off-White
  static const Color textSecondary = Color(0xFFA1B5A9);    // Muted Sage Gray
  static const Color textMuted = Color(0xFF6B8073);        // Dark Sage

  // Status & Utility
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF38BDF8);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);

  static Color getRiskColor(String category) {
    switch (category.toLowerCase()) {
      case 'low':
        return riskLow;
      case 'moderate':
        return riskModerate;
      case 'high':
        return riskHigh;
      case 'very high':
        return riskVeryHigh;
      case 'extreme':
        return riskExtreme;
      default:
        return primary;
    }
  }

  static Color getRiskColorForScore(int score) {
    if (score <= 25) return riskLow;
    if (score <= 50) return riskModerate;
    if (score <= 75) return riskHigh;
    if (score <= 90) return riskVeryHigh;
    return riskExtreme;
  }
}
