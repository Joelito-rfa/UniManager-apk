import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';
import '../models/classroom_model.dart';

class ClassroomState {
  final List<ClassroomModel> classrooms;
  final ClassroomModel? selectedClassroom;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;

  ClassroomState({
    this.classrooms = const [],
    this.selectedClassroom,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  ClassroomState copyWith({
    List<ClassroomModel>? classrooms,
    ClassroomModel? selectedClassroom,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? lastPage,
    int? total,
    bool clearError = false,
  }) {
    return ClassroomState(
      classrooms: classrooms ?? this.classrooms,
      selectedClassroom: selectedClassroom ?? this.selectedClassroom,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
    );
  }
}

class ClassroomNotifier extends StateNotifier<ClassroomState> {
  final DioClient _dioClient;

  ClassroomNotifier(this._dioClient) : super(ClassroomState());

  Future<void> loadClassrooms({int page = 1, String? search, int? levelId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': 10};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (levelId != null) queryParams['level_id'] = levelId;
      final response = await _dioClient.get(
        ApiConstants.classrooms,
        queryParameters: queryParams,
      );
      final data = response.data;
      final paginated = PaginatedResponse.fromJson(
        data,
        (json) => ClassroomModel.fromJson(json),
      );
      state = state.copyWith(
        classrooms: paginated.items,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
        total: paginated.total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createClassroom(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.post(ApiConstants.classrooms, data: data);
      final result = response.data;
      if (result['success'] == true) {
        await loadClassrooms();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateClassroom(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.put(
        '${ApiConstants.classrooms}/$id',
        data: data,
      );
      final result = response.data;
      if (result['success'] == true) {
        await loadClassrooms();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteClassroom(int id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.classrooms}/$id');
      final result = response.data;
      if (result['success'] == true) {
        await loadClassrooms();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<String?> getNextClassroomCode() async {
    try {
      final response = await _dioClient.get(ApiConstants.classroomNextCode);
      final data = response.data;
      if (data['success'] == true) {
        return data['data']['next_code'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void setSelectedClassroom(ClassroomModel? classroom) {
    state = state.copyWith(selectedClassroom: classroom);
  }

  Future<List<ClassroomModel>> getAllClassrooms() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.classrooms,
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
        return items.map((e) => ClassroomModel.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

final classroomProvider =
    StateNotifierProvider<ClassroomNotifier, ClassroomState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ClassroomNotifier(dioClient);
});
