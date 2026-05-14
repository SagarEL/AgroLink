import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agrolink/services/auth_service.dart';
import 'package:agrolink/features/auth/login_page.dart';
import 'package:agrolink/features/shell/app_shell.dart';
import 'package:agrolink/features/dashboard/dashboard_page.dart';
import 'package:agrolink/features/farmers/farmers_list_page.dart';
import 'package:agrolink/features/farmers/farmer_detail_page.dart';
import 'package:agrolink/features/farmers/add_edit_farmer_page.dart';
import 'package:agrolink/features/plots/plots_page.dart';
import 'package:agrolink/features/visits/visits_page.dart';
import 'package:agrolink/features/visits/add_visit_page.dart';
import 'package:agrolink/features/routes/route_planner_page.dart';
import 'package:agrolink/features/analytics/analytics_page.dart';
import 'package:agrolink/features/notifications/notifications_page.dart';
import 'package:agrolink/features/settings/settings_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/farmers',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const FarmersListPage(),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const AddEditFarmerPage(),
                  transitionsBuilder: _slideTransition,
                ),
              ),
              GoRoute(
                path: ':farmerId',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: FarmerDetailPage(
                    farmerId: state.pathParameters['farmerId']!,
                  ),
                  transitionsBuilder: _fadeTransition,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: AddEditFarmerPage(
                        farmerId: state.pathParameters['farmerId'],
                      ),
                      transitionsBuilder: _slideTransition,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/plots',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const PlotsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/visits',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const VisitsPage(),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const AddVisitPage(),
                  transitionsBuilder: _slideTransition,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/routes',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const RoutePlannerPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AnalyticsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const NotificationsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsPage(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
      ),
    ],
  );
});

Widget _fadeTransition(
    BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(
    BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  );
}
