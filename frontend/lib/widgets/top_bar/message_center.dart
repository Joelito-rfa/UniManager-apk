import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/unread_messages_provider.dart';
import '../../core/localization/app_strings.dart';

class MessageCenter extends ConsumerStatefulWidget {
  final String role;

  const MessageCenter({super.key, required this.role});

  @override
  ConsumerState<MessageCenter> createState() => _MessageCenterState();
}

class _MessageCenterState extends ConsumerState<MessageCenter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(unreadMessagesProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.watch(appStringsProvider);
    final unread = ref.watch(unreadMessagesProvider);

    return Tooltip(
      message: s.messages,
      child: InkWell(
        onTap: () => context.go('/${widget.role}/messaging'),
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withAlpha(10),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withAlpha(10),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.chat_outlined, color: const Color(0xFF06B6D4), size: 20),
            ),
            if (unread > 0)
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
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
