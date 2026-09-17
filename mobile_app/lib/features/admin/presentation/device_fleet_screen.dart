import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_card.dart';
import '../../../core/widgets/luster_button.dart';
import '../application/admin_controller.dart';

class DeviceFleetScreen extends ConsumerWidget {
  const DeviceFleetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final fleet = adminState.fleet;

    final onlineCount = fleet.where((d) => d['is_online'] == true).length;
    final offlineCount = fleet.length - onlineCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('DEVICE FLEET', style: LusterTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(adminProvider.notifier).refreshFleet(),
          ),
        ],
      ),
      body: adminState.isLoading && fleet.isEmpty
          ? const Center(child: CircularProgressIndicator(color: LusterColors.primaryBlue))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Fleet Summary Pills
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: LusterColors.panel,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: LusterColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: LusterColors.success),
                            ),
                            const SizedBox(width: 8),
                            Text('Online: $onlineCount', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: LusterColors.panel,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: LusterColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: LusterColors.stateOffline),
                            ),
                            const SizedBox(width: 8),
                            Text('Offline: $offlineCount', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text('REGISTERED HARDWARE UNITS', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
                const SizedBox(height: 10),

                if (fleet.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: const Center(
                      child: Text('No devices registered in fleet.', style: TextStyle(color: LusterColors.textMuted)),
                    ),
                  )
                else
                  ...fleet.map((device) => _buildDeviceCard(context, ref, device)),
              ],
            ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, WidgetRef ref, Map<String, dynamic> device) {
    final isOnline = device['is_online'] == true;
    final isDecommissioned = device['current_state'] == 'DECOMMISSIONED';
    final battery = device['battery_level'] as int? ?? 0;
    final isCharging = device['is_charging'] == true;
    final deviceId = device['device_identifier'] ?? 'DEVICE';
    final deviceName = device['device_name'] ?? 'Rotator Booth';
    final platform = device['platform'] ?? 'android';
    final storageFreeBytes = device['storage_free_bytes'] as num? ?? 0;
    final storageFreeGb = (storageFreeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: LusterCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      platform == 'ios' ? Icons.apple_rounded : Icons.phone_android_rounded,
                      color: LusterColors.primaryBlue,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(deviceId, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text(deviceName, style: const TextStyle(color: LusterColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDecommissioned
                        ? LusterColors.danger.withOpacity(0.15)
                        : (isOnline ? LusterColors.success : LusterColors.stateOffline).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isDecommissioned ? 'DECOMMISSIONED' : (isOnline ? 'ONLINE' : 'OFFLINE'),
                    style: TextStyle(
                      color: isDecommissioned
                          ? LusterColors.danger
                          : (isOnline ? LusterColors.success : LusterColors.stateOffline),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Live Telemetry Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isCharging ? Icons.battery_charging_full_rounded : Icons.battery_std_rounded,
                      color: battery < 20 ? LusterColors.danger : LusterColors.primaryBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text('$battery%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.sd_storage_rounded, color: LusterColors.textMuted, size: 18),
                    const SizedBox(width: 4),
                    Text('$storageFreeGb GB Free', style: const TextStyle(fontSize: 12, color: LusterColors.textMuted)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.speed_rounded, color: LusterColors.textMuted, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      device['operational_state'] ?? 'READY',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),

            if (!isDecommissioned) ...[
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.phonelink_erase_rounded, color: LusterColors.danger, size: 18),
                  label: const Text('Deauthorize Unit', style: TextStyle(color: LusterColors.danger, fontSize: 12)),
                  onPressed: () => _confirmDeauthorize(context, ref, deviceId),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDeauthorize(BuildContext context, WidgetRef ref, String deviceId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LusterColors.panel,
        title: const Text('Deauthorize Device?'),
        content: Text(
          'Are you sure you want to deauthorize device $deviceId? It will be disconnected immediately and blocked from capturing videos until reprovisioned.',
          style: const TextStyle(color: LusterColors.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: LusterColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: LusterColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(adminProvider.notifier).deauthorizeDevice(deviceId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Device $deviceId deauthorized' : 'Failed to deauthorize device'),
                    backgroundColor: success ? LusterColors.success : LusterColors.danger,
                  ),
                );
              }
            },
            child: const Text('Deauthorize', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
