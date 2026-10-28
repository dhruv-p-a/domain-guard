import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../providers/domain_provider.dart';
import 'add_domain_dialog.dart';

class DomainManagementScreen extends StatefulWidget {
  const DomainManagementScreen({super.key});

  @override
  State<DomainManagementScreen> createState() => _DomainManagementScreenState();
}

class _DomainManagementScreenState extends State<DomainManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DomainProvider>().fetchDomains();
      }
    });
  }

  void _showVerifyDialog(BuildContext context, dynamic domain) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.dns_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('DNS Ownership Verification'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To verify ownership of ${domain['domain_name']}, create the following DNS TXT record in your DNS provider (Cloudflare, Route53, Namecheap, etc.):',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dnsRow('Record Type', 'TXT'),
                    const SizedBox(height: 8),
                    _dnsRow('Host / Name', '_domainguard-challenge.${domain['domain_name']}'),
                    const SizedBox(height: 8),
                    _dnsRow('TXT Value', domain['verification_token'] ?? ''),
                  ],
                ),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final provider = context.read<DomainProvider>();
              nav.pop();
              final res = await provider.verifyDomain(domain['id']);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(res['message'] ?? 'Verification completed'),
                  backgroundColor: res['is_verified'] == true ? AppColors.success : AppColors.warning,
                ),
              );
            },
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: const Text('Verify TXT Record Now'),
          ),
        ],
      ),
    );
  }

  Widget _dnsRow(String label, String val) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ),
        Expanded(
          child: SelectableText(
            val,
            style: const TextStyle(
              color: AppColors.primaryLight,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DomainProvider>();

    if (provider.isLoading && provider.domains.isEmpty) {
      return const LoadingIndicator(message: 'Fetching monitored domains...');
    }

    if (provider.errorMessage != null && provider.domains.isEmpty) {
      return ErrorStateView(
        errorMessage: provider.errorMessage!,
        onRetry: () => provider.fetchDomains(),
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
                children: const [
                  Text(
                    'Domain Management & DNS Verification',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Authorized domain security monitoring requires DNS ownership proof.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const AddDomainDialog(),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Domain'),
              )
            ],
          ),
          const SizedBox(height: 24),

          if (provider.domains.isEmpty)
            Expanded(
              child: EmptyStateView(
                title: 'No Domains Configured',
                description: 'Add a domain to begin non-destructive SSL, DNS, and security header monitoring.',
                icon: Icons.language_rounded,
                actionLabel: 'Add Domain',
                onAction: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const AddDomainDialog(),
                  );
                },
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: provider.domains.length,
                itemBuilder: (context, idx) {
                  final domain = provider.domains[idx];
                  final isVerified = domain['is_verified'] == true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                            color: (isVerified ? AppColors.success : AppColors.warning).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isVerified ? Icons.verified_rounded : Icons.pending_rounded,
                            color: isVerified ? AppColors.success : AppColors.warning,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    domain['domain_name'] ?? '',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  StatusChip(
                                    label: isVerified ? 'Verified Ownership' : 'Pending DNS TXT Verification',
                                    isSuccess: isVerified,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'SSL: ${domain['ssl_status'] ?? 'Unknown'}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Headers Score: ${domain['security_headers_score'] ?? 'B'}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Status: ${domain['monitoring_status'] ?? 'Active'}',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        if (!isVerified)
                          OutlinedButton.icon(
                            onPressed: () => _showVerifyDialog(context, domain),
                            icon: const Icon(Icons.dns_rounded, size: 16),
                            label: const Text('Verify TXT'),
                          ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () => provider.deleteDomain(domain['id']),
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.critical),
                          tooltip: 'Remove Domain',
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
