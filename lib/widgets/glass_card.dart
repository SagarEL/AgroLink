import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Subtle frosted card used for hero KPI tiles. Falls back to a regular card on
/// platforms where ImageFilter is expensive (Flutter Web Skwasm honors it fine).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.lg,
    this.tint,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: (tint ?? AppColors.glassFill),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.1),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 12)),
            ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
