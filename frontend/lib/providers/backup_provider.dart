import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';

final backupProvider = StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  final dio = ref.read(dioClientProvider);
  return BackupNotifier(dio);
});

class BackupState {
  final Map<String, dynamic>? lastBackup;
  final int backupCount;
  final bool isLoading;
  final bool isCreating;
  final String? error;

  const BackupState({
    this.lastBackup,
    this.backupCount = 0,
    this.isLoading = false,
    this.isCreating = false,
    this.error,
  });
}

class BackupNotifier extends StateNotifier<BackupState> {
  final DioClient _dio;

  BackupNotifier(this._dio) : super(const BackupState());

  Future<void> load() async {
    state = BackupState(isLoading: true);
    try {
      final response = await _dio.get('/admin/backups/last');
      final data = response.data['data'];
      state = BackupState(
        lastBackup: data['last_backup'] as Map<String, dynamic>?,
        backupCount: data['backup_count'] as int? ?? 0,
        isLoading: false,
      );
    } catch (e) {
      state = BackupState(error: e.toString());
    }
  }

  Future<void> create() async {
    state = BackupState(isCreating: true, lastBackup: state.lastBackup, backupCount: state.backupCount);
    try {
      await _dio.post('/admin/backups/create');
      await load();
    } catch (e) {
      state = BackupState(error: e.toString(), lastBackup: state.lastBackup, backupCount: state.backupCount);
    }
  }
}
