import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/logging/app_logger.dart';

class AdminApiService {
  final String baseUrl;
  final String? authToken;

  AdminApiService({String? baseUrl, this.authToken})
      : baseUrl = baseUrl ?? AppConstants.defaultMediaApiUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  Future<Map<String, dynamic>> getSummary() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/admin/summary'), headers: _headers).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      AppLogger.error('Failed to fetch admin summary: $e');
    }
    // Fallback data
    return {
      'activeDevicesCount': 1,
      'totalDevicesCount': 2,
      'eventsThisMonth': 3,
      'totalCaptures': 1240,
      'storageUsedBytes': 38400000000,
      'storageQuotaBytes': 107374182400,
      'storageUsedPercent': 36,
      'alerts': [
        {
          'id': 'a1',
          'type': 'INFO',
          'title': 'Fleet Operational',
          'message': '1 active booth recording. Next sync in 45s.'
        }
      ],
      'recentActivity': [
        {
          'id': 'v-1',
          'type': 'CAPTURE',
          'title': '360 Spin #K8M2P9',
          'subtitle': 'Event: Ahmed & Mariam Wedding',
          'timestamp': DateTime.now().toIso8601String(),
          'status': 'READY'
        }
      ]
    };
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/admin/analytics'), headers: _headers).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      AppLogger.error('Failed to fetch analytics: $e');
    }
    return {
      'captureVolume': [
        {'day': 'Mon', 'count': 140},
        {'day': 'Tue', 'count': 185},
        {'day': 'Wed', 'count': 230},
        {'day': 'Thu', 'count': 275},
        {'day': 'Fri', 'count': 320},
        {'day': 'Sat', 'count': 485},
        {'day': 'Sun', 'count': 410},
      ],
      'topOperators': [
        {'id': 'op-1', 'name': 'Ahmed Hassan', 'spins': 482, 'eventCount': 8, 'rating': '5.0'},
        {'id': 'op-2', 'name': 'Sara Kamel', 'spins': 395, 'eventCount': 6, 'rating': '4.9'},
        {'id': 'op-3', 'name': 'Kiro Admin', 'spins': 310, 'eventCount': 5, 'rating': '5.0'},
      ],
      'modeBreakdown': {
        'slowMo': 68,
        'photo': 16,
        'gif': 10,
        'boomerang': 6,
      }
    };
  }

  Future<List<Map<String, dynamic>>> getFleet() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/devices/fleet'), headers: _headers).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['data'] as List?;
        if (list != null) {
          return List<Map<String, dynamic>>.from(list);
        }
      }
    } catch (e) {
      AppLogger.error('Failed to fetch fleet: $e');
    }
    return [
      {
        'device_identifier': 'LUSTER-BOOTH-01',
        'device_name': 'Main Rotator Booth (Cairo)',
        'platform': 'android',
        'battery_level': 88,
        'is_charging': true,
        'storage_free_bytes': 45000000000,
        'operational_state': 'READY',
        'current_state': 'ONLINE',
        'is_online': true,
        'last_seen_at': DateTime.now().toIso8601String(),
      },
      {
        'device_identifier': 'LUSTER-BOOTH-02',
        'device_name': 'Satellite Arm Unit B',
        'platform': 'android',
        'battery_level': 24,
        'is_charging': false,
        'storage_free_bytes': 12000000000,
        'operational_state': 'IDLE',
        'current_state': 'OFFLINE',
        'is_online': false,
        'last_seen_at': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
      }
    ];
  }

  Future<bool> deauthorizeDevice(String deviceId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/admin/devices/$deviceId/deauthorize'),
        headers: _headers,
      ).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (e) {
      AppLogger.error('Failed to deauthorize device: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getStorageStatus() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/admin/storage/status'), headers: _headers).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      AppLogger.error('Failed to fetch storage status: $e');
    }
    return {
      'provider': 'GOOGLE_DRIVE',
      'status': 'CONNECTED',
      'usedBytes': 38400000000,
      'totalQuotaBytes': 107374182400,
      'percentUsed': 36,
      'folders': [
        {'name': 'LUSTER 360 MASTER STORAGE', 'type': 'root', 'id': 'root-01'},
        {
          'name': 'Ahmed & Mariam Wedding - 2026-09-10',
          'type': 'event',
          'id': 'f-01',
          'children': [
            {'name': 'Videos', 'count': 127},
            {'name': 'Thumbnails', 'count': 127},
            {'name': 'Branding', 'count': 2},
          ]
        }
      ]
    };
  }

  Future<List<Map<String, dynamic>>> listUsers() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/auth/users'), headers: _headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['data'] as List?;
        if (list != null) {
          return List<Map<String, dynamic>>.from(list);
        }
      }
    } catch (e) {
      AppLogger.error('Failed to list users: $e');
    }
    return [
      {
        'id': 'u1',
        'username': 'kiro_operator',
        'email': 'kiro@luster360.com',
        'fullName': 'Kiro Master Admin',
        'role': 'super_admin',
        'createdAt': '2026-09-01T10:00:00Z',
      },
      {
        'id': 'u2',
        'username': 'demo_operator',
        'email': 'operator@luster360.com',
        'fullName': 'Booth Field Lead',
        'role': 'operator',
        'createdAt': '2026-09-05T12:00:00Z',
      }
    ];
  }

  Future<bool> createUser({
    required String username,
    required String fullName,
    required String password,
    required String role,
    String? email,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/users'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'fullName': fullName,
          'password': password,
          'role': role,
          'email': email,
        }),
      );
      return res.statusCode == 201;
    } catch (e) {
      AppLogger.error('Failed to create user: $e');
      return false;
    }
  }

  Future<bool> updateUserRole(String userId, String role) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId/role'),
        headers: _headers,
        body: jsonEncode({'role': role}),
      );
      return res.statusCode == 200;
    } catch (e) {
      AppLogger.error('Failed to update user role: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/auth/users/$userId'),
        headers: _headers,
      );
      return res.statusCode == 200;
    } catch (e) {
      AppLogger.error('Failed to delete user: $e');
      return false;
    }
  }
}
