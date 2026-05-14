import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/plot.dart';
import '../models/visit.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  factory StatusPill.priority(PriorityLevel p) {
    final color = switch (p) {
      PriorityLevel.low => AppColors.severityLow,
      PriorityLevel.medium => AppColors.severityMedium,
      PriorityLevel.high => AppColors.severityHigh,
      PriorityLevel.critical => AppColors.severityCritical,
    };
    return StatusPill(label: p.label, color: color, icon: Icons.flag_outlined);
  }

  factory StatusPill.disease(DiseaseStatus d) {
    final color = switch (d) {
      DiseaseStatus.healthy => AppColors.success,
      DiseaseStatus.observation => AppColors.warning,
      DiseaseStatus.infected => AppColors.danger,
      DiseaseStatus.recovering => AppColors.info,
    };
    return StatusPill(label: d.label, color: color, icon: Icons.healing_outlined);
  }

  factory StatusPill.visit(VisitStatus s) {
    final color = switch (s) {
      VisitStatus.planned => AppColors.info,
      VisitStatus.inProgress => AppColors.warning,
      VisitStatus.completed => AppColors.success,
      VisitStatus.cancelled => AppColors.textMuted,
    };
    return StatusPill(label: s.label, color: color);
  }
}
