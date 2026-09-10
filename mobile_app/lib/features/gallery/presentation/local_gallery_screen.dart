import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../events/application/event_controller.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_video_card.dart';
import '../../../core/widgets/luster_status_badge.dart';

class LocalGalleryScreen extends ConsumerWidget {
  const LocalGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventProvider);

    // Realistic demo event videos matching Ahmed & Mariam wedding
    final sampleVideos = [
      (code: '8F3K2A', title: 'Spin #127 (Mariam & Friends)', dur: '00:15', status: LusterBoothStatus.ready),
      (code: '9X7L4Q', title: 'Spin #126 (Ahmed Solo)', dur: '00:14', status: LusterBoothStatus.ready),
      (code: '4M9T1Z', title: 'Spin #125 (Family Group)', dur: '00:15', status: LusterBoothStatus.ready),
      (code: '2P8W5K', title: 'Spin #124 (Bride & Groom)', dur: '00:15', status: LusterBoothStatus.ready),
      (code: '7N3R9B', title: 'Spin #123 (VIP Table)', dur: '00:14', status: LusterBoothStatus.ready),
      (code: '1K6D8Y', title: 'Spin #122 (Dance Crew)', dur: '00:15', status: LusterBoothStatus.ready),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(eventState.currentEvent?.name ?? 'Event Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded, color: LusterColors.primaryBlue),
            tooltip: 'Event Gallery QR',
            onPressed: () => context.push('/share'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Summary Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: LusterColors.panel,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL VIDEOS', style: LusterTypography.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      '${eventState.currentEvent?.videoCount ?? 127} captures',
                      style: LusterTypography.titleMedium.copyWith(color: LusterColors.text),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('EVENT DURATION', style: LusterTypography.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      eventState.formattedDuration,
                      style: LusterTypography.monoTimer.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Video Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: sampleVideos.length,
              itemBuilder: (context, index) {
                final vid = sampleVideos[index];
                return LusterVideoCard(
                  title: vid.title,
                  duration: vid.dur,
                  shortCode: vid.code,
                  status: vid.status,
                  onTap: () {
                    // Preview video
                    context.push('/share');
                  },
                  onShare: () {
                    context.push('/share');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
