import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/analytics_page.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/forgot_password_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/dashboard/admin_dashboard_page.dart';
import '../../features/farmer_portal/farmer_dashboard_page.dart';
import '../../features/farmer_portal/farmer_reports_page.dart';
import '../../features/farmer_portal/farmer_plots_page.dart';
import '../../features/farmer_portal/farmer_visits_page.dart';
import '../../features/farmers/farmer_detail_page.dart';
import '../../features/farmers/farmer_form_page.dart';
import '../../features/farmers/farmers_list_page.dart';
import '../../features/notifications/notifications_page.dart';
import '../../features/plots/plot_detail_page.dart';
import '../../features/plots/plot_form_page.dart';
import '../../features/plots/plots_list_page.dart';
import '../../features/routes/route_planner_page.dart';
import '../../features/settings/profile_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/shell/admin_shell.dart';
import '../../features/shell/farmer_shell.dart';
import '../../features/visits/visit_detail_page.dart';
import '../../features/visits/visit_form_page.dart';
import '../../features/visits/visits_list_page.dart';
import '../../models/app_user.dart';
import '../../widgets/splash_screen.dart';
import 'route_names.dart';

/// GoRouter wired into the auth stream — redirects unauthenticated users to
/// /login and routes farmers to /portal regardless of which URL they hit.
final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefresh(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final auth = ref.read(firebaseUserProvider);
      final profile = ref.read(currentUserProvider);
      final loc = state.matchedLocation;

      // Still resolving auth — stay on splash.
      if (auth.isLoading) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final loggedIn = auth.valueOrNull != null;
      final isAuthRoute = loc == AppRoutes.login ||
          loc == AppRoutes.forgotPassword ||
          loc == AppRoutes.splash;

      if (!loggedIn) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      // Logged in but profile still loading.
      if (profile.isLoading) return loc == AppRoutes.splash ? null : AppRoutes.splash;
      final role = profile.valueOrNull?.role ?? UserRole.admin;

      // Route farmers into the portal, doctors into the admin shell.
      if (isAuthRoute) {
        return role == UserRole.farmer ? AppRoutes.portalDashboard : AppRoutes.adminDashboard;
      }
      if (role == UserRole.farmer && !loc.startsWith('/portal')) {
        return AppRoutes.portalDashboard;
      }
      if (role != UserRole.farmer && loc.startsWith('/portal')) {
        return AppRoutes.adminDashboard;
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (_, state) => _fade(state, const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (_, state) => _fade(state, const ForgotPasswordPage()),
      ),

      // Admin shell — sidebar/bottom nav.
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.adminDashboard,
            pageBuilder: (_, state) => _fade(state, const AdminDashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.farmers,
            pageBuilder: (_, state) => _fade(state, const FarmersListPage()),
            routes: [
              GoRoute(
                path: 'new',
                pageBuilder: (_, state) => _slide(state, const FarmerFormPage()),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (_, state) =>
                    _slide(state, FarmerDetailPage(farmerId: state.pathParameters['id']!)),
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (_, state) => _slide(
                      state,
                      FarmerFormPage(farmerId: state.pathParameters['id']),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.plots,
            pageBuilder: (_, state) => _fade(state, const PlotsListPage()),
            routes: [
              GoRoute(
                path: 'new',
                pageBuilder: (_, state) {
                  final farmerId = state.uri.queryParameters['farmerId'];
                  return _slide(state, PlotFormPage(presetFarmerId: farmerId));
                },
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (_, state) =>
                    _slide(state, PlotDetailPage(plotId: state.pathParameters['id']!)),
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (_, state) => _slide(
                      state,
                      PlotFormPage(plotId: state.pathParameters['id']),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.visits,
            pageBuilder: (_, state) => _fade(state, const VisitsListPage()),
            routes: [
              GoRoute(
                path: 'new',
                pageBuilder: (_, state) {
                  final params = state.uri.queryParameters;
                  return _slide(
                    state,
                    VisitFormPage(
                      presetFarmerId: params['farmerId'],
                      presetPlotId: params['plotId'],
                    ),
                  );
                },
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (_, state) =>
                    _slide(state, VisitDetailPage(visitId: state.pathParameters['id']!)),
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (_, state) => _slide(
                      state,
                      VisitFormPage(visitId: state.pathParameters['id']),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.routes,
            pageBuilder: (_, state) => _fade(state, const RoutePlannerPage()),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            pageBuilder: (_, state) => _fade(state, const AnalyticsPage()),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            pageBuilder: (_, state) => _fade(state, const NotificationsPage()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (_, state) => _fade(state, const SettingsPage()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (_, state) => _fade(state, const ProfilePage()),
          ),
        ],
      ),

      // Farmer portal shell.
      ShellRoute(
        builder: (context, state, child) => FarmerShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.portalDashboard,
            pageBuilder: (_, state) => _fade(state, const FarmerDashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.portalPlots,
            pageBuilder: (_, state) => _fade(state, const FarmerPlotsPage()),
          ),
          GoRoute(
            path: AppRoutes.portalReports,
            pageBuilder: (_, state) => _fade(state, const FarmerReportsPage()),
          ),
          GoRoute(
            path: AppRoutes.portalVisits,
            pageBuilder: (_, state) => _fade(state, const FarmerVisitsPage()),
          ),
          GoRoute(
            path: AppRoutes.portalProfile,
            pageBuilder: (_, state) => _fade(state, const ProfilePage()),
          ),
          GoRoute(
            path: AppRoutes.portalNotifications,
            pageBuilder: (_, state) => _fade(state, const NotificationsPage()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.matchedLocation}')),
    ),
  );
});

CustomTransitionPage _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 220),
    child: child,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: child,
      );
    },
  );
}

CustomTransitionPage _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 260),
    child: child,
    transitionsBuilder: (_, animation, __, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curve),
        child: FadeTransition(opacity: curve, child: child),
      );
    },
  );
}

/// Bridges Riverpod streams into a Listenable that GoRouter can refresh on.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _userSub = _ref.listen(firebaseUserProvider, (_, __) => notifyListeners());
    _profileSub = _ref.listen(currentUserProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
  late final ProviderSubscription _userSub;
  late final ProviderSubscription _profileSub;

  @override
  void dispose() {
    _userSub.close();
    _profileSub.close();
    super.dispose();
  }
}
