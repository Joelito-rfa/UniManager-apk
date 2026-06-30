import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors/app_exception.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final String? token;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.token,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    String? token,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : error ?? this.error,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final StorageService _storageService;

  AuthNotifier(this._authService, this._storageService)
      : super(const AuthState());

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final hasToken = await _storageService.hasToken();
      if (!hasToken) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          token: null,
        );
        return;
      }
      final token = await _storageService.getToken();
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          token: token,
        );
      } else {
        await _storageService.clearTokens();
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          token: null,
        );
      }
    } catch (e) {
      await _storageService.clearTokens();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        token: null,
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final response = await _authService.login(email, password);
      if (response.success && response.data != null) {
        final token = await _storageService.getToken();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.data,
          token: token,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: response.message ?? 'La connexion a échoué',
        );
      }
    } on AppException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Une erreur est survenue',
      );
    }
  }

  Future<String?> registerStudent({
    required String studentNumber,
    required String dateOfBirth,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final response = await _authService.registerStudent(
        studentNumber: studentNumber,
        dateOfBirth: dateOfBirth,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (response.success && response.data != null) {
        final token = await _storageService.getToken();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.data,
          token: token,
          clearError: true,
        );
        return null;
      }
      state = state.copyWith(status: AuthStatus.error, error: response.message);
      return response.message;
    } on AppException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
      return e.message;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: 'Une erreur est survenue');
      return 'Une erreur est survenue';
    }
  }

  Future<String?> registerTeacher({
    required String teacherNumber,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final response = await _authService.registerTeacher(
        teacherNumber: teacherNumber,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (response.success && response.data != null) {
        final token = await _storageService.getToken();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.data,
          token: token,
          clearError: true,
        );
        return null;
      }
      state = state.copyWith(status: AuthStatus.error, error: response.message);
      return response.message;
    } on AppException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
      return e.message;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: 'Une erreur est survenue');
      return 'Une erreur est survenue';
    }
  }

  Future<String?> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String invitationCode,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final response = await _authService.registerAdmin(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        invitationCode: invitationCode,
      );
      if (response.success && response.data != null) {
        final token = await _storageService.getToken();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.data,
          token: token,
          clearError: true,
        );
        return null;
      }
      state = state.copyWith(status: AuthStatus.error, error: response.message);
      return response.message;
    } on AppException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
      return e.message;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: 'Une erreur est survenue');
      return 'Une erreur est survenue';
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<String?> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _authService.updateProfile(data);
      if (response.success && response.data != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.data,
        );
        await _storageService.saveUserData(jsonEncode(response.data!.toJson()));
        return null;
      }
      return response.message ?? 'Une erreur est survenue';
    } on AppException catch (e) {
      return e.message;
    } catch (e) {
      return 'Une erreur est survenue';
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      if (response.success) {
        state = state.copyWith(status: AuthStatus.authenticated);
        return null;
      }
      state = state.copyWith(status: AuthStatus.authenticated);
      return response.message ?? 'Une erreur est survenue';
    } on AppException catch (e) {
      state = state.copyWith(status: AuthStatus.authenticated);
      return e.message;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.authenticated);
      return 'Une erreur est survenue';
    }
  }

  void forceLogout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  final storageService = ref.read(storageServiceProvider);
  return AuthNotifier(authService, storageService);
});
