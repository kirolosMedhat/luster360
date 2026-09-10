import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/event_model.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/logging/app_logger.dart';

class EventState {
  final List<EventModel> events;
  final EventModel? currentEvent;
  final String formattedDuration;
  final int durationSeconds;
  final bool isLoading;
  final String? error;

  const EventState({
    required this.events,
    this.currentEvent,
    this.formattedDuration = '00h 00m',
    this.durationSeconds = 0,
    this.isLoading = false,
    this.error,
  });

  EventState copyWith({
    List<EventModel>? events,
    EventModel? currentEvent,
    String? formattedDuration,
    int? durationSeconds,
    bool? isLoading,
    String? error,
  }) {
    return EventState(
      events: events ?? this.events,
      currentEvent: currentEvent ?? this.currentEvent,
      formattedDuration: formattedDuration ?? this.formattedDuration,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EventNotifier extends StateNotifier<EventState> {
  Timer? _durationTimer;

  EventNotifier() : super(const EventState(events: [])) {
    _initializeDemoEvents();
    _startDurationTimer();
  }

  void _initializeDemoEvents() {
    final now = DateTime.now().toUtc();
    // Simulate active event running for 4 hours and 42 minutes
    final demoStartedAt = now.subtract(const Duration(hours: 4, minutes: 42));

    final initialEvents = [
      EventModel(
        id: 'e0000001-0000-0000-0000-000000000001',
        name: 'Ahmed & Mariam Wedding',
        eventDate: '2026-09-10',
        startTime: '18:00',
        endTime: '23:59',
        venue: 'Four Seasons Nile Plaza, Cairo',
        clientName: 'Ahmed Hassan',
        clientContact: '+20 100 123 4567',
        status: 'ACTIVE',
        startedAt: demoStartedAt,
        gallerySlug: 'ahmed-mariam',
        brandColor: '#86CFFF',
        brandSecondaryColor: '#18283F',
        videoCount: 127,
        uploadedCount: 119,
        pendingCount: 8,
        failedCount: 0,
        driveRootFolderId: 'drive_folder_root_ahmed_mariam',
        driveVideosFolderId: 'drive_folder_videos_ahmed_mariam',
        driveThumbnailsFolderId: 'drive_folder_thumbs_ahmed_mariam',
      ),
      EventModel(
        id: 'e0000002-0000-0000-0000-000000000002',
        name: 'Vodafone Annual Gala 2026',
        eventDate: '2026-09-15',
        startTime: '19:00',
        venue: 'JW Marriott Cairo',
        clientName: 'Vodafone Egypt Events',
        status: 'DRAFT',
        gallerySlug: 'vodafone-gala-2026',
        videoCount: 0,
      ),
    ];

    state = state.copyWith(
      events: initialEvents,
      currentEvent: initialEvents.first,
    );

    _updateDuration();
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateDuration();
    });
  }

  void _updateDuration() {
    if (state.currentEvent == null || !state.currentEvent!.isActive) {
      if (state.currentEvent?.startedAt != null && state.currentEvent?.endedAt != null) {
        final calc = DurationFormatter.calculateEventDuration(
          startedAt: state.currentEvent!.startedAt,
          endedAt: state.currentEvent!.endedAt,
        );
        state = state.copyWith(
          formattedDuration: calc.formatted,
          durationSeconds: calc.durationSeconds,
        );
      }
      return;
    }

    final calc = DurationFormatter.calculateEventDuration(
      startedAt: state.currentEvent!.startedAt,
    );

    state = state.copyWith(
      formattedDuration: calc.formatted,
      durationSeconds: calc.durationSeconds,
    );
  }

  void selectEvent(String eventId) {
    final event = state.events.firstWhere((e) => e.id == eventId, orElse: () => state.events.first);
    state = state.copyWith(currentEvent: event);
    _updateDuration();
  }

  void startEvent(String eventId) {
    final now = DateTime.now().toUtc();
    final updatedList = state.events.map((e) {
      if (e.id == eventId) {
        return e.copyWith(status: 'ACTIVE', startedAt: now);
      }
      return e;
    }).toList();

    final current = updatedList.firstWhere((e) => e.id == eventId);
    state = state.copyWith(events: updatedList, currentEvent: current);
    AppLogger.info('Started event: ${current.name} at $now');
    _updateDuration();
  }

  void pauseEvent(String eventId) {
    final updatedList = state.events.map((e) {
      if (e.id == eventId) {
        return e.copyWith(status: 'PAUSED');
      }
      return e;
    }).toList();

    final current = updatedList.firstWhere((e) => e.id == eventId);
    state = state.copyWith(events: updatedList, currentEvent: current);
  }

  void endEvent(String eventId) {
    final now = DateTime.now().toUtc();
    final updatedList = state.events.map((e) {
      if (e.id == eventId) {
        return e.copyWith(status: 'COMPLETED', endedAt: now);
      }
      return e;
    }).toList();

    final current = updatedList.firstWhere((e) => e.id == eventId);
    state = state.copyWith(events: updatedList, currentEvent: current);
    _updateDuration();
  }

  void addVideoToCurrentEvent() {
    if (state.currentEvent == null) return;
    final updated = state.currentEvent!.copyWith(
      videoCount: state.currentEvent!.videoCount + 1,
      pendingCount: state.currentEvent!.pendingCount + 1,
    );

    final updatedList = state.events.map((e) => e.id == updated.id ? updated : e).toList();
    state = state.copyWith(events: updatedList, currentEvent: updated);
  }

  void markVideoUploaded() {
    if (state.currentEvent == null) return;
    final updated = state.currentEvent!.copyWith(
      uploadedCount: state.currentEvent!.uploadedCount + 1,
      pendingCount: (state.currentEvent!.pendingCount - 1).clamp(0, 9999),
    );

    final updatedList = state.events.map((e) => e.id == updated.id ? updated : e).toList();
    state = state.copyWith(events: updatedList, currentEvent: updated);
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }
}

final eventProvider = StateNotifierProvider<EventNotifier, EventState>((ref) {
  return EventNotifier();
});
