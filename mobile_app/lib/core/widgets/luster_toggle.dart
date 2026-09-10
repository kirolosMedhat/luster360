import 'package:flutter/material.dart';
import '../theme/luster_colors.dart';
import '../theme/luster_typography.dart';

class LusterToggle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const LusterToggle({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: LusterColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LusterColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: LusterTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LusterColors.text,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: LusterTypography.bodySmall),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: LusterColors.primaryBlue,
            activeTrackColor: LusterColors.accentMuted,
            inactiveThumbColor: LusterColors.textMuted,
            inactiveTrackColor: LusterColors.border,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
