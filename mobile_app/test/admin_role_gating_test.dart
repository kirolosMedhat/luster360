import 'package:flutter_test/flutter_test.dart';
import 'package:luster_360/features/auth/domain/user_model.dart';

void main() {
  group('Admin Role-Gating & UserModel Tests', () {
    test('Identifies admin roles correctly', () {
      final superAdmin = UserModel(
        id: 'u-1',
        email: 'admin@luster360.com',
        fullName: 'Super Admin',
        role: 'super_admin',
        token: 'token-1',
      );

      final companyAdmin = UserModel(
        id: 'u-2',
        email: 'company@luster360.com',
        fullName: 'Company Admin',
        role: 'company_admin',
        token: 'token-2',
      );

      final operator = UserModel(
        id: 'u-3',
        email: 'op@luster360.com',
        fullName: 'Booth Operator',
        role: 'operator',
        token: 'token-3',
      );

      final viewer = UserModel(
        id: 'u-4',
        email: 'viewer@luster360.com',
        fullName: 'Gallery Viewer',
        role: 'viewer',
        token: 'token-4',
      );

      expect(superAdmin.isAdmin, isTrue);
      expect(superAdmin.isSuperAdmin, isTrue);

      expect(companyAdmin.isAdmin, isTrue);
      expect(companyAdmin.isSuperAdmin, isFalse);

      expect(operator.isAdmin, isFalse);
      expect(operator.isSuperAdmin, isFalse);

      expect(viewer.isAdmin, isFalse);
      expect(viewer.isSuperAdmin, isFalse);
    });

    test('Parses UserModel from JSON with lowercased role', () {
      final user = UserModel.fromJson({
        'id': 'usr_99',
        'email': 'lead@luster360.com',
        'full_name': 'Sarah Field Lead',
        'role': 'SUPER_ADMIN',
      }, 'jwt_mock_token');

      expect(user.id, 'usr_99');
      expect(user.fullName, 'Sarah Field Lead');
      expect(user.role, 'super_admin');
      expect(user.isAdmin, isTrue);
    });

    test('Computes correct tab count based on role', () {
      List<String> getTabsForRole(String role) {
        final isAdmin = role == 'super_admin' || role == 'company_admin';
        return [
          'Dashboard',
          'Booth',
          'Gallery',
          'Settings',
          if (isAdmin) 'Admin',
        ];
      }

      final operatorTabs = getTabsForRole('operator');
      final superAdminTabs = getTabsForRole('super_admin');
      final companyAdminTabs = getTabsForRole('company_admin');
      final viewerTabs = getTabsForRole('viewer');

      expect(operatorTabs.length, 4);
      expect(operatorTabs.contains('Admin'), isFalse);

      expect(viewerTabs.length, 4);
      expect(viewerTabs.contains('Admin'), isFalse);

      expect(superAdminTabs.length, 5);
      expect(superAdminTabs.contains('Admin'), isTrue);

      expect(companyAdminTabs.length, 5);
      expect(companyAdminTabs.contains('Admin'), isTrue);
    });
  });
}
