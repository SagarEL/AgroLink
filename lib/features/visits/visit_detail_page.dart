import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/visit.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/surface_card.dart';
import 'visit_repository.dart';

class VisitDetailPage extends ConsumerWidget {
  const VisitDetailPage({super.key, required this.visitId});
  final String visitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(visitByIdProvider(visitId));
    return Scaffold(
      body: v.when(
        loading: () => const SkeletonList(),
        error: (e, _) => ErrorRetry(message: '$e'),
        data: (visit) {
          if (visit == null) return const EmptyState(title: 'Visit not found');
          return _Body(visit: visit, ref: ref);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.visit, required this.ref});
  final Visit visit;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      children: [
        SurfaceCard(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visit on ${Formatters.dateTime(visit.visitDate)}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${visit.farmerName ?? "Farmer"} · ${visit.plotLabel ?? "Plot"}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (visit.status != VisitStatus.completed)
                    FilledButton.icon(
                      onPressed: () => ref.read(visitRepositoryProvider).markComplete(visit.id),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Mark completed'),
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => context.go('${AppRoutes.visits}/${visit.id}/edit'),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusPill.visit(visit.status),
                  StatusPill.priority(visit.severity),
                  if (visit.followUpRequired)
                    const StatusPill(label: 'Follow-up', color: AppColors.warning, icon: Icons.event_repeat_outlined),
                  if (visit.nextVisitDate != null)
                    StatusPill(
                      label: 'Next ${Formatters.relative(visit.nextVisitDate!)}',
                      color: AppColors.info,
                      icon: Icons.upcoming_outlined,
                    ),
                  if (visit.feeCharged != null)
                    StatusPill(
                      label: Formatters.currency(visit.feeCharged!),
                      color: AppColors.pomegranate,
                      icon: Icons.currency_rupee_rounded,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        context.isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _FindingsCard(visit: visit)),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: _TreatmentCard(visit: visit)),
                ],
              )
            : Column(
                children: [
                  _FindingsCard(visit: visit),
                  const SizedBox(height: AppSpacing.lg),
                  _TreatmentCard(visit: visit),
                ],
              ),
        const SizedBox(height: AppSpacing.lg),
        _PhotosCard(visit: visit),
      ],
    );
  }
}

class _FindingsCard extends StatelessWidget {
  const _FindingsCard({required this.visit});
  final Visit visit;
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Findings'),
          const SizedBox(height: AppSpacing.sm),
          if (visit.diseasesObserved.isEmpty)
            Text(
              'No disease observations were recorded for this visit.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final d in visit.diseasesObserved)
                  Chip(
                    avatar: const Icon(Icons.bug_report_outlined, size: 14),
                    label: Text(d),
                  ),
              ],
            ),
          if (visit.notes != null && visit.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Notes', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(visit.notes!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.visit});
  final Visit visit;
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Treatment plan'),
          const SizedBox(height: AppSpacing.sm),
          if (visit.medicines.isEmpty)
            Text(
              'No medicines prescribed for this visit.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            Column(
              children: [
                for (final m in visit.medicines)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Icon(Icons.medication_outlined, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.name, style: Theme.of(context).textTheme.titleSmall),
                              Text(
                                '${m.dosage}${m.frequency != null ? " · ${m.frequency}" : ""}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (m.notes != null)
                                Text(m.notes!, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          if (visit.fertilizerRecommendation != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Fertilizer', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(visit.fertilizerRecommendation!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _PhotosCard extends StatelessWidget {
  const _PhotosCard({required this.visit});
  final Visit visit;
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Attachments'),
          const SizedBox(height: AppSpacing.md),
          if (visit.photos.isEmpty)
            const EmptyState(
              icon: Icons.image_outlined,
              title: 'No photos attached',
            )
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: context.responsive(mobile: 2, tablet: 3, desktop: 4),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                for (final url in visit.photos)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Skeleton(height: 100),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
