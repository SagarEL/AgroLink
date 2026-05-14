import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'surface_card.dart';

/// Compact dashboard tile — large numeric, secondary delta, icon chip.
class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.delta,
    this.deltaIsPositive,
    this.iconColor = AppColors.primary,
    this.iconBg = AppColors.primarySoft,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? delta;
  final bool? deltaIsPositive;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              if (delta != null) _DeltaPill(label: delta!, positive: deltaIsPositive ?? true),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(value, style: text.displaySmall?.copyWith(fontWeight: FontWeight.w700))
              .animate()
              .fadeIn(duration: 300.ms),
          const SizedBox(height: 4),
          Text(label, style: text.bodySmall),
        ],
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  const _DeltaPill({required this.label, required this.positive});
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.success : AppColors.danger;
    final bg = positive ? AppColors.successSoft : AppColors.dangerSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
