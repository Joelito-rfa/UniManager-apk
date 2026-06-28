import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../core/localization/app_strings.dart';

class NotificationCenter extends ConsumerStatefulWidget {
  final String role;
  final bool compact;

  const NotificationCenter({super.key, required this.role, this.compact = false});

  @override
  ConsumerState<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends ConsumerState<NotificationCenter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).refreshUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.watch(appStringsProvider);
    final state = ref.watch(notificationProvider);

    return Tooltip(
      message: s.notifications,
      child: PopupMenuButton<String>(
        offset: const Offset(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 480),
        onSelected: (value) {
          if (value == 'all') {
            context.go('/${widget.role}/notifications');
          }
        },
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withAlpha(10),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.notifications_outlined, color: const Color(0xFFF59E0B), size: 20),
            ),
            if (state.unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48),
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.surface, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      state.unreadCount > 9 ? '9+' : '${state.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
          ],
        ),
        itemBuilder: (context) {
          final previews = state.notifications.take(5).toList();
          return [
            PopupMenuItem(
              enabled: false,
              height: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.notifications, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Text('${state.unreadCount} non lues', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (previews.isEmpty)
              PopupMenuItem(
                enabled: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text(s.noNotifications, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                ),
              ),
            ...previews.map((n) => PopupMenuItem(
              enabled: false,
              child: _buildNotificationItem(theme, n),
            )),
            if (state.notifications.isNotEmpty) ...[
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'all',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.markAllRead, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                  ],
                ),
              ),
            ],
          ];
        },
      ),
    );
  }

  Widget _buildNotificationItem(ThemeData theme, NotificationModel n) {
    final icons = {
      'info': Icons.info_rounded,
      'warning': Icons.warning_rounded,
      'success': Icons.check_circle_rounded,
      'error': Icons.error_rounded,
    };
    final colors = {
      'info': theme.colorScheme.primary,
      'warning': const Color(0xFFF59E0B),
      'success': const Color(0xFF10B981),
      'error': const Color(0xFFEF4444),
    };

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (colors[n.type] ?? theme.colorScheme.primary).withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icons[n.type] ?? Icons.info_rounded, size: 16, color: colors[n.type] ?? theme.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(n.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(n.message, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
