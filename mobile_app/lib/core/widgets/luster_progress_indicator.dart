import 'package:flutter/material.dart';
import '../theme/luster_colors.dart';
import '../theme/luster_typography.dart';

class LusterProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? label;
  final bool showPercentage;

  const LusterProgressIndicator({
    super.key,
    required this.progress,
    this.label,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percent = (clampedProgress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: LusterTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LusterColors.text,
                  ),
                ),
              if (showPercentage)
                Text(
                  '$percent%',
                  style: LusterTypography.monoTimer.copyWith(fontSize: 14),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: LusterColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: LusterColors.border, width: 0.5),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: constraints.maxWidth * clampedProgress,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [LusterColors.darkNavy, LusterColors.primaryBlue],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
