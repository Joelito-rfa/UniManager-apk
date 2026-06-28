import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/schedule_model.dart';

class ScheduleState {
  final List<ScheduleModel> schedules;
  final ScheduleModel? selectedSchedule;
  final bool isLoading;
  final String? error;

  ScheduleState({
    this.schedules = const [],
    this.selectedSchedule,
    this.isLoading = false,
    this.error,
  });

  ScheduleState copyWith({
    List<ScheduleModel>? schedules,
    ScheduleModel? selectedSchedule,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      selectedSchedule: selectedSchedule ?? this.selectedSchedule,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final DioClient _dioClient;

  ScheduleNotifier(this._dioClient) : super(ScheduleState());

  Future<void> loadSchedules({Map<String, dynamic>? filters, String role = 'admin'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final queryParams = <String, dynamic>{};
      if (filters != null) {
        queryParams.addAll(filters);
      }
      final endpoint = role == 'teacher' ? ApiConstants.teacherSchedule
          : role == 'student' ? ApiConstants.studentSchedule
          : ApiConstants.schedules;
      final response = await _dioClient.get(
        endpoint,
        queryParameters: queryParams,
      );
      final data = response.data;
      if (data['success'] == true) {
        final items = (data['data'] as List<dynamic>? ?? [])
            .map((e) => ScheduleModel.fromJson(e))
            .toList();
        state = state.copyWith(schedules: items, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createSchedule(Map<String, dynamic> data, {String role = 'admin'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.post(ApiConstants.schedules, data: data);
      final result = response.data;
      if (result['success'] == true) {
        await loadSchedules();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateSchedule(int id, Map<String, dynamic> data, {String role = 'admin'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.put(
        '${ApiConstants.schedules}/$id',
        data: data,
      );
      final result = response.data;
      if (result['success'] == true) {
        await loadSchedules();
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteSchedule(int id, {String role = 'admin'}) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.schedules}/$id');
      final result = response.data;
      if (result['success'] == true) {
        await loadSchedules();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void setSelectedSchedule(ScheduleModel? schedule) {
    state = state.copyWith(selectedSchedule: schedule);
  }

  List<ScheduleModel> getSchedulesForDay(String day) {
    return state.schedules.where((s) => s.dayOfWeek == day).toList();
  }
}

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ScheduleNotifier(dioClient);
});
