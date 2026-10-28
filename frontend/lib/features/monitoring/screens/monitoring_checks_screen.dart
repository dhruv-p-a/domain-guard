import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_chip.dart';
import '../providers/monitoring_provider.dart';

class MonitoringChecksScreen extends StatefulWidget {
  const MonitoringChecksScreen({super.key});

  @override
  State<MonitoringChecksScreen> createState() => _MonitoringChecksScreenState();
}

class _MonitoringChecksScreenState extends State<MonitoringChecksScreen> {
  final _domainInputController = TextEditingController(text: 'api.domainguard.io');

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitoringProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Passive Domain Security Scanner',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Executes non-destructive, safe passive audits: SSL/TLS, Security Headers, DNS SEC, Exposed Configs, and Subdomains.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Search Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _domainInputController,
                    decoration: const InputDecoration(
                      labelText: 'Verified Domain Target',
                      hintText: 'e.g. api.domainguard.io',
                      prefixIcon: Icon(Icons.language_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: provider.isScanning
                      ? null
                      : () {
                          final target = _domainInputController.text.trim();
                          if (target.isNotEmpty) {
                            provider.runSecurityScan(target);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  ),
                  icon: const Icon(Icons.radar_rounded),
                  label: const Text('Run Security Audit'),
                )
              ],
            ),
          ),
          const SizedBox(height: 28),

          if (provider.isScanning)
            const LoadingIndicator(message: 'Running non-destructive passive security checks...')
          else if (provider.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.critical.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.critical.withOpacity(0.4)),
              ),
              child: Text(
                'Scan Error: ${provider.errorMessage}',
                style: const TextStyle(color: AppColors.critical, fontSize: 14),
              ),
            )
          else if (provider.scanResult != null)
            _buildScanResultsView(provider.scanResult!)
          else
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Column(
                  children: const [
                    Icon(Icons.shield_outlined, size: 48, color: AppColors.textMuted),
                    SizedBox(height: 16),
                    Text(
                      'Ready to Scan Verified Domain',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Click "Run Security Audit" above to analyze SSL certificates, headers, and DNS posture.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildScanResultsView(Map<String, dynamic> res) {
    final ssl = res['ssl'] ?? {};
    final headers = res['headers'] ?? {};
    final dns = res['dns'] ?? {};
    final exposed = res['exposed'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Health Summary Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audit Summary: ${res['domain_name']}',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${res['findings_count']} potential security issues or optimization recommendations identified.',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              StatusChip(
                label: 'Health: ${res['overall_health']}',
                isSuccess: res['overall_health'] == 'Secure',
              )
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Grid of Checks
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _checkCard('SSL / TLS Certificate', Icons.lock_rounded, [
              _detailRow('Issuer', ssl['issuer'] ?? 'Let\'s Encrypt'),
              _detailRow('Status', ssl['status'] ?? 'Valid'),
              _detailRow('Days Remaining', '${ssl['days_remaining'] ?? 0} days'),
              _detailRow('Cipher Suite', ssl['cipher_suite'] ?? 'TLS_AES_256_GCM_SHA384'),
            ]),
            _checkCard('Security Headers Posture', Icons.web_rounded, [
              _detailRow('Header Score', headers['score'] ?? 'B'),
              _detailRow('Headers Missing', '${(headers['headers_missing'] as List?)?.length ?? 0} required headers'),
              _detailRow('Recommendations', (headers['recommendations'] as List?)?.join(', ') ?? 'All good'),
            ]),
            _checkCard('DNS & Email Security', Icons.dns_rounded, [
              _detailRow('SPF Policy', dns['has_spf'] == true ? 'Configured (Pass)' : 'Missing'),
              _detailRow('DMARC Policy', dns['has_dmarc'] == true ? 'Configured (Pass)' : 'Missing'),
              _detailRow('A Records', (dns['a_records'] as List?)?.join(', ') ?? 'None'),
            ]),
            _checkCard('Exposed Config Indicators', Icons.find_in_page_outlined, [
              _detailRow('Paths Checked', '${exposed['paths_checked'] ?? 5} sensitive paths'),
              _detailRow('Exposed Files', '${(exposed['exposed_files'] as List?)?.length ?? 0} files found'),
              _detailRow('Public Safety', exposed['is_safe'] == true ? 'No exposed secrets' : 'Action needed'),
            ]),
          ],
        )
      ],
    );
  }

  Widget _checkCard(String title, IconData icon, List<Widget> details) {
    return Container(
      width: 380,
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
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          ...details
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
