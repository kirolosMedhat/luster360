import 'package:flutter/material.dart';
import '../theme/luster_colors.dart';
import '../theme/luster_typography.dart';

class LusterSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String Function(double)? valueFormatter;

  const LusterSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = valueFormatter != null ? valueFormatter!(value) : value.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: LusterTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: LusterColors.text,
              ),
            ),
            Text(
              displayValue,
              style: LusterTypography.monoTimer.copyWith(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: LusterColors.primaryBlue,
            inactiveTrackColor: LusterColors.border,
            thumbColor: LusterColors.primaryBlue,
            overlayColor: LusterColors.accentMuted,
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
