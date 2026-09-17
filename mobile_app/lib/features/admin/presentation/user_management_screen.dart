import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_card.dart';
import '../../../core/widgets/luster_button.dart';
import '../../../core/widgets/luster_text_field.dart';
import '../application/admin_controller.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final List<String> availableRoles = ['super_admin', 'company_admin', 'operator', 'viewer'];

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final users = adminState.users;

    return Scaffold(
      appBar: AppBar(
        title: Text('USER GOVERNANCE', style: LusterTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: LusterColors.primaryBlue),
            onPressed: () => _showCreateUserModal(context),
          ),
        ],
      ),
      body: adminState.isLoading && users.isEmpty
          ? const Center(child: CircularProgressIndicator(color: LusterColors.primaryBlue))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('SYSTEM USERS & ROLES', style: LusterTypography.bodySmall.copyWith(letterSpacing: 1.0)),
                const SizedBox(height: 12),
                if (users.isEmpty)
                  const Center(child: Text('No users found', style: TextStyle(color: LusterColors.textMuted)))
                else
                  ...users.map((user) => _buildUserCard(context, user)),
              ],
            ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user) {
    final userId = user['id'] ?? '';
    final username = user['username'] ?? '';
    final fullName = user['fullName'] ?? user['full_name'] ?? 'Operator';
    final email = user['email'] ?? '';
    final role = (user['role'] ?? 'operator').toString().toLowerCase();

    Color roleBadgeColor;
    if (role == 'super_admin') {
      roleBadgeColor = LusterColors.primaryBlue;
    } else if (role == 'company_admin') {
      roleBadgeColor = LusterColors.info;
    } else if (role == 'operator') {
      roleBadgeColor = LusterColors.success;
    } else {
      roleBadgeColor = LusterColors.textMuted;
    }

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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: roleBadgeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.person_rounded, color: roleBadgeColor),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('@$username • $email', style: const TextStyle(color: LusterColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleBadgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: roleBadgeColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(color: roleBadgeColor, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit_attributes_rounded, size: 16, color: LusterColors.primaryBlue),
                  label: const Text('Change Role', style: TextStyle(color: LusterColors.primaryBlue, fontSize: 12)),
                  onPressed: () => _showChangeRoleModal(context, userId, fullName, role),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: LusterColors.danger),
                  label: const Text('Delete', style: TextStyle(color: LusterColors.danger, fontSize: 12)),
                  onPressed: () => _confirmDeleteUser(context, userId, fullName),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeRoleModal(BuildContext context, String userId, String fullName, String currentRole) {
    String selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: LusterColors.panel,
          title: Text('Change Role: $fullName', style: const TextStyle(fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableRoles.map((role) {
              return RadioListTile<String>(
                title: Text(role.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                value: role,
                groupValue: selectedRole,
                activeColor: LusterColors.primaryBlue,
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedRole = val);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: LusterColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: LusterColors.primaryBlue),
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await ref.read(adminProvider.notifier).updateUserRole(userId, selectedRole);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Role updated to ${selectedRole.toUpperCase()}' : 'Failed to update role'),
                      backgroundColor: success ? LusterColors.success : LusterColors.danger,
                    ),
                  );
                }
              },
              child: const Text('Save Role', style: TextStyle(color: LusterColors.darkNavy, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateUserModal(BuildContext context) {
    final usernameCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'operator';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: LusterColors.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create New System User', style: LusterTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              LusterTextField(label: 'Username', controller: usernameCtrl, hint: 'e.g. sara_operator'),
              const SizedBox(height: 12),
              LusterTextField(label: 'Full Name', controller: nameCtrl, hint: 'e.g. Sara Kamel'),
              const SizedBox(height: 12),
              LusterTextField(label: 'Email Address', controller: emailCtrl, hint: 'sara@luster360.com'),
              const SizedBox(height: 12),
              LusterTextField(label: 'Password', controller: passwordCtrl, obscureText: true, hint: '••••••••'),
              const SizedBox(height: 16),
              const Text('System Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: LusterColors.textMuted)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedRole,
                dropdownColor: LusterColors.surface,
                items: availableRoles.map((r) {
                  return DropdownMenuItem(value: r, child: Text(r.toUpperCase()));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedRole = val);
                },
              ),
              const SizedBox(height: 20),
              LusterButton(
                label: 'CREATE USER',
                leadingIcon: Icons.check_circle_rounded,
                onPressed: () async {
                  if (usernameCtrl.text.isEmpty || nameCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all required fields'), backgroundColor: LusterColors.danger),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  final ok = await ref.read(adminProvider.notifier).createUser(
                        username: usernameCtrl.text.trim(),
                        fullName: nameCtrl.text.trim(),
                        password: passwordCtrl.text,
                        role: selectedRole,
                        email: emailCtrl.text.trim(),
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'User created successfully' : 'Failed to create user'),
                        backgroundColor: ok ? LusterColors.success : LusterColors.danger,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, String userId, String fullName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LusterColors.panel,
        title: const Text('Delete User?'),
        content: Text('Are you sure you want to remove user "$fullName"? They will no longer be able to log in to Luster 360.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: LusterColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: LusterColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(adminProvider.notifier).deleteUser(userId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'User removed' : 'Failed to remove user'),
                    backgroundColor: ok ? LusterColors.success : LusterColors.danger,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
