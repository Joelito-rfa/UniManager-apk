import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../core/localization/app_strings.dart';

class ProfileMenu extends ConsumerWidget {
  final String role;
  final bool compact;

  const ProfileMenu({super.key, required this.role, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = ref.watch(appStringsProvider);
    final baseRole = role;
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      onSelected: (value) async {
        switch (value) {
          case 'profile':
            context.go('/$baseRole/profile');
          case 'edit':
            context.go('/$baseRole/profile');
          case 'preferences':
            context.go('/$baseRole/profile');
          case 'changePassword':
            context.go('/change-password');
          case 'contact':
            final dio = ref.read(dioClientProvider);
            try {
              final response = await dio.get(ApiConstants.contactSupport);
              final adminId = response.data['data']['id'] as int;
              final conv = await ref.read(conversationProvider.notifier).createConversation([adminId]);
              if (conv != null && context.mounted) {
                context.push('/messaging/chat/${conv.id}', extra: conv);
              }
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Impossible de contacter le support.')),
                );
              }
            }
          case 'logout':
            ref.read(authProvider.notifier).logout();
            context.go('/login');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: compact ? 14 : 16,
              backgroundColor: const Color(0xFFEC4899).withAlpha(15),
              backgroundImage: _avatarImage(user?.avatar),
              child: user?.avatar == null
                  ? Icon(Icons.person_rounded, size: compact ? 14 : 18, color: const Color(0xFFEC4899))
                  : null,
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              Text(
                user?.name ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.onSurfaceVariant, size: 18),
            ],
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'profile', child: _menuItem(theme, Icons.person_rounded, s.myProfile, theme.colorScheme.primary)),
        PopupMenuItem(value: 'edit', child: _menuItem(theme, Icons.edit_rounded, s.editProfile, theme.colorScheme.primary)),
        PopupMenuItem(value: 'changePassword', child: _menuItem(theme, Icons.lock_rounded, s.changePassword, theme.colorScheme.primary)),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'contact', child: _menuItem(theme, Icons.headset_mic_rounded, s.contactUs, const Color(0xFF14B8A6))),
        PopupMenuItem(value: 'logout', child: _menuItem(theme, Icons.logout_rounded, s.logout, theme.colorScheme.error)),
      ],
    );
  }

  Widget _menuItem(ThemeData theme, IconData icon, String label, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 16),
        Text(label, style: TextStyle(color: color == theme.colorScheme.error ? color : null)),
      ],
    );
  }

  ImageProvider? _avatarImage(String? avatar) {
    if (avatar == null || avatar.isEmpty) return null;
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) return NetworkImage(avatar);
    try {
      return MemoryImage(base64Decode(avatar));
    } catch (_) {
      return null;
    }
  }
}
