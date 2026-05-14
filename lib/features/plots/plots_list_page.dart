import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/plot.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/surface_card.dart';
import 'plot_repository.dart';

class PlotsListPage extends ConsumerWidget {
  const PlotsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plots = ref.watch(allPlotsProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('${AppRoutes.plots}/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add plot'),
      ),
      body: plots.when(
        loading: () => const SkeletonList(),
        error: (e, _) => ErrorRetry(message: '$e'),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.eco_outlined,
              title: 'No plots yet',
              subtitle: 'Plots represent the actual farmland units you treat. Add the first one to get started.',
              actionLabel: 'Add plot',
              onAction: () => context.go('${AppRoutes.plots}/new'),
            );
          }
          return _Grid(list: list);
        },
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.list});
  final List<Plot> list;

  @override
  Widget build(BuildContext context) {
    final cols = context.responsive(mobile: 1, tablet: 2, desktop: 3, wide: 4);
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        mainAxisExtent: 232,
      ),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final p = list[i];
        return SurfaceCard(
          onTap: () => context.go('${AppRoutes.plots}/${p.id}'),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                  gradient: LinearGradient(
                    colors: p.cropType.toLowerCase().contains('pome')
                        ? [const Color(0xFFC83E5C), AppColors.pomegranate]
                        : [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  children: [
                    const Icon(Icons.eco_rounded, color: Colors.white),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        p.cropType,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusPill.priority(p.priorityLevel),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.label, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        '${p.acreage.toStringAsFixed(1)} acres · ${p.variety ?? "—"}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          StatusPill.disease(p.diseaseStatus),
                          const Spacer(),
                          if (p.nextVisitAt != null)
                            Text(
                              'Next ${Formatters.relative(p.nextVisitAt!)}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primaryDark,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (i * 25).ms, duration: 250.ms);
      },
    );
  }
}
