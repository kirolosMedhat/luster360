import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booth Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Device Identity
          Text('DEVICE IDENTITY', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 8),
          LusterCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LUSTER-360-001', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    SizedBox(height: 2),
                    Text('Registered to: Cairo Operations', style: TextStyle(color: LusterColors.textMuted, fontSize: 13)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: LusterColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: LusterColors.success.withOpacity(0.4)),
                  ),
                  child: const Text('PAIRED', style: TextStyle(color: LusterColors.success, fontWeight: FontWeight.w700, fontSize: 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cloud Storage & Media API
          Text('CLOUD MEDIA ENGINE', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 8),
          LusterCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Primary Media Storage', style: TextStyle(fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: LusterColors.accentMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Google Drive V1', style: TextStyle(color: LusterColors.primaryBlue, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Media API Gateway', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('localhost:4000/api/v1', style: LusterTypography.monoTimer.copyWith(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Storage Manager Link
          Text('STORAGE MANAGEMENT', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 8),
          LusterCard(
            onTap: () => context.push('/storage-manager'),
            child: const Row(
              children: [
                Icon(Icons.storage_rounded, color: LusterColors.primaryBlue),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Device Storage & Retention', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('42 GB Free • Manage Raw Footage', style: TextStyle(color: LusterColors.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: LusterColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Future Hardware Integration (Honest "NOT CONNECTED")
          Text('HARDWARE EXPANSIONS', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 8),
          _buildHardwareTile('GoPro Hero 11/12', 'NOT CONNECTED', Icons.camera_alt_outlined),
          const SizedBox(height: 8),
          _buildHardwareTile('Sony Alpha Mirrorless', 'NOT CONNECTED', Icons.camera_outlined),
          const SizedBox(height: 8),
          _buildHardwareTile('Canon EOS Tether', 'NOT CONNECTED', Icons.photo_camera_outlined),
          const SizedBox(height: 8),
          _buildHardwareTile('360 Turntable BLE Controller', 'DISCONNECTED', Icons.bluetooth_disabled_rounded),
        ],
      ),
    );
  }

  Widget _buildHardwareTile(String name, String status, IconData icon) {
    return LusterCard(
      child: Row(
        children: [
          Icon(icon, color: LusterColors.textMuted),
          const SizedBox(width: 14),
          Expanded(
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: LusterColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: LusterColors.border),
            ),
            child: Text(status, style: const TextStyle(color: LusterColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
