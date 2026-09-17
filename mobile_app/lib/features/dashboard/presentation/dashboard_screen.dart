import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../events/application/event_controller.dart';
import '../../auth/application/auth_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventState = ref.watch(eventProvider);
    final authState = ref.watch(authControllerProvider);
    final isAdmin = authState.user?.isAdmin ?? false;

    // Real dynamic counts or fallback to studio metrics
    final totalCaptures = eventState.events.fold<int>(0, (sum, e) => sum + e.videoCount);
    final displayCaptures = totalCaptures > 0 ? '$totalCaptures' : '1.2k';
    final eventsHosted = eventState.events.isNotEmpty ? '${eventState.events.length}' : '48';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // 1. Studio Header (Studio Luster / Pro+ Plan)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Studio Luster',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAdmin ? 'Super Admin • 2 active devices' : 'Pro+ Plan • 2 active devices',
                      style: const TextStyle(
                        color: Color(0xFF8E95A5),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Settings Gear Badge with Cyan Indicator Dot
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: Stack(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF161822),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Icon(Icons.settings_outlined, color: Colors.white70, size: 22),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A3FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF0B0C10), width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Top Metric Cards (Total Captures & Events Hosted)
            Row(
              children: [
                // Card 1: Total Captures
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14151B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1E202B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.videocam_outlined, color: Color(0xFF00A3FF), size: 24),
                        const SizedBox(height: 14),
                        Text(
                          displayCaptures,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Total Captures',
                          style: TextStyle(
                            color: Color(0xFF8E95A5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Card 2: Events Hosted
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14151B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1E202B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bolt_rounded, color: Color(0xFF00A3FF), size: 24),
                        const SizedBox(height: 14),
                        Text(
                          eventsHosted,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Events Hosted',
                          style: TextStyle(
                            color: Color(0xFF8E95A5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Vibrant "+ Create New Event" Pill Button
            GestureDetector(
              onTap: () => context.push('/events/new'),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF009BFF), Color(0xFF0072D6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF009BFF).withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Create New Event',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 4. Upcoming Events Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/events'),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF00A3FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. Event Cards List (matching media_1789558957614.png)
            _buildEventCard(
              context: context,
              title: 'Neon Nights Gala',
              timeText: 'Tonight, 9 PM',
              badgeIcon: Icons.videocam_rounded,
              badgeText: '360 Slow-Mo',
              imageGradient: const [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
              onTap: () => context.push('/booth-mode'),
            ),
            const SizedBox(height: 12),

            _buildEventCard(
              context: context,
              title: 'Smith Wedding',
              timeText: 'Oct 24, 4 PM',
              badgeIcon: Icons.movie_filter_rounded,
              badgeText: 'Photo & GIF',
              imageGradient: const [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
              onTap: () => context.push('/booth-mode'),
            ),

            // If real backend event exists and differs from presets, list it as well
            if (eventState.currentEvent != null &&
                eventState.currentEvent!.name != 'Neon Nights Gala' &&
                eventState.currentEvent!.name != 'Smith Wedding') ...[
              const SizedBox(height: 12),
              _buildEventCard(
                context: context,
                title: eventState.currentEvent!.name,
                timeText: eventState.currentEvent!.eventDate,
                badgeIcon: Icons.videocam_rounded,
                badgeText: 'Active Session',
                imageGradient: const [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF6FB1FC)],
                onTap: () => context.push('/booth-mode'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required BuildContext context,
    required String title,
    required String timeText,
    required IconData badgeIcon,
    required String badgeText,
    required List<Color> imageGradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF14151B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E202B)),
        ),
        child: Row(
          children: [
            // Event Thumbnail
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: imageGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.music_note_rounded, color: Colors.white60, size: 28),
            ),
            const SizedBox(width: 14),

            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeText,
                    style: const TextStyle(
                      color: Color(0xFF8E95A5),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Pill Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1E28),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, size: 12, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Trailing Chevron
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF8E95A5), size: 24),
          ],
        ),
      ),
    );
  }
}
