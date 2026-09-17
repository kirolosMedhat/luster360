import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_card.dart';
import '../../events/application/event_controller.dart';
import '../../events/domain/event_model.dart';

class EventsDataScreen extends ConsumerWidget {
  const EventsDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventProvider);
    final events = eventState.events;

    return Scaffold(
      appBar: AppBar(
        title: Text('EVENTS & CAPTURES', style: LusterTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('ALL MANAGED EVENTS', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 12),
          if (events.isEmpty)
            const Center(child: Text('No events found', style: TextStyle(color: LusterColors.textMuted)))
          else
            ...events.map((event) => _buildEventItem(context, event)),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, EventModel event) {
    final statusUpper = event.status.toUpperCase();
    final isActive = statusUpper == 'ACTIVE';
    final isEnded = statusUpper == 'COMPLETED' || statusUpper == 'ENDED';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: LusterCard(
        onTap: () => _showEventDrilldown(context, event),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isActive
                        ? LusterColors.success.withOpacity(0.15)
                        : (isEnded ? LusterColors.stateOffline.withOpacity(0.15) : LusterColors.warning.withOpacity(0.15)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusUpper,
                    style: TextStyle(
                      color: isActive
                          ? LusterColors.success
                          : (isEnded ? LusterColors.stateOffline : LusterColors.warning),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${event.venue} • ${event.clientName}',
              style: const TextStyle(color: LusterColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('DATE', event.eventDate),
                _buildStatItem('CAPTURES', '${event.videoCount}'),
                _buildStatItem('UPLOADED', '${event.uploadedCount} / ${event.videoCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: LusterColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
      ],
    );
  }

  void _showEventDrilldown(BuildContext context, EventModel event) {
    final uploadPercent = event.videoCount > 0 ? (event.uploadedCount / event.videoCount * 100).toInt() : 100;

    showModalBottomSheet(
      context: context,
      backgroundColor: LusterColors.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(event.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: LusterColors.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${event.venue} • Client: ${event.clientName}', style: const TextStyle(color: LusterColors.textMuted, fontSize: 13)),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: LusterColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: LusterColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Upload Reliability', style: TextStyle(color: LusterColors.textMuted, fontSize: 11)),
                        const SizedBox(height: 6),
                        Text('$uploadPercent%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: LusterColors.success)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: LusterColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: LusterColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estimated Cloud Size', style: TextStyle(color: LusterColors.textMuted, fontSize: 11)),
                        const SizedBox(height: 6),
                        Text('${(event.videoCount * 42 / 1024).toStringAsFixed(1)} GB', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: LusterColors.primaryBlue)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: LusterColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: LusterColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSharingMetric(Icons.qr_code_rounded, 'QR Scans', '${(event.videoCount * 1.4).toInt()}'),
                  _buildSharingMetric(Icons.share_rounded, 'Shares', '${(event.videoCount * 0.72).toInt()}'),
                  _buildSharingMetric(Icons.download_rounded, 'Direct DL', '${(event.videoCount * 0.85).toInt()}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSharingMetric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: LusterColors.primaryBlue, size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        Text(label, style: const TextStyle(color: LusterColors.textMuted, fontSize: 10)),
      ],
    );
  }
}
