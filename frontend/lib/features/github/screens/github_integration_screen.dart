import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/severity_badge.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../providers/github_provider.dart';

class GitHubIntegrationScreen extends StatefulWidget {
  const GitHubIntegrationScreen({super.key});

  @override
  State<GitHubIntegrationScreen> createState() => _GitHubIntegrationScreenState();
}

class _GitHubIntegrationScreenState extends State<GitHubIntegrationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GitHubProvider>().fetchRepositories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GitHubProvider>();

    if (provider.isLoading && provider.repositories.isEmpty) {
      return const LoadingIndicator(message: 'Fetching connected GitHub repositories...');
    }

    if (provider.errorMessage != null && provider.repositories.isEmpty) {
      return ErrorStateView(
        errorMessage: provider.errorMessage!,
        onRetry: () => provider.fetchRepositories(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'GitHub Repositories & App Integration',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Least-privilege repository monitoring for Dependabot, CodeQL, and Secret Scanning.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Configure GitHub App'),
              )
            ],
          ),
          const SizedBox(height: 24),

          // Main Layout split: Left Repos List, Right Security Alerts
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Repository Selection Panel
                SizedBox(
                  width: 360,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Accessible Repositories (${provider.repositories.length})',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.builder(
                            itemCount: provider.repositories.length,
                            itemBuilder: (context, idx) {
                              final repo = provider.repositories[idx];
                              final isSelected = provider.selectedRepoId == repo['id'];
                              final isMonitored = repo['is_monitored'] == true;

                              return InkWell(
                                onTap: () => provider.selectRepository(repo['id']),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                                    border: const Border(bottom: BorderSide(color: AppColors.border)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              repo['name'] ?? '',
                                              style: TextStyle(
                                                color: isSelected ? AppColors.primaryLight : AppColors.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Switch(
                                            value: isMonitored,
                                            onChanged: (_) => provider.toggleMonitoring(repo['id']),
                                            activeThumbColor: AppColors.primary,
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            repo['is_private'] == true ? Icons.lock_outline : Icons.public,
                                            size: 14,
                                            color: AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            repo['default_branch'] ?? 'main',
                                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Selected Repository Security Findings Detail
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
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
                          children: const [
                            Text(
                              'Repository Security Findings & Scans',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.security_rounded, color: AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),

                        if (provider.isLoading)
                          const Expanded(child: LoadingIndicator(message: 'Loading repository alerts...'))
                        else if (provider.selectedRepoAlerts.isEmpty)
                          const Expanded(
                            child: EmptyStateView(
                              title: 'No Active Security Alerts',
                              description: 'No Dependabot, Secret Scanning, or CodeQL vulnerabilities found for this repository.',
                              icon: Icons.check_circle_outline_rounded,
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: provider.selectedRepoAlerts.length,
                              itemBuilder: (context, idx) {
                                final alert = provider.selectedRepoAlerts[idx];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceCard,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SeverityBadge(severity: alert['severity'] ?? 'Medium'),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              alert['tool_name'] ?? 'GitHub Security',
                                              style: const TextStyle(
                                                color: AppColors.primaryLight,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        alert['title'] ?? '',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        alert['description'] ?? '',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.insert_drive_file_outlined, size: 14, color: AppColors.textMuted),
                                          const SizedBox(width: 6),
                                          Text(
                                            alert['file_path'] ?? 'root',
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 12,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
