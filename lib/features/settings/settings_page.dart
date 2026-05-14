import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/utils/responsive.dart';
import 'package:agrolink/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _darkMode = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _offlineMode = true;
  bool _autoSync = true;

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.contentPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: padding,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card
                _buildProfileSection(context),
                const SizedBox(height: 24),

                // Appearance
                _buildSection(context, 'Appearance', Icons.palette_outlined, [
                  _switchTile('Dark Mode', 'Switch to dark theme', Icons.dark_mode_outlined,
                    _darkMode, (v) => setState(() => _darkMode = v)),
                ]).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),

                // Notifications
                _buildSection(context, 'Notifications', Icons.notifications_outlined, [
                  _switchTile('Push Notifications', 'Receive visit reminders & alerts',
                    Icons.notifications_active_outlined, _pushNotifications,
                    (v) => setState(() => _pushNotifications = v)),
                  const Divider(height: 1),
                  _switchTile('Email Notifications', 'Receive weekly reports by email',
                    Icons.email_outlined, _emailNotifications,
                    (v) => setState(() => _emailNotifications = v)),
                ]).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),

                // Data & Sync
                _buildSection(context, 'Data & Sync', Icons.sync_outlined, [
                  _switchTile('Offline Mode', 'Cache data for offline access',
                    Icons.cloud_off_outlined, _offlineMode,
                    (v) => setState(() => _offlineMode = v)),
                  const Divider(height: 1),
                  _switchTile('Auto Sync', 'Sync automatically when online',
                    Icons.sync_rounded, _autoSync,
                    (v) => setState(() => _autoSync = v)),
                  const Divider(height: 1),
                  _actionTile('Clear Cache', 'Free up local storage',
                    Icons.delete_sweep_outlined, () {}),
                  const Divider(height: 1),
                  _actionTile('Export Data', 'Download all data as CSV',
                    Icons.download_rounded, () {}),
                ]).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),

                // About
                _buildSection(context, 'About', Icons.info_outlined, [
                  _infoTile('Version', '1.0.0', Icons.verified_outlined),
                  const Divider(height: 1),
                  _actionTile('Privacy Policy', '', Icons.privacy_tip_outlined, () {}),
                  const Divider(height: 1),
                  _actionTile('Terms of Service', '', Icons.description_outlined, () {}),
                  const Divider(height: 1),
                  _actionTile('Help & Support', '', Icons.help_outline_rounded, () {}),
                ]).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await ref.read(authServiceProvider).signOut();
                        if (context.mounted) context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                    label: const Text('Sign Out', style: TextStyle(color: AppTheme.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.primaryGreen,
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dr. Agro Expert',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('admin@agrolink.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textTertiary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Admin', style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {},
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: AppTheme.glassCard,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _switchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      secondary: Icon(icon, color: AppTheme.textTertiary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryGreen,
    );
  }

  Widget _actionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, color: AppTheme.textTertiary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)) : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary),
      onTap: onTap,
    );
  }

  Widget _infoTile(String title, String value, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Icon(icon, color: AppTheme.textTertiary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.textTertiary)),
    );
  }
}
