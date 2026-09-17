import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_card.dart';
import '../application/admin_controller.dart';

class StorageIntegrationScreen extends ConsumerWidget {
  const StorageIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final storage = adminState.storage;

    final provider = storage?['provider'] ?? 'GOOGLE_DRIVE';
    final status = storage?['status'] ?? 'CONNECTED';
    final percentUsed = (storage?['percentUsed'] as num?)?.toInt() ?? 36;
    final folders = (storage?['folders'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('CLOUD STORAGE & DRIVE', style: LusterTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Service Provider Health Card
          LusterCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: LusterColors.primaryBlue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_to_drive_rounded, color: LusterColors.primaryBlue, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(provider, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            const Text('Service Account OAuth2 Integration', style: TextStyle(color: LusterColors.textMuted, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: LusterColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(color: LusterColors.success, fontWeight: FontWeight.w800, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Master Quota Usage', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    Text(
                      '$percentUsed% (38.4 GB / 100 GB)',
                      style: const TextStyle(color: LusterColors.primaryBlue, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentUsed / 100.0,
                    minHeight: 8,
                    backgroundColor: LusterColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(LusterColors.primaryBlue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Drive Folder Structure
          Text('DRIVE MASTER DIRECTORY TREE', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
          const SizedBox(height: 12),

          ...folders.map((f) => _buildFolderTile(f)),
        ],
      ),
    );
  }

  Widget _buildFolderTile(Map<String, dynamic> folder) {
    final name = folder['name'] ?? '';
    final children = (folder['children'] as List?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: LusterCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder_rounded, color: LusterColors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
            if (children.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  children: children.map((c) {
                    final cName = c['name'] ?? '';
                    final count = c['count'] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.subdirectory_arrow_right_rounded, size: 16, color: LusterColors.textMuted),
                          const SizedBox(width: 6),
                          Text(cName, style: const TextStyle(color: LusterColors.textMuted, fontSize: 12)),
                          const Spacer(),
                          Text('$count items', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
