import 'package:flutter/material.dart';
import '../theme/luster_colors.dart';
import '../theme/luster_typography.dart';
import 'luster_button.dart';

class LusterDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String? confirmLabel;
  final VoidCallback? onConfirm;
  final String cancelLabel;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const LusterDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel,
    this.onConfirm,
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.isDestructive = false,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String? confirmLabel,
    VoidCallback? onConfirm,
    String cancelLabel = 'Cancel',
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: LusterColors.overlayBackdrop,
      builder: (ctx) => LusterDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        cancelLabel: cancelLabel,
        onCancel: onCancel ?? () => Navigator.of(ctx).pop(),
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: LusterColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: LusterColors.border, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: LusterTypography.titleLarge),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LusterButton(
                  label: cancelLabel,
                  variant: LusterButtonVariant.subtle,
                  height: 42,
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                ),
                if (confirmLabel != null) ...[
                  const SizedBox(width: 12),
                  LusterButton(
                    label: confirmLabel!,
                    variant: isDestructive ? LusterButtonVariant.danger : LusterButtonVariant.primary,
                    height: 42,
                    onPressed: onConfirm,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
