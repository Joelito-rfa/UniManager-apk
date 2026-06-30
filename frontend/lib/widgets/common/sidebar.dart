import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../core/localization/app_strings.dart';

class SidebarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final int badgeCount;

  const SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.badgeCount = 0,
  });
}

class Sidebar extends ConsumerStatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const Sidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).refreshUnreadCount();
    });
    _notificationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => ref.read(notificationProvider.notifier).refreshUnreadCount(),
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final role = user?.role ?? 'student';
    final location = GoRouterState.of(context).uri.toString();
    final s = ref.watch(appStringsProvider);

    final notificationState = ref.watch(notificationProvider);
    final items = _getNavigationItems(role, notificationState.unreadCount, s);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: widget.isCollapsed ? 72 : 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0F172A),
            const Color(0xFF1E1B4B),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(theme, user, role),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isCollapsed ? 8 : 12,
                vertical: 8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isActive = location == item.route ||
                    (item.route != '/$role/dashboard' &&
                        location.startsWith(item.route));

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: widget.isCollapsed ? 4 : 2,
                  ),
                  child: Tooltip(
                    message: widget.isCollapsed ? item.label : '',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go(item.route),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.isCollapsed ? 0 : 14,
                            vertical: widget.isCollapsed ? 14 : 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: isActive
                                ? LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary.withAlpha(60),
                                      theme.colorScheme.primary.withAlpha(20),
                                    ],
                                  )
                                : null,
                            border: isActive
                                ? Border.all(
                                    color: theme.colorScheme.primary.withAlpha(80),
                                    width: 0.5,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: widget.isCollapsed
                                      ? MainAxisAlignment.center
                                      : MainAxisAlignment.start,
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Icon(
                                          isActive ? item.activeIcon : item.icon,
                                          color: isActive
                                              ? theme.colorScheme.primary
                                              : Colors.white.withAlpha(160),
                                          size: widget.isCollapsed ? 24 : 22,
                                        ),
                                        if (item.badgeCount > 0)
                                          Positioned(
                                            right: widget.isCollapsed ? -6 : -4,
                                            top: widget.isCollapsed ? -6 : -4,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE11D48),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(0xFF0F172A),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Text(
                                                '${item.badgeCount}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: widget.isCollapsed ? 0 : 14,
                                    ),
                                    if (!widget.isCollapsed)
                                      Flexible(
                                        child: AnimatedOpacity(
                                          duration: const Duration(milliseconds: 200),
                                          opacity: widget.isCollapsed ? 0.0 : 1.0,
                                          child: Text(
                                            item.label,
                                            style: TextStyle(
                                              color: isActive
                                                  ? Colors.white
                                                  : Colors.white.withAlpha(160),
                                              fontSize: 14,
                                              fontWeight: isActive
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: isActive && !widget.isCollapsed ? 3 : 0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: theme.colorScheme.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withAlpha(120),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildLogoutSection(theme),
          _buildToggleButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, dynamic user, String role) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 12 : 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withAlpha(15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: widget.isCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withAlpha(180),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(80),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/app_icon.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (!widget.isCollapsed)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0F172A), width: 2),
                    ),
                  ),
                ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.isCollapsed ? 0 : 14,
          ),
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: widget.isCollapsed ? 0.0 : 1.0,
              child: widget.isCollapsed
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'UniManager',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user?.name ?? '',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildRoleBadge(role),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final s = ref.watch(appStringsProvider);
    final label = role == 'admin'
        ? s.admin
        : role == 'teacher'
            ? s.professor
            : s.student;
    final color = role == 'admin'
        ? const Color(0xFF818CF8)
        : role == 'teacher'
            ? const Color(0xFF2DD4BF)
            : const Color(0xFFFBBF24);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildLogoutSection(ThemeData theme) {
    final s = ref.watch(appStringsProvider);
    return Container(
      padding: EdgeInsets.all(widget.isCollapsed ? 12 : 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withAlpha(15),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          ref.read(authProvider.notifier).logout();
          context.go('/login');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 0 : 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withAlpha(8),
          ),
          child: Row(
            mainAxisAlignment: widget.isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                Icons.logout_rounded,
                color: const Color(0xFFEF4444),
                size: 20,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.isCollapsed ? 0 : 14,
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isCollapsed ? 0.0 : 1.0,
                child: widget.isCollapsed
                    ? const SizedBox.shrink()
                    : Text(
                        s.logout,
                        style: TextStyle(
                          color: const Color(0xFFEF4444),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withAlpha(10),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: widget.onToggle,
        borderRadius: BorderRadius.zero,
        child: SizedBox(
          height: 44,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                widget.isCollapsed
                    ? Icons.chevron_right_rounded
                    : Icons.chevron_left_rounded,
                key: ValueKey(widget.isCollapsed),
                color: Colors.white.withAlpha(120),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<SidebarItem> _getNavigationItems(String role, int unreadCount, AppStrings s) {
    switch (role) {
      case 'admin':
        return [
          SidebarItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: s.dashboard,
            route: '/admin/dashboard',
          ),
          SidebarItem(
            icon: Icons.people_outlined,
            activeIcon: Icons.people_rounded,
            label: s.students,
            route: '/admin/students',
          ),
          SidebarItem(
            icon: Icons.person_outlined,
            activeIcon: Icons.person_rounded,
            label: s.teachers,
            route: '/admin/teachers',
          ),
          SidebarItem(
            icon: Icons.business_outlined,
            activeIcon: Icons.business_rounded,
            label: s.departments,
            route: '/admin/departments',
          ),
          SidebarItem(
            icon: Icons.school_outlined,
            activeIcon: Icons.school_rounded,
            label: s.programs,
            route: '/admin/programs',
          ),
          SidebarItem(
            icon: Icons.book_outlined,
            activeIcon: Icons.book_rounded,
            label: s.subjects,
            route: '/admin/subjects',
          ),
          SidebarItem(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book_rounded,
            label: s.courses,
            route: '/admin/courses',
          ),
          SidebarItem(
            icon: Icons.meeting_room_outlined,
            activeIcon: Icons.meeting_room_rounded,
            label: s.classrooms,
            route: '/admin/classrooms',
          ),
          SidebarItem(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month_rounded,
            label: s.schedules,
            route: '/admin/schedules',
          ),
          SidebarItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            label: s.enrollments,
            route: '/admin/enrollments',
          ),
          SidebarItem(
            icon: Icons.grade_outlined,
            activeIcon: Icons.grade_rounded,
            label: s.grades,
            route: '/admin/grades',
          ),
          SidebarItem(
            icon: Icons.assessment_outlined,
            activeIcon: Icons.assessment_rounded,
            label: s.results,
            route: '/admin/results',
          ),
          SidebarItem(
            icon: Icons.trending_up_rounded,
            activeIcon: Icons.trending_up_rounded,
            label: s.admissions,
            route: '/admin/admissions',
          ),
          SidebarItem(
            icon: Icons.quiz_outlined,
            activeIcon: Icons.quiz_rounded,
            label: s.exams,
            route: '/admin/exams',
          ),
          SidebarItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications_rounded,
            label: s.notifications,
            route: '/admin/notifications',
            badgeCount: unreadCount,
          ),
          SidebarItem(
            icon: Icons.chat_outlined,
            activeIcon: Icons.chat_rounded,
            label: s.messaging,
            route: '/admin/messaging',
          ),
          SidebarItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            label: s.settings,
            route: '/admin/settings',
          ),
        ];
      case 'teacher':
        return [
          SidebarItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: s.dashboard,
            route: '/teacher/dashboard',
          ),
          SidebarItem(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book_rounded,
            label: s.myCourses,
            route: '/teacher/courses',
          ),
          SidebarItem(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month_rounded,
            label: s.schedules,
            route: '/teacher/schedule',
          ),
          SidebarItem(
            icon: Icons.quiz_outlined,
            activeIcon: Icons.quiz_rounded,
            label: s.exams,
            route: '/teacher/exams',
          ),
          SidebarItem(
            icon: Icons.grade_outlined,
            activeIcon: Icons.grade_rounded,
            label: s.gradeEntry,
            route: '/teacher/grades',
          ),
          SidebarItem(
            icon: Icons.people_outlined,
            activeIcon: Icons.people_rounded,
            label: s.students,
            route: '/teacher/students',
          ),
          SidebarItem(
            icon: Icons.assessment_outlined,
            activeIcon: Icons.assessment_rounded,
            label: s.results,
            route: '/teacher/results',
          ),
          SidebarItem(
            icon: Icons.chat_outlined,
            activeIcon: Icons.chat_rounded,
            label: s.messaging,
            route: '/teacher/messaging',
          ),
          SidebarItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications_rounded,
            label: s.notifications,
            route: '/teacher/notifications',
            badgeCount: unreadCount,
          ),
        ];
      case 'student':
        return [
          SidebarItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: s.dashboard,
            route: '/student/dashboard',
          ),
          SidebarItem(
            icon: Icons.folder_outlined,
            activeIcon: Icons.folder_rounded,
            label: s.resources,
            route: '/student/resources',
          ),
          SidebarItem(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book_rounded,
            label: s.courses,
            route: '/student/courses',
          ),
          SidebarItem(
            icon: Icons.quiz_outlined,
            activeIcon: Icons.quiz_rounded,
            label: s.exams,
            route: '/student/exams',
          ),
          SidebarItem(
            icon: Icons.grade_outlined,
            activeIcon: Icons.grade_rounded,
            label: s.myGrades,
            route: '/student/grades',
          ),
          SidebarItem(
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month_rounded,
            label: s.schedules,
            route: '/student/schedule',
          ),
          SidebarItem(
            icon: Icons.assessment_outlined,
            activeIcon: Icons.assessment_rounded,
            label: s.results,
            route: '/student/results',
          ),
          SidebarItem(
            icon: Icons.chat_outlined,
            activeIcon: Icons.chat_rounded,
            label: s.messaging,
            route: '/student/messaging',
          ),
          SidebarItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications_rounded,
            label: s.notifications,
            route: '/student/notifications',
            badgeCount: unreadCount,
          ),
        ];
      default:
        return [];
    }
  }
}
