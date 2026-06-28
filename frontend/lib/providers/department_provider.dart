import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';
import '../models/department_model.dart';

class DepartmentState {
  final List<DepartmentModel> departments;
  final DepartmentModel? selectedDepartment;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;

  DepartmentState({
    this.departments = const [],
    this.selectedDepartment,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  DepartmentState copyWith({
    List<DepartmentModel>? departments,
    DepartmentModel? selectedDepartment,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? lastPage,
    int? total,
    bool clearError = false,
  }) {
    return DepartmentState(
      departments: departments ?? this.departments,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
    );
  }
}

class DepartmentNotifier extends StateNotifier<DepartmentState> {
  final DioClient _dioClient;

  DepartmentNotifier(this._dioClient) : super(DepartmentState());

  Future<void> loadDepartments({int page = 1, String? search}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': 10};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      final response = await _dioClient.get(
        ApiConstants.departments,
        queryParameters: queryParams,
      );
      final data = response.data;
      final paginated = PaginatedResponse.fromJson(
        data,
        (json) => DepartmentModel.fromJson(json),
      );
      state = state.copyWith(
        departments: paginated.items,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
        total: paginated.total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createDepartment(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.post(ApiConstants.departments, data: data);
      final result = response.data;
      if (result['success'] == true) {
        await loadDepartments();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateDepartment(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.put(
        '${ApiConstants.departments}/$id',
        data: data,
      );
      final result = response.data;
      if (result['success'] == true) {
        await loadDepartments();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteDepartment(int id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.departments}/$id');
      final result = response.data;
      if (result['success'] == true) {
        await loadDepartments();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<String?> getNextDepartmentCode() async {
    try {
      final response = await _dioClient.get(ApiConstants.departmentNextCode);
      final data = response.data;
      if (data['success'] == true) {
        return data['data']['next_code'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void setSelectedDepartment(DepartmentModel? department) {
    state = state.copyWith(selectedDepartment: department);
  }

  Future<List<DepartmentModel>> getAllDepartments() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.departments,
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
        return items.map((e) => DepartmentModel.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

final departmentProvider =
    StateNotifierProvider<DepartmentNotifier, DepartmentState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return DepartmentNotifier(dioClient);
});
