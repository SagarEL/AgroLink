import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────
/// AgroLink Design System — Premium Agri-Tech SaaS Theme
/// ─────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // ── Brand Colors ──────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accentAmber = Color(0xFFF9A825);
  static const Color accentOrange = Color(0xFFEF6C00);

  // ── Earthy Tones ──────────────────────────────────────────
  static const Color earthBrown = Color(0xFF5D4037);
  static const Color earthLight = Color(0xFF8D6E63);
  static const Color earthBeige = Color(0xFFF5F0E8);
  static const Color earthSand = Color(0xFFEFEBE9);

  // ── Semantic Colors ───────────────────────────────────────
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFF8F00);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF1E88E5);

  // ── Severity Colors ───────────────────────────────────────
  static const Color severityCritical = Color(0xFFD32F2F);
  static const Color severityHigh = Color(0xFFEF6C00);
  static const Color severityMedium = Color(0xFFF9A825);
  static const Color severityLow = Color(0xFF66BB6A);

  // ── Neutral Colors ────────────────────────────────────────
  static const Color surfaceWhite = Color(0xFFFAFAFA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF1B1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textTertiary = Color(0xFF79747E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Dark Theme Colors ─────────────────────────────────────
  static const Color darkSurface = Color(0xFF1A1C1E);
  static const Color darkCard = Color(0xFF232528);
  static const Color darkCardElevated = Color(0xFF2C2E31);
  static const Color darkTextPrimary = Color(0xFFE6E1E5);
  static const Color darkTextSecondary = Color(0xFFCAC4D0);
  static const Color darkDivider = Color(0xFF3D3D3D);

  // ── Glassmorphism ─────────────────────────────────────────
  static const Color glassLight = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x1AFFFFFF);

  // ── Border Radius ─────────────────────────────────────────
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 100.0;

  // ── Elevation ─────────────────────────────────────────────
  static const double elevationNone = 0.0;
  static const double elevationLow = 1.0;
  static const double elevationMedium = 3.0;
  static const double elevationHigh = 6.0;

  // ── Spacing ───────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ── Card Decoration ───────────────────────────────────────
  static BoxDecoration get glassCard => BoxDecoration(
        color: cardWhite.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(radiusLarge),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get glassCardDark => BoxDecoration(
        color: darkCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(radiusLarge),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration get elevatedCard => BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration statCardDecoration(Color color) => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      );

  // ── Text Theme ────────────────────────────────────────────
  static TextTheme get _textTheme => TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      );

  // ═══════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.light,
          primary: primaryGreen,
          onPrimary: textOnPrimary,
          secondary: earthBrown,
          tertiary: accentAmber,
          surface: surfaceWhite,
          error: error,
        ),
        textTheme: _textTheme.apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          color: cardWhite,
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 1,
          backgroundColor: cardWhite,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          iconTheme: const IconThemeData(color: textPrimary),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: cardWhite,
          selectedIconTheme: const IconThemeData(color: primaryGreen),
          unselectedIconTheme: IconThemeData(color: textSecondary),
          indicatorColor: primaryGreen.withValues(alpha: 0.12),
          selectedLabelTextStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryGreen,
          ),
          unselectedLabelTextStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: cardWhite,
          selectedItemColor: primaryGreen,
          unselectedItemColor: textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryGreen,
          foregroundColor: textOnPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: textOnPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMedium),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryGreen,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: const BorderSide(color: primaryGreen),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMedium),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryGreen,
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: primaryGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: error, width: 2),
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: textTertiary,
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            color: textSecondary,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF0F4F0),
          selectedColor: primaryGreen.withValues(alpha: 0.15),
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusRound),
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        dividerTheme: const DividerThemeData(
          color: dividerColor,
          thickness: 1,
          space: 1,
        ),
        dialogTheme: DialogThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXLarge),
          ),
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          contentTextStyle: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: primaryGreen,
          unselectedLabelColor: textTertiary,
          indicatorColor: primaryGreen,
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primaryGreen,
        ),
      );

  // ═══════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryLight,
          brightness: Brightness.dark,
          primary: primaryLight,
          onPrimary: Colors.black,
          secondary: earthLight,
          tertiary: accentAmber,
          surface: darkSurface,
          error: error,
        ),
        textTheme: _textTheme.apply(
          bodyColor: darkTextPrimary,
          displayColor: darkTextPrimary,
        ),
        scaffoldBackgroundColor: darkSurface,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          color: darkCard,
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 1,
          backgroundColor: darkCard,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: darkTextPrimary,
          ),
          iconTheme: const IconThemeData(color: darkTextPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkCardElevated,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: primaryLight, width: 2),
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: darkTextSecondary,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryLight,
          foregroundColor: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: darkDivider,
          thickness: 1,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primaryLight,
        ),
      );
}
