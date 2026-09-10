import 'package:flutter/material.dart';
import '../theme/luster_colors.dart';
import '../theme/luster_typography.dart';

enum LusterBoothStatus {
  idle,
  ready,
  countdown,
  recording,
  processing,
  rendering,
  uploading,
  error,
  offline,
}

class LusterStatusBadge extends StatefulWidget {
  final LusterBoothStatus status;
  final String? customLabel;

  const LusterStatusBadge({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  State<LusterStatusBadge> createState() => _LusterStatusBadgeState();
}

class _LusterStatusBadgeState extends State<LusterStatusBadge> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    bool pulse = false;

    switch (widget.status) {
      case LusterBoothStatus.idle:
        color = LusterColors.textMuted;
        label = 'IDLE';
        break;
      case LusterBoothStatus.ready:
        color = LusterColors.stateReady;
        label = 'READY';
        break;
      case LusterBoothStatus.countdown:
        color = LusterColors.warning;
        label = 'COUNTDOWN';
        pulse = true;
        break;
      case LusterBoothStatus.recording:
        color = LusterColors.stateRecording;
        label = 'RECORDING';
        pulse = true;
        break;
      case LusterBoothStatus.processing:
        color = LusterColors.stateRendering;
        label = 'PROCESSING';
        pulse = true;
        break;
      case LusterBoothStatus.rendering:
        color = LusterColors.stateRendering;
        label = 'RENDERING';
        pulse = true;
        break;
      case LusterBoothStatus.uploading:
        color = LusterColors.stateUploading;
        label = 'UPLOADING';
        pulse = true;
        break;
      case LusterBoothStatus.error:
        color = LusterColors.danger;
        label = 'ERROR';
        break;
      case LusterBoothStatus.offline:
        color = LusterColors.stateOffline;
        label = 'OFFLINE';
        break;
    }

    final displayText = widget.customLabel ?? label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          pulse
              ? FadeTransition(
                  opacity: _animController,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                )
              : Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
          const SizedBox(width: 6),
          Text(
            displayText,
            style: LusterTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
