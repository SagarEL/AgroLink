import 'package:flutter/material.dart';

/// Agrolink brand palette — earthy greens balanced with off-white surfaces and
/// soft accents. Designed for an enterprise agri-tech feel.
class AppColors {
  AppColors._();

  // Primary — Deep forest green for trust and growth.
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF66BB6A);
  static const Color primarySoft = Color(0xFFE8F5E9);

  // Secondary — Warm earth tone for accents.
  static const Color secondary = Color(0xFFC68B59);
  static const Color secondarySoft = Color(0xFFF5E6D8);

  // Tertiary — Sky blue for informational accents.
  static const Color tertiary = Color(0xFF1976D2);
  static const Color tertiarySoft = Color(0xFFE3F2FD);

  // Surfaces.
  static const Color background = Color(0xFFF5F7F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFFAFBF9);
  static const Color surfaceMuted = Color(0xFFEEF2EC);
  static const Color glassFill = Color(0x99FFFFFF);

  // Text.
  static const Color textPrimary = Color(0xFF14241B);
  static const Color textSecondary = Color(0xFF4E6051);
  static const Color textMuted = Color(0xFF8A9B90);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status.
  static const Color success = Color(0xFF2E7D32);
  static const Color successSoft = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF9A825);
  static const Color warningSoft = Color(0xFFFFF8E1);
  static const Color danger = Color(0xFFC62828);
  static const Color dangerSoft = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1976D2);
  static const Color infoSoft = Color(0xFFE3F2FD);

  // Misc.
  static const Color border = Color(0xFFE3E8E1);
  static const Color borderStrong = Color(0xFFCBD3C7);
  static const Color shadow = Color(0x14000000);
  static const Color overlay = Color(0x99000000);

  // Severity gradient (for priorityLevel / diseaseStatus indicators).
  static const Color severityLow = Color(0xFF43A047);
  static const Color severityMedium = Color(0xFFFB8C00);
  static const Color severityHigh = Color(0xFFE53935);
  static const Color severityCritical = Color(0xFFB71C1C);

  // Crop accent for pomegranate emphasis.
  static const Color pomegranate = Color(0xFFB13A4A);
}
