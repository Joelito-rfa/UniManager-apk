import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';

class NotificationListScreen extends ConsumerStatefulWidget {
  const NotificationListScreen({super.key});

  @override
  ConsumerState<NotificationListScreen> createState() =>
      _NotificationListScreenState();
}

class _NotificationListScreenState
    extends ConsumerState<NotificationListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).loadNotifications(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.unreadCount > 0)
            TextButton.icon(
              onPressed: () =>
                  ref.read(notificationProvider.notifier).markAllAsRead(),
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Tout lire'),
            ),
        ],
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(NotificationState state, ThemeData theme) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const LoadingWidget(message: 'Chargement...');
    }

    if (state.error != null && state.notifications.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () =>
            ref.read(notificationProvider.notifier).loadNotifications(),
      );
    }

    if (state.notifications.isEmpty) {
      return EmptyState(
        title: 'Aucune notification',
        subtitle: 'Vous n\'avez pas encore de notifications',
        icon: Icons.notifications_off_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationProvider.notifier).loadNotifications(
              refresh: true,
            );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _NotificationTile(
            notification: state.notifications[index],
            onTap: () =>
                ref.read(notificationProvider.notifier).markAsRead(
                      state.notifications[index].id,
                    ),
            onDelete: () =>
                ref.read(notificationProvider.notifier).delete(
                      state.notifications[index].id,
                    ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'success':
        return Icons.check_circle_rounded;
      case 'warning':
        return Icons.warning_rounded;
      case 'error':
        return Icons.error_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getTypeColor(String? type, ThemeData theme) {
    switch (type) {
      case 'success':
        return const Color(0xFF059669);
      case 'warning':
        return const Color(0xFFD97706);
      case 'error':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification.isRead;
    final type = notification.type;
    final title = notification.title;
    final message = notification.message;
    final createdAt = notification.createdAt;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: isRead ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getTypeColor(type, theme).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(type),
                  color: _getTypeColor(type, theme),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight:
                                  isRead ? FontWeight.w500 : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (createdAt != null)
                      const SizedBox(height: 6),
                    if (createdAt != null)
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(
                          createdAt,
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
