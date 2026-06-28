import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/dio_client.dart';
import '../../models/course_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';

class StudentResourcesScreen extends ConsumerStatefulWidget {
  const StudentResourcesScreen({super.key});

  @override
  ConsumerState<StudentResourcesScreen> createState() => _StudentResourcesScreenState();
}

class _StudentResourcesScreenState extends ConsumerState<StudentResourcesScreen> {
  List<CourseModel> _courses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get('/student/courses');
      final data = response.data;
      final list = (data['data'] as List)
          .map((json) => CourseModel.fromJson(json))
          .toList();
      if (mounted) setState(() { _courses = list; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) return const LoadingWidget(message: 'Chargement des cours...');
    if (_error != null) return AppErrorWidget(message: _error!, onRetry: _loadCourses);
    if (_courses.isEmpty) {
      return const EmptyState(
        title: 'Aucun cours',
        subtitle: 'Aucun cours disponible pour le moment.',
        icon: Icons.menu_book_outlined,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ressources pédagogiques')),
      body: RefreshIndicator(
        onRefresh: _loadCourses,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _courses.length,
          itemBuilder: (context, index) {
            final course = _courses[index];
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
                            Text(course.teacherName ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
      ),
    );
  }
}
