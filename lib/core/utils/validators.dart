/// Form field validators returning a localized error message or null.
class Validators {
  Validators._();

  static String? required(String? v, {String field = 'This field'}) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email';
  }

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Phone is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 15) return 'Enter a valid phone number';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    return null;
  }

  static String? minLength(String? v, int min, {String field = 'This field'}) {
    if (v == null || v.trim().length < min) return '$field must be at least $min characters';
    return null;
  }

  static String? otp(String? v) {
    if (v == null || v.length != 6) return 'Enter the 6-digit code';
    if (!RegExp(r'^\d{6}$').hasMatch(v)) return 'OTP must be numeric';
    return null;
  }

  static String? positiveNumber(String? v, {String field = 'Value'}) {
    if (v == null || v.isEmpty) return '$field is required';
    final parsed = double.tryParse(v);
    if (parsed == null || parsed <= 0) return '$field must be greater than 0';
    return null;
  }
}
