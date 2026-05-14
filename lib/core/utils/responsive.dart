import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// Responsive Breakpoint System
/// ─────────────────────────────────────────────────────────────
class Responsive {
  Responsive._();

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double wideBreakpoint = 1536;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wideBreakpoint;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Returns a value based on the current breakpoint
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= wideBreakpoint && wide != null) return wide;
    if (width >= desktopBreakpoint && desktop != null) return desktop;
    if (width >= mobileBreakpoint && tablet != null) return tablet;
    return mobile;
  }

  /// Grid cross-axis count based on screen width
  static int gridColumns(BuildContext context, {int min = 1, int max = 4}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= wideBreakpoint) return max;
    if (width >= desktopBreakpoint) return (max * 0.75).ceil();
    if (width >= mobileBreakpoint) return (max * 0.5).ceil();
    return min;
  }

  /// Content padding based on screen width
  static EdgeInsets contentPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: value(context, mobile: 16, tablet: 24, desktop: 32),
      vertical: value(context, mobile: 16, tablet: 20, desktop: 24),
    );
  }

  /// Sidebar width for desktop
  static double sidebarWidth(BuildContext context) {
    return value(context, mobile: 0, tablet: 80, desktop: 260);
  }
}

/// Responsive layout builder widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Responsive.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= Responsive.mobileBreakpoint) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}
