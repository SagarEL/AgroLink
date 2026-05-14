import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:agrolink/core/theme/app_theme.dart';

/// Premium stat card widget for dashboard
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend = '',
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = trend.startsWith('+');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (trend.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppTheme.success : AppTheme.error).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 12,
                        color: isPositive ? AppTheme.success : AppTheme.error,
                      ),
                      const SizedBox(width: 2),
                      Text(trend,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isPositive ? AppTheme.success : AppTheme.error,
                        )),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            )),
          const SizedBox(height: 4),
          Text(title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
            )),
        ],
      ),
    );
  }
}
