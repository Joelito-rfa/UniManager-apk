import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';
import '../models/teacher_model.dart';

class TeacherState {
  final List<TeacherModel> teachers;
  final TeacherModel? selectedTeacher;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;
  final String searchQuery;

  TeacherState({
    this.teachers = const [],
    this.selectedTeacher,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.searchQuery = '',
  });

  TeacherState copyWith({
    List<TeacherModel>? teachers,
    TeacherModel? selectedTeacher,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? lastPage,
    int? total,
    String? searchQuery,
    bool clearError = false,
  }) {
    return TeacherState(
      teachers: teachers ?? this.teachers,
      selectedTeacher: selectedTeacher ?? this.selectedTeacher,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TeacherNotifier extends StateNotifier<TeacherState> {
  final DioClient _dioClient;

  TeacherNotifier(this._dioClient) : super(TeacherState());

  Future<void> loadTeachers({int page = 1, String? search}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': 10,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      final response = await _dioClient.get(
        ApiConstants.teachers,
        queryParameters: queryParams,
      );
      final data = response.data;
      final paginated = PaginatedResponse.fromJson(
        data,
        (json) => TeacherModel.fromJson(json),
      );
      state = state.copyWith(
        teachers: paginated.items,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
        total: paginated.total,
        isLoading: false,
        searchQuery: search ?? '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadTeacher(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.get('${ApiConstants.teachers}/$id');
      final data = response.data;
      if (data['success'] == true) {
        state = state.copyWith(
          selectedTeacher: TeacherModel.fromJson(data['data']),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createTeacher(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.post(ApiConstants.teachers, data: data);
      final result = response.data;
      if (result['success'] == true) {
        await loadTeachers();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateTeacher(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.put('${ApiConstants.teachers}/$id', data: data);
      final result = response.data;
      if (result['success'] == true) {
        await loadTeachers();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteTeacher(int id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.teachers}/$id');
      final result = response.data;
      if (result['success'] == true) {
        await loadTeachers();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<String?> getNextTeacherNumber() async {
    try {
      final response = await _dioClient.get(ApiConstants.teacherNextNumber);
      final data = response.data;
      if (data['success'] == true) {
        return data['data']['next_number'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void setSelectedTeacher(TeacherModel? teacher) {
    state = state.copyWith(selectedTeacher: teacher);
  }

  Future<List<TeacherModel>> getAllTeachers() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.teachers,
        queryParameters: {'per_page': -1},
      );
      final data = response.data;
      if (data['success'] == true) {
        final rawData = data['data'];
        List<dynamic> items;
        if (rawData is List) {
          items = rawData;
        } else if (rawData is Map<String, dynamic> && rawData['data'] is List) {
          items = rawData['data'] as List<dynamic>;
        } else {
          items = [];
        }
        return items.map((e) => TeacherModel.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

final teacherProvider =
    StateNotifierProvider<TeacherNotifier, TeacherState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return TeacherNotifier(dioClient);
});
