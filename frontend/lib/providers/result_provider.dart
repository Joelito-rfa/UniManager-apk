import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../core/constants/api_constants.dart';
import '../models/result_model.dart';

class ResultState {
  final List<ResultModel> results;
  final ResultModel? selectedResult;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;

  const ResultState({
    this.results = const [],
    this.selectedResult,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  ResultState copyWith({
    List<ResultModel>? results,
    ResultModel? selectedResult,
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? currentPage,
    int? lastPage,
    int? total,
  }) {
    return ResultState(
      results: results ?? this.results,
      selectedResult: selectedResult ?? this.selectedResult,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
    );
  }
}

class ResultNotifier extends StateNotifier<ResultState> {
  final DioClient _dioClient;

  ResultNotifier(this._dioClient) : super(const ResultState());

  Future<void> loadResults({
    int page = 1,
    String? search,
    int? studentId,
    int? courseId,
    int? levelId,
    int? programId,
    int? departmentId,
    String? semester,
    String? academicYear,
    String? decision,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final params = <String, dynamic>{
        'page': page,
        'per_page': 10,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (studentId != null) params['student_id'] = studentId;
      if (courseId != null) params['course_id'] = courseId;
      if (levelId != null) params['level_id'] = levelId;
      if (programId != null) params['program_id'] = programId;
      if (departmentId != null) params['department_id'] = departmentId;
      if (semester != null) params['semester'] = semester;
      if (academicYear != null) params['academic_year'] = academicYear;
      if (decision != null) params['decision'] = decision;

      final response = await _dioClient.get(ApiConstants.results, queryParameters: params);
      final paginated = PaginatedResponse.fromJson(
        response.data,
        (json) => ResultModel.fromJson(json as Map<String, dynamic>),
      );

      state = state.copyWith(
        results: paginated.items.cast<ResultModel>(),
        isLoading: false,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
        total: paginated.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> publish({int? levelId, int? courseId, List<int>? ids}) async {
    try {
      final data = <String, dynamic>{};
      if (levelId != null) data['level_id'] = levelId;
      if (courseId != null) data['course_id'] = courseId;
      if (ids != null) data['ids'] = ids;
      final response = await _dioClient.post('${ApiConstants.results}/publish', data: data);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> calculate({int? courseId, int? studentId, String? semester, String? academicYear}) async {
    try {
      final data = <String, dynamic>{};
      if (courseId != null) data['course_id'] = courseId;
      if (studentId != null) data['student_id'] = studentId;
      if (semester != null) data['semester'] = semester;
      if (academicYear != null) data['academic_year'] = academicYear;
      final response = await _dioClient.post('${ApiConstants.results}/calculate', data: data);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> recalculateAll() async {
    try {
      final response = await _dioClient.post('${ApiConstants.results}/recalculate');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateResult(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put('${ApiConstants.results}/$id', data: data);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteResult(int id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.results}/$id');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTranscript(int studentId) async {
    try {
      final response = await _dioClient.get('${ApiConstants.results}/transcript/$studentId');
      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final resultProvider = StateNotifierProvider<ResultNotifier, ResultState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ResultNotifier(dioClient);
});
