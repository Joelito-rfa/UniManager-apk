import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/search_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/localization/app_strings.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final bool compact;

  const SearchBarWidget({super.key, this.compact = false});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final _controller = TextEditingController();
  final _layerLink = LayerLink();
  final _overlayController = OverlayPortalController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(searchProvider.notifier).search(value);
    if (value.isNotEmpty) {
      _overlayController.show();
    } else {
      _overlayController.hide();
    }
  }

  void _clearSearch() {
    _controller.clear();
    _overlayController.hide();
    ref.read(searchProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = ref.watch(appStringsProvider);
    final searchState = ref.watch(searchProvider);

    if (widget.compact) {
      return IconButton(
        icon: Icon(Icons.search_rounded, color: const Color(0xFF3B82F6)),
        onPressed: () => _showSearchDialog(context),
      );
    }

    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) => CompositedTransformFollower(
        link: _layerLink,
        offset: const Offset(0, 44),
        targetAnchor: Alignment.topLeft,
        child: _buildSearchDropdown(theme, searchState, s),
      ),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: SizedBox(
          width: 280,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withAlpha(10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: searchState.query.isNotEmpty ? const Color(0xFF3B82F6).withAlpha(50) : const Color(0xFF3B82F6).withAlpha(20)),
            ),
            child: TextField(
              controller: _controller,
              style: theme.textTheme.bodyMedium,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: s.search,
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFF3B82F6), size: 20),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(icon: Icon(Icons.close_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant), onPressed: _clearSearch)
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchDropdown(ThemeData theme, SearchState searchState, AppStrings s) {
    if (searchState.isLoading) {
      return Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final results = searchState.results;
    if (results == null || results.isEmpty) return const SizedBox.shrink();

    final sections = <_SearchSection>[
      if (results.students.isNotEmpty) _SearchSection(s.students, Icons.school_rounded, results.students, 'student'),
      if (results.teachers.isNotEmpty) _SearchSection(s.teachers, Icons.person_rounded, results.teachers, 'teacher'),
      if (results.departments.isNotEmpty) _SearchSection(s.departments, Icons.business_rounded, results.departments, 'department'),
      if (results.programs.isNotEmpty) _SearchSection(s.programs, Icons.account_tree_rounded, results.programs, 'program'),
      if (results.subjects.isNotEmpty) _SearchSection(s.subjects, Icons.book_rounded, results.subjects, 'subject'),
      if (results.courses.isNotEmpty) _SearchSection(s.courses, Icons.menu_book_rounded, results.courses, 'course'),
      if (results.classrooms.isNotEmpty) _SearchSection(s.classrooms, Icons.meeting_room_rounded, results.classrooms, 'classroom'),
    ];

    return Container(
      width: 360,
      constraints: const BoxConstraints(maxHeight: 420),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(60)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
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
    );
  }

  Widget _buildSectionHeader(ThemeData theme, _SearchSection section) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      color: const Color(0xFF3B82F6).withAlpha(8),
      child: Row(
        children: [
          Icon(section.icon, size: 16, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 8),
          Text(section.title, style: theme.textTheme.labelLarge?.copyWith(color: const Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSearchItem(ThemeData theme, SearchResultItem item, String type) {
    final role = ref.read(authProvider).user?.role ?? 'admin';
    return InkWell(
      onTap: () {
        _clearSearch();
        FocusScope.of(context).unfocus();
        _navigateTo(type, item.id, role);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Row(
                    children: [
                      if (item.code != null)
                        Text(item.code!, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
                      if (item.code != null && item.secondary != null)
                        Text(' · ', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                      if (item.secondary != null)
                        Text(item.secondary!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
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

  void _navigateTo(String type, int id, String role) {
    switch (type) {
      case 'student': context.go('/$role/students'); break;
      case 'teacher': context.go('/$role/teachers'); break;
      case 'department': if (role == 'admin') context.go('/admin/departments'); break;
      case 'program': if (role == 'admin') context.go('/admin/programs'); break;
      case 'subject': if (role == 'admin') context.go('/admin/subjects'); break;
      case 'course': context.go('/$role/courses'); break;
      case 'classroom': if (role == 'admin') context.go('/admin/classrooms'); break;
    }
  }

  void _showSearchDialog(BuildContext context) {
    final hint = ref.read(appStringsProvider).search;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSection {
  final String title;
  final IconData icon;
  final List<SearchResultItem> items;
  final String type;
  _SearchSection(this.title, this.icon, this.items, this.type);
}
