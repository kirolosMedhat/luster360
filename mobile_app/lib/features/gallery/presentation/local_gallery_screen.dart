import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../events/application/event_controller.dart';

class LocalGalleryScreen extends ConsumerStatefulWidget {
  const LocalGalleryScreen({super.key});

  @override
  ConsumerState<LocalGalleryScreen> createState() => _LocalGalleryScreenState();
}

class _LocalGalleryScreenState extends ConsumerState<LocalGalleryScreen> {
  String _selectedCategory = 'All Events';
  final List<String> _categories = ['All Events', 'Weddings', 'Corporate', 'Nightlife', 'Private'];

  final List<Map<String, dynamic>> _presetGalleries = [
    {
      'title': 'Neon Nights',
      'captures': 420,
      'gradient': [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
      'category': 'Nightlife',
    },
    {
      'title': 'Smith Wedding',
      'captures': 185,
      'gradient': [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
      'category': 'Weddings',
    },
    {
      'title': 'Tech Conf 23',
      'captures': 890,
      'gradient': [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
      'category': 'Corporate',
    },
    {
      'title': 'Summer Fest',
      'captures': 320,
      'gradient': [Color(0xFF134E5E), Color(0xFF71B280)],
      'category': 'Nightlife',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final eventState = ref.watch(eventProvider);

    // Combine preset galleries with real backend events
    final allGalleries = List<Map<String, dynamic>>.from(_presetGalleries);
    for (final e in eventState.events) {
      if (!allGalleries.any((g) => g['title'] == e.name)) {
        allGalleries.insert(0, {
          'title': e.name,
          'captures': e.videoCount > 0 ? e.videoCount : 48,
          'gradient': [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF6FB1FC)],
          'category': 'All Events',
        });
      }
    }

    final filtered = _selectedCategory == 'All Events'
        ? allGalleries
        : allGalleries.where((g) => g['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Galleries & Public URL button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Galleries',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),

                  // Public URL Pill Button
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: 'https://gallery.luster360.com'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Public Gallery URL copied to clipboard: https://gallery.luster360.com'),
                          backgroundColor: Color(0xFF00A3FF),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161822),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.link_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Public URL',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Horizontal Category Filter Chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : const Color(0xFF14151B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.white : const Color(0xFF1E202B),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.black : const Color(0xFF8E95A5),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 3. 2-Column Event Galleries Grid (matching media_1789558976711.png)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return GestureDetector(
                    onTap: () => context.push('/booth-mode'),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          colors: item['gradient'] as List<Color>,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Vignette & bottom dark gradient
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                colors: [Colors.transparent, Color(0xCC0B0C10), Color(0xF20B0C10)],
                                stops: [0.3, 0.75, 1.0],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),

                          // Top Icon
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.35),
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                            ),
                          ),

                          // Bottom Labels
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${item['captures']} captures',
                                  style: const TextStyle(
                                    color: Color(0xFF8E95A5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
