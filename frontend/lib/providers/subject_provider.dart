import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';
import '../models/subject_model.dart';

class SubjectState {
  final List<SubjectModel> subjects;
  final SubjectModel? selectedSubject;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;

  SubjectState({
    this.subjects = const [],
    this.selectedSubject,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  SubjectState copyWith({
    List<SubjectModel>? subjects,
    SubjectModel? selectedSubject,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? lastPage,
    int? total,
    bool clearError = false,
  }) {
    return SubjectState(
      subjects: subjects ?? this.subjects,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
    );
  }
}

class SubjectNotifier extends StateNotifier<SubjectState> {
  final DioClient _dioClient;

  SubjectNotifier(this._dioClient) : super(SubjectState());

  Future<void> loadSubjects({int page = 1, String? search, int? programId, int? levelId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': 10};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (programId != null) queryParams['program_id'] = programId;
      if (levelId != null) queryParams['level_id'] = levelId;
      final response = await _dioClient.get(
        ApiConstants.subjects,
        queryParameters: queryParams,
      );
      final data = response.data;
      final paginated = PaginatedResponse.fromJson(
        data,
        (json) => SubjectModel.fromJson(json),
      );
      state = state.copyWith(
        subjects: paginated.items,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
        total: paginated.total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createSubject(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.post(ApiConstants.subjects, data: data);
      final result = response.data;
      if (result['success'] == true) {
        await loadSubjects();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateSubject(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.put(
        '${ApiConstants.subjects}/$id',
        data: data,
      );
      final result = response.data;
      if (result['success'] == true) {
        await loadSubjects();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteSubject(int id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.subjects}/$id');
      final result = response.data;
      if (result['success'] == true) {
        await loadSubjects();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<String?> getNextSubjectCode() async {
    try {
      final response = await _dioClient.get(ApiConstants.subjectNextCode);
      final data = response.data;
      if (data['success'] == true) {
        return data['data']['next_code'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void setSelectedSubject(SubjectModel? subject) {
    state = state.copyWith(selectedSubject: subject);
  }

  Future<List<SubjectModel>> getAllSubjects() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.subjects,
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
        return items.map((e) => SubjectModel.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

final subjectProvider =
    StateNotifierProvider<SubjectNotifier, SubjectState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return SubjectNotifier(dioClient);
});
