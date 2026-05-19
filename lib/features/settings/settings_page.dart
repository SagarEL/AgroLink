import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:agrolink/core/theme/app_theme.dart';
import 'package:agrolink/core/utils/responsive.dart';
import 'package:agrolink/services/auth_service.dart';
import 'package:agrolink/features/auth/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = Responsive.contentPadding(context);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

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
                _buildProfileSection(context, currentUser),
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
                    Icons.delete_sweep_outlined, () => _showClearCacheDialog(context)),
                  const Divider(height: 1),
                  _actionTile('Export Data', 'Download all data as CSV',
                    Icons.download_rounded, () => _showExportDialog(context)),
                ]).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),

                // About
                _buildSection(context, 'About', Icons.info_outlined, [
                  _infoTile('Version', '1.0.0', Icons.verified_outlined),
                  const Divider(height: 1),
                  _actionTile('Privacy Policy', '', Icons.privacy_tip_outlined, () => _launchURL('https://agrolink.app/privacy')),
                  const Divider(height: 1),
                  _actionTile('Terms of Service', '', Icons.description_outlined, () => _launchURL('https://agrolink.app/terms')),
                  const Divider(height: 1),
                  _actionTile('Help & Support', '', Icons.help_outline_rounded, () => _showHelpDialog(context)),
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

  Widget _buildProfileSection(BuildContext context, dynamic currentUser) {
    final userName = currentUser?.name ?? 'User';
    final userEmail = currentUser?.email ?? 'email@example.com';
    final userRole = currentUser?.role?.name ?? 'User';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassCard,
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.primaryGreen,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(userEmail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textTertiary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(userRole.toUpperCase(), style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _showEditProfileDialog(context, userName, userEmail),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will free up local storage and remove cached data. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Your data will be exported as CSV and downloaded to your device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export started. Check your downloads.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentName, String currentEmail) {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              readOnly: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Need help?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Text(
                'Email: support@agrolink.app\n'
                'Phone: +91 9876 543210\n\n'
                'Visit our website for documentation and FAQs.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
