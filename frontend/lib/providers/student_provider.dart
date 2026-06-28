import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';
import '../models/student_model.dart';

class StudentState {
  final List<StudentModel> students;
  final StudentModel? selectedStudent;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;
  final String searchQuery;

  StudentState({
    this.students = const [],
    this.selectedStudent,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.searchQuery = '',
  });

  StudentState copyWith({
    List<StudentModel>? students,
    StudentModel? selectedStudent,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? lastPage,
    int? total,
    String? searchQuery,
    bool clearError = false,
  }) {
    return StudentState(
      students: students ?? this.students,
      selectedStudent: selectedStudent ?? this.selectedStudent,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class StudentNotifier extends StateNotifier<StudentState> {
  final DioClient _dioClient;

  StudentNotifier(this._dioClient) : super(StudentState());

  Future<void> loadStudents({int page = 1, String? search, int? programId, int? levelId, String? endpoint}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': 10,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (programId != null) queryParams['program_id'] = programId;
      if (levelId != null) queryParams['level_id'] = levelId;
      final response = await _dioClient.get(
        endpoint ?? ApiConstants.students,
        queryParameters: queryParams,
      );
      final data = response.data;
      final paginated = PaginatedResponse.fromJson(
        data,
        (json) => StudentModel.fromJson(json),
      );
      state = state.copyWith(
        students: paginated.items,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
        total: paginated.total,
        isLoading: false,
        searchQuery: search ?? '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadStudent(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.get('${ApiConstants.students}/$id');
      final data = response.data;
      if (data['success'] == true) {
        state = state.copyWith(
          selectedStudent: StudentModel.fromJson(data['data']),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createStudent(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.post(ApiConstants.students, data: data);
      final result = response.data;
      if (result['success'] == true) {
        await loadStudents();
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        error: result['message'],
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateStudent(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.put('${ApiConstants.students}/$id', data: data);
      final result = response.data;
      if (result['success'] == true) {
        await loadStudents();
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        error: result['message'],
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteStudent(int id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.students}/$id');
      final result = response.data;
      if (result['success'] == true) {
        await loadStudents();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<String?> getNextStudentNumber() async {
    try {
      final response = await _dioClient.get(ApiConstants.studentNextNumber);
      final data = response.data;
      if (data['success'] == true) {
        return data['data']['next_number'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void setSelectedStudent(StudentModel? student) {
    state = state.copyWith(selectedStudent: student);
  }
}

final studentProvider =
    StateNotifierProvider<StudentNotifier, StudentState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return StudentNotifier(dioClient);
});
