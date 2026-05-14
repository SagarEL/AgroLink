import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/utils/responsive.dart';
import 'package:agrolink/core/utils/helpers.dart';
import 'package:agrolink/services/firestore_service.dart';
import 'package:agrolink/models/visit_model.dart';
import 'package:agrolink/widgets/empty_state.dart';
import 'package:agrolink/widgets/shimmer_loading.dart';

final visitsStreamProvider = StreamProvider<List<VisitModel>>((ref) {
  return ref.read(firestoreServiceProvider).streamVisits();
});

class VisitsPage extends ConsumerStatefulWidget {
  const VisitsPage({super.key});
  @override
  ConsumerState<VisitsPage> createState() => _VisitsPageState();
}

class _VisitsPageState extends ConsumerState<VisitsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _filter = ['all', 'scheduled', 'completed', 'critical'][_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visitsAsync = ref.watch(visitsStreamProvider);
    final padding = Responsive.contentPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Scheduled'),
            Tab(text: 'Completed'),
            Tab(text: 'Critical'),
          ],
        ),
      ),
      body: visitsAsync.when(
        loading: () => ListView.builder(
          padding: padding, itemCount: 5,
          itemBuilder: (_, __) => const Padding(padding: EdgeInsets.only(bottom: 12), child: ShimmerCard()),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (visits) {
          var filtered = visits;
          if (_filter == 'scheduled') filtered = visits.where((v) => v.isScheduled).toList();
          if (_filter == 'completed') filtered = visits.where((v) => v.isCompleted).toList();
          if (_filter == 'critical') filtered = visits.where((v) => v.isCritical).toList();

          if (filtered.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.assignment_outlined,
              title: 'No Visits Found',
              subtitle: 'Create a new visit to get started',
              actionLabel: 'New Visit',
              onAction: () => context.go('/visits/add'),
            );
          }

          return ListView.builder(
            padding: padding,
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _VisitCard(visit: filtered[index])
                  .animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.05);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/visits/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Visit'),
      ).animate().scale(delay: 300.ms, duration: 300.ms, curve: Curves.elasticOut),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final VisitModel visit;
  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: AppHelpers.severityColor(visit.severity), width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
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
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppHelpers.severityColor(visit.severity).withValues(alpha: 0.1),
                      child: Icon(Icons.agriculture_rounded,
                        color: AppHelpers.severityColor(visit.severity), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(visit.farmerName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          Text(visit.village ?? '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppHelpers.visitStatusColor(visit.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppHelpers.visitStatusIcon(visit.status),
                            size: 14, color: AppHelpers.visitStatusColor(visit.status)),
                          const SizedBox(width: 4),
                          Text(visit.status.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                              color: AppHelpers.visitStatusColor(visit.status))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.textTertiary),
                    const SizedBox(width: 6),
                    Text(AppHelpers.formatDate(visit.visitDate),
                      style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppHelpers.severityColor(visit.severity).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(visit.severity.toUpperCase(),
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                          color: AppHelpers.severityColor(visit.severity))),
                    ),
                    if (visit.followUpRequired) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.repeat_rounded, size: 14, color: AppTheme.warning),
                      const SizedBox(width: 2),
                      Text('Follow-up', style: TextStyle(fontSize: 10, color: AppTheme.warning, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
                if (visit.diseaseObserved.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6, runSpacing: 4,
                    children: visit.diseaseObserved.map((d) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.15)),
                      ),
                      child: Text(d, style: const TextStyle(fontSize: 10, color: AppTheme.error)),
                    )).toList(),
                  ),
                ],
                if (visit.photos.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.photo_library_outlined, size: 14, color: AppTheme.textTertiary),
                      const SizedBox(width: 4),
                      Text('${visit.photos.length} photos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
