import 'package:intl/intl.dart';

/// Reusable formatters. Keep one instance per pattern (DateFormat caches).
class Formatters {
  Formatters._();

  static final DateFormat _date = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _dayMonth = DateFormat('dd MMM');
  static final DateFormat _month = DateFormat('MMM');
  static final NumberFormat _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  static final NumberFormat _decimal = NumberFormat.decimalPattern('en_IN');

  static String date(DateTime? d) => d == null ? '—' : _date.format(d);
  static String dateTime(DateTime? d) => d == null ? '—' : _dateTime.format(d);
  static String dayMonth(DateTime d) => _dayMonth.format(d);
  static String monthLabel(DateTime d) => _month.format(d);
  static String currency(num v) => _inr.format(v);
  static String number(num v) => _decimal.format(v);

  static String relative(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 30) return _date.format(d);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    if (diff.isNegative) {
      final future = -diff.inDays;
      if (future > 0) return 'in ${future}d';
      return 'soon';
    }
    return 'just now';
  }

  static String shortPhone(String phone) {
    if (phone.length <= 4) return phone;
    return '••• ${phone.substring(phone.length - 4)}';
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
