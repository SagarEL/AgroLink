import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/constants/app_constants.dart';

/// ─────────────────────────────────────────────────────────────
/// Helper Utilities
/// ─────────────────────────────────────────────────────────────

class AppHelpers {
  AppHelpers._();

  // ── Date Formatting ───────────────────────────────────────
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 0 && diff <= 7) return 'In $diff days';
    if (diff < 0 && diff >= -7) return '${-diff} days ago';
    return formatDate(date);
  }

  // ── Number Formatting ─────────────────────────────────────
  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
        .format(amount);
  }

  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  static String formatDecimal(double number, {int digits = 1}) {
    return number.toStringAsFixed(digits);
  }

  // ── Severity Helpers ──────────────────────────────────────
  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case AppConstants.severityCritical:
        return AppTheme.severityCritical;
      case AppConstants.severityHigh:
        return AppTheme.severityHigh;
      case AppConstants.severityMedium:
        return AppTheme.severityMedium;
      case AppConstants.severityLow:
        return AppTheme.severityLow;
      default:
        return AppTheme.textTertiary;
    }
  }

  static IconData severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case AppConstants.severityCritical:
        return Icons.warning_rounded;
      case AppConstants.severityHigh:
        return Icons.error_outline_rounded;
      case AppConstants.severityMedium:
        return Icons.info_outline_rounded;
      case AppConstants.severityLow:
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // ── Visit Status Helpers ──────────────────────────────────
  static Color visitStatusColor(String status) {
    switch (status.toLowerCase()) {
      case AppConstants.visitCompleted:
        return AppTheme.success;
      case AppConstants.visitInProgress:
        return AppTheme.info;
      case AppConstants.visitScheduled:
        return AppTheme.accentAmber;
      case AppConstants.visitCancelled:
        return AppTheme.textTertiary;
      case AppConstants.visitMissed:
        return AppTheme.error;
      default:
        return AppTheme.textTertiary;
    }
  }

  static IconData visitStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case AppConstants.visitCompleted:
        return Icons.check_circle_rounded;
      case AppConstants.visitInProgress:
        return Icons.pending_rounded;
      case AppConstants.visitScheduled:
        return Icons.schedule_rounded;
      case AppConstants.visitCancelled:
        return Icons.cancel_rounded;
      case AppConstants.visitMissed:
        return Icons.event_busy_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // ── Validation ────────────────────────────────────────────
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 10) return 'Enter a valid 10-digit phone number';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validateRequired(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  // ── Snackbar Helpers ──────────────────────────────────────
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.info,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Initials Generator ────────────────────────────────────
  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
