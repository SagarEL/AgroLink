/// In-memory summary used by the dashboard & analytics screens. Aggregated
/// client-side from streams; for >10k records, switch to a server-side daily
/// rollup in `analytics/{yyyy_MM}`.
class AnalyticsSummary {
  final int totalFarmers;
  final int totalPlots;
  final int totalVisits;
  final int upcomingVisits;
  final int criticalCases;
  final int monthlyVisits;
  final double monthlyRevenue;
  final Map<String, int> visitsByMonth;
  final Map<String, double> revenueByMonth;
  final Map<String, int> diseaseTrend;
  final Map<String, int> villageStats;

  const AnalyticsSummary({
    required this.totalFarmers,
    required this.totalPlots,
    required this.totalVisits,
    required this.upcomingVisits,
    required this.criticalCases,
    required this.monthlyVisits,
    required this.monthlyRevenue,
    required this.visitsByMonth,
    required this.revenueByMonth,
    required this.diseaseTrend,
    required this.villageStats,
  });

  factory AnalyticsSummary.empty() => const AnalyticsSummary(
        totalFarmers: 0,
        totalPlots: 0,
        totalVisits: 0,
        upcomingVisits: 0,
        criticalCases: 0,
        monthlyVisits: 0,
        monthlyRevenue: 0,
        visitsByMonth: {},
        revenueByMonth: {},
        diseaseTrend: {},
        villageStats: {},
      );
}
