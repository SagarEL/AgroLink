import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Shimmer-based placeholders. Use for above-the-fold content while streams
/// resolve. Below-the-fold can use lighter spinners.
class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.height = 16, this.width, this.radius = 8});
  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceMuted,
      highlightColor: AppColors.surfaceAlt,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 120});
  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(height: 14, width: 80),
          SizedBox(height: 12),
          Skeleton(height: 28, width: 120),
          SizedBox(height: 12),
          Skeleton(height: 12, width: 160),
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 6});
  final int count;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemBuilder: (_, __) => const SkeletonCard(height: 86),
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemCount: count,
    );
  }
}
