import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/avatar.dart';
import '../../widgets/connectivity_banner.dart';
import '../auth/auth_controller.dart';
import '../notifications/notification_repository.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = context.formFactor;
    if (form.index >= FormFactor.desktop.index) {
      return _DesktopLayout(child: child);
    }
    if (form == FormFactor.tablet) {
      return _TabletLayout(child: child);
    }
    return _MobileLayout(child: child);
  }
}

/// Navigation items used by both sidebar and bottom bar variants.
class NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  const NavItem(this.label, this.icon, this.selectedIcon, this.route);
}

const List<NavItem> _adminNav = [
  NavItem('Dashboard', Icons.dashboard_outlined, Icons.dashboard_rounded, AppRoutes.adminDashboard),
  NavItem('Farmers', Icons.people_alt_outlined, Icons.people_alt_rounded, AppRoutes.farmers),
  NavItem('Plots', Icons.eco_outlined, Icons.eco_rounded, AppRoutes.plots),
  NavItem('Visits', Icons.event_note_outlined, Icons.event_note_rounded, AppRoutes.visits),
  NavItem('Routes', Icons.route_outlined, Icons.route_rounded, AppRoutes.routes),
  NavItem('Analytics', Icons.bar_chart_outlined, Icons.bar_chart_rounded, AppRoutes.analytics),
];

class _DesktopLayout extends ConsumerWidget {
  const _DesktopLayout({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(currentRoute: loc),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                const ConnectivityBanner(),
                const _TopBar(),
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabletLayout extends ConsumerWidget {
  const _TabletLayout({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _adminNav.indexWhere((n) => loc.startsWith(n.route));
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: idx < 0 ? 0 : idx,
              onDestinationSelected: (i) => context.go(_adminNav[i].route),
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: _BrandBadge(compact: true),
              ),
              destinations: [
                for (final n in _adminNav)
                  NavigationRailDestination(
                    icon: Icon(n.icon),
                    selectedIcon: Icon(n.selectedIcon),
                    label: Text(n.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  const ConnectivityBanner(),
                  const _TopBar(compact: true),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileLayout extends ConsumerWidget {
  const _MobileLayout({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _adminNav.indexWhere((n) => loc.startsWith(n.route));
    return Scaffold(
      appBar: const _MobileAppBar(),
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx < 0 ? 0 : idx.clamp(0, 4),
        onDestinationSelected: (i) => context.go(_adminNav[i].route),
        destinations: [
          for (final n in _adminNav.take(5))
            NavigationDestination(
              icon: Icon(n.icon),
              selectedIcon: Icon(n.selectedIcon),
              label: n.label,
            ),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.currentRoute});
  final String currentRoute;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    return Container(
      width: 260,
      color: AppColors.surface,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: _BrandBadge(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final n in _adminNav)
                  _SidebarTile(
                    item: n,
                    selected: currentRoute.startsWith(n.route),
                    onTap: () => context.go(n.route),
                  ),
                const Divider(height: 32),
                _SidebarTile(
                  item: const NavItem(
                    'Notifications',
                    Icons.notifications_none_rounded,
                    Icons.notifications_rounded,
                    AppRoutes.notifications,
                  ),
                  selected: currentRoute == AppRoutes.notifications,
                  onTap: () => context.go(AppRoutes.notifications),
                ),
                _SidebarTile(
                  item: const NavItem(
                    'Settings',
                    Icons.settings_outlined,
                    Icons.settings_rounded,
                    AppRoutes.settings,
                  ),
                  selected: currentRoute == AppRoutes.settings,
                  onTap: () => context.go(AppRoutes.settings),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            onTap: () => context.go(AppRoutes.profile),
            leading: Avatar(name: user?.name ?? 'Agronomist', imageUrl: user?.profileImage, size: 38),
            title: Text(user?.name ?? 'Agronomist',
                style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
            subtitle: Text(user?.email ?? user?.phone ?? '—',
                style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout_rounded, size: 18),
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.item, required this.selected, required this.onTap});
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 20,
                  color: selected ? AppColors.primaryDark : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    item.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: selected ? AppColors.primaryDark : AppColors.textPrimary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
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

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(Icons.eco_outlined, color: Colors.white, size: 22),
        ),
        if (!compact) ...[
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agrolink',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
              ),
              Text(
                'Agronomist console',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final unread = user == null
        ? const AsyncValue.data(0)
        : ref.watch(unreadCountProvider(user.uid));

    return Container(
      height: compact ? 64 : 72,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _titleFor(GoRouterState.of(context).matchedLocation),
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().fadeIn(duration: 200.ms),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.go(AppRoutes.notifications),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded),
                if ((unread.valueOrNull ?? 0) > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '${unread.valueOrNull}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.go(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}

class _MobileAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _MobileAppBar();
  @override
  Size get preferredSize => const Size.fromHeight(56);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    return AppBar(
      titleSpacing: AppSpacing.lg,
      title: Row(
        children: [
          const _BrandBadge(compact: true),
          const SizedBox(width: AppSpacing.sm),
          Text(_titleFor(GoRouterState.of(context).matchedLocation),
              style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => context.go(AppRoutes.notifications),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        IconButton(
          onPressed: () => context.go(AppRoutes.profile),
          icon: Avatar(name: user?.name ?? 'A', imageUrl: user?.profileImage, size: 30),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}

String _titleFor(String location) {
  if (location.startsWith(AppRoutes.farmers)) return 'Farmers';
  if (location.startsWith(AppRoutes.plots)) return 'Plots';
  if (location.startsWith(AppRoutes.visits)) return 'Visits';
  if (location.startsWith(AppRoutes.routes)) return 'Route planner';
  if (location.startsWith(AppRoutes.analytics)) return 'Analytics';
  if (location.startsWith(AppRoutes.notifications)) return 'Notifications';
  if (location.startsWith(AppRoutes.settings)) return 'Settings';
  if (location.startsWith(AppRoutes.profile)) return 'Profile';
  return 'Dashboard';
}
