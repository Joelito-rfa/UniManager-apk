import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../models/level_result_model.dart';

class LevelResultState {
  final List<LevelResultModel> results;
  final LevelResultModel? selectedResult;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;

  const LevelResultState({
    this.results = const [],
    this.selectedResult,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  LevelResultState copyWith({
    List<LevelResultModel>? results,
    LevelResultModel? selectedResult,
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? currentPage,
    int? lastPage,
    int? total,
  }) {
    return LevelResultState(
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

class LevelResultNotifier extends StateNotifier<LevelResultState> {
  final DioClient _dioClient;

  LevelResultNotifier(this._dioClient) : super(const LevelResultState());

  static const String _endpoint = '/admin/level-results';

  Future<void> loadResults({
    int page = 1,
    String? search,
    int? levelId,
    int? programId,
    int? departmentId,
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
      if (levelId != null) params['level_id'] = levelId;
      if (programId != null) params['program_id'] = programId;
      if (departmentId != null) params['department_id'] = departmentId;
      if (academicYear != null) params['academic_year'] = academicYear;
      if (decision != null) params['decision'] = decision;

      final response = await _dioClient.get(_endpoint, queryParameters: params);
      final paginated = PaginatedResponse.fromJson(
        response.data,
        (json) => LevelResultModel.fromJson(json as Map<String, dynamic>),
      );

      state = state.copyWith(
        results: paginated.items.cast<LevelResultModel>(),
        isLoading: false,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
        total: paginated.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> calculate({int? studentId, int? levelId, int? programId, String? academicYear}) async {
    try {
      final data = <String, dynamic>{};
      if (studentId != null) data['student_id'] = studentId;
      if (levelId != null) data['level_id'] = levelId;
      if (programId != null) data['program_id'] = programId;
      if (academicYear != null) data['academic_year'] = academicYear;
      final response = await _dioClient.post('$_endpoint/calculate', data: data);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> publish({int? levelId, int? programId, String? academicYear, List<int>? ids}) async {
    try {
      final data = <String, dynamic>{};
      if (levelId != null) data['level_id'] = levelId;
      if (programId != null) data['program_id'] = programId;
      if (academicYear != null) data['academic_year'] = academicYear;
      if (ids != null) data['ids'] = ids;
      final response = await _dioClient.post('$_endpoint/publish', data: data);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteResult(int id) async {
    try {
      final response = await _dioClient.delete('$_endpoint/$id');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}

final levelResultProvider = StateNotifierProvider<LevelResultNotifier, LevelResultState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return LevelResultNotifier(dioClient);
});
