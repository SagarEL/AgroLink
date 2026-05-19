import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/utils/responsive.dart';
import 'package:agrolink/core/utils/pdf_generator.dart';
import 'package:agrolink/widgets/stat_card.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.contentPadding(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              PdfGenerator.generateAndPrintAnalyticsReport(
                month: 'April 2024',
                totalRevenue: 428500,
                totalVisits: 156,
                newFarmers: 12,
              );
            },
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Export PDF'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Row(
              children: ['This Month', 'Last 3 Months', '6 Months', 'Year'].map((p) {
                final selected = p == 'This Month';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p),
                    selected: selected,
                    selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(),
            const SizedBox(height: 24),

            // Summary stats
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: Responsive.value(context, mobile: 2, tablet: 3, desktop: 4),
              crossAxisSpacing: 16, mainAxisSpacing: 16,
              childAspectRatio: Responsive.value(context, mobile: 1.4, tablet: 1.5, desktop: 1.6),
              children: [
                StatCard(title: 'Total Revenue', value: '₹4,28,500', icon: Icons.currency_rupee_rounded,
                  color: AppTheme.success, trend: '+15.2%'),
                StatCard(title: 'Visits Done', value: '156', icon: Icons.assignment_turned_in_rounded,
                  color: AppTheme.info, trend: '+23%'),
                StatCard(title: 'New Farmers', value: '12', icon: Icons.person_add_rounded,
                  color: AppTheme.primaryGreen, trend: '+8'),
                StatCard(title: 'Avg per Visit', value: '₹2,750', icon: Icons.trending_up_rounded,
                  color: AppTheme.accentAmber, trend: '+5%'),
              ].asMap().entries.map((e) =>
                e.value.animate(delay: (e.key * 80).ms).fadeIn().slideY(begin: 0.2)).toList(),
            ),
            const SizedBox(height: 24),

            // Revenue chart
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _revenueChart(context)),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: _villageDistribution(context)),
                    ],
                  )
                : Column(
                    children: [
                      _revenueChart(context),
                      const SizedBox(height: 20),
                      _villageDistribution(context),
                    ],
                  ),
            const SizedBox(height: 24),

            // Disease trends
            _diseaseTrends(context),
            const SizedBox(height: 24),

            // Top farmers table
            _topFarmersTable(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _revenueChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue Trend', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, drawVerticalLine: false,
                  horizontalInterval: 100000,
                  getDrawingHorizontalLine: (v) => FlLine(color: AppTheme.dividerColor, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 45,
                    getTitlesWidget: (v, _) => Text('${(v / 1000).toInt()}K',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                    getTitlesWidget: (v, _) {
                      const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                      return Text(m[v.toInt() % m.length], style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary));
                    })),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 320000), FlSpot(1, 380000), FlSpot(2, 290000),
                      FlSpot(3, 420000), FlSpot(4, 460000), FlSpot(5, 428500)],
                    isCurved: true,
                    color: AppTheme.primaryGreen,
                    barWidth: 3,
                    dotData: FlDotData(show: true, getDotPainter: (s, _, __, ___) =>
                      FlDotCirclePainter(radius: 4, color: AppTheme.primaryGreen,
                        strokeWidth: 2, strokeColor: Colors.white)),
                    belowBarData: BarAreaData(show: true,
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [AppTheme.primaryGreen.withValues(alpha: 0.2), AppTheme.primaryGreen.withValues(alpha: 0.0)])),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _villageDistribution(BuildContext context) {
    final villages = [
      {'name': 'Shirur', 'count': 85, 'color': AppTheme.primaryGreen},
      {'name': 'Baramati', 'count': 62, 'color': AppTheme.info},
      {'name': 'Indapur', 'count': 48, 'color': AppTheme.accentAmber},
      {'name': 'Daund', 'count': 35, 'color': AppTheme.earthBrown},
      {'name': 'Other', 'count': 18, 'color': AppTheme.textTertiary},
    ];
    final total = villages.fold<int>(0, (s, v) => s + (v['count'] as int));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Village Distribution', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          ...villages.asMap().entries.map((e) {
            final v = e.value;
            final pct = (v['count'] as int) / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(v['name'] as String, style: Theme.of(context).textTheme.bodyMedium),
                      Text('${v['count']} farmers', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: (v['color'] as Color).withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(v['color'] as Color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ).animate(delay: (e.key * 80 + 400).ms).fadeIn().slideX(begin: 0.1);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _diseaseTrends(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Disease Trends', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 50,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40,
                    getTitlesWidget: (v, _) {
                      const d = ['Blight', 'Wilt', 'Mildew', 'Borer', 'Spot'];
                      return Padding(padding: const EdgeInsets.only(top: 8),
                        child: Text(d[v.toInt() % d.length], style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary)));
                    })),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10,
                  getDrawingHorizontalLine: (v) => FlLine(color: AppTheme.dividerColor, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _bar(0, 42, AppTheme.error),
                  _bar(1, 28, AppTheme.accentOrange),
                  _bar(2, 22, AppTheme.accentAmber),
                  _bar(3, 15, AppTheme.info),
                  _bar(4, 12, AppTheme.primaryLight),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: y, color: color, width: 24,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
    ]);
  }

  Widget _topFarmersTable(BuildContext context) {
    final farmers = [
      ['Ramesh Patil', 'Shirur', '24', '₹66,000'],
      ['Sunil Jadhav', 'Baramati', '18', '₹49,500'],
      ['Vijay More', 'Indapur', '15', '₹41,250'],
      ['Anil Shinde', 'Shirur', '12', '₹33,000'],
      ['Prakash Pawar', 'Daund', '10', '₹27,500'],
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Farmers by Visits', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1.2)},
            children: [
              TableRow(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.dividerColor))),
                children: ['Farmer', 'Village', 'Visits', 'Revenue'].map((h) =>
                  Padding(padding: const EdgeInsets.only(bottom: 12),
                    child: Text(h, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.textTertiary)))).toList(),
              ),
              ...farmers.asMap().entries.map((e) => TableRow(
                children: e.value.map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(c, style: Theme.of(context).textTheme.bodyMedium),
                )).toList(),
              )),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }
}
