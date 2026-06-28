import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/subject_provider.dart';
import '../../providers/program_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/level_provider.dart';
import '../../widgets/forms/app_text_field.dart';
import '../../widgets/forms/app_dropdown_field.dart';
import '../../models/level_model.dart';
import '../../core/utils/validators.dart';

class SubjectFormScreen extends ConsumerStatefulWidget {
  final int? subjectId;
  const SubjectFormScreen({super.key, this.subjectId});

  @override
  ConsumerState<SubjectFormScreen> createState() => _SubjectFormScreenState();
}

class _SubjectFormScreenState extends ConsumerState<SubjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _creditsController = TextEditingController();
  final _hoursController = TextEditingController();
  final _coefficientController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _selectedProgramId;
  int? _selectedTeacherId;
  int? _selectedLevelId;
  List<LevelModel> _filteredLevels = [];
  bool _isLoading = false;
  bool _isGeneratingCode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(programProvider.notifier).loadPrograms();
      if (widget.subjectId == null) {
        _generateNextCode();
      }
    });
  }

  Future<void> _generateNextCode() async {
    setState(() => _isGeneratingCode = true);
    final code = await ref.read(subjectProvider.notifier).getNextSubjectCode();
    if (mounted) {
      setState(() {
        _codeController.text = code ?? '';
        _isGeneratingCode = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _creditsController.dispose();
    _hoursController.dispose();
    _coefficientController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectState = ref.watch(subjectProvider);
    final programState = ref.watch(programProvider);
    final teacherState = ref.watch(teacherProvider);
    final levelsAsync = ref.watch(allLevelsProvider);
    final isEdit = widget.subjectId != null;

    final allLevels = levelsAsync.valueOrNull ?? [];

    if (isEdit && _nameController.text.isEmpty) {
      final subject = subjectState.subjects.where((s) => s.id == widget.subjectId).firstOrNull;
      if (subject != null) {
        _nameController.text = subject.name;
        _codeController.text = subject.code ?? '';
        _creditsController.text = subject.credits?.toString() ?? '';
        _hoursController.text = subject.hoursTotal?.toString() ?? '';
        _coefficientController.text = subject.coefficient?.toString() ?? '';
        _descriptionController.text = subject.description ?? '';
        _selectedProgramId = subject.programId;
        _selectedTeacherId = subject.teacherId;
        _selectedLevelId = subject.levelId;
      }
    }

    _filteredLevels = allLevels;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier matière' : 'Ajouter matière')),
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
                  _buildSectionHeader(theme, Icons.book_rounded, 'Informations générales'),
                  const SizedBox(height: 20),
                  AppTextField(label: 'Nom', controller: _nameController, prefixIcon: Icons.book_rounded, validator: (v) => Validators.name(v, 'Le nom')),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Code', controller: _codeController, prefixIcon: Icons.code_rounded, enabled: !isEdit && !_isGeneratingCode),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Crédits', controller: _creditsController, keyboardType: TextInputType.number, prefixIcon: Icons.star_rounded),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Heures', controller: _hoursController, keyboardType: TextInputType.number, prefixIcon: Icons.timer_rounded),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Coefficient', controller: _coefficientController, keyboardType: TextInputType.number, prefixIcon: Icons.scale_rounded),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Description', controller: _descriptionController, maxLines: 3, prefixIcon: Icons.description_rounded),
                  const SizedBox(height: 24),
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  _buildSectionHeader(theme, Icons.assignment_rounded, 'Assignations'),
                  const SizedBox(height: 20),
                  AppDropdownField<int>(label: 'Filière', value: _selectedProgramId, prefixIcon: Icons.school_rounded, items: programState.programs.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(), onChanged: (v) => setState(() => _selectedProgramId = v)),
                  const SizedBox(height: 16),
                  AppDropdownField<int>(label: 'Enseignant', value: _selectedTeacherId, prefixIcon: Icons.person_rounded, items: teacherState.teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.fullName))).toList(), onChanged: (v) => setState(() => _selectedTeacherId = v)),
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
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'credits': int.tryParse(_creditsController.text.trim()),
      'hours_total': int.tryParse(_hoursController.text.trim()),
      'coefficient': int.tryParse(_coefficientController.text.trim()),
      'description': _descriptionController.text.trim(),
      'program_id': _selectedProgramId,
      'level_id': _selectedLevelId,
      'teacher_id': _selectedTeacherId,
    };

    bool success;
    if (widget.subjectId != null) {
      success = await ref.read(subjectProvider.notifier).updateSubject(widget.subjectId!, data);
    } else {
      success = await ref.read(subjectProvider.notifier).createSubject(data);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) context.pop();
    }
  }
}
