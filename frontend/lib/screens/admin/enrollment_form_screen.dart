import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/program_provider.dart';
import '../../widgets/forms/app_text_field.dart';
import '../../widgets/forms/app_dropdown_field.dart';
import '../../core/utils/validators.dart';

class EnrollmentFormScreen extends ConsumerStatefulWidget {
  final int? enrollmentId;
  const EnrollmentFormScreen({super.key, this.enrollmentId});

  @override
  ConsumerState<EnrollmentFormScreen> createState() => _EnrollmentFormScreenState();
}

class _EnrollmentFormScreenState extends ConsumerState<EnrollmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _academicYearController = TextEditingController();
  int? _selectedStudentId;
  int? _selectedProgramId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studentProvider.notifier).loadStudents();
      ref.read(programProvider.notifier).loadPrograms();
    });
  }

  @override
  void dispose() {
    _academicYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentState = ref.watch(studentProvider);
    final programState = ref.watch(programProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle inscription')),
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
                  _buildSectionHeader(theme, Icons.assignment_rounded, "Informations d'inscription"),
                  const SizedBox(height: 20),
                  AppDropdownField<int>(label: 'Étudiant', value: _selectedStudentId, prefixIcon: Icons.person_rounded, items: studentState.students.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.fullName} (${s.studentNumber})'))).toList(), onChanged: (v) => setState(() => _selectedStudentId = v)),
                  const SizedBox(height: 16),
                  AppDropdownField<int>(label: 'Filière', value: _selectedProgramId, prefixIcon: Icons.school_rounded, items: programState.programs.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(), onChanged: (v) => setState(() => _selectedProgramId = v)),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Année académique', controller: _academicYearController, prefixIcon: Icons.calendar_today_rounded, hintText: '2024-2025', validator: (v) => Validators.required(v, "L'année académique")),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : const Text('Inscrire'),
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
      'student_id': _selectedStudentId,
      'program_id': _selectedProgramId,
      'academic_year': _academicYearController.text.trim(),
    };

    final success = await ref.read(enrollmentProvider.notifier).createEnrollment(data);
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) context.pop();
    }
  }
}
