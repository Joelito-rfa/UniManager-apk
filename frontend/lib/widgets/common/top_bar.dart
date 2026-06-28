import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/search_provider.dart';
import '../../core/constants/theme_provider.dart';

class TopBar extends ConsumerStatefulWidget {
  final bool isMobile;
  final VoidCallback? onMenuTap;

  const TopBar({
    super.key,
    this.isMobile = false,
    this.onMenuTap,
  });

  @override
  ConsumerState<TopBar> createState() => _TopBarState();
}

class _TopBarState extends ConsumerState<TopBar> {
  final _searchController = TextEditingController();
  final _searchLayerLink = LayerLink();
  final _searchOverlayController = OverlayPortalController();
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
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(searchProvider.notifier).search(value);
    if (value.isNotEmpty) {
      _searchOverlayController.show();
    } else {
      _searchOverlayController.hide();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchOverlayController.hide();
    ref.read(searchProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final role = user?.role ?? 'student';
    final themeMode = ref.watch(themeModeProvider);
    final notificationState = ref.watch(notificationProvider);
    final now = DateTime.now();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 16 : 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withAlpha(15),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF8B5CF6).withAlpha(60),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (widget.isMobile)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: widget.onMenuTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      color: const Color(0xFF7C3AED),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          if (!widget.isMobile)
            Flexible(
              child: OverlayPortal(
                controller: _searchOverlayController,
                overlayChildBuilder: (context) => CompositedTransformFollower(
                  link: _searchLayerLink,
                  offset: const Offset(0, 44),
                  targetAnchor: Alignment.topLeft,
                  child: _buildSearchDropdown(theme),
                ),
                child: CompositedTransformTarget(
                  link: _searchLayerLink,
                  child: _buildSearchBar(theme),
                ),
              ),
            ),
          const Spacer(),
          if (!widget.isMobile)
            _buildDateDisplay(theme, now),
          _buildThemeToggle(theme, themeMode),
          const SizedBox(width: 8),
          _buildNotificationBell(theme, notificationState, role),
          const SizedBox(width: 12),
          _buildProfileMenu(theme, user, role),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    final searchState = ref.watch(searchProvider);
    final layerLink = LayerLink();

    return CompositedTransformTarget(
      link: layerLink,
      child: Container(
        height: 40,
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED).withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: searchState.query.isNotEmpty
                ? theme.colorScheme.primary
                : const Color(0xFF7C3AED).withAlpha(50),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          style: theme.textTheme.bodyMedium,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Rechercher...',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: searchState.query.isNotEmpty
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, size: 18,
                        color: theme.colorScheme.onSurfaceVariant),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            filled: false,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchDropdown(ThemeData theme) {
    final searchState = ref.watch(searchProvider);
    if (searchState.isLoading) {
      return Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final results = searchState.results;
    if (results == null || results.isEmpty) return const SizedBox.shrink();

    final sections = <_SearchSection>[
      if (results.students.isNotEmpty) _SearchSection('Étudiants', Icons.school_rounded, results.students, 'student'),
      if (results.teachers.isNotEmpty) _SearchSection('Enseignants', Icons.person_rounded, results.teachers, 'teacher'),
      if (results.departments.isNotEmpty) _SearchSection('Départements', Icons.business_rounded, results.departments, 'department'),
      if (results.programs.isNotEmpty) _SearchSection('Filières', Icons.account_tree_rounded, results.programs, 'program'),
      if (results.levels.isNotEmpty) _SearchSection('Niveaux', Icons.grade_rounded, results.levels, 'level'),
      if (results.subjects.isNotEmpty) _SearchSection('Matières', Icons.book_rounded, results.subjects, 'subject'),
      if (results.courses.isNotEmpty) _SearchSection('Cours', Icons.menu_book_rounded, results.courses, 'course'),
      if (results.classrooms.isNotEmpty) _SearchSection('Salles', Icons.meeting_room_rounded, results.classrooms, 'classroom'),
    ];

    return Container(
      width: 360,
      constraints: const BoxConstraints(maxHeight: 420),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(60)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: sections.expand((section) {
                  return [
                    _buildSectionHeader(theme, section),
                    ...section.items.map((item) => _buildSearchItem(theme, item, section.type)),
                  ];
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, _SearchSection section) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(60),
      child: Row(
        children: [
          Icon(section.icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            section.title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchItem(ThemeData theme, SearchResultItem item, String type) {
    return InkWell(
      onTap: () {
        _clearSearch();
        FocusScope.of(context).unfocus();
        _navigateTo(type, item.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      if (item.code != null)
                        Text(
                          item.code!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (item.code != null && item.secondary != null)
                        Text(
                          ' · ',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        ),
                      if (item.secondary != null)
                        Text(
                          item.secondary!,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(String type, int id) {
    final role = ref.read(authProvider).user?.role ?? 'admin';
    switch (type) {
      case 'student':
        context.go('/$role/students');
        break;
      case 'teacher':
        context.go('/$role/teachers');
        break;
      case 'department':
        if (role == 'admin') context.go('/admin/departments');
        break;
      case 'program':
        if (role == 'admin') context.go('/admin/programs');
        break;
      case 'level':
        if (role == 'admin') context.go('/admin/levels');
        break;
      case 'subject':
        if (role == 'admin') context.go('/admin/subjects');
        break;
      case 'course':
        context.go('/$role/courses');
        break;
      case 'classroom':
        if (role == 'admin') context.go('/admin/classrooms');
        break;
    }
  }

  Widget _buildDateDisplay(ThemeData theme, DateTime now) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: theme.colorScheme.primary,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('d MMM yyyy', 'fr_FR').format(now),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
              DateFormat('EEEE', 'fr_FR').format(now)[0].toUpperCase() +
                  DateFormat('EEEE', 'fr_FR').format(now).substring(1),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(ThemeData theme, ThemeMode themeMode) {
    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).toggle();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED).withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF7C3AED).withAlpha(50),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            themeMode == ThemeMode.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            key: ValueKey(themeMode),
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBell(ThemeData theme, dynamic notificationState, String role) {
    return Stack(
      children: [
        InkWell(
          onTap: () => context.go('/$role/notifications'),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF7C3AED).withAlpha(50),
              ),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
        if (notificationState.unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  notificationState.unreadCount > 9
                      ? '9+'
                      : '${notificationState.unreadCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileMenu(ThemeData theme, dynamic user, String role) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      onSelected: (value) {
        if (value == 'logout') {
          ref.read(authProvider.notifier).logout();
          context.go('/login');
        } else if (value == 'profile') {
          context.go('/$role/profile');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(60),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF7C3AED).withAlpha(25),
              backgroundImage: _avatarImage(user?.avatar),
              child: user?.avatar == null
                  ? Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
            if (!widget.isMobile)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  Text(
                    user?.name ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                const Text('Mon profil'),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: theme.colorScheme.error,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Déconnexion',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider? _avatarImage(String? avatar) {
    if (avatar == null || avatar.isEmpty) return null;
    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return NetworkImage(avatar);
    }
    try {
      return MemoryImage(base64Decode(avatar));
    } catch (_) {
      return null;
    }
  }
}

class _SearchSection {
  final String title;
  final IconData icon;
  final List<SearchResultItem> items;
  final String type;

  _SearchSection(this.title, this.icon, this.items, this.type);
}
