import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/analytics_summary.dart';
import '../../models/visit.dart';
import '../farmers/farmer_repository.dart';
import '../plots/plot_repository.dart';
import '../visits/visit_repository.dart';

/// Client-side analytics rollup. Sufficient for hundreds of visits per month;
/// for higher volumes, replace with a Cloud Functions write-time aggregation
/// into `analytics/{yyyy_MM}` documents.
final analyticsSummaryProvider =
    Provider.family<AsyncValue<AnalyticsSummary>, String>((ref, doctorId) {
  final farmers = ref.watch(farmersStreamProvider(const FarmerFilter(limit: 1000)));
  final plots = ref.watch(allPlotsProvider);
  final visits = ref.watch(visitsForDoctorProvider(doctorId));

  if (farmers.isLoading || plots.isLoading || visits.isLoading) {
    return const AsyncLoading();
  }
  if (farmers.hasError) return AsyncError(farmers.error!, StackTrace.current);
  if (plots.hasError) return AsyncError(plots.error!, StackTrace.current);
  if (visits.hasError) return AsyncError(visits.error!, StackTrace.current);

  final allVisits = visits.value ?? const <Visit>[];
  final now = DateTime.now();
  final monthFmt = DateFormat('MMM');

  final visitsByMonth = <String, int>{};
  final revenueByMonth = <String, double>{};
  for (var i = 5; i >= 0; i--) {
    final d = DateTime(now.year, now.month - i, 1);
    final k = monthFmt.format(d);
    visitsByMonth[k] = 0;
    revenueByMonth[k] = 0;
  }
  var monthlyVisits = 0;
  var monthlyRevenue = 0.0;
  var critical = 0;
  var upcoming = 0;
  final diseaseTrend = <String, int>{};
  final villageStats = <String, int>{};

  for (final v in allVisits) {
    final d = v.visitDate;
    final k = monthFmt.format(d);
    if (visitsByMonth.containsKey(k)) {
      visitsByMonth[k] = (visitsByMonth[k] ?? 0) + 1;
      revenueByMonth[k] = (revenueByMonth[k] ?? 0) + (v.feeCharged ?? 0);
    }
    if (d.year == now.year && d.month == now.month) {
      monthlyVisits += 1;
      monthlyRevenue += v.feeCharged ?? 0;
    }
    if (v.severity.key == 'critical' || v.severity.key == 'high') critical += 1;
    if (v.status == VisitStatus.planned && v.visitDate.isAfter(now)) upcoming += 1;
    for (final disease in v.diseasesObserved) {
      diseaseTrend[disease] = (diseaseTrend[disease] ?? 0) + 1;
    }
    if (v.village != null && v.village!.isNotEmpty) {
      villageStats[v.village!] = (villageStats[v.village!] ?? 0) + 1;
    }
  }

  return AsyncData(AnalyticsSummary(
    totalFarmers: farmers.value!.length,
    totalPlots: plots.value!.length,
    totalVisits: allVisits.length,
    upcomingVisits: upcoming,
    criticalCases: critical,
    monthlyVisits: monthlyVisits,
    monthlyRevenue: monthlyRevenue,
    visitsByMonth: visitsByMonth,
    revenueByMonth: revenueByMonth,
    diseaseTrend: diseaseTrend,
    villageStats: villageStats,
  ));
});
