import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/severity_badge.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationProvider>().fetchNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    if (provider.isLoading && provider.notifications.isEmpty) {
      return const LoadingIndicator(message: 'Loading notification feed...');
    }

    if (provider.errorMessage != null && provider.notifications.isEmpty) {
      return ErrorStateView(
        errorMessage: provider.errorMessage!,
        onRetry: () => provider.fetchNotifications(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alerts & Notifications',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.unreadCount} unread security notifications.',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: provider.unreadCount > 0 ? () => provider.markAllAsRead() : null,
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: const Text('Mark All Read'),
              )
            ],
          ),
          const SizedBox(height: 24),

          if (provider.notifications.isEmpty)
            const Expanded(
              child: EmptyStateView(
                title: 'No Notifications',
                description: 'You have no unread or historical security alerts.',
                icon: Icons.notifications_off_outlined,
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: provider.notifications.length,
                itemBuilder: (context, idx) {
                  final notif = provider.notifications[idx];
                  final isRead = notif['is_read'] == true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isRead ? AppColors.surface : AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isRead ? AppColors.border : AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SeverityBadge(severity: notif['severity'] ?? 'Info'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif['title'] ?? '',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif['message'] ?? '',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          )
                      ],
                    ),
                  );
                },
              ),
            )
        ],
      ),
    );
  }
}
