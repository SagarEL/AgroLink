import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/utils/responsive.dart';
import 'package:agrolink/core/utils/helpers.dart';
import 'package:agrolink/services/firestore_service.dart';
import 'package:agrolink/widgets/stat_card.dart';
import 'package:agrolink/widgets/shimmer_loading.dart';
import 'package:agrolink/features/auth/auth_controller.dart';
import 'package:agrolink/features/analytics/analytics_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.contentPadding(context);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard'),
            Text('Welcome back, ${user?.name.split(' ').first ?? "Doctor"}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/notifications'),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryGreen,
              child: Icon(user?.name.isNotEmpty ?? false ? 
                null : Icons.person, 
                color: Colors.white, 
                size: 20),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            ref.invalidate(analyticsSummaryProvider(user.uid));
          }
        },
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Stat Cards ──────────────────────────────
              user != null
                  ? _buildStatCards(context, ref, user.uid)
                  : const ShimmerLoading(height: 100),
              const SizedBox(height: 24),

              // ── Charts Row ──────────────────────────────
              Responsive.isDesktop(context)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildVisitsChart(context)),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: _buildDiseaseChart(context)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildVisitsChart(context),
                        const SizedBox(height: 20),
                        _buildDiseaseChart(context),
                      ],
                    ),
              const SizedBox(height: 24),

              // ── Today's Schedule & Quick Actions ────────
              Responsive.isDesktop(context)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildTodaysSchedule(context)),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: _buildQuickActions(context)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildTodaysSchedule(context),
                        const SizedBox(height: 20),
                        _buildQuickActions(context),
                      ],
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: Responsive.isMobile(context)
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/visits/add'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Visit'),
            ).animate().scale(delay: 500.ms, duration: 300.ms, curve: Curves.elasticOut)
          : null,
    );
  }

  Widget _buildStatCards(BuildContext context, WidgetRef ref, String userId) {
    final columns = Responsive.value(context, mobile: 2, tablet: 3, desktop: 4, wide: 6);
    final summary = ref.watch(analyticsSummaryProvider(userId));

    return summary.when(
      loading: () => const ShimmerLoading(height: 120),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading stats: $err'),
        ),
      ),
      data: (analytics) {
        final stats = [
          _StatData('Total Farmers', analytics.totalFarmers.toString(), Icons.people_rounded, AppTheme.primaryGreen, ''),
          _StatData('Total Plots', analytics.totalPlots.toString(), Icons.grass_rounded, AppTheme.accentAmber, ''),
          _StatData('Total Visits', analytics.totalVisits.toString(), Icons.assignment_rounded, AppTheme.info, ''),
          _StatData('This Month', analytics.monthlyVisits.toString(), Icons.calendar_today_rounded, AppTheme.primaryLight, ''),
          _StatData('Critical', analytics.criticalCases.toString(), Icons.warning_rounded, AppTheme.error, ''),
          _StatData('Upcoming', analytics.upcomingVisits.toString(), Icons.route_rounded, AppTheme.earthBrown, ''),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: Responsive.value(context, mobile: 1.4, tablet: 1.5, desktop: 1.6),
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final s = stats[index];
            return StatCard(
              title: s.title,
              value: s.value,
              icon: s.icon,
              color: s.color,
              trend: s.trend,
            ).animate(delay: (index * 80).ms).fadeIn().slideY(begin: 0.2);
          },
        );
      },
    );
  }

  Widget _buildVisitsChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Visits', style: Theme.of(context).textTheme.titleMedium),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Last 6 months',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primaryGreen)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 200,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 32,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary))),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true,
                      getTitlesWidget: (v, _) {
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                        return Text(months[v.toInt() % months.length],
                          style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary));
                      }),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppTheme.dividerColor.withValues(alpha: 0.5), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 120),
                  _makeBarGroup(1, 145),
                  _makeBarGroup(2, 98),
                  _makeBarGroup(3, 167),
                  _makeBarGroup(4, 182),
                  _makeBarGroup(5, 156),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: y,
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [AppTheme.primaryGreen, AppTheme.primaryLight],
        ),
        width: 20,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    ]);
  }

  Widget _buildDiseaseChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Disease Distribution', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(value: 35, color: AppTheme.error, title: 'Blight\n35%',
                    radius: 55, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                  PieChartSectionData(value: 25, color: AppTheme.warning, title: 'Wilt\n25%',
                    radius: 55, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                  PieChartSectionData(value: 20, color: AppTheme.info, title: 'Mildew\n20%',
                    radius: 55, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                  PieChartSectionData(value: 20, color: AppTheme.primaryLight, title: 'Other\n20%',
                    radius: 55, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildTodaysSchedule(BuildContext context) {
    final visits = [
      {'farmer': 'Ramesh Patil', 'village': 'Shirur', 'time': '9:00 AM', 'severity': 'high', 'crop': 'Pomegranate'},
      {'farmer': 'Sunil Jadhav', 'village': 'Baramati', 'time': '11:00 AM', 'severity': 'medium', 'crop': 'Pomegranate'},
      {'farmer': 'Vijay More', 'village': 'Indapur', 'time': '2:00 PM', 'severity': 'low', 'crop': 'Grape'},
      {'farmer': 'Anil Shinde', 'village': 'Shirur', 'time': '4:00 PM', 'severity': 'critical', 'crop': 'Pomegranate'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today's Schedule", style: Theme.of(context).textTheme.titleMedium),
              TextButton(onPressed: () => context.go('/visits'), child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          ...visits.asMap().entries.map((entry) {
            final i = entry.key;
            final v = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(left: BorderSide(
                    color: AppHelpers.severityColor(v['severity']!), width: 3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppHelpers.severityColor(v['severity']!).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.agriculture_rounded,
                        color: AppHelpers.severityColor(v['severity']!), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v['farmer']!, style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text('${v['village']} • ${v['crop']}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(v['time']!, style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppHelpers.severityColor(v['severity']!).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(v['severity']!.toUpperCase(),
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                              color: AppHelpers.severityColor(v['severity']!))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate(delay: (i * 100 + 500).ms).fadeIn().slideX(begin: 0.1);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.person_add_rounded, 'label': 'Add Farmer', 'path': '/farmers/add', 'color': AppTheme.primaryGreen},
      {'icon': Icons.add_task_rounded, 'label': 'New Visit', 'path': '/visits/add', 'color': AppTheme.info},
      {'icon': Icons.route_rounded, 'label': 'Plan Route', 'path': '/routes', 'color': AppTheme.accentAmber},
      {'icon': Icons.analytics_rounded, 'label': 'Reports', 'path': '/analytics', 'color': AppTheme.earthBrown},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...actions.asMap().entries.map((entry) {
            final i = entry.key;
            final a = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.go(a['path'] as String),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (a['color'] as Color).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (a['color'] as Color).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Text(a['label'] as String, style: Theme.of(context).textTheme.titleSmall),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textTertiary),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate(delay: (i * 80 + 600).ms).fadeIn().slideX(begin: 0.15);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }
}

class _StatData {
  final String title, value, trend;
  final IconData icon;
  final Color color;
  const _StatData(this.title, this.value, this.icon, this.color, this.trend);
}
