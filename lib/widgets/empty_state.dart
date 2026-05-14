import 'package:flutter/material.dart';
import 'package:agrolink/core/theme/app_theme.dart';

/// Empty state widget for when no data is available
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: AppTheme.primaryGreen.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 24),
            Text(title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textTertiary),
              textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
