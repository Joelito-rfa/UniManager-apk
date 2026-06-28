import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';

final serverStatusProvider = StateNotifierProvider<ServerStatusNotifier, ServerStatusState>((ref) {
  final dio = ref.read(dioClientProvider);
  return ServerStatusNotifier(dio);
});

class ServerStatusState {
  final String status;
  final int responseTimeMs;
  final bool database;
  final bool isLoading;
  final String? error;

  const ServerStatusState({
    this.status = 'unknown',
    this.responseTimeMs = 0,
    this.database = false,
    this.isLoading = false,
    this.error,
  });
}

class ServerStatusNotifier extends StateNotifier<ServerStatusState> {
  final DioClient _dio;

  ServerStatusNotifier(this._dio) : super(const ServerStatusState());

  Future<void> check() async {
    state = ServerStatusState(isLoading: true);
    try {
      final response = await _dio.get('/server/status');
      final data = response.data['data'];
      state = ServerStatusState(
        status: data['status'] as String? ?? 'unknown',
        responseTimeMs: data['response_time_ms'] as int? ?? 0,
        database: data['database'] as bool? ?? false,
      );
    } catch (e) {
      state = ServerStatusState(status: 'offline', error: e.toString());
    }
  }
}
