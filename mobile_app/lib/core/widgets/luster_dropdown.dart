import 'package:flutter/material.dart';
import '../theme/luster_colors.dart';
import '../theme/luster_typography.dart';

class LusterDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const LusterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: LusterTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: LusterColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: LusterColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LusterColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              dropdownColor: LusterColors.surface,
              isExpanded: true,
              style: LusterTypography.bodyLarge,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: LusterColors.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }
}
