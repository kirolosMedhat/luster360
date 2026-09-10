import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/logging/app_logger.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final String apiUrl;

  AuthController({String? apiUrl})
      : apiUrl = apiUrl ?? AppConstants.defaultMediaApiUrl,
        super(const AuthState()) {
    checkSavedSession();
  }

  Future<void> checkSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final email = prefs.getString('auth_email');
      final name = prefs.getString('auth_name');
      final id = prefs.getString('auth_id');

      if (token != null && email != null) {
        state = state.copyWith(
          user: UserModel(
            id: id ?? '',
            email: email,
            fullName: name ?? 'Operator',
            role: 'OPERATOR',
            token: token,
          ),
          isAuthenticated: true,
        );
      }
    } catch (e) {
      AppLogger.error('Failed to restore session: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.trim(),
          'password': password,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final token = body['data']['token'] as String;
        final userData = body['data']['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userData, token);

        // Save to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('auth_email', user.email);
        await prefs.setString('auth_name', user.fullName);
        await prefs.setString('auth_id', user.id);

        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
          errorMessage: null,
        );

        AppLogger.info('Operator ${user.fullName} logged in successfully');
        return true;
      } else {
        final errorMsg = body['error']?['message'] ?? 'Invalid username or password';
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return false;
      }
    } catch (e) {
      AppLogger.error('Login request failed: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error. Could not connect to Luster Media API.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_email');
      await prefs.remove('auth_name');
      await prefs.remove('auth_id');
    } catch (_) {}

    state = const AuthState();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});
