import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_card.dart';
import '../../auth/application/auth_controller.dart';
import '../application/admin_controller.dart';

class AdminConsoleScreen extends ConsumerWidget {
  const AdminConsoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final adminState = ref.watch(adminProvider);
    final summary = adminState.summary;

    final activeDevices = summary?['activeDevicesCount'] ?? 1;
    final totalDevices = summary?['totalDevicesCount'] ?? 2;
    final totalCaptures = summary?['totalCaptures'] ?? 1240;
    final eventsCount = summary?['eventsThisMonth'] ?? 3;
    final storagePercent = (summary?['storageUsedPercent'] as num?)?.toInt() ?? 36;
    final alerts = (summary?['alerts'] as List?) ?? [];
    final recentActivity = (summary?['recentActivity'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded, color: LusterColors.primaryBlue),
            const SizedBox(width: 10),
            Text(
              'ADMIN CONSOLE',
              style: LusterTypography.titleLarge.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.0),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: LusterColors.primaryBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: LusterColors.primaryBlue.withOpacity(0.5)),
            ),
            child: Text(
              (authState.user?.role ?? 'ADMIN').toUpperCase(),
              style: const TextStyle(
                color: LusterColors.primaryBlue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: LusterColors.textMuted),
            onPressed: () => ref.read(adminProvider.notifier).refreshAll(),
          ),
        ],
      ),
      body: adminState.isLoading && summary == null
          ? const Center(child: CircularProgressIndicator(color: LusterColors.primaryBlue))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Alerts Banner
                if (alerts.isNotEmpty)
                  ...alerts.map((alert) {
                    final isWarning = alert['type'] == 'WARNING';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (isWarning ? LusterColors.warning : LusterColors.info).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (isWarning ? LusterColors.warning : LusterColors.info).withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isWarning ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                            color: isWarning ? LusterColors.warning : LusterColors.info,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert['title'] ?? 'System Notice',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: isWarning ? LusterColors.warning : LusterColors.info,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  alert['message'] ?? '',
                                  style: const TextStyle(color: LusterColors.text, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                // 2. High-Level KPI Matrix
                Text('FLEET OVERVIEW', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        title: 'ACTIVE UNITS',
                        value: '$activeDevices / $totalDevices',
                        icon: Icons.phonelink_ring_rounded,
                        accentColor: LusterColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        title: 'TOTAL SPINS',
                        value: '$totalCaptures',
                        icon: Icons.slow_motion_video_rounded,
                        accentColor: LusterColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        title: 'EVENTS THIS MO',
                        value: '$eventsCount',
                        icon: Icons.event_available_rounded,
                        accentColor: LusterColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricTile(
                        title: 'STORAGE USED',
                        value: '$storagePercent%',
                        icon: Icons.cloud_done_rounded,
                        accentColor: storagePercent > 80 ? LusterColors.warning : LusterColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Storage Quota Progress Bar
                LusterCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Google Drive Master Quota', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(
                            '$storagePercent% of 100 GB',
                            style: TextStyle(
                              color: storagePercent > 80 ? LusterColors.warning : LusterColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: storagePercent / 100.0,
                          minHeight: 8,
                          backgroundColor: LusterColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            storagePercent > 80 ? LusterColors.warning : LusterColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Governance Modules Navigation Grid
                Text('MANAGEMENT MODULES', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
                const SizedBox(height: 10),

                _buildNavigationTile(
                  context,
                  title: 'Device Fleet & Hardware Monitor',
                  subtitle: '$activeDevices online • Telemetry, battery & decommission',
                  icon: Icons.devices_other_rounded,
                  route: '/admin/fleet',
                ),
                _buildNavigationTile(
                  context,
                  title: 'Events & Captures Archive',
                  subtitle: 'Explore event metrics, video counts and direct drilldowns',
                  icon: Icons.folder_special_rounded,
                  route: '/admin/events',
                ),
                _buildNavigationTile(
                  context,
                  title: 'Analytics & Operator Leaderboard',
                  subtitle: 'Weekly volume, mode distributions and operator stats',
                  icon: Icons.bar_chart_rounded,
                  route: '/admin/statistics',
                ),
                _buildNavigationTile(
                  context,
                  title: 'User & Role Access Management',
                  subtitle: 'Invite operators, assign Super Admin and manage roles',
                  icon: Icons.manage_accounts_rounded,
                  route: '/admin/users',
                ),
                _buildNavigationTile(
                  context,
                  title: 'Cloud Storage & Drive Integration',
                  subtitle: 'Service account health, folder tree and raw archives',
                  icon: Icons.cloud_sync_rounded,
                  route: '/admin/storage',
                ),
                const SizedBox(height: 20),

                // 5. Recent Activity Feed
                if (recentActivity.isNotEmpty) ...[
                  Text('RECENT CAPTURE ACTIVITY', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
                  const SizedBox(height: 10),
                  ...recentActivity.map((act) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: LusterCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: LusterColors.primaryBlue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.slow_motion_video_rounded, color: LusterColors.primaryBlue, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(act['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text(act['subtitle'] ?? '', style: const TextStyle(color: LusterColors.textMuted, fontSize: 11)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: LusterColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                act['status'] ?? 'READY',
                                style: const TextStyle(color: LusterColors.success, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                ],
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return LusterCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: LusterColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
              Icon(icon, color: accentColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: LusterColors.text)),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: LusterCard(
        onTap: () => context.push(route),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: LusterColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: LusterColors.borderLight),
              ),
              child: Icon(icon, color: LusterColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: LusterColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: LusterColors.textMuted),
          ],
        ),
      ),
    );
  }
}
