import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/grade_model.dart';

class GradeState {
  final List<GradeModel> grades;
  final GradeModel? selectedGrade;
  final bool isLoading;
  final String? error;

  GradeState({
    this.grades = const [],
    this.selectedGrade,
    this.isLoading = false,
    this.error,
  });

  GradeState copyWith({
    List<GradeModel>? grades,
    GradeModel? selectedGrade,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return GradeState(
      grades: grades ?? this.grades,
      selectedGrade: selectedGrade ?? this.selectedGrade,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class GradeNotifier extends StateNotifier<GradeState> {
  final DioClient _dioClient;

  GradeNotifier(this._dioClient) : super(GradeState());

  Future<void> loadGrades({Map<String, dynamic>? filters, String role = 'admin'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, dynamic>{};
      if (filters != null) {
        queryParams.addAll(filters);
      }
      final endpoint = role == 'teacher' ? ApiConstants.teacherGrades
          : role == 'student' ? ApiConstants.studentGrades
          : ApiConstants.grades;
      final response = await _dioClient.get(
        endpoint,
        queryParameters: queryParams,
      );
      final data = response.data;
      if (data['success'] == true) {
        final items = (data['data'] as List<dynamic>? ?? [])
            .map((e) => GradeModel.fromJson(e))
            .toList();
        state = state.copyWith(grades: items, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createGrade(Map<String, dynamic> data, {String role = 'teacher'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final endpoint = role == 'teacher' ? ApiConstants.teacherGrades : ApiConstants.grades;
      final response = await _dioClient.post(endpoint, data: data);
      final result = response.data;
      if (result['success'] == true) {
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateGrade(int id, Map<String, dynamic> data, {String role = 'teacher'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final endpoint = role == 'teacher' ? ApiConstants.teacherGrades : ApiConstants.grades;
      final response = await _dioClient.put(
        '$endpoint/$id',
        data: data,
      );
      final result = response.data;
      if (result['success'] == true) {
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteGrade(int id, {String role = 'admin'}) async {
    try {
      final endpoint = role == 'teacher' ? ApiConstants.teacherGrades : ApiConstants.grades;
      final response = await _dioClient.delete('$endpoint/$id');
      final result = response.data;
      if (result['success'] == true) {
        await loadGrades();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> submitGrades(List<Map<String, dynamic>> grades, {String role = 'teacher'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final endpoint = role == 'teacher' ? ApiConstants.teacherGradeBatch : ApiConstants.gradeAdminBatch;
      final response = await _dioClient.post(
        endpoint,
        data: {'grades': grades},
      );
      final result = response.data;
      if (result['success'] == true) {
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void setSelectedGrade(GradeModel? grade) {
    state = state.copyWith(selectedGrade: grade);
  }
}

final gradeProvider =
    StateNotifierProvider<GradeNotifier, GradeState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return GradeNotifier(dioClient);
});
