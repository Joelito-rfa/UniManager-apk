import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/dashboard_stats_model.dart';

class DashboardState {
  final DashboardStatsModel? stats;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.stats,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    DashboardStatsModel? stats,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DioClient _dioClient;

  DashboardNotifier(this._dioClient) : super(DashboardState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.get(ApiConstants.dashboard);
      final data = response.data;
      if (data['success'] == true) {
        state = state.copyWith(
          stats: DashboardStatsModel.fromJson(data['data']),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadTeacherDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.get(ApiConstants.dashboardTeacher);
      final data = response.data;
      if (data['success'] == true) {
        state = state.copyWith(
          stats: DashboardStatsModel.fromJson(data['data']),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadStudentDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dioClient.get(ApiConstants.dashboardStudent);
      final data = response.data;
      if (data['success'] == true) {
        state = state.copyWith(
          stats: DashboardStatsModel.fromJson(data['data']),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return DashboardNotifier(dioClient);
});
