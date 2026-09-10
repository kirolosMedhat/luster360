import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/luster_colors.dart';

class LusterIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final bool isPrimary;
  final BorderSide? border;

  const LusterIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.size = 48,
    this.iconSize = 22,
    this.isPrimary = false,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? (isPrimary ? LusterColors.primaryBlue : LusterColors.surface);
    final effectiveFg = color ?? (isPrimary ? LusterColors.darkNavy : LusterColors.text);

    Widget button = Material(
      color: onPressed != null ? effectiveBg : effectiveBg.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: border ?? const BorderSide(color: LusterColors.border, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed != null
            ? () {
                HapticFeedback.lightImpact();
                onPressed!();
              }
            : null,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(icon, color: effectiveFg, size: iconSize),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
