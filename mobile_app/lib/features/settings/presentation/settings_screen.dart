import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/application/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isAdmin = authState.user?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // 1. Header
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 28),

            // 2. HARDWARE SETUP Section
            const Text(
              'HARDWARE SETUP',
              style: TextStyle(
                color: Color(0xFF8E95A5),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF14151B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E202B)),
              ),
              child: Column(
                children: [
                  // Main Camera Tile
                  InkWell(
                    onTap: () => context.push('/booth-mode'),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.camera_alt_outlined, color: Color(0xFF00A3FF), size: 22),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Main Camera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                                SizedBox(height: 3),
                                Text('GoPro Hero 11 Connected', style: TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF8E95A5), size: 22),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xFF1E202B), height: 1),

                  // Remote Trigger Tile
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_android_rounded, color: Color(0xFF8E95A5), size: 22),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Remote Trigger', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                              SizedBox(height: 3),
                              Text('Pair second device', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF222530),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Text('Pair', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 3. BUSINESS Section
            const Text(
              'BUSINESS',
              style: TextStyle(
                color: Color(0xFF8E95A5),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF14151B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E202B)),
              ),
              child: Column(
                children: [
                  // Branding & White-Label Tile
                  _buildSettingsTile(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Branding & White-Label',
                    onTap: () => context.push('/editor'),
                  ),
                  const Divider(color: Color(0xFF1E202B), height: 1),

                  // Cloud Storage Tile
                  _buildSettingsTile(
                    icon: Icons.cloud_upload_outlined,
                    title: 'Cloud Storage (85% used)',
                    onTap: () {
                      if (isAdmin) {
                        context.push('/admin/storage');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cloud Storage: Google Drive Master Synchronized (85% quota)')),
                        );
                      }
                    },
                  ),
                  const Divider(color: Color(0xFF1E202B), height: 1),

                  // Team Accounts / Admin Console Tile
                  _buildSettingsTile(
                    icon: Icons.manage_accounts_outlined,
                    title: isAdmin ? 'Team Accounts (Admin Console)' : 'Team Accounts',
                    onTap: () {
                      if (isAdmin) {
                        context.push('/admin');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Team accounts managed by studio administrator.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // 4. Sign Out Pill Button (matching media_1789558981568.png)
            GestureDetector(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF14151B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Sign Out?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    content: const Text('Are you sure you want to sign out from the booth app?', style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel', style: TextStyle(color: Colors.white60))),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30)),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1215),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFF4A181C), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Color(0xFFFF3B30),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF8E95A5), size: 22),
          ],
        ),
      ),
    );
  }
}
