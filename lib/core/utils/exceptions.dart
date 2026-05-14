/// Application-level exception hierarchy. Repositories should translate
/// platform errors (FirebaseAuthException, FirebaseException) into one of these.
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final Object? cause;
  const AppException(this.message, {this.code, this.cause});
  @override
  String toString() => '$runtimeType($code): $message';
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.cause});
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.cause});
}

class PermissionException extends AppException {
  const PermissionException(super.message, {super.code, super.cause});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.cause});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.cause});
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.code, super.cause});
}

/// Map Firebase-ish error codes to user friendly text.
String describeAuthError(String? code) {
  switch (code) {
    case 'user-not-found':
      return 'No account found with that email.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'Incorrect email or password.';
    case 'email-already-in-use':
      return 'An account already exists with this email.';
    case 'weak-password':
      return 'Choose a stronger password (8+ characters).';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'invalid-phone-number':
      return 'Enter a valid mobile number.';
    case 'invalid-verification-code':
      return 'The OTP entered is incorrect.';
    case 'session-expired':
      return 'OTP expired. Please request a new code.';
    case 'network-request-failed':
      return 'Network issue. Check your connection and retry.';
    default:
      return 'Something went wrong. Please try again.';
  }
}
