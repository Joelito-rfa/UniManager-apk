import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/course_provider.dart';
import '../../providers/level_provider.dart';
import '../../models/level_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/filter_bar.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  int? _selectedLevelId;
  List<LevelModel> _levels = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(courseProvider.notifier).loadCourses(endpoint: ApiConstants.teacherCourses);
      _loadFilters();
    });
  }

  Future<void> _loadFilters() async {
    final levels = await ref.read(allLevelsProvider.future);
    if (mounted) setState(() => _levels = levels);
  }

  void _onFilterChanged() {
    ref.read(courseProvider.notifier).loadCourses(
      levelId: _selectedLevelId,
      endpoint: ApiConstants.teacherCourses,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cours')),
      body: Column(
        children: [
          FilterBar(
            dropdowns: [
              FilterDropdown(
                label: 'Niveau',
                value: _selectedLevelId,
                options: [
                  const FilterOption(value: null, label: 'Tous'),
                  ..._levels.map((l) =>
                    FilterOption(value: l.id, label: '${l.code} - ${l.name}')),
                ],
                onChanged: (v) {
                  setState(() => _selectedLevelId = v as int?);
                  _onFilterChanged();
                },
              ),
            ],
          ),
          Expanded(child: _buildBody(state, theme)),
        ],
      ),
    );
  }

  Widget _buildBody(CourseState state, ThemeData theme) {
    if (state.isLoading && state.courses.isEmpty) return const LoadingWidget(message: 'Chargement des cours...');
    if (state.error != null && state.courses.isEmpty) return AppErrorWidget(message: state.error!, onRetry: () => ref.read(courseProvider.notifier).loadCourses(endpoint: ApiConstants.teacherCourses));
    if (state.courses.isEmpty) return const EmptyState(title: 'Aucun cours', subtitle: 'Aucun cours disponible pour le moment.', icon: Icons.menu_book_outlined);

    return RefreshIndicator(
      onRefresh: () => ref.read(courseProvider.notifier).loadCourses(endpoint: ApiConstants.teacherCourses),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.courses.length,
        itemBuilder: (context, index) {
          final course = state.courses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.go('/teacher/grades/course/${course.id}'),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course.subjectName ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(course.teacherName ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.folder_outlined, color: theme.colorScheme.primary, size: 20),
                      tooltip: 'Ressources',
                      onPressed: () => context.push('/teacher/courses/${course.id}/resources', extra: course),
                    ),
                    Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline, size: 22),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
