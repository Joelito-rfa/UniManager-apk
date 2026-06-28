import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/program_provider.dart';
import '../../providers/department_provider.dart';
import '../../widgets/forms/app_text_field.dart';
import '../../widgets/forms/app_dropdown_field.dart';
import '../../core/utils/validators.dart';

class ProgramFormScreen extends ConsumerStatefulWidget {
  final int? programId;
  const ProgramFormScreen({super.key, this.programId});

  @override
  ConsumerState<ProgramFormScreen> createState() => _ProgramFormScreenState();
}

class _ProgramFormScreenState extends ConsumerState<ProgramFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  int? _selectedDepartmentId;
  bool _isLoading = false;
  bool _isGeneratingCode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(departmentProvider.notifier).loadDepartments();
      if (widget.programId == null) {
        _generateNextCode();
      }
    });
  }

  Future<void> _generateNextCode() async {
    setState(() => _isGeneratingCode = true);
    final code = await ref.read(programProvider.notifier).getNextProgramCode();
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
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final programState = ref.watch(programProvider);
    final departmentState = ref.watch(departmentProvider);
    final isEdit = widget.programId != null;

    if (isEdit && _nameController.text.isEmpty) {
      final program = programState.programs.where((p) => p.id == widget.programId).firstOrNull;
      if (program != null) {
        _nameController.text = program.name;
        _codeController.text = program.code ?? '';
        _descriptionController.text = program.description ?? '';
        _durationController.text = program.duration?.toString() ?? '';
        _selectedDepartmentId = program.departmentId;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier filière' : 'Ajouter filière')),
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
                  _buildSectionHeader(theme, Icons.school_rounded, 'Informations générales'),
                  const SizedBox(height: 20),
                  AppTextField(label: 'Nom', controller: _nameController, prefixIcon: Icons.school_rounded, validator: (v) => Validators.name(v, 'Le nom')),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Code', controller: _codeController, prefixIcon: Icons.code_rounded, enabled: !isEdit && !_isGeneratingCode),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Durée (années)', controller: _durationController, keyboardType: TextInputType.number, prefixIcon: Icons.timer_rounded),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Description', controller: _descriptionController, maxLines: 3, prefixIcon: Icons.description_rounded),
                  const SizedBox(height: 24),
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  _buildSectionHeader(theme, Icons.business_rounded, 'Département'),
                  const SizedBox(height: 20),
                  AppDropdownField<int>(label: 'Département', value: _selectedDepartmentId, prefixIcon: Icons.business_rounded, items: departmentState.departments.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(), onChanged: (v) => setState(() => _selectedDepartmentId = v)),
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
      'description': _descriptionController.text.trim(),
      'duration': int.tryParse(_durationController.text.trim()),
      'department_id': _selectedDepartmentId,
    };

    bool success;
    if (widget.programId != null) {
      success = await ref.read(programProvider.notifier).updateProgram(widget.programId!, data);
    } else {
      success = await ref.read(programProvider.notifier).createProgram(data);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) context.pop();
    }
  }
}
