import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import 'search_bar_widget.dart';
import 'clock_widget.dart';
import 'theme_switcher.dart';
import 'language_selector.dart';
import 'notification_center.dart';
import 'message_center.dart';
import 'profile_menu.dart';
import 'quick_actions.dart';

class AppTopBar extends ConsumerWidget {
  final bool isMobile;
  final VoidCallback? onMenuTap;

  const AppTopBar({super.key, this.isMobile = false, this.onMenuTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    final role = user?.role ?? 'student';

    return Container(
      padding: EdgeInsets.only(left: isMobile ? 12 : 16, right: isMobile ? 12 : 16, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withAlpha(15),
        border: Border(bottom: BorderSide(color: const Color(0xFF8B5CF6).withAlpha(60), width: 1)),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
        boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withAlpha(20), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: isMobile ? _buildMobileLayout(context, theme, role) : _buildDesktopLayout(context, theme, role),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme, String role) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 880;
        return Row(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (role == 'admin' || role == 'teacher')
                    if (compact)
                      QuickActions(role: role, compact: true)
                    else ...[
                      QuickActions(role: role),
                      const SizedBox(width: 12),
                    ]
                  else
                    const SizedBox(width: 8),
                  Flexible(
                    child: SizedBox(
                      width: compact ? null : 280,
                      child: SearchBarWidget(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: compact ? 4 : 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClockWidget(compact: compact),
                SizedBox(width: compact ? 6 : 14),
                ThemeSwitcher(),
                SizedBox(width: compact ? 4 : 6),
                LanguageSelector(),
                SizedBox(width: compact ? 4 : 6),
                NotificationCenter(role: role),
                if (role != 'student') ...[
                  SizedBox(width: compact ? 4 : 6),
                  MessageCenter(role: role),
                ],
                SizedBox(width: compact ? 4 : 6),
                ProfileMenu(role: role, compact: compact),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme, String role) {
    return Row(
      children: [
        InkWell(
          onTap: onMenuTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.menu_rounded, color: const Color(0xFF7C3AED), size: 22),
          ),
        ),
        const SizedBox(width: 8),
        SearchBarWidget(compact: true),
        const Spacer(),
        ClockWidget(compact: true),
        const SizedBox(width: 4),
        NotificationCenter(role: role, compact: true),
        const SizedBox(width: 4),
        ProfileMenu(role: role, compact: true),
      ],
    );
  }
}
