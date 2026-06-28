import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';
import '../models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return NotificationService(dioClient);
});

class NotificationService {
  final DioClient _dioClient;

  NotificationService(this._dioClient);

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int perPage = 20,
    bool? unread,
    String? type,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (unread == true) params['unread'] = true;
    if (type != null) params['type'] = type;

    final response = await _dioClient.get(
      ApiConstants.notifications,
      queryParameters: params,
    );
    final data = response.data;
    final list = (data['data'] as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();

    return {
      'notifications': list,
      'currentPage': data['meta']['current_page'] ?? 1,
      'lastPage': data['meta']['last_page'] ?? 1,
      'total': data['meta']['total'] ?? 0,
      'unreadCount': data['meta']['unread_count'] ?? 0,
    };
  }

  Future<int> getUnreadCount() async {
    final response = await _dioClient.get(
      '${ApiConstants.notifications}/unread-count',
    );
    return response.data['data']['unread_count'] ?? 0;
  }

  Future<void> markAsRead(int id) async {
    await _dioClient.put('${ApiConstants.notifications}/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dioClient.put('${ApiConstants.notifications}/read-all');
  }

  Future<void> delete(int id) async {
    await _dioClient.delete('${ApiConstants.notifications}/$id');
  }
}
