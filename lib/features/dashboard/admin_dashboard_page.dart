import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/analytics_summary.dart';
import '../../models/visit.dart';
import '../../widgets/avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/kpi_tile.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/surface_card.dart';
import '../analytics/analytics_provider.dart';
import '../auth/auth_controller.dart';
import '../visits/visit_repository.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) return const SkeletonList();
    final summary = ref.watch(analyticsSummaryProvider(user.uid));
    final today = DateTime.now();
    final todayVisits = ref.watch(visitsForDateProvider(today));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(analyticsSummaryProvider),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        children: [
          _Header(name: user.name),
          const SizedBox(height: AppSpacing.xxl),
          summary.when(
            loading: () => const _KpiSkeletonRow(),
            error: (e, _) => ErrorRetry(message: '$e'),
            data: (s) => _KpiGrid(summary: s),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _ChartsRow(summary: summary),
          const SizedBox(height: AppSpacing.xxl),
          context.isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _TodayVisits(visits: todayVisits)),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: _DiseaseTrend(summary: summary)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TodayVisits(visits: todayVisits),
                    const SizedBox(height: AppSpacing.lg),
                    _DiseaseTrend(summary: summary),
                  ],
                ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final greeting = _greet();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${name.split(' ').first} 👋',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
              ).animate().fadeIn(duration: 240.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: AppSpacing.xs),
              Text(
                Formatters.dateTime(DateTime.now()),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        if (context.isDesktop)
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.routes),
            icon: const Icon(Icons.route_rounded, size: 18),
            label: const Text("Plan tomorrow's route"),
          ),
      ],
    );
  }

  String _greet() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _KpiSkeletonRow extends StatelessWidget {
  const _KpiSkeletonRow();
  @override
  Widget build(BuildContext context) {
    final cols = context.responsive(mobile: 2, tablet: 3, desktop: 4, wide: 6);
    return GridView.count(
      crossAxisCount: cols,
      crossAxisSpacing: AppSpacing.lg,
      mainAxisSpacing: AppSpacing.lg,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(6, (_) => const SkeletonCard()),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.summary});
  final AnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final cols = context.responsive(mobile: 2, tablet: 3, desktop: 4, wide: 6);
    final tiles = <Widget>[
      KpiTile(
        label: 'Total farmers',
        value: Formatters.number(summary.totalFarmers),
        icon: Icons.people_alt_rounded,
        iconColor: AppColors.primary,
        iconBg: AppColors.primarySoft,
        onTap: () => context.go(AppRoutes.farmers),
      ),
      KpiTile(
        label: 'Total visits',
        value: Formatters.number(summary.totalVisits),
        icon: Icons.event_note_rounded,
        iconColor: AppColors.tertiary,
        iconBg: AppColors.tertiarySoft,
        onTap: () => context.go(AppRoutes.visits),
      ),
      KpiTile(
        label: 'Upcoming visits',
        value: Formatters.number(summary.upcomingVisits),
        icon: Icons.upcoming_rounded,
        iconColor: AppColors.warning,
        iconBg: AppColors.warningSoft,
      ),
      KpiTile(
        label: 'Critical cases',
        value: Formatters.number(summary.criticalCases),
        icon: Icons.priority_high_rounded,
        iconColor: AppColors.danger,
        iconBg: AppColors.dangerSoft,
      ),
      KpiTile(
        label: 'Monthly visits',
        value: Formatters.number(summary.monthlyVisits),
        icon: Icons.trending_up_rounded,
        iconColor: AppColors.success,
        iconBg: AppColors.successSoft,
        delta: '+${(summary.monthlyVisits * 0.08).toStringAsFixed(0)}%',
        deltaIsPositive: true,
      ),
      KpiTile(
        label: 'Monthly revenue',
        value: Formatters.currency(summary.monthlyRevenue),
        icon: Icons.currency_rupee_rounded,
        iconColor: AppColors.pomegranate,
        iconBg: const Color(0xFFFCE7EA),
      ),
    ];
    return GridView.count(
      crossAxisCount: cols,
      crossAxisSpacing: AppSpacing.lg,
      mainAxisSpacing: AppSpacing.lg,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < tiles.length; i++)
          tiles[i].animate().fadeIn(delay: (i * 60).ms, duration: 280.ms).slideY(begin: 0.06),
      ],
    );
  }
}

class _ChartsRow extends StatelessWidget {
  const _ChartsRow({required this.summary});
  final AsyncValue<AnalyticsSummary> summary;

