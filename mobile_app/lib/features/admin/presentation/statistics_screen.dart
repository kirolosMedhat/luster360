import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_card.dart';
import '../application/admin_controller.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final analytics = adminState.analytics;

    final volume = (analytics?['captureVolume'] as List?) ?? [];
    final operators = (analytics?['topOperators'] as List?) ?? [];
    final modes = (analytics?['modeBreakdown'] as Map<String, dynamic>?) ?? {
      'slowMo': 68,
      'photo': 16,
      'gif': 10,
      'boomerang': 6,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('ANALYTICS & LEADERBOARD', style: LusterTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Weekly Capture Volume Bars
          Text('WEEKLY CAPTURE VOLUME', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 12),
          LusterCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: volume.map((v) {
                    final day = v['day'] ?? '';
                    final count = (v['count'] as num?)?.toInt() ?? 0;
                    final heightFactor = (count / 500.0).clamp(0.15, 1.0);

                    return Column(
                      children: [
                        Text('$count', style: const TextStyle(fontSize: 10, color: LusterColors.textMuted, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Container(
                          width: 28,
                          height: 100 * heightFactor,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [LusterColors.darkNavy, LusterColors.primaryBlue],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(day, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Capture Mode Distribution
          Text('POPULAR CAPTURE MODES', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 12),
          LusterCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildModeBar('360 High-Frame Slow-Mo', modes['slowMo'] ?? 68, LusterColors.primaryBlue),
                const SizedBox(height: 12),
                _buildModeBar('Burst GIF Sequence', modes['gif'] ?? 10, LusterColors.info),
                const SizedBox(height: 12),
                _buildModeBar('Still Photo Studio', modes['photo'] ?? 16, LusterColors.success),
                const SizedBox(height: 12),
                _buildModeBar('Boomerang Ping-Pong', modes['boomerang'] ?? 6, LusterColors.warning),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Operator Leaderboard
          Text('OPERATOR LEADERBOARD', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 12),
          ...operators.map((op) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: LusterCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: LusterColors.primaryBlue.withOpacity(0.15),
                          border: Border.all(color: LusterColors.primaryBlue.withOpacity(0.5)),
                        ),
                        child: Center(
                          child: Text(
                            (op['name'] as String? ?? 'O')[0],
                            style: const TextStyle(fontWeight: FontWeight.w800, color: LusterColors.primaryBlue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(op['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text('${op['eventCount']} Events Managed', style: const TextStyle(color: LusterColors.textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${op['spins']} Spins', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: LusterColors.primaryBlue)),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: LusterColors.warning, size: 14),
                              const SizedBox(width: 2),
                              Text(op['rating'] ?? '5.0', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildModeBar(String name, int percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text('$percent%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100.0,
            minHeight: 6,
            backgroundColor: LusterColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
