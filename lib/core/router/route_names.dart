/// Centralized route paths. Use these instead of string literals when calling
/// context.go / context.push.
class AppRoutes {
  AppRoutes._();

  // Auth.
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot';

  // Admin shell.
  static const String adminDashboard = '/dashboard';
  static const String farmers = '/farmers';
  static const String plots = '/plots';
  static const String visits = '/visits';
  static const String routes = '/routes';
  static const String analytics = '/analytics';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // Farmer portal.
  static const String portalDashboard = '/portal';
  static const String portalPlots = '/portal/plots';
  static const String portalReports = '/portal/reports';
  static const String portalVisits = '/portal/visits';
  static const String portalProfile = '/portal/profile';
  static const String portalNotifications = '/portal/notifications';
}
