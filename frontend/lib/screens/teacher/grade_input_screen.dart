import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/grade_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';

class GradeInputScreen extends ConsumerStatefulWidget {
  final int? courseId;
  final String role;
  const GradeInputScreen({super.key, this.courseId, this.role = 'teacher'});

  @override
  ConsumerState<GradeInputScreen> createState() => _GradeInputScreenState();
}

class _GradeInputScreenState extends ConsumerState<GradeInputScreen> {
  final Map<int, TextEditingController> _gradeControllers = {};
  final _gradeTypeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.courseId != null) {
        ref.read(enrollmentProvider.notifier).loadEnrollments(
          filters: {'course_id': widget.courseId},
          role: widget.role,
        );
        ref.read(gradeProvider.notifier).loadGrades(
          role: widget.role,
          filters: {'course_id': widget.courseId},
        );
      }
    });
  }

  @override
  void dispose() {
    _gradeTypeController.dispose();
    for (final controller in _gradeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enrollmentState = ref.watch(enrollmentProvider);
    final gradeState = ref.watch(gradeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saisie des notes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _submitGrades,
              icon: _isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(_isSubmitting ? 'En cours...' : 'Enregistrer'),
            ),
          ),
        ],
      ),
      body: _buildBody(theme, enrollmentState, gradeState),
    );
  }

  Widget _buildBody(ThemeData theme, EnrollmentState enrollmentState, GradeState gradeState) {
    if (enrollmentState.isLoading) return const LoadingWidget(message: 'Chargement des étudiants...');
    if (enrollmentState.error != null) return AppErrorWidget(message: enrollmentState.error!);

    if (widget.courseId == null) {
      return EmptyState(
        title: 'Sélectionnez un cours',
        subtitle: 'Choisissez un cours depuis la liste pour saisir les notes.',
        icon: Icons.touch_app,
      );
    }

    if (enrollmentState.enrollments.isEmpty) {
      return EmptyState(
        title: 'Aucun étudiant',
        subtitle: 'Aucun étudiant inscrit à ce cours.',
        icon: Icons.people_outlined,
      );
    }

    for (final enrollment in enrollmentState.enrollments) {
      _gradeControllers.putIfAbsent(enrollment.studentId, () => TextEditingController());
    }

    for (final grade in gradeState.grades) {
      _gradeControllers[grade.enrollmentId]?.text = grade.grade.toString();
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _gradeTypeController,
            decoration: InputDecoration(
              labelText: "Type d'évaluation",
              prefixIcon: Icon(Icons.category_rounded, size: 20, color: theme.colorScheme.primary),
              hintText: 'Examen, Devoir, Projet...',
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('${enrollmentState.enrollments.length} étudiant(s)',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const Spacer(),
              Text('Saisissez les notes sur 20',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: enrollmentState.enrollments.length,
            itemBuilder: (context, index) {
              final enrollment = enrollmentState.enrollments[index];
              final controller = _gradeControllers[enrollment.studentId]!;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          enrollment.studentName?.isNotEmpty == true ? enrollment.studentName![0].toUpperCase() : '?',
                          style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(enrollment.studentName ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                            Text(enrollment.studentNumber ?? '', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Note',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _submitGrades() async {
    setState(() => _isSubmitting = true);
    final enrollmentState = ref.read(enrollmentProvider);

    final grades = enrollmentState.enrollments
        .where((e) {
          final controller = _gradeControllers[e.studentId];
          return controller != null && controller.text.isNotEmpty;
        })
        .map((e) => {
              'enrollment_id': e.id,
              'grade_value': double.tryParse(_gradeControllers[e.studentId]!.text),
              'grade_type': _gradeTypeController.text.trim(),
              'course_id': widget.courseId,
            })
        .toList();

    if (grades.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune note à enregistrer')),
        );
      }
      setState(() => _isSubmitting = false);
      return;
    }

    final success = await ref.read(gradeProvider.notifier).submitGrades(grades, role: widget.role);
    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Notes enregistrées' : 'L\'enregistrement a échoué'),
        ),
      );
      if (success) context.pop();
    }
  }
}
