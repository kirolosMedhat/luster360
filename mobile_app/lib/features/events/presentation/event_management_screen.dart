import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/event_controller.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_button.dart';
import '../../../core/widgets/luster_card.dart';
import '../../../core/widgets/luster_status_badge.dart';
import '../../../core/widgets/luster_dialog.dart';
import '../../../core/widgets/luster_text_field.dart';

class EventManagementScreen extends ConsumerWidget {
  const EventManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventProvider);
    final eventNotifier = ref.read(eventProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: LusterColors.primaryBlue),
            onPressed: () => _showCreateEventDialog(context, ref),
            tooltip: 'Create New Event',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Event Active Banner
          if (eventState.currentEvent != null) ...[
            Text('ACTIVE EVENT', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
            const SizedBox(height: 8),
            LusterCard(
              borderColor: LusterColors.primaryBlue.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          eventState.currentEvent!.name,
                          style: LusterTypography.displayMedium.copyWith(fontSize: 22),
                        ),
                      ),
                      LusterStatusBadge(
                        status: eventState.currentEvent!.isActive
                            ? LusterBoothStatus.ready
                            : LusterBoothStatus.idle,
                        customLabel: eventState.currentEvent!.status,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (eventState.currentEvent!.venue != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: LusterColors.textMuted),
                        const SizedBox(width: 4),
                        Text(eventState.currentEvent!.venue!, style: LusterTypography.bodyMedium),
                      ],
                    ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LIVE DURATION', style: LusterTypography.bodySmall),
                          const SizedBox(height: 2),
                          Text(
                            eventState.formattedDuration,
                            style: LusterTypography.monoTimer.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('VIDEOS RECORDED', style: LusterTypography.bodySmall),
                          const SizedBox(height: 2),
                          Text(
                            '${eventState.currentEvent!.videoCount}',
                            style: LusterTypography.titleMedium.copyWith(color: LusterColors.text),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (!eventState.currentEvent!.isActive)
                        Expanded(
                          child: LusterButton(
                            label: 'Start Event',
                            leadingIcon: Icons.play_arrow_rounded,
                            onPressed: () => eventNotifier.startEvent(eventState.currentEvent!.id),
                          ),
                        )
                      else ...[
                        Expanded(
                          child: LusterButton(
                            label: 'Pause',
                            variant: LusterButtonVariant.secondary,
                            leadingIcon: Icons.pause_rounded,
                            onPressed: () => eventNotifier.pauseEvent(eventState.currentEvent!.id),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LusterButton(
                            label: 'End Event',
                            variant: LusterButtonVariant.danger,
                            leadingIcon: Icons.stop_rounded,
                            onPressed: () => eventNotifier.endEvent(eventState.currentEvent!.id),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // All Events List
          Text('ALL EVENTS', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 8),
          ...eventState.events.map((event) {
            final isSelected = eventState.currentEvent?.id == event.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LusterCard(
                backgroundColor: isSelected ? LusterColors.panel : LusterColors.surface,
                borderColor: isSelected ? LusterColors.primaryBlue : LusterColors.border,
                onTap: () => eventNotifier.selectEvent(event.id),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: LusterColors.header,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.event_note_rounded, color: LusterColors.primaryBlue),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.name, style: LusterTypography.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            '${event.eventDate} • ${event.clientName}',
                            style: LusterTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, color: LusterColors.primaryBlue)
                    else
                      const Icon(Icons.chevron_right_rounded, color: LusterColors.textMuted),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final clientCtrl = TextEditingController();
    final venueCtrl = TextEditingController();

    LusterDialog.show(
      context: context,
      title: 'Create New Event',
      confirmLabel: 'Create Event',
      onConfirm: () {
        if (nameCtrl.text.isNotEmpty && clientCtrl.text.isNotEmpty) {
          // Add event logic
          Navigator.of(context).pop();
        }
      },
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LusterTextField(label: 'Event Name', hint: 'e.g. Karim & Salma Wedding', controller: nameCtrl),
          const SizedBox(height: 12),
          LusterTextField(label: 'Client Name', hint: 'e.g. Karim Fahmy', controller: clientCtrl),
          const SizedBox(height: 12),
          LusterTextField(label: 'Venue', hint: 'e.g. Semiramis InterContinental', controller: venueCtrl),
        ],
      ),
    );
  }
}
