import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';
import '../models/enrollment_model.dart';

class EnrollmentState {
  final List<EnrollmentModel> enrollments;
  final EnrollmentModel? selectedEnrollment;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;

  EnrollmentState({
    this.enrollments = const [],
    this.selectedEnrollment,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  EnrollmentState copyWith({
    List<EnrollmentModel>? enrollments,
    EnrollmentModel? selectedEnrollment,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? lastPage,
    int? total,
    bool clearError = false,
  }) {
    return EnrollmentState(
      enrollments: enrollments ?? this.enrollments,
      selectedEnrollment: selectedEnrollment ?? this.selectedEnrollment,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
    );
  }
}

class EnrollmentNotifier extends StateNotifier<EnrollmentState> {
  final DioClient _dioClient;

  EnrollmentNotifier(this._dioClient) : super(EnrollmentState());

  Future<void> loadEnrollments({int page = 1, String? search, Map<String, dynamic>? filters, String role = 'admin'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': 10,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (filters != null) {
        queryParams.addAll(filters);
      }
      final endpoint = role == 'teacher' ? ApiConstants.teacherEnrollments : ApiConstants.enrollments;
      final response = await _dioClient.get(
        endpoint,
        queryParameters: queryParams,
      );
      final data = response.data;
      final paginated = PaginatedResponse.fromJson(
        data,
        (json) => EnrollmentModel.fromJson(json),
      );
      state = state.copyWith(
        enrollments: paginated.items,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
        total: paginated.total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createEnrollment(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.post(ApiConstants.enrollments, data: data);
      final result = response.data;
      if (result['success'] == true) {
        await loadEnrollments();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateEnrollment(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.put(
        '${ApiConstants.enrollments}/$id',
        data: data,
      );
      final result = response.data;
      if (result['success'] == true) {
        await loadEnrollments();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteEnrollment(int id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.enrollments}/$id');
      final result = response.data;
      if (result['success'] == true) {
        await loadEnrollments();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void setSelectedEnrollment(EnrollmentModel? enrollment) {
    state = state.copyWith(selectedEnrollment: enrollment);
  }
}

final enrollmentProvider =
    StateNotifierProvider<EnrollmentNotifier, EnrollmentState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return EnrollmentNotifier(dioClient);
});
