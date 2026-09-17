import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_controller.dart';
import '../data/admin_api_service.dart';

class AdminState {
  final bool isLoading;
  final Map<String, dynamic>? summary;
  final Map<String, dynamic>? analytics;
  final List<Map<String, dynamic>> fleet;
  final Map<String, dynamic>? storage;
  final List<Map<String, dynamic>> users;
  final String? error;

  const AdminState({
    this.isLoading = false,
    this.summary,
    this.analytics,
    this.fleet = const [],
    this.storage,
    this.users = const [],
    this.error,
  });

  AdminState copyWith({
    bool? isLoading,
    Map<String, dynamic>? summary,
    Map<String, dynamic>? analytics,
    List<Map<String, dynamic>>? fleet,
    Map<String, dynamic>? storage,
    List<Map<String, dynamic>>? users,
    String? error,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      analytics: analytics ?? this.analytics,
      fleet: fleet ?? this.fleet,
      storage: storage ?? this.storage,
      users: users ?? this.users,
      error: error,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminApiService _api;

  AdminNotifier(this._api) : super(const AdminState()) {
    refreshAll();
  }

  Future<void> refreshAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final summary = await _api.getSummary();
      final analytics = await _api.getAnalytics();
      final fleet = await _api.getFleet();
      final storage = await _api.getStorageStatus();
      final users = await _api.listUsers();

      state = state.copyWith(
        isLoading: false,
        summary: summary,
        analytics: analytics,
        fleet: fleet,
        storage: storage,
        users: users,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> deauthorizeDevice(String deviceId) async {
    final ok = await _api.deauthorizeDevice(deviceId);
    if (ok) {
      final updatedFleet = state.fleet.map((d) {
        if (d['device_identifier'] == deviceId) {
          final copy = Map<String, dynamic>.from(d);
          copy['current_state'] = 'DECOMMISSIONED';
          copy['is_online'] = false;
          return copy;
        }
        return d;
      }).toList();
      state = state.copyWith(fleet: updatedFleet);
    }
    return ok;
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    final ok = await _api.updateUserRole(userId, newRole);
    if (ok) {
      final updatedUsers = state.users.map((u) {
        if (u['id'] == userId) {
          final copy = Map<String, dynamic>.from(u);
          copy['role'] = newRole;
          return copy;
        }
        return u;
      }).toList();
      state = state.copyWith(users: updatedUsers);
    }
    return ok;
  }

  Future<bool> createUser({
    required String username,
    required String fullName,
    required String password,
    required String role,
    String? email,
  }) async {
    final ok = await _api.createUser(
      username: username,
      fullName: fullName,
      password: password,
      role: role,
      email: email,
    );
    if (ok) {
      await refreshUsers();
    }
    return ok;
  }

  Future<bool> deleteUser(String userId) async {
    final ok = await _api.deleteUser(userId);
    if (ok) {
      final updatedUsers = state.users.where((u) => u['id'] != userId).toList();
      state = state.copyWith(users: updatedUsers);
    }
    return ok;
  }

  Future<void> refreshUsers() async {
    final users = await _api.listUsers();
    state = state.copyWith(users: users);
  }

  Future<void> refreshFleet() async {
    final fleet = await _api.getFleet();
    state = state.copyWith(fleet: fleet);
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final auth = ref.watch(authControllerProvider);
  final api = AdminApiService(authToken: auth.user?.token);
  return AdminNotifier(api);
});
