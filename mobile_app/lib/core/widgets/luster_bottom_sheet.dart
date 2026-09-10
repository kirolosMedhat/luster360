import 'package:flutter/material.dart';
import '../theme/luster_colors.dart';
import '../theme/luster_typography.dart';

class LusterBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const LusterBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    Widget? action,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: LusterColors.panel,
      isScrollControlled: true,
      barrierColor: LusterColors.overlayBackdrop,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => LusterBottomSheet(
        title: title,
        action: action,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: LusterColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: LusterTypography.titleLarge),
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: 16),
            Flexible(child: SingleChildScrollView(child: child)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
