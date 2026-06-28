import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';
import '../models/course_model.dart';

class CourseState {
  final List<CourseModel> courses;
  final CourseModel? selectedCourse;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;

  CourseState({
    this.courses = const [],
    this.selectedCourse,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  CourseState copyWith({
    List<CourseModel>? courses,
    CourseModel? selectedCourse,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? lastPage,
    int? total,
    bool clearError = false,
  }) {
    return CourseState(
      courses: courses ?? this.courses,
      selectedCourse: selectedCourse ?? this.selectedCourse,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
    );
  }
}

class CourseNotifier extends StateNotifier<CourseState> {
  final DioClient _dioClient;

  CourseNotifier(this._dioClient) : super(CourseState());

  Future<void> loadCourses({int page = 1, String? search, int? levelId, String? endpoint}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': 10};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (levelId != null) queryParams['level_id'] = levelId;
      final path = endpoint ?? ApiConstants.courses;
      final response = await _dioClient.get(
        path,
        queryParameters: queryParams,
      );
      final data = response.data;
      final paginated = PaginatedResponse.fromJson(
        data,
        (json) => CourseModel.fromJson(json),
      );
      state = state.copyWith(
        courses: paginated.items,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
        total: paginated.total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createCourse(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.post(ApiConstants.courses, data: data);
      final result = response.data;
      if (result['success'] == true) {
        await loadCourses();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateCourse(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.put(
        '${ApiConstants.courses}/$id',
        data: data,
      );
      final result = response.data;
      if (result['success'] == true) {
        await loadCourses();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteCourse(int id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.courses}/$id');
      final result = response.data;
      if (result['success'] == true) {
        await loadCourses();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void setSelectedCourse(CourseModel? course) {
    state = state.copyWith(selectedCourse: course);
  }
}

final courseProvider =
    StateNotifierProvider<CourseNotifier, CourseState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return CourseNotifier(dioClient);
});
