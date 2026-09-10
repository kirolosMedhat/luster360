import 'package:flutter/material.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_button.dart';
import '../../../core/widgets/luster_card.dart';
import '../../../core/widgets/luster_dialog.dart';

class StorageManagerScreen extends StatefulWidget {
  const StorageManagerScreen({super.key});

  @override
  State<StorageManagerScreen> createState() => _StorageManagerScreenState();
}

class _StorageManagerScreenState extends State<StorageManagerScreen> {
  bool _cleanedRaw = false;

  void _confirmCleanRawFootage() {
    LusterDialog.show(
      context: context,
      title: 'Clean Raw Footage',
      confirmLabel: 'Clean 8.2 GB',
      isDestructive: true,
      onConfirm: () {
        setState(() {
          _cleanedRaw = true;
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Safely removed raw footage for verified uploaded videos. Final MP4s preserved.'),
            backgroundColor: LusterColors.success,
          ),
        );
      },
      content: const Text(
        'This action permanently removes raw camera capture files for videos that have already been verified and uploaded to Google Drive. Final rendered MP4 videos and thumbnails will NOT be deleted.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawSize = _cleanedRaw ? '0.0 GB' : '8.2 GB';
    final freeSpace = _cleanedRaw ? '50.2 GB' : '42.0 GB';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Manager'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total Disk Overview Card
          LusterCard(
            borderColor: LusterColors.primaryBlue.withOpacity(0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('DEVICE STORAGE', style: LusterTypography.bodySmall),
                    Text('$freeSpace Available', style: LusterTypography.monoTimer.copyWith(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      Expanded(flex: 30, child: Container(height: 14, color: LusterColors.primaryBlue)),
                      Expanded(flex: 20, child: Container(height: 14, color: LusterColors.warning)),
                      Expanded(flex: 5, child: Container(height: 14, color: LusterColors.info)),
                      Expanded(flex: 45, child: Container(height: 14, color: LusterColors.borderLight)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Detailed Breakdown
          Text('MEDIA STORAGE LIFECYCLE', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 10),

          _buildStorageItem(
            title: 'Raw Camera Captures',
            subtitle: 'Uncompressed high-FPS source videos',
            size: rawSize,
            color: LusterColors.warning,
            icon: Icons.video_camera_back_outlined,
          ),
          const SizedBox(height: 10),

          _buildStorageItem(
            title: 'Final Rendered 360 MP4s',
            subtitle: 'Complete videos with speed ramp & overlays',
            size: '5.4 GB',
            color: LusterColors.primaryBlue,
            icon: Icons.movie_outlined,
          ),
          const SizedBox(height: 10),

          _buildStorageItem(
            title: 'Thumbnails & Posters',
            subtitle: 'WebP and JPEG preview posters',
            size: '120 MB',
            color: LusterColors.info,
            icon: Icons.image_outlined,
          ),
          const SizedBox(height: 10),

          _buildStorageItem(
            title: 'Pending Cloud Uploads',
            subtitle: 'Queued local files awaiting sync',
            size: '1.8 GB',
            color: LusterColors.danger,
            icon: Icons.cloud_upload_outlined,
          ),

          const SizedBox(height: 32),

          // Safe Cleanup Controls
          Text('SAFE STORAGE RETENTION', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 10),
          LusterCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Operator Raw File Cleanup', style: LusterTypography.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Remove raw camera footage after upload is verified in Google Drive. Never deletes un-uploaded footage.',
                  style: LusterTypography.bodySmall,
                ),
                const SizedBox(height: 16),
                LusterButton(
                  label: _cleanedRaw ? 'Raw Footage Cleaned' : 'Clean Verified Raw Footage',
                  variant: LusterButtonVariant.secondary,
                  leadingIcon: Icons.cleaning_services_rounded,
                  onPressed: _cleanedRaw ? null : _confirmCleanRawFootage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageItem({
    required String title,
    required String subtitle,
    required String size,
    required Color color,
    required IconData icon,
  }) {
    return LusterCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: LusterTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: LusterColors.text)),
                Text(subtitle, style: LusterTypography.bodySmall),
              ],
            ),
          ),
          Text(size, style: LusterTypography.monoTimer.copyWith(fontSize: 14, color: LusterColors.text)),
        ],
      ),
    );
  }
}
