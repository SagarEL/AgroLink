import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography scale built on Inter (display) + Plus Jakarta Sans (body).
class AppTypography {
  AppTypography._();

  static TextTheme build() {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base
        .copyWith(
          displayLarge: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
            color: AppColors.textPrimary,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            color: AppColors.textPrimary,
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: AppColors.textPrimary,
          ),
          headlineLarge: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleLarge: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleMedium: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleSmall: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          bodyLarge: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.45,
            color: AppColors.textPrimary,
          ),
          bodyMedium: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.45,
            color: AppColors.textPrimary,
          ),
          bodySmall: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
          labelLarge: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: AppColors.textPrimary,
          ),
          labelMedium: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: AppColors.textSecondary,
          ),
          labelSmall: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: AppColors.textMuted,
          ),
        )
        .apply(displayColor: AppColors.textPrimary, bodyColor: AppColors.textPrimary);
  }
}
