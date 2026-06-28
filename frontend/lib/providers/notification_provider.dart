import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors/app_exception.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int unreadCount;
  final int currentPage;
  final int lastPage;
  final int total;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.unreadCount = 0,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  bool get hasMore => currentPage < lastPage;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? unreadCount,
    int? currentPage,
    int? lastPage,
    int? total,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : error ?? this.error,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;

  NotificationNotifier(this._notificationService)
      : super(const NotificationState());

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh || state.notifications.isEmpty) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final result = await _notificationService.getNotifications(page: 1);
      state = state.copyWith(
        notifications: result['notifications'] as List<NotificationModel>,
        isLoading: false,
        currentPage: result['currentPage'] as int,
        lastPage: result['lastPage'] as int,
        total: result['total'] as int,
        unreadCount: result['unreadCount'] as int,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Le chargement des notifications a échoué',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final result = await _notificationService.getNotifications(page: nextPage);
      final newList = [
        ...state.notifications,
        ...(result['notifications'] as List<NotificationModel>),
      ];
      state = state.copyWith(
        notifications: newList,
        isLoadingMore: false,
        currentPage: result['currentPage'] as int,
        lastPage: result['lastPage'] as int,
        total: result['total'] as int,
        unreadCount: result['unreadCount'] as int,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Le chargement de plus de notifications a échoué',
      );
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      state = state.copyWith(unreadCount: count);
    } catch (_) {}
  }

  Future<void> markAsRead(int id) async {
    try {
      await _notificationService.markAsRead(id);
      final updated = state.notifications.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList();
      state = state.copyWith(
        notifications: updated,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(
        error: 'Le marquage comme lu a échoué',
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      final updated = state.notifications.map((n) {
        if (!n.isRead) return n.copyWith(isRead: true);
        return n;
      }).toList();
      state = state.copyWith(notifications: updated, unreadCount: 0);
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(
        error: 'Le marquage de tout comme lu a échoué',
      );
    }
  }

  Future<void> delete(int id) async {
    try {
      await _notificationService.delete(id);
      final updated = state.notifications.where((n) => n.id != id).toList();
      final wasUnread = state.notifications.any(
        (n) => n.id == id && !n.isRead,
      );
      state = state.copyWith(
        notifications: updated,
        total: state.total > 0 ? state.total - 1 : 0,
        unreadCount: wasUnread && state.unreadCount > 0
            ? state.unreadCount - 1
            : state.unreadCount,
      );
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(
        error: 'La suppression de la notification a échoué',
      );
    }
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final notificationService = ref.read(notificationServiceProvider);
  return NotificationNotifier(notificationService);
});
