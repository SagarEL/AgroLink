import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/avatar.dart';
import '../../widgets/connectivity_banner.dart';
import '../auth/auth_controller.dart';

/// Lean farmer-facing shell — bottom nav on all form factors with a clean top
/// bar showing the active section.
class FarmerShell extends ConsumerWidget {
  const FarmerShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _farmerNav.indexWhere((n) => loc == n.route);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: AppSpacing.lg,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.eco_outlined, size: 18, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user?.name.split(' ').first ?? 'Farmer'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _subtitleFor(loc),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.portalNotifications),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            onPressed: () => context.go(AppRoutes.portalProfile),
            icon: Avatar(name: user?.name ?? 'F', imageUrl: user?.profileImage, size: 30),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx < 0 ? 0 : idx,
        onDestinationSelected: (i) => context.go(_farmerNav[i].route),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco_rounded),
            label: 'My plots',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.summarize_outlined),
            selectedIcon: Icon(Icons.summarize_rounded),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _FarmerNav {
  final String route;
  const _FarmerNav(this.route);
}

const List<_FarmerNav> _farmerNav = [
  _FarmerNav(AppRoutes.portalDashboard),
  _FarmerNav(AppRoutes.portalPlots),
  _FarmerNav(AppRoutes.portalVisits),
  _FarmerNav(AppRoutes.portalReports),
  _FarmerNav(AppRoutes.portalProfile),
];

String _subtitleFor(String loc) {
  if (loc == AppRoutes.portalPlots) return 'Your plots';
  if (loc == AppRoutes.portalVisits) return 'Visit history';
  if (loc == AppRoutes.portalReports) return 'Treatment reports';
  if (loc == AppRoutes.portalProfile) return 'Your profile';
  if (loc == AppRoutes.portalNotifications) return 'Notifications';
  return 'Welcome back';
}
