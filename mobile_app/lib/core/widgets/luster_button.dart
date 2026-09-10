import 'package:flutter/material.dart';
import '../theme/luster_colors.dart';
import '../theme/luster_typography.dart';

enum LusterButtonVariant { primary, secondary, subtle, danger }

class LusterButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final LusterButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final double? width;
  final double height;

  const LusterButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = LusterButtonVariant.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case LusterButtonVariant.primary:
        bg = LusterColors.primaryBlue;
        fg = LusterColors.darkNavy;
        break;
      case LusterButtonVariant.secondary:
        bg = LusterColors.surface;
        fg = LusterColors.text;
        border = const BorderSide(color: LusterColors.border, width: 1);
        break;
      case LusterButtonVariant.subtle:
        bg = Colors.transparent;
        fg = LusterColors.primaryBlue;
        break;
      case LusterButtonVariant.danger:
        bg = LusterColors.danger;
        fg = LusterColors.pureWhite;
        break;
    }

    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: isEnabled ? bg : bg.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: border,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isEnabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else if (leadingIcon != null) ...[
                  Icon(leadingIcon, color: fg, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: LusterTypography.buttonLabel.copyWith(color: fg),
                ),
                if (trailingIcon != null && !isLoading) ...[
                  const SizedBox(width: 8),
                  Icon(trailingIcon, color: fg, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
