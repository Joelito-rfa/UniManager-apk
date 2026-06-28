import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/student_provider.dart';
import '../../providers/program_provider.dart';
import '../../providers/level_provider.dart';
import '../../widgets/forms/app_text_field.dart';
import '../../widgets/forms/app_dropdown_field.dart';
import '../../models/level_model.dart';
import '../../core/utils/validators.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  final int? studentId;
  const StudentFormScreen({super.key, this.studentId});

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _studentNumberController = TextEditingController();
  int? _selectedProgramId;
  int? _selectedLevelId;
  List<LevelModel> _filteredLevels = [];
  bool _isLoading = false;
  bool _isGeneratingNumber = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(programProvider.notifier).loadPrograms();
      if (widget.studentId != null) {
        ref.read(studentProvider.notifier).loadStudent(widget.studentId!);
      } else {
        _generateNextNumber();
      }
    });
  }

  Future<void> _generateNextNumber() async {
    setState(() => _isGeneratingNumber = true);
    final number = await ref.read(studentProvider.notifier).getNextStudentNumber();
    if (mounted) {
      setState(() {
        _studentNumberController.text = number ?? '';
        _isGeneratingNumber = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _studentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentState = ref.watch(studentProvider);
    final programState = ref.watch(programProvider);
    final levelsAsync = ref.watch(allLevelsProvider);
    final student = studentState.selectedStudent;
    final isEdit = widget.studentId != null;

    final allLevels = levelsAsync.valueOrNull ?? [];

    if (isEdit && student == null && studentState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modifier étudiant')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (isEdit && student != null && _firstNameController.text.isEmpty) {
      _firstNameController.text = student.firstName ?? '';
      _lastNameController.text = student.lastName ?? '';
      _emailController.text = student.email ?? '';
      _phoneController.text = student.phone ?? '';
      _addressController.text = student.address ?? '';
      _studentNumberController.text = student.studentNumber;
      _selectedProgramId = student.programId;
      _selectedLevelId = student.levelId;
    }

    _filteredLevels = allLevels;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier étudiant' : 'Ajouter étudiant')),
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
                  _buildSectionHeader(theme, Icons.person_rounded, 'Informations personnelles'),
                  const SizedBox(height: 20),
                  AppTextField(label: 'Prénom', controller: _firstNameController, prefixIcon: Icons.person_rounded, validator: (v) => Validators.name(v, 'Le prénom')),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Nom', controller: _lastNameController, prefixIcon: Icons.person_rounded, validator: (v) => Validators.name(v, 'Le nom')),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_rounded, validator: Validators.email),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Numéro étudiant', controller: _studentNumberController, prefixIcon: Icons.badge_rounded, enabled: !isEdit && !_isGeneratingNumber, validator: (v) => Validators.required(v, 'Le numéro étudiant')),
                  const SizedBox(height: 16),
                  if (isEdit && student?.code != null)
                    AppTextField(
                      label: 'Code',
                      controller: TextEditingController(text: student!.code),
                      prefixIcon: Icons.qr_code_rounded,
                      enabled: false,
                    ),
                  if (isEdit && student?.code != null) const SizedBox(height: 16),
                  AppTextField(label: 'Téléphone', controller: _phoneController, keyboardType: TextInputType.phone, prefixIcon: Icons.phone_rounded, validator: Validators.phone),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Adresse', controller: _addressController, prefixIcon: Icons.location_on_rounded, maxLines: 3),
                  const SizedBox(height: 24),
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  _buildSectionHeader(theme, Icons.school_rounded, 'Inscription'),
                  const SizedBox(height: 20),
                  AppDropdownField<int>(label: 'Filière', value: _selectedProgramId, prefixIcon: Icons.school_rounded, items: programState.programs.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(), onChanged: (v) => setState(() { _selectedProgramId = v; _selectedLevelId = null; })),
                  const SizedBox(height: 16),
                  AppDropdownField<int>(label: 'Niveau', value: _selectedLevelId, prefixIcon: Icons.grade_rounded, items: _filteredLevels.map((l) => DropdownMenuItem(value: l.id, child: Text(l.name))).toList(), onChanged: (v) => setState(() => _selectedLevelId = v)),
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
      'name': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'student_number': _studentNumberController.text.trim(),
      'program_id': _selectedProgramId,
      'level_id': _selectedLevelId,
    };

    bool success;
    if (widget.studentId != null) {
      success = await ref.read(studentProvider.notifier).updateStudent(widget.studentId!, data);
    } else {
      success = await ref.read(studentProvider.notifier).createStudent(data);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) context.pop();
    }
  }
}
