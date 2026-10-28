import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NavigationItem {
  final String title;
  final IconData icon;
  final String route;
  final int index;

  const NavigationItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.index,
  });
}

class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onLogout;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
  });

  static const List<NavigationItem> items = [
    NavigationItem(title: 'Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard', index: 0),
    NavigationItem(title: 'GitHub Repos', icon: Icons.code_rounded, route: '/github', index: 1),
    NavigationItem(title: 'Domains', icon: Icons.language_rounded, route: '/domains', index: 2),
    NavigationItem(title: 'Security Scan', icon: Icons.security_rounded, route: '/monitoring', index: 3),
    NavigationItem(title: 'Events Timeline', icon: Icons.timeline_rounded, route: '/events', index: 4),
    NavigationItem(title: 'Integrations', icon: Icons.cloud_done_outlined, route: '/integrations', index: 5),
    NavigationItem(title: 'Notifications', icon: Icons.notifications_none_rounded, route: '/notifications', index: 6),
    NavigationItem(title: 'Settings', icon: Icons.settings_outlined, route: '/settings', index: 7),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Column(
        children: [
          // Header Logo with Neon Cyan / Pink branding
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.shield_rounded, color: AppColors.neonCyan, size: 24),
                ),
                const SizedBox(width: 12),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'DOMAIN',
                        style: TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: 'GUARD',
                        style: TextStyle(
                          color: AppColors.neonPink,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Nav List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: items.length,
              itemBuilder: (context, idx) {
                final item = items[idx];
                final isSelected = selectedIndex == item.index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () => onItemSelected(item.index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5), width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 20,
                            color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                              letterSpacing: isSelected ? 0.5 : 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Footer Logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: OutlinedButton.icon(
              onPressed: onLogout,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                side: BorderSide(color: AppColors.critical.withValues(alpha: 0.5)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.critical),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
