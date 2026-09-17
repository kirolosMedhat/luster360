import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/event_controller.dart';

class NewEventScreen extends ConsumerStatefulWidget {
  const NewEventScreen({super.key});

  @override
  ConsumerState<NewEventScreen> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends ConsumerState<NewEventScreen> {
  final _nameController = TextEditingController(text: 'Neon Nights Gala');
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 21, minute: 0);
  String _selectedMode = '360 Slow-Mo';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    ref.read(eventProvider.notifier).createEvent(
      name: name,
      clientName: 'VIP Client',
      venue: 'Luxury Venue',
      date: _selectedDate,
    );

    context.push('/booth-mode');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0C10),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'New Event',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // 1. Event Name
                const Text(
                  'Event Name',
                  style: TextStyle(color: Color(0xFF8E95A5), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF14151B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E202B)),
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: InputBorder.none,
                      hintText: 'Enter event name',
                      hintStyle: TextStyle(color: Colors.white30),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Date & Time Row
                Row(
                  children: [
                    // Date Field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 13)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setState(() => _selectedDate = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF14151B),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF1E202B)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                  const Icon(Icons.calendar_today_outlined, color: Colors.white38, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Time Field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Time', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 13)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(context: context, initialTime: _selectedTime);
                              if (picked != null) setState(() => _selectedTime = picked);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF14151B),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF1E202B)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedTime.format(context),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                  const Icon(Icons.access_time_rounded, color: Colors.white38, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Capture Modes Section (2x2 Grid)
                const Text(
                  'Capture Modes',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildModeCard(
                        title: '360 Slow-Mo',
                        icon: Icons.videocam_outlined,
                        isSelected: _selectedMode == '360 Slow-Mo',
                        onTap: () => setState(() => _selectedMode = '360 Slow-Mo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModeCard(
                        title: 'Photo',
                        icon: Icons.camera_alt_outlined,
                        isSelected: _selectedMode == 'Photo',
                        onTap: () => setState(() => _selectedMode = 'Photo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildModeCard(
                        title: 'GIF',
                        icon: Icons.movie_filter_outlined,
                        isSelected: _selectedMode == 'GIF',
                        onTap: () => setState(() => _selectedMode = 'GIF'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModeCard(
                        title: 'Boomerang',
                        icon: Icons.bolt_rounded,
                        isSelected: _selectedMode == 'Boomerang',
                        onTap: () => setState(() => _selectedMode = 'Boomerang'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. Overlays & Branding
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Overlays & Branding',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A3FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Pro Feature', style: TextStyle(color: Color(0xFF00A3FF), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14151B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E202B)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.file_upload_outlined, color: Colors.white70),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Upload Custom Frame', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('PNG with transparency', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Sticky Bottom Gradient Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: _handleSave,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF009BFF), Color(0xFF0072D6)],
                    ),
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF009BFF).withOpacity(0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Next: Booth Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF14151B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00A3FF) : const Color(0xFF1E202B),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF00A3FF) : Colors.white70, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00A3FF) : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
