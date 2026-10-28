import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/severity_badge.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../providers/event_provider.dart';
import '../widgets/event_detail_dialog.dart';

class EventTimelineScreen extends StatefulWidget {
  const EventTimelineScreen({super.key});

  @override
  State<EventTimelineScreen> createState() => _EventTimelineScreenState();
}

class _EventTimelineScreenState extends State<EventTimelineScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EventProvider>().fetchEvents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();

    if (provider.isLoading && provider.events.isEmpty) {
      return const LoadingIndicator(message: 'Loading security event timeline...');
    }

    if (provider.errorMessage != null && provider.events.isEmpty) {
      return ErrorStateView(
        errorMessage: provider.errorMessage!,
        onRetry: () => provider.fetchEvents(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Unified Security Events Timeline',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Real-time correlated timeline of findings from GitHub App, Domain Audits, and Cloud Firewall Integrations.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Filters Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search findings by title, asset, or evidence...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                provider.setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) => provider.setSearchQuery(val),
                  ),
                ),
                const SizedBox(width: 16),
                _filterDropdown(
                  'Severity',
                  provider.selectedSeverity,
                  ['All', 'Critical', 'High', 'Medium', 'Low', 'Informational'],
                  (val) => provider.setFilterSeverity(val!),
                ),
                const SizedBox(width: 12),
                _filterDropdown(
                  'Status',
                  provider.selectedStatus,
                  ['All', 'Open', 'Acknowledged', 'Resolved'],
                  (val) => provider.setFilterStatus(val!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Event Timeline List
          if (provider.events.isEmpty)
            const Expanded(
              child: EmptyStateView(
                title: 'No Matching Security Events',
                description: 'No events matched your search or severity filter criteria.',
                icon: Icons.search_off_rounded,
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: provider.events.length,
                itemBuilder: (context, idx) {
                  final event = provider.events[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => EventDetailDialog(
                            event: event,
                            onStatusChange: (newStatus) {
                              provider.updateEventStatus(event['id'], newStatus);
                            },
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          SeverityBadge(severity: event['severity'] ?? 'Low'),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['title'] ?? '',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      '${event['source']} • ${event['target_name']}',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      event['created_at']?.toString().split('T').first ?? '',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    )
                                  ],
                                )
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
                              event['status'] ?? 'Open',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
        ],
      ),
    );
  }

  Widget _filterDropdown(
    String label,
    String currentValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<String>(
        initialValue: currentValue,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: options
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(fontSize: 13))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
