import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/student_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';

class StudentListScreen extends ConsumerStatefulWidget {
  const StudentListScreen({super.key});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studentProvider.notifier).loadStudents(endpoint: ApiConstants.teacherStudents);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes étudiants')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(StudentState state) {
    final theme = Theme.of(context);
    if (state.isLoading && state.students.isEmpty) return const LoadingWidget(message: 'Chargement...');
    if (state.error != null && state.students.isEmpty) return AppErrorWidget(message: state.error!, onRetry: () => ref.read(studentProvider.notifier).loadStudents());
    if (state.students.isEmpty) return const EmptyState(title: 'Aucun étudiant', icon: Icons.people_outlined);

    return RefreshIndicator(
      onRefresh: () => ref.read(studentProvider.notifier).loadStudents(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.students.length,
        itemBuilder: (context, index) {
          final student = state.students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        (student.firstName ?? '?')[0].toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.fullName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(student.studentNumber,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                    _buildLevelChip(student.levelName ?? '', theme),
                    const SizedBox(width: 8),
                    Text(student.programName ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelChip(String level, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(level, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
    );
  }
}
