import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/course_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/classroom_provider.dart';
import '../../providers/level_provider.dart';
import '../../widgets/forms/app_text_field.dart';
import '../../widgets/forms/app_dropdown_field.dart';

class CourseFormScreen extends ConsumerStatefulWidget {
  final int? courseId;
  const CourseFormScreen({super.key, this.courseId});

  @override
  ConsumerState<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends ConsumerState<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _semesterController = TextEditingController();
  final _academicYearController = TextEditingController();
  int? _selectedSubjectId;
  int? _selectedTeacherId;
  int? _selectedClassroomId;
  int? _selectedLevelId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subjectProvider.notifier).loadSubjects();
      ref.read(teacherProvider.notifier).loadTeachers();
      ref.read(classroomProvider.notifier).loadClassrooms();
    });
  }

  @override
  void dispose() {
    _semesterController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courseState = ref.watch(courseProvider);
    final subjectState = ref.watch(subjectProvider);
    final teacherState = ref.watch(teacherProvider);
    final classroomState = ref.watch(classroomProvider);
    final levelsAsync = ref.watch(allLevelsProvider);
    final isEdit = widget.courseId != null;

    final allLevels = levelsAsync.valueOrNull ?? [];

    final course = widget.courseId != null
        ? courseState.courses.where((c) => c.id == widget.courseId).firstOrNull
        : null;

    if (isEdit && _semesterController.text.isEmpty) {
      if (course != null) {
        _semesterController.text = course.semester ?? '';
        _academicYearController.text = course.academicYear ?? '';
        _selectedSubjectId = course.subjectId;
        _selectedTeacherId = course.teacherId;
        _selectedClassroomId = course.classroomId;
        _selectedLevelId = course.levelId;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier cours' : 'Ajouter cours')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(theme, Icons.menu_book_rounded, 'Assignations'),
                  const SizedBox(height: 20),
                  AppDropdownField<int>(label: 'Matière', value: _selectedSubjectId, prefixIcon: Icons.book_rounded, items: subjectState.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(), onChanged: (v) => setState(() => _selectedSubjectId = v)),
                  const SizedBox(height: 16),
                  AppDropdownField<int>(label: 'Enseignant', value: _selectedTeacherId, prefixIcon: Icons.person_rounded, items: teacherState.teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.fullName))).toList(), onChanged: (v) => setState(() => _selectedTeacherId = v)),
                  const SizedBox(height: 16),
                  AppDropdownField<int>(label: 'Niveau', value: _selectedLevelId, prefixIcon: Icons.grade_rounded, items: allLevels.map((l) => DropdownMenuItem(value: l.id, child: Text(l.name))).toList(), onChanged: (v) => setState(() => _selectedLevelId = v)),
                  const SizedBox(height: 16),
                  AppDropdownField<int>(label: 'Salle', value: _selectedClassroomId, prefixIcon: Icons.meeting_room_rounded, items: classroomState.classrooms.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (v) => setState(() => _selectedClassroomId = v)),
                  const SizedBox(height: 24),
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  _buildSectionHeader(theme, Icons.schedule_rounded, 'Période'),
                  const SizedBox(height: 20),
                  AppTextField(label: 'Semestre', controller: _semesterController, prefixIcon: Icons.format_list_numbered_rounded, hintText: 'Ex: S1, S2...'),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Année académique', controller: _academicYearController, prefixIcon: Icons.calendar_today_rounded, hintText: 'Ex: 2024-2025'),
                  if (isEdit && course?.code != null)
                    AppTextField(
                      label: 'Code',
                      controller: TextEditingController(text: course!.code),
                      prefixIcon: Icons.qr_code_rounded,
                      enabled: false,
                    ),
                  if (isEdit && course?.code != null) const SizedBox(height: 16),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : Text(isEdit ? 'Mettre à jour' : 'Ajouter'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    final data = {
      'subject_id': _selectedSubjectId,
      'teacher_id': _selectedTeacherId,
      'level_id': _selectedLevelId,
      'classroom_id': _selectedClassroomId,
      'semester': _semesterController.text.trim(),
      'academic_year': _academicYearController.text.trim(),
    };

    bool success;
    if (widget.courseId != null) {
      success = await ref.read(courseProvider.notifier).updateCourse(widget.courseId!, data);
    } else {
      success = await ref.read(courseProvider.notifier).createCourse(data);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) context.pop();
    }
  }
}