  @override
  Widget build(BuildContext context) {
    return summary.when(
      loading: () => const SkeletonCard(height: 280),
      error: (e, _) => ErrorRetry(message: '$e'),
      data: (s) => context.isDesktop
          ? Row(
              children: [
                Expanded(child: _VisitsChartCard(data: s.visitsByMonth)),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: _RevenueChartCard(data: s.revenueByMonth)),
              ],
            )
          : Column(
              children: [
                _VisitsChartCard(data: s.visitsByMonth),
                const SizedBox(height: AppSpacing.lg),
                _RevenueChartCard(data: s.revenueByMonth),
              ],
            ),
    );
  }
}

class _VisitsChartCard extends StatelessWidget {
  const _VisitsChartCard({required this.data});
  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxY = (entries.map((e) => e.value).fold<int>(0, (a, b) => a > b ? a : b) + 4).toDouble();
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Visits over time', subtitle: 'Last 6 months'),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: AppColors.border, strokeWidth: 1, dashArray: [3, 4]),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(entries[i].key, style: Theme.of(context).textTheme.labelSmall),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (var i = 0; i < entries.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: entries[i].value.toDouble(),
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          width: 18,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueChartCard extends StatelessWidget {
  const _RevenueChartCard({required this.data});
  final Map<String, double> data;

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxY = (entries.map((e) => e.value).fold<double>(0, (a, b) => a > b ? a : b) * 1.2);
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Revenue trend', subtitle: 'Last 6 months'),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY == 0 ? 1000 : maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY == 0 ? 1000 : maxY) / 4,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: AppColors.border, strokeWidth: 1, dashArray: [3, 4]),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (v, _) => Text(
                        v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(entries[i].key, style: Theme.of(context).textTheme.labelSmall),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    curveSmoothness: 0.32,
                    color: AppColors.pomegranate,
                    barWidth: 3,
                    spots: [
                      for (var i = 0; i < entries.length; i++) FlSpot(i.toDouble(), entries[i].value),
                    ],
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.pomegranate.withValues(alpha: 0.25),
                          AppColors.pomegranate.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayVisits extends StatelessWidget {
  const _TodayVisits({required this.visits});
  final AsyncValue<List<Visit>> visits;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: "Today's visits",
            subtitle: Formatters.date(DateTime.now()),
            trailing: TextButton(
              onPressed: () => context.go(AppRoutes.visits),
              child: const Text('See all'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          visits.when(
            loading: () => const SkeletonList(count: 3),
            error: (e, _) => ErrorRetry(message: '$e'),
            data: (list) {
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: EmptyState(
                    icon: Icons.event_available_outlined,
                    title: 'No visits scheduled today',
                    subtitle: 'Plan a route to schedule visits across nearby farms.',
                  ),
                );
              }
              return Column(
                children: [
                  for (final v in list.take(6))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: _VisitRow(visit: v),
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

class _VisitRow extends StatelessWidget {
  const _VisitRow({required this.visit});
  final Visit visit;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => context.go('${AppRoutes.visits}/${visit.id}'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Avatar(name: visit.farmerName ?? 'Farmer', size: 42),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visit.farmerName ?? 'Unknown farmer',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '${visit.plotLabel ?? 'Plot'} · ${visit.village ?? '—'} · ${Formatters.relative(visit.visitDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            StatusPill.priority(visit.severity),
          ],
        ),
      ),
    );
  }
}

class _DiseaseTrend extends StatelessWidget {
  const _DiseaseTrend({required this.summary});
  final AsyncValue<AnalyticsSummary> summary;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Top diseases', subtitle: 'Across all monitored plots'),
          const SizedBox(height: AppSpacing.md),
          summary.when(
            loading: () => const SkeletonList(count: 4),
            error: (e, _) => ErrorRetry(message: '$e'),
            data: (s) {
              final entries = s.diseaseTrend.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              if (entries.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: EmptyState(
                    icon: Icons.health_and_safety_outlined,
                    title: 'No disease records yet',
                    subtitle: 'They’ll appear here as visits are logged.',
                  ),
                );
              }
              final max = entries.first.value;
              return Column(
                children: [
                  for (final e in entries.take(6))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(e.key, style: Theme.of(context).textTheme.titleSmall),
                              ),
                              Text('${e.value}',
                                  style: Theme.of(context).textTheme.labelMedium),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: max == 0 ? 0 : e.value / max,
                              minHeight: 6,
                              backgroundColor: AppColors.surfaceMuted,
                              valueColor: const AlwaysStoppedAnimation(AppColors.pomegranate),
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
