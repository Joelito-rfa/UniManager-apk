import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/grade_provider.dart';
import '../../providers/course_provider.dart';
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
  String _selectedGradeType = 'Examen';
  final _gradeTypeOptions = ['Examen', 'Devoir', 'Projet', 'TP', 'TD', 'Oral', 'Partiel', 'Final'];
  bool _isSubmitting = false;
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courseId = widget.courseId;
      if (courseId != null) {
        _selectedCourseId = courseId;
        _loadData(courseId);
      }
      ref.read(courseProvider.notifier).loadCourses(endpoint: ApiConstants.teacherCourses);
    });
  }

  void _loadData(int courseId) {
    ref.read(enrollmentProvider.notifier).loadEnrollments(
      filters: {'course_id': courseId},
      role: widget.role,
    );
    ref.read(gradeProvider.notifier).loadGrades(
      role: widget.role,
      filters: {'course_id': courseId},
    );
  }

  @override
  void dispose() {
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

    if (_selectedCourseId == null) {
      final courseState = ref.watch(courseProvider);
      final theme = Theme.of(context);
      if (courseState.isLoading && courseState.courses.isEmpty) {
        return const LoadingWidget(message: 'Chargement des cours...');
      }
      if (courseState.error != null && courseState.courses.isEmpty) {
        return AppErrorWidget(message: courseState.error!, onRetry: () => ref.read(courseProvider.notifier).loadCourses(endpoint: ApiConstants.teacherCourses));
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.grade_rounded, size: 64, color: theme.colorScheme.primary.withAlpha(80)),
              const SizedBox(height: 16),
              Text('Saisie des notes', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Sélectionnez un cours pour saisir les notes', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              SizedBox(
                width: 320,
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Cours',
                    prefixIcon: Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: courseState.courses.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.subjectName ?? ''),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedCourseId = v);
                      _loadData(v);
                    }
                  },
                ),
              ),
              if (courseState.courses.isEmpty && !courseState.isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Aucun cours disponible', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ),
            ],
          ),
        ),
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
      _gradeControllers.putIfAbsent(enrollment.id, () => TextEditingController());
    }

    for (final grade in gradeState.grades) {
      _gradeControllers[grade.enrollmentId]?.text = grade.grade.toString();
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedGradeType,
            decoration: InputDecoration(
              labelText: "Type d'évaluation",
              prefixIcon: Icon(Icons.category_rounded, size: 20, color: theme.colorScheme.primary),
              border: InputBorder.none,
            ),
            items: _gradeTypeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedGradeType = v);
            },
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
              final controller = _gradeControllers[enrollment.id]!;
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

  bool _validateGrade(String text) {
    if (text.isEmpty) return true;
    final value = double.tryParse(text);
    return value != null && value >= 0 && value <= 20;
  }

  Future<void> _submitGrades() async {
    final enrollmentState = ref.read(enrollmentProvider);

    final invalid = enrollmentState.enrollments.firstWhere(
      (e) {
        final ctrl = _gradeControllers[e.id];
        return ctrl != null && ctrl.text.isNotEmpty && !_validateGrade(ctrl.text);
      },
      orElse: () => enrollmentState.enrollments.first,
    );

    final ctrl = _gradeControllers[invalid.id];
    if (ctrl != null && ctrl.text.isNotEmpty && !_validateGrade(ctrl.text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les notes doivent être comprises entre 0 et 20')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    final grades = enrollmentState.enrollments
        .where((e) {
          final controller = _gradeControllers[e.id];
          return controller != null && controller.text.isNotEmpty;
        })
        .map((e) => {
              'enrollment_id': e.id,
              'grade_value': double.tryParse(_gradeControllers[e.id]!.text),
              'grade_type': _selectedGradeType,
              'course_id': _selectedCourseId,
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
