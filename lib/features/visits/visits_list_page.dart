import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/visit.dart';
import '../../widgets/avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/surface_card.dart';
import '../auth/auth_controller.dart';
import 'visit_repository.dart';

class VisitsListPage extends ConsumerStatefulWidget {
  const VisitsListPage({super.key});
  @override
  ConsumerState<VisitsListPage> createState() => _VisitsListPageState();
}

class _VisitsListPageState extends ConsumerState<VisitsListPage> {
  VisitStatus? _statusFilter;
  bool _onlyCritical = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) return const SkeletonList();
    final visits = ref.watch(visitsForDoctorProvider(user.uid));
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('${AppRoutes.visits}/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log visit'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.md,
            ),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _statusFilter == null,
                  onSelected: (_) => setState(() => _statusFilter = null),
                ),
                for (final s in VisitStatus.values)
                  FilterChip(
                    label: Text(s.label),
                    selected: _statusFilter == s,
                    onSelected: (_) => setState(() => _statusFilter = s),
                  ),
                const VerticalDivider(),
                FilterChip(
                  avatar: const Icon(Icons.priority_high_rounded, size: 16, color: AppColors.danger),
                  label: const Text('Critical only'),
                  selected: _onlyCritical,
                  onSelected: (v) => setState(() => _onlyCritical = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: visits.when(
              loading: () => const SkeletonList(),
              error: (e, _) => ErrorRetry(message: '$e'),
              data: (list) {
                final filtered = list.where((v) {
                  if (_statusFilter != null && v.status != _statusFilter) return false;
                  if (_onlyCritical && v.severity.key != 'critical' && v.severity.key != 'high') return false;
                  return true;
                }).toList();
                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.event_note_outlined,
                    title: 'No visits match these filters',
                  );
                }
                final groups = _groupByDate(filtered);
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  children: [
                    for (final entry in groups.entries) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                      for (final v in entry.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _VisitTile(visit: v),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Visit>> _groupByDate(List<Visit> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final map = <String, List<Visit>>{};
    for (final v in list) {
      final d = DateTime(v.visitDate.year, v.visitDate.month, v.visitDate.day);
      String key;
      if (d == today) {
        key = 'Today';
      } else if (d == tomorrow) {
        key = 'Tomorrow';
      } else if (d.isBefore(today)) {
        key = Formatters.date(v.visitDate);
      } else {
        key = Formatters.date(v.visitDate);
      }
      map.putIfAbsent(key, () => []).add(v);
    }
    return map;
  }
}

class _VisitTile extends StatelessWidget {
  const _VisitTile({required this.visit});
  final Visit visit;
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: () => context.go('${AppRoutes.visits}/${visit.id}'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Avatar(name: visit.farmerName ?? 'Farmer', size: 48),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.farmerName ?? 'Unknown farmer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${visit.plotLabel ?? "Plot"} · ${visit.village ?? "—"}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (visit.diseasesObserved.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Disease: ${visit.diseasesObserved.join(", ")}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.pomegranate),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.dateTime(visit.visitDate), style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusPill.priority(visit.severity),
                  const SizedBox(width: 6),
                  StatusPill.visit(visit.status),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
