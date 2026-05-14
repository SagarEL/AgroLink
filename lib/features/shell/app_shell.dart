import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/utils/responsive.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ─────────────────────────────────────────────────────────────
/// App Shell — Responsive sidebar/bottom nav wrapper
/// ─────────────────────────────────────────────────────────────
class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/dashboard'),
    _NavItem(icon: Icons.people_rounded, label: 'Farmers', path: '/farmers'),
    _NavItem(icon: Icons.grid_view_rounded, label: 'Plots', path: '/plots'),
    _NavItem(icon: Icons.assignment_rounded, label: 'Visits', path: '/visits'),
    _NavItem(icon: Icons.route_rounded, label: 'Routes', path: '/routes'),
    _NavItem(icon: Icons.analytics_rounded, label: 'Analytics', path: '/analytics'),
    _NavItem(icon: Icons.notifications_rounded, label: 'Alerts', path: '/notifications'),
    _NavItem(icon: Icons.settings_rounded, label: 'Settings', path: '/settings'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navItems.length; i++) {
      if (location.startsWith(_navItems[i].path)) {
        if (_selectedIndex != i) setState(() => _selectedIndex = i);
        return;
      }
    }
  }

  void _onNavTap(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
      context.go(_navItems[index].path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _DesktopSidebar(
              selectedIndex: _selectedIndex,
              onTap: _onNavTap,
              items: _navItems,
            ),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            _TabletRail(
              selectedIndex: _selectedIndex,
              onTap: _onNavTap,
              items: _navItems,
            ),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    // Mobile
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _MobileBottomNav(
        selectedIndex: _selectedIndex > 4 ? 4 : _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Desktop Sidebar
// ═══════════════════════════════════════════════════════════════
class _DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _DesktopSidebar({
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(
          right: BorderSide(color: theme.dividerTheme.color ?? Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'AgroLink',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Agriculture Consultation',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
                              color: isSelected ? AppTheme.primaryGreen : AppTheme.textTertiary,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              item.label,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                            if (isSelected) ...[
                              const Spacer(),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: (50 * index).ms).fadeIn().slideX(begin: -0.1);
              },
            ),
          ),
          // Bottom user area
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryGreen,
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. Agro Expert',
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text('Admin',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Tablet Rail
// ═══════════════════════════════════════════════════════════════
class _TabletRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _TabletRail({required this.selectedIndex, required this.onTap, required this.items});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 8),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.primaryLight],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 22),
        ),
      ),
      destinations: items
          .map((item) => NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.icon),
                label: Text(item.label),
              ))
          .toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Mobile Bottom Nav
// ═══════════════════════════════════════════════════════════════
class _MobileBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _MobileBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Farmers'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Plots'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Visits'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz_rounded), label: 'More'),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem({required this.icon, required this.label, required this.path});
}
