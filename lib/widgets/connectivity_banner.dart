import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/providers.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Top-of-shell offline indicator. Shows when connectivity drops, hides on
/// reconnect. Stays out of the way when online.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityStreamProvider).valueOrNull ?? true;
    if (online) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: AppColors.warningSoft,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 18, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              "You're offline — changes will sync when the connection returns.",
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 240.ms);
  }
}
