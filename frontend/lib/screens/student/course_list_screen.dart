import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/course_provider.dart';
import '../../core/network/dio_client.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';

class StudentCourseListScreen extends ConsumerStatefulWidget {
  const StudentCourseListScreen({super.key});

  @override
  ConsumerState<StudentCourseListScreen> createState() => _StudentCourseListScreenState();
}

class _StudentCourseListScreenState extends ConsumerState<StudentCourseListScreen> {
  int? _levelId;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiConstants.studentProfile);
      final data = response.data;
      final profile = data['data'] as Map<String, dynamic>? ?? data as Map<String, dynamic>?;
      final levelId = profile?['level_id'] as int? ?? profile?['level']?['id'] as int?;
      if (mounted) {
        setState(() => _levelId = levelId);
        ref.read(courseProvider.notifier).loadCourses(
          endpoint: ApiConstants.courses,
          levelId: levelId,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingProfile = false);
        ref.read(courseProvider.notifier).loadCourses(endpoint: ApiConstants.courses);
      }
    }
  }

  void _reload() {
    ref.read(courseProvider.notifier).loadCourses(
      endpoint: ApiConstants.courses,
      levelId: _levelId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courseProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes cours')),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(CourseState state, ThemeData theme) {
    if ((state.isLoading || _loadingProfile) && state.courses.isEmpty) return const LoadingWidget(message: 'Chargement des cours...');
    if (state.error != null && state.courses.isEmpty) return AppErrorWidget(message: state.error!, onRetry: _reload);
    if (state.courses.isEmpty) return const EmptyState(title: 'Aucun cours', subtitle: 'Aucun cours disponible pour le moment.', icon: Icons.menu_book_outlined);

    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.courses.length,
        itemBuilder: (context, index) {
          final course = state.courses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/student/courses/${course.id}/resources', extra: course),
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
                          Text('${course.teacherName ?? ''} · ${course.levelName ?? ''}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                        ],
                      ),
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
