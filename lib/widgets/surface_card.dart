import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Standard floating card used across detail screens. Adds a hover lift on
/// desktop for that premium SaaS feel.
class SurfaceCard extends StatefulWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.lg,
    this.onTap,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  State<SurfaceCard> createState() => _SurfaceCardState();
}

class _SurfaceCardState extends State<SurfaceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null;
    return MouseRegion(
      onEnter: isInteractive ? (_) => setState(() => _hover = true) : null,
      onExit: isInteractive ? (_) => setState(() => _hover = false) : null,
      cursor: isInteractive ? SystemMouseCursors.click : MouseCursor.defer,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: _hover
            ? (Matrix4.identity()..translate(0.0, -2.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: widget.borderColor ?? AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: _hover ? 24 : 12,
              offset: Offset(0, _hover ? 12 : 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.radius),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.radius),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
