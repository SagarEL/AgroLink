import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/utils/responsive.dart';
import 'package:agrolink/core/utils/helpers.dart';

class RoutePlannerPage extends ConsumerStatefulWidget {
  const RoutePlannerPage({super.key});
  @override
  ConsumerState<RoutePlannerPage> createState() => _RoutePlannerPageState();
}

class _RoutePlannerPageState extends ConsumerState<RoutePlannerPage> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isOptimizing = false;
  bool _isOptimized = false;

  // Sample route stops
  final List<Map<String, dynamic>> _stops = [
    {'farmer': 'Ramesh Patil', 'village': 'Shirur', 'priority': 'critical', 'time': '9:00 AM', 'distance': '0 km', 'done': false},
    {'farmer': 'Sunil Jadhav', 'village': 'Shirur', 'priority': 'high', 'time': '10:30 AM', 'distance': '3 km', 'done': false},
    {'farmer': 'Vijay More', 'village': 'Baramati', 'priority': 'medium', 'time': '12:00 PM', 'distance': '18 km', 'done': false},
    {'farmer': 'Anil Shinde', 'village': 'Baramati', 'priority': 'low', 'time': '1:30 PM', 'distance': '2 km', 'done': false},
    {'farmer': 'Prakash Pawar', 'village': 'Indapur', 'priority': 'high', 'time': '3:00 PM', 'distance': '25 km', 'done': false},
  ];

  Future<void> _optimizeRoute() async {
    setState(() => _isOptimizing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _isOptimizing = false; _isOptimized = true; });
    if (mounted) AppHelpers.showSuccess(context, 'Route optimized! Saved 12 km');
  }

  void _openInGoogleMaps() async {
    const url = 'https://www.google.com/maps/dir/Shirur/Baramati/Indapur';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.contentPadding(context);
    final completedCount = _stops.where((s) => s['done'] == true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Planner'),
        actions: [
          if (_isOptimized)
            TextButton.icon(
              onPressed: _openInGoogleMaps,
              icon: const Icon(Icons.map_rounded, size: 18),
              label: const Text('Open Maps'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Summary card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppTheme.primaryDark, AppTheme.primaryGreen],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.route_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tomorrow's Route",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white, fontWeight: FontWeight.w600)),
                            Text(AppHelpers.formatDate(_selectedDate),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem('${_stops.length}', 'Stops', Icons.pin_drop_rounded),
                      _summaryItem('48 km', 'Distance', Icons.straighten_rounded),
                      _summaryItem('4.5 hrs', 'Est. Time', Icons.access_time_rounded),
                      _summaryItem('$completedCount/${_stops.length}', 'Done', Icons.check_circle_outline_rounded),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _stops.isEmpty ? 0 : completedCount / _stops.length,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Optimize button
            if (!_isOptimized)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isOptimizing ? null : _optimizeRoute,
                  icon: _isOptimizing
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_fix_high_rounded),
                  label: Text(_isOptimizing ? 'Optimizing...' : 'Optimize Route'),
                ),
              ).animate().fadeIn(delay: 200.ms),
            if (_isOptimized) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppTheme.success),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Route Optimized!', style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.success, fontWeight: FontWeight.w600)),
                        Text('Saved 12 km by grouping villages together',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                      ],
                    )),
                    TextButton(onPressed: _openInGoogleMaps, child: const Text('Navigate')),
                  ],
                ),
              ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
            ],
            const SizedBox(height: 24),

            // Route stops timeline
            Text('Route Stops', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ..._stops.asMap().entries.map((entry) {
              final i = entry.key;
              final stop = entry.value;
              final isLast = i == _stops.length - 1;
              return _buildStopItem(context, stop, i, isLast);
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
      ],
    );
  }

  Widget _buildStopItem(BuildContext context, Map<String, dynamic> stop, int index, bool isLast) {
    final isDone = stop['done'] as bool;
    final color = AppHelpers.severityColor(stop['priority'] as String);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: isDone ? AppTheme.success : color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: isDone ? AppTheme.success : color, width: 2),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text('${index + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: AppTheme.dividerColor)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Stop card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDone ? AppTheme.success.withValues(alpha: 0.04) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDone ? AppTheme.success.withValues(alpha: 0.2) : AppTheme.dividerColor),
                boxShadow: isDone ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stop['farmer'] as String,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: isDone ? TextDecoration.lineThrough : null)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textTertiary),
                            const SizedBox(width: 3),
                            Text('${stop['village']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                            const SizedBox(width: 10),
                            Icon(Icons.access_time, size: 13, color: AppTheme.textTertiary),
                            const SizedBox(width: 3),
                            Text('${stop['time']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('+${stop['distance']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.info)),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isDone,
                    activeColor: AppTheme.success,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (v) => setState(() => stop['done'] = v),
                  ),
                ],
              ),
            ),
          ).animate(delay: (index * 80).ms).fadeIn().slideX(begin: 0.1),
        ],
      ),
    );
  }
}
