import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/config/api_config.dart';
import '../../../core/networking/api_client.dart';
import '../../authentication/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailAlerts = true;
  bool _criticalOnly = false;
  bool _weeklySummary = true;
  bool _isSaving = false;

  void _saveNotificationSettings() async {
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ApiClient.patch(
        '${ApiConfig.baseUrl}/settings/notifications',
        body: {
          'email_alerts': _emailAlerts,
          'critical_only': _criticalOnly,
          'weekly_summary': _weeklySummary,
        },
      );
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Notification preferences saved'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.critical),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account & Security Data'),
        content: const Text(
          'Are you sure you want to permanently delete your DomainGuard account? All connected domains, repository alerts, and security event histories will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final auth = context.read<AuthProvider>();
              nav.pop();
              try {
                await ApiClient.delete('${ApiConfig.baseUrl}/settings/account');
                auth.logout();
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppColors.critical),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
            child: const Text('Delete Permanently'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account & Security Settings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage connected accounts, alert severity thresholds, and data privacy.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 28),

          // User Profile Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null,
                  child: user['avatar_url'] == null
                      ? const Icon(Icons.person_outline_rounded, size: 32, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['full_name'] ?? 'SecOps Officer',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'] ?? 'secops@domainguard.io',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Plan Tier: ${user['plan_tier'] ?? 'Pro'}',
                          style: const TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Notification Preferences
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notification Preferences',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Email Security Alerts', style: TextStyle(color: AppColors.textPrimary)),
                  subtitle: const Text('Receive immediate email notifications for new findings', style: TextStyle(color: AppColors.textMuted)),
                  value: _emailAlerts,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _emailAlerts = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Critical Severity Only', style: TextStyle(color: AppColors.textPrimary)),
                  subtitle: const Text('Suppress low and medium informational findings from email dispatch', style: TextStyle(color: AppColors.textMuted)),
                  value: _criticalOnly,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _criticalOnly = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Weekly Security Summary Email', style: TextStyle(color: AppColors.textPrimary)),
                  subtitle: const Text('Receive weekly consolidated security posture email report', style: TextStyle(color: AppColors.textMuted)),
                  value: _weeklySummary,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _weeklySummary = val),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveNotificationSettings,
                    child: _isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save Preferences'),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Danger Zone
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.critical.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.critical.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Danger Zone & Account Deletion',
                  style: TextStyle(color: AppColors.critical, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Permanently delete your DomainGuard account, connected GitHub App authorizations, verified domain records, and historical security findings.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _confirmDeleteAccount,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('Delete Account & Purge Data'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
