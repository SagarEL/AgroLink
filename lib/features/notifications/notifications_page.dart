import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/utils/responsive.dart';
import 'package:agrolink/core/utils/helpers.dart';
import 'package:agrolink/widgets/empty_state.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.contentPadding(context);

    // Sample notifications
    final notifications = [
      {'title': 'Follow-up Reminder', 'body': 'Ramesh Patil\'s pomegranate plot needs follow-up visit tomorrow',
        'type': 'follow_up', 'time': DateTime.now().subtract(const Duration(minutes: 30)), 'read': false},
      {'title': 'Critical Disease Alert', 'body': 'Bacterial blight detected in Shirur region - 3 farms affected',
        'type': 'critical_alert', 'time': DateTime.now().subtract(const Duration(hours: 2)), 'read': false},
      {'title': 'Route Ready', 'body': 'Tomorrow\'s route has been optimized - 5 stops, 48 km total',
        'type': 'general', 'time': DateTime.now().subtract(const Duration(hours: 5)), 'read': true},
      {'title': 'Visit Completed', 'body': 'Sunil Jadhav visit marked as completed successfully',
        'type': 'general', 'time': DateTime.now().subtract(const Duration(days: 1)), 'read': true},
      {'title': 'Missed Visit', 'body': 'Scheduled visit to Vijay More was missed yesterday',
        'type': 'missed_visit', 'time': DateTime.now().subtract(const Duration(days: 1, hours: 6)), 'read': true},
      {'title': 'Monthly Report', 'body': 'Your April analytics report is ready to view',
        'type': 'general', 'time': DateTime.now().subtract(const Duration(days: 3)), 'read': true},
    ];

    final unreadCount = notifications.where((n) => n['read'] == false).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {},
              child: const Text('Mark all read'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.notifications_off_outlined,
              title: 'No Notifications',
              subtitle: 'You\'re all caught up!',
            )
          : ListView.builder(
              padding: padding,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return _NotificationTile(
                  title: n['title'] as String,
                  body: n['body'] as String,
                  type: n['type'] as String,
                  time: n['time'] as DateTime,
                  isRead: n['read'] as bool,
                  onTap: () {},
                ).animate(delay: (index * 60).ms).fadeIn().slideX(begin: 0.05);
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title, body, type;
  final DateTime time;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.title, required this.body, required this.type,
    required this.time, required this.isRead, required this.onTap,
  });

  IconData get _icon {
    switch (type) {
      case 'follow_up': return Icons.repeat_rounded;
      case 'critical_alert': return Icons.warning_rounded;
      case 'missed_visit': return Icons.event_busy_rounded;
      case 'visit_reminder': return Icons.schedule_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color get _color {
    switch (type) {
      case 'follow_up': return AppTheme.accentAmber;
      case 'critical_alert': return AppTheme.error;
      case 'missed_visit': return AppTheme.accentOrange;
      case 'visit_reminder': return AppTheme.info;
      default: return AppTheme.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : AppTheme.primaryGreen.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isRead ? AppTheme.dividerColor : AppTheme.primaryGreen.withValues(alpha: 0.15)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon, color: _color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.w600))),
                          if (!isRead)
                            Container(width: 8, height: 8, decoration: const BoxDecoration(
                              color: AppTheme.primaryGreen, shape: BoxShape.circle)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(body, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(AppHelpers.timeAgo(time),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textTertiary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
