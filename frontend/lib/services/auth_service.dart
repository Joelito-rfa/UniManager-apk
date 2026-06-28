import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dioClient = ref.read(dioClientProvider);
  final storageService = ref.read(storageServiceProvider);
  return AuthService(dioClient, storageService);
});

class AuthService {
  final DioClient _dioClient;
  final StorageService _storageService;

  AuthService(this._dioClient, this._storageService);

  Future<ApiResponse<UserModel>> login(String email, String password) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data;
    if (data['success'] == true) {
      final token = data['data']['access_token'] as String;
      final refreshToken = data['data']['refresh_token'] as String?;
      final userData = data['data']['user'];
      final user = UserModel.fromJson(userData);
      await _storageService.saveToken(token);
      if (refreshToken != null) {
        await _storageService.saveRefreshToken(refreshToken);
      }
      await _storageService.saveUserData(userData.toString());
      return ApiResponse.success(user, message: data['message']);
    }
    return ApiResponse.error(data['message'] ?? 'La connexion a échoué');
  }

  Future<ApiResponse<UserModel>> registerStudent({
    required String studentNumber,
    required String dateOfBirth,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.registerStudent,
      data: {
        'student_number': studentNumber,
        'date_of_birth': dateOfBirth,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    final data = response.data;
    if (data['token'] != null) {
      final token = data['token'] as String;
      final userData = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);
      await _storageService.saveToken(token);
      await _storageService.saveUserData(userData.toString());
      return ApiResponse.success(user, message: 'Inscription réussie');
    }
    return ApiResponse.error(data['message'] ?? 'Une erreur est survenue');
  }

  Future<ApiResponse<UserModel>> registerTeacher({
    required String teacherNumber,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.registerTeacher,
      data: {
        'teacher_number': teacherNumber,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    final data = response.data;
    if (data['token'] != null) {
      final token = data['token'] as String;
      final userData = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);
      await _storageService.saveToken(token);
      await _storageService.saveUserData(userData.toString());
      return ApiResponse.success(user, message: 'Inscription réussie');
    }
    return ApiResponse.error(data['message'] ?? 'Une erreur est survenue');
  }

  Future<ApiResponse<UserModel>> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String invitationCode,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.registerAdmin,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'invitation_code': invitationCode,
      },
    );
    final data = response.data;
    if (data['token'] != null) {
      final token = data['token'] as String;
      final userData = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);
      await _storageService.saveToken(token);
      await _storageService.saveUserData(userData.toString());
      return ApiResponse.success(user, message: 'Inscription réussie');
    }
    return ApiResponse.error(data['message'] ?? 'Une erreur est survenue');
  }

  Future<ApiResponse<Map<String, dynamic>>> checkStudent(String studentNumber) async {
    final response = await _dioClient.post(
      ApiConstants.checkStudent,
      data: {'student_number': studentNumber},
    );
    final data = response.data;
    if (data['success'] == true) {
      return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
    }
    return ApiResponse.error(data['message'] ?? 'Étudiant non trouvé');
  }

  Future<ApiResponse<Map<String, dynamic>>> checkTeacher(String teacherNumber) async {
    final response = await _dioClient.post(
      ApiConstants.checkTeacher,
      data: {'teacher_number': teacherNumber},
    );
    final data = response.data;
    if (data['success'] == true) {
      return ApiResponse.success(data['data'] as Map<String, dynamic>, message: data['message']);
    }
    return ApiResponse.error(data['message'] ?? 'Enseignant non trouvé');
  }

  Future<void> logout() async {
    try {
      await _dioClient.post(ApiConstants.logout);
    } catch (_) {}
    await _storageService.clearTokens();
  }

  Future<bool> isAuthenticated() async {
    return await _storageService.hasToken();
  }

  Future<String?> getToken() async {
    return await _storageService.getToken();
  }

  Future<void> saveToken(String token) async {
    await _storageService.saveToken(token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storageService.saveRefreshToken(token);
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _dioClient.get(ApiConstants.me);
      final data = response.data;
      if (data['success'] == true) {
        return UserModel.fromJson(data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dioClient.put(ApiConstants.updateProfile, data: data);
    final responseData = response.data;
    if (responseData['success'] == true) {
      final user = UserModel.fromJson(responseData['data']);
      return ApiResponse.success(user, message: responseData['message']);
    }
    return ApiResponse.error(responseData['message'] ?? 'Une erreur est survenue');
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await _dioClient.post(ApiConstants.changePassword, data: {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    });
    final data = response.data;
    if (data['success'] == true) {
      return ApiResponse.success(null, message: data['message']);
    }
    return ApiResponse.error(data['message'] ?? 'Une erreur est survenue');
  }

  Future<ApiResponse<void>> forgotPassword(String email) async {
    final response = await _dioClient.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
    final data = response.data;
    if (data['success'] == true) {
      return ApiResponse.success(null, message: data['message']);
    }
    return ApiResponse.error(data['message'] ?? 'Une erreur est survenue');
  }

  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.resetPassword,
      data: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    final data = response.data;
    if (data['success'] == true) {
      return ApiResponse.success(null, message: data['message']);
    }
    return ApiResponse.error(data['message'] ?? 'Une erreur est survenue');
  }
}
