import 'package:flutter/material.dart';
import '../theme/luster_colors.dart';
import '../theme/luster_typography.dart';
import 'luster_status_badge.dart';

class LusterDeviceCard extends StatelessWidget {
  final String deviceIdentifier;
  final String deviceName;
  final String platform;
  final int? batteryLevel;
  final bool isCharging;
  final LusterBoothStatus operationalState;
  final String? currentEventName;
  final String? storageFree;
  final bool isOnline;
  final VoidCallback? onTap;

  const LusterDeviceCard({
    super.key,
    required this.deviceIdentifier,
    required this.deviceName,
    required this.platform,
    this.batteryLevel,
    this.isCharging = false,
    required this.operationalState,
    this.currentEventName,
    this.storageFree,
    this.isOnline = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LusterColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOnline ? LusterColors.border : LusterColors.borderLight.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline ? LusterColors.success : LusterColors.danger,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        deviceIdentifier,
                        style: LusterTypography.titleMedium.copyWith(
                          color: isOnline ? LusterColors.text : LusterColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  LusterStatusBadge(status: operationalState),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                deviceName,
                style: LusterTypography.bodyMedium,
              ),
              if (currentEventName != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Event: $currentEventName',
                  style: LusterTypography.bodySmall.copyWith(color: LusterColors.primaryBlue),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (batteryLevel != null)
                    Row(
                      children: [
                        Icon(
                          isCharging ? Icons.battery_charging_full_rounded : Icons.battery_std_rounded,
                          size: 16,
                          color: batteryLevel! < 20 ? LusterColors.danger : LusterColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text('$batteryLevel%', style: LusterTypography.bodySmall),
                      ],
                    ),
                  if (storageFree != null)
                    Text(
                      '$storageFree free',
                      style: LusterTypography.bodySmall,
                    ),
                  Text(
                    platform.toUpperCase(),
                    style: LusterTypography.bodySmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
