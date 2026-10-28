import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/severity_badge.dart';

class EventDetailDialog extends StatelessWidget {
  final dynamic event;
  final Function(String) onStatusChange;

  const EventDetailDialog({
    super.key,
    required this.event,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final status = event['status'] ?? 'Open';

    return AlertDialog(
      title: Row(
        children: [
          SeverityBadge(severity: event['severity'] ?? 'Medium'),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              event['title'] ?? 'Security Finding Details',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 580,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Source', event['source'] ?? 'Engine'),
              _infoRow('Target Asset', '${event['target_type']} / ${event['target_name']}'),
              _infoRow('Event Type', event['event_type'] ?? 'SECURITY_EVENT'),
              _infoRow('Logged At', event['created_at'] ?? ''),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Evidence
              const Text(
                'Captured Evidence & Technical Data',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: SelectableText(
                  event['evidence'] ?? 'No additional raw evidence captured.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Recommended Remediation
              const Text(
                'Recommended Remediation Steps',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: SelectableText(
                  event['remediation'] ?? 'Follow standard SecOps guidelines for this finding.',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (status == 'Open') ...[
          OutlinedButton(
            onPressed: () {
              onStatusChange('Acknowledged');
              Navigator.of(context).pop();
            },
            child: const Text('Acknowledge'),
          ),
          ElevatedButton(
            onPressed: () {
              onStatusChange('Resolved');
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Mark as Resolved'),
          ),
        ] else ...[
          OutlinedButton(
            onPressed: () {
              onStatusChange('Open');
              Navigator.of(context).pop();
            },
            child: const Text('Re-open Finding'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ]
      ],
    );
  }

  Widget _infoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
          Expanded(
            child: Text(val, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
