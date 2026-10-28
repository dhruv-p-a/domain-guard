import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_chip.dart';
import '../providers/integration_provider.dart';

class IntegrationsScreen extends StatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<IntegrationProvider>().fetchIntegrations();
      }
    });
  }

  void _showSampleLogDialog(BuildContext context) {
    String selectedProvider = 'cloudflare';
    String selectedLogType = 'waf_event';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.bug_report_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Simulate Log Ingestion'),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingest a sample live firewall or server auth log entry to test normalization into the security event timeline.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: selectedProvider,
                  decoration: const InputDecoration(labelText: 'Integration Provider'),
                  items: const [
                    DropdownMenuItem(value: 'cloudflare', child: Text('Cloudflare Edge WAF')),
                    DropdownMenuItem(value: 'server_auth', child: Text('Linux SSH Auth Log')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => selectedProvider = val);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedLogType,
                  decoration: const InputDecoration(labelText: 'Log Event Type'),
                  items: const [
                    DropdownMenuItem(value: 'waf_event', child: Text('SQL Injection Probe Blocked')),
                    DropdownMenuItem(value: 'auth_failure', child: Text('SSH Brute Force Failure')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => selectedLogType = val);
                  },
                ),
              ],
            ),
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
                final provider = context.read<IntegrationProvider>();
                nav.pop();
                final ok = await provider.ingestSampleLog(
                  selectedProvider,
                  selectedLogType,
                  {
                    'ip': '198.51.100.42',
                    'path': '/api/v1/auth/login',
                    'action': 'block',
                    'timestamp': DateTime.now().toIso8601String()
                  },
                );
                if (ok) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Sample log successfully ingested and normalized!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Ingest Payload'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IntegrationProvider>();

    if (provider.isLoading && provider.integrations.isEmpty) {
      return const LoadingIndicator(message: 'Loading hosting & firewall integrations...');
    }

    final arch = provider.architectureInfo ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Hosting & Firewall Integrations',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Connect Cloudflare WAF, server authentication logs, and cloud access logs.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showSampleLogDialog(context),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Ingest Sample Log Payload'),
              )
            ],
          ),
          const SizedBox(height: 24),

          // Security & Scope Notice Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.primaryLight, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arch['title'] ?? 'Security Scope Notice',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        arch['explanation'] ??
                            'GitHub repository access alone does NOT expose live website login attempts, server processes, or firewall traffic. Live traffic sources must be connected separately via secure webhooks.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Connected Integrations List
          const Text(
            'Connected Integrations',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.integrations.length,
            itemBuilder: (context, idx) {
              final item = provider.integrations[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.cloud_done_rounded, color: AppColors.accent, size: 24),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? '',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Provider: ${item['provider']} • Last Synced: ${item['last_synced_at']?.toString().split('T').first ?? 'Just now'}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          )
                        ],
                      ),
                    ),
                    StatusChip(label: item['status'] ?? 'Connected', isSuccess: true),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
