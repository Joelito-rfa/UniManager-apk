import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

final unreadMessagesProvider = StateNotifierProvider<UnreadMessagesNotifier, int>((ref) {
  final dio = ref.read(dioClientProvider);
  return UnreadMessagesNotifier(dio);
});

class UnreadMessagesNotifier extends StateNotifier<int> {
  final DioClient _dio;

  UnreadMessagesNotifier(this._dio) : super(0);

  Future<void> refresh() async {
    try {
      final response = await _dio.get('${ApiConstants.conversations}/unread-count');
      final count = response.data['data']['unread_count'] as int? ?? 0;
      state = count;
    } catch (_) {}
  }
}
