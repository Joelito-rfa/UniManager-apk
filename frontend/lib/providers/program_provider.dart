import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';
import '../models/program_model.dart';

class ProgramState {
  final List<ProgramModel> programs;
  final ProgramModel? selectedProgram;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;

  ProgramState({
    this.programs = const [],
    this.selectedProgram,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  ProgramState copyWith({
    List<ProgramModel>? programs,
    ProgramModel? selectedProgram,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? lastPage,
    int? total,
    bool clearError = false,
  }) {
    return ProgramState(
      programs: programs ?? this.programs,
      selectedProgram: selectedProgram ?? this.selectedProgram,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
    );
  }
}

class ProgramNotifier extends StateNotifier<ProgramState> {
  final DioClient _dioClient;

  ProgramNotifier(this._dioClient) : super(ProgramState());

  Future<void> loadPrograms({int page = 1, String? search}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': 10};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      final response = await _dioClient.get(
        ApiConstants.programs,
        queryParameters: queryParams,
      );
      final data = response.data;
      final paginated = PaginatedResponse.fromJson(
        data,
        (json) => ProgramModel.fromJson(json),
      );
      state = state.copyWith(
        programs: paginated.items,
        currentPage: paginated.currentPage,
        lastPage: paginated.lastPage,
        total: paginated.total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createProgram(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.post(ApiConstants.programs, data: data);
      final result = response.data;
      if (result['success'] == true) {
        await loadPrograms();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateProgram(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.put(
        '${ApiConstants.programs}/$id',
        data: data,
      );
      final result = response.data;
      if (result['success'] == true) {
        await loadPrograms();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteProgram(int id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.programs}/$id');
      final result = response.data;
      if (result['success'] == true) {
        await loadPrograms();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<String?> getNextProgramCode() async {
    try {
      final response = await _dioClient.get(ApiConstants.programNextCode);
      final data = response.data;
      if (data['success'] == true) {
        return data['data']['next_code'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void setSelectedProgram(ProgramModel? program) {
    state = state.copyWith(selectedProgram: program);
  }

  Future<List<ProgramModel>> getAllPrograms() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.programs,
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
        return items.map((e) => ProgramModel.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

final programProvider =
    StateNotifierProvider<ProgramNotifier, ProgramState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ProgramNotifier(dioClient);
});
