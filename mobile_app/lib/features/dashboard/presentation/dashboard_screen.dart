import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../events/application/event_controller.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_button.dart';
import '../../../core/widgets/luster_card.dart';
import '../../../core/widgets/luster_status_badge.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 28,
              errorBuilder: (_, __, ___) => const Icon(Icons.blur_on_rounded, color: LusterColors.primaryBlue),
            ),
            const SizedBox(width: 10),
            Text('LUSTER 360', style: LusterTypography.titleLarge.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.0)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: LusterColors.text),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Live Active Event Hero Card
          LusterCard(
            borderColor: LusterColors.primaryBlue.withOpacity(0.6),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ACTIVE EVENT', style: LusterTypography.bodySmall.copyWith(color: LusterColors.primaryBlue, fontWeight: FontWeight.w700)),
                    const LusterStatusBadge(status: LusterBoothStatus.ready),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  eventState.currentEvent?.name ?? 'Ahmed & Mariam Wedding',
                  style: LusterTypography.displayMedium.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  '${eventState.currentEvent?.venue ?? 'Four Seasons Nile Plaza'} • ${eventState.currentEvent?.clientName ?? 'Ahmed Hassan'}',
                  style: LusterTypography.bodyMedium,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Live Metrics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CURRENT DURATION', style: LusterTypography.bodySmall),
                        const SizedBox(height: 2),
                        Text(eventState.formattedDuration, style: LusterTypography.monoTimer.copyWith(fontSize: 22)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('CAPTURES', style: LusterTypography.bodySmall),
                        const SizedBox(height: 2),
                        Text('${eventState.currentEvent?.videoCount ?? 127}', style: LusterTypography.titleLarge),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('UPLOADED', style: LusterTypography.bodySmall),
                        const SizedBox(height: 2),
                        Text(
                          '${eventState.currentEvent?.uploadedCount ?? 119} / ${eventState.currentEvent?.videoCount ?? 127}',
                          style: LusterTypography.titleMedium.copyWith(color: LusterColors.success),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Primary Booth Launch CTA
                LusterButton(
                  label: 'LAUNCH 360 BOOTH',
                  leadingIcon: Icons.camera_alt_rounded,
                  height: 54,
                  onPressed: () => context.push('/booth-mode'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Operational Quick Shortcuts
          Text('BOOTH WORKFLOW', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: LusterCard(
                  onTap: () => context.push('/capture'),
                  child: const Column(
                    children: [
                      Icon(Icons.videocam_rounded, color: LusterColors.primaryBlue, size: 32),
                      SizedBox(height: 8),
                      Text('Camera View', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Capture Mode', style: TextStyle(color: LusterColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LusterCard(
                  onTap: () => context.push('/editor'),
                  child: const Column(
                    children: [
                      Icon(Icons.slow_motion_video_rounded, color: LusterColors.primaryBlue, size: 32),
                      SizedBox(height: 8),
                      Text('360 Editor', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Speed & Overlays', style: TextStyle(color: LusterColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LusterCard(
                  onTap: () => context.push('/gallery'),
                  child: const Column(
                    children: [
                      Icon(Icons.collections_rounded, color: LusterColors.primaryBlue, size: 32),
                      SizedBox(height: 8),
                      Text('Event Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Review Spins', style: TextStyle(color: LusterColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LusterCard(
                  onTap: () => context.push('/events'),
                  child: const Column(
                    children: [
                      Icon(Icons.event_note_rounded, color: LusterColors.primaryBlue, size: 32),
                      SizedBox(height: 8),
                      Text('Events List', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Switch Event', style: TextStyle(color: LusterColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Device Diagnostics & Fleet Telemetry
          Text('BOOTH TELEMETRY', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 10),
          LusterCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.phone_android_rounded, color: LusterColors.textMuted),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LUSTER-360-001', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Battery: 84% • 42 GB Free', style: TextStyle(color: LusterColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: LusterColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('ONLINE', style: TextStyle(color: LusterColors.success, fontWeight: FontWeight.w700, fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
