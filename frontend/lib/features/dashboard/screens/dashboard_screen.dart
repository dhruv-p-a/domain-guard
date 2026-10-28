import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/severity_badge.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_state_view.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/event_trend_chart.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardProvider>().fetchSummary();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    if (provider.isLoading) {
      return const LoadingIndicator(message: 'Fetching security posture...');
    }

    if (provider.errorMessage != null) {
      return ErrorStateView(
        errorMessage: provider.errorMessage!,
        onRetry: () => provider.fetchSummary(),
      );
    }

    final data = provider.summary ?? {};
    final recentEvents = data['recent_events'] as List<dynamic>? ?? [];
    final trends = data['event_trends'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Security Overview',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Continuous monitoring engine active',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => provider.fetchSummary(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh Telemetry'),
              )
            ],
          ),
          const SizedBox(height: 28),

          // Summary Metric Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                childAspectRatio: isWide ? 1.6 : 1.3,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    title: 'Connected Repos',
                    value: '${data['connected_repositories_count'] ?? 0}',
                    icon: Icons.code_rounded,
                    color: AppColors.primary,
                    subtitle: 'Least-privilege GitHub App',
                  ),
                  StatCard(
                    title: 'Monitored Domains',
                    value: '${data['monitored_domains_count'] ?? 0}',
                    icon: Icons.language_rounded,
                    color: AppColors.accent,
                    subtitle: 'DNS ownership verified',
                  ),
                  StatCard(
                    title: 'Open Findings',
                    value: '${data['open_findings_count'] ?? 0}',
                    icon: Icons.bug_report_outlined,
                    color: AppColors.warning,
                    subtitle: '${data['high_alerts_count'] ?? 0} High / Medium',
                  ),
                  StatCard(
                    title: 'Critical Alerts',
                    value: '${data['critical_alerts_count'] ?? 0}',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.critical,
                    subtitle: 'Immediate action required',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Event Trends Chart
          EventTrendChart(trends: trends),
          const SizedBox(height: 28),

          // Recent Events Timeline Table
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Latest Security Events',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => widget.onNavigate(4), // Navigate to Events Timeline
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('View Full Timeline'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (recentEvents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text('No security events recorded', style: TextStyle(color: AppColors.textMuted))),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentEvents.length,
                    separatorBuilder: (ctx, idx) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final item = recentEvents[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            SeverityBadge(severity: item['severity'] ?? 'Low'),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] ?? 'Security Finding',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item['source'] ?? 'Engine'} • ${item['target'] ?? 'System'}',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceCard,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                item['status'] ?? 'Open',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
