import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/utils/responsive.dart';
import 'package:agrolink/core/utils/helpers.dart';
import 'package:agrolink/services/firestore_service.dart';
import 'package:agrolink/models/plot_model.dart';
import 'package:agrolink/widgets/empty_state.dart';
import 'package:agrolink/widgets/shimmer_loading.dart';

final plotsStreamProvider = StreamProvider<List<PlotModel>>((ref) {
  return ref.read(firestoreServiceProvider).streamPlots();
});

class PlotsPage extends ConsumerStatefulWidget {
  const PlotsPage({super.key});
  @override
  ConsumerState<PlotsPage> createState() => _PlotsPageState();
}

class _PlotsPageState extends ConsumerState<PlotsPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final plotsAsync = ref.watch(plotsStreamProvider);
    final padding = Responsive.contentPadding(context);
    final columns = Responsive.value(context, mobile: 1, tablet: 2, desktop: 3);

    return Scaffold(
      appBar: AppBar(title: const Text('Plot Management')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding.horizontal / 2, vertical: 12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search plots by crop, farmer, location...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
          Expanded(
            child: plotsAsync.when(
              loading: () => GridView.builder(
                padding: padding,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.4),
                itemCount: 6,
                itemBuilder: (_, __) => const ShimmerCard(),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (plots) {
                var filtered = plots;
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered.where((p) =>
                    p.cropType.toLowerCase().contains(_searchQuery) ||
                    p.farmerName.toLowerCase().contains(_searchQuery) ||
                    p.location.toLowerCase().contains(_searchQuery)).toList();
                }
                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.grid_view_rounded,
                    title: 'No Plots Found',
                    subtitle: 'Add plots through farmer profiles',
                  );
                }
                return GridView.builder(
                  padding: padding,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns, crossAxisSpacing: 16, mainAxisSpacing: 16,
                    childAspectRatio: Responsive.value(context, mobile: 1.6, tablet: 1.4, desktop: 1.5)),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _PlotCard(plot: filtered[index])
                        .animate(delay: (index * 60).ms).fadeIn().scale(begin: const Offset(0.95, 0.95));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlotCard extends StatelessWidget {
  final PlotModel plot;
  const _PlotCard({required this.plot});

  @override
  Widget build(BuildContext context) {
    final priorityColor = AppHelpers.severityColor(plot.priorityLevel);

    return Container(
      decoration: AppTheme.glassCard,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.grass_rounded, color: AppTheme.primaryGreen, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plot.cropType, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600)),
                          Text('${plot.acreage} acres', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textTertiary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(plot.priorityLevel.toUpperCase(),
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: priorityColor)),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.textTertiary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(plot.farmerName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
                      overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textTertiary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(plot.location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
                      overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _chip('${plot.totalVisits} visits', AppTheme.info),
                    const SizedBox(width: 6),
                    _chip(plot.diseaseStatus, priorityColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
