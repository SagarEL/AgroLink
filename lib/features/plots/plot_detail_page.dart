import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/plot.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/surface_card.dart';
import '../farmers/farmer_repository.dart';
import '../visits/visit_repository.dart';
import 'plot_repository.dart';

class PlotDetailPage extends ConsumerWidget {
  const PlotDetailPage({super.key, required this.plotId});
  final String plotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plot = ref.watch(plotByIdProvider(plotId));
    return Scaffold(
      body: plot.when(
        loading: () => const SkeletonList(),
        error: (e, _) => ErrorRetry(message: '$e'),
        data: (p) {
          if (p == null) return const EmptyState(title: 'Plot not found');
          return _Body(plot: p);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('${AppRoutes.visits}/new?plotId=$plotId'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log visit'),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.plot});
  final Plot plot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmer = ref.watch(farmerByIdProvider(plot.farmerId));
    final visits = ref.watch(visitsForPlotProvider(plot.id));
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      children: [
        _Hero(plot: plot, farmerName: farmer.valueOrNull?.name),
        const SizedBox(height: AppSpacing.lg),
        context.isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _Photos(images: plot.images)),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: _DetailsCard(plot: plot)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Photos(images: plot.images),
                  const SizedBox(height: AppSpacing.lg),
                  _DetailsCard(plot: plot),
                ],
              ),
        const SizedBox(height: AppSpacing.lg),
        _VisitHistory(visits: visits),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.plot, this.farmerName});
  final Plot plot;
  final String? farmerName;
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              gradient: LinearGradient(
                colors: plot.cropType.toLowerCase().contains('pome')
                    ? const [Color(0xFFC83E5C), AppColors.pomegranate]
                    : const [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plot.label,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (farmerName != null)
                  Text('Owned by $farmerName', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusPill.disease(plot.diseaseStatus),
                    StatusPill.priority(plot.priorityLevel),
                    StatusPill(label: '${plot.acreage} acres', color: AppColors.primary, icon: Icons.straighten_rounded),
                    if (plot.nextVisitAt != null)
                      StatusPill(
                        label: 'Next ${Formatters.relative(plot.nextVisitAt!)}',
                        color: AppColors.warning,
                        icon: Icons.upcoming_outlined,
                      ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go('${AppRoutes.plots}/${plot.id}/edit'),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.plot});
  final Plot plot;
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _kv(context, 'Crop', plot.cropType),
          _kv(context, 'Variety', plot.variety ?? '—'),
          _kv(context, 'Acreage', '${plot.acreage} acres'),
          _kv(context, 'Planting date', Formatters.date(plot.plantingDate)),
          _kv(context, 'Last visit', plot.lastVisitAt == null ? '—' : Formatters.relative(plot.lastVisitAt!)),
          _kv(context, 'Next visit', plot.nextVisitAt == null ? '—' : Formatters.relative(plot.nextVisitAt!)),
          if (plot.notes != null && plot.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Notes', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(plot.notes!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(k, style: Theme.of(context).textTheme.labelSmall),
          ),
          Expanded(child: Text(v, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _Photos extends StatelessWidget {
  const _Photos({required this.images});
  final List<String> images;
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Photos'),
          const SizedBox(height: AppSpacing.md),
          if (images.isEmpty)
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const EmptyState(
                icon: Icons.image_outlined,
                title: 'No photos yet',
                subtitle: 'Photos from visits will appear here.',
              ),
            )
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: context.responsive(mobile: 2, tablet: 3, desktop: 4),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                for (final url in images)
                  GestureDetector(
                    onTap: () => _openPreview(context, url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Skeleton(height: 100),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceMuted,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _openPreview(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: AppColors.overlay,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        backgroundColor: Colors.black,
        child: SizedBox(
          height: 600,
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(url),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class _VisitHistory extends StatelessWidget {
  const _VisitHistory({required this.visits});
  final AsyncValue visits;
  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Visit history', subtitle: 'All recorded treatments for this plot'),
          const SizedBox(height: AppSpacing.md),
          visits.when(
            loading: () => const SkeletonList(count: 2),
            error: (e, _) => ErrorRetry(message: '$e'),
            data: (list) {
              if ((list as List).isEmpty) {
                return const EmptyState(
                  icon: Icons.history_outlined,
                  title: 'No visits yet',
                );
              }
              return Column(
                children: [
                  for (var i = 0; i < list.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (i != list.length - 1)
                                Container(width: 2, height: 56, color: AppColors.border),
                            ],
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: InkWell(
                              onTap: () => context.go('${AppRoutes.visits}/${list[i].id}'),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(Formatters.date(list[i].visitDate),
                                        style: Theme.of(context).textTheme.titleSmall),
                                    if (list[i].diseasesObserved.isNotEmpty)
                                      Text(
                                        list[i].diseasesObserved.join(', '),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    if (list[i].notes != null && list[i].notes!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          list[i].notes!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
