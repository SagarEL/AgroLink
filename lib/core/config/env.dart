/// Environment configuration. Override at build time with --dart-define.
class Env {
  Env._();

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'YOUR_GOOGLE_MAPS_API_KEY',
  );

  static const String firebaseRegion = String.fromEnvironment(
    'FIREBASE_REGION',
    defaultValue: 'us-central1',
  );

  static const bool useEmulators = bool.fromEnvironment(
    'USE_EMULATORS',
    defaultValue: false,
  );

  static const String appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'production');
  static bool get isProduction => appEnv == 'production';
}
