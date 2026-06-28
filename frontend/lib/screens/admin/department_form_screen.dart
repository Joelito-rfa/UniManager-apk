import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/department_provider.dart';
import '../../widgets/forms/app_text_field.dart';
import '../../core/utils/validators.dart';

class DepartmentFormScreen extends ConsumerStatefulWidget {
  final int? departmentId;
  const DepartmentFormScreen({super.key, this.departmentId});

  @override
  ConsumerState<DepartmentFormScreen> createState() => _DepartmentFormScreenState();
}

class _DepartmentFormScreenState extends ConsumerState<DepartmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isGeneratingCode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.departmentId != null) {
        ref.read(departmentProvider.notifier).loadDepartments();
      } else {
        _generateNextCode();
      }
    });
  }

  Future<void> _generateNextCode() async {
    setState(() => _isGeneratingCode = true);
    final code = await ref.read(departmentProvider.notifier).getNextDepartmentCode();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(departmentProvider);
    final isEdit = widget.departmentId != null;

    if (isEdit && _nameController.text.isEmpty) {
      final dept = state.departments.where((d) => d.id == widget.departmentId).firstOrNull;
      if (dept != null) {
        _nameController.text = dept.name;
        _codeController.text = dept.code ?? '';
        _descriptionController.text = dept.description ?? '';
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier département' : 'Ajouter département')),
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
                  _buildSectionHeader(theme, Icons.business_rounded, 'Informations générales'),
                  const SizedBox(height: 20),
                  AppTextField(label: 'Nom', controller: _nameController, prefixIcon: Icons.business_rounded, validator: (v) => Validators.name(v, 'Le nom')),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Code', controller: _codeController, prefixIcon: Icons.code_rounded, enabled: !isEdit && !_isGeneratingCode),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Description', controller: _descriptionController, prefixIcon: Icons.description_rounded, maxLines: 3),
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
    };

    bool success;
    if (widget.departmentId != null) {
      success = await ref.read(departmentProvider.notifier).updateDepartment(widget.departmentId!, data);
    } else {
      success = await ref.read(departmentProvider.notifier).createDepartment(data);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) context.pop();
    }
  }
}
