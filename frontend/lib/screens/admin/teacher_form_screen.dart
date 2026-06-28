import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/department_provider.dart';
import '../../widgets/forms/app_text_field.dart';
import '../../widgets/forms/app_dropdown_field.dart';
import '../../core/utils/validators.dart';

class TeacherFormScreen extends ConsumerStatefulWidget {
  final int? teacherId;
  const TeacherFormScreen({super.key, this.teacherId});

  @override
  ConsumerState<TeacherFormScreen> createState() => _TeacherFormScreenState();
}

class _TeacherFormScreenState extends ConsumerState<TeacherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _teacherNumberController = TextEditingController();
  final _specialityController = TextEditingController();
  int? _selectedDepartmentId;
  bool _isLoading = false;
  bool _isGeneratingNumber = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(departmentProvider.notifier).loadDepartments();
      if (widget.teacherId != null) {
        ref.read(teacherProvider.notifier).loadTeacher(widget.teacherId!);
      } else {
        _generateNextNumber();
      }
    });
  }

  Future<void> _generateNextNumber() async {
    setState(() => _isGeneratingNumber = true);
    final number = await ref.read(teacherProvider.notifier).getNextTeacherNumber();
    if (mounted) {
      setState(() {
        _teacherNumberController.text = number ?? '';
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
    _teacherNumberController.dispose();
    _specialityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teacherState = ref.watch(teacherProvider);
    final departmentState = ref.watch(departmentProvider);
    final teacher = teacherState.selectedTeacher;
    final isEdit = widget.teacherId != null;

    if (isEdit && teacher == null && teacherState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modifier enseignant')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (isEdit && teacher != null && _firstNameController.text.isEmpty) {
      _firstNameController.text = teacher.firstName ?? '';
      _lastNameController.text = teacher.lastName ?? '';
      _emailController.text = teacher.email ?? '';
      _phoneController.text = teacher.phone ?? '';
      _addressController.text = teacher.address ?? '';
      _teacherNumberController.text = teacher.teacherNumber;
      _specialityController.text = teacher.speciality ?? '';
      _selectedDepartmentId = teacher.departmentId;
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier enseignant' : 'Ajouter enseignant')),
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
                  AppTextField(label: 'Téléphone', controller: _phoneController, keyboardType: TextInputType.phone, prefixIcon: Icons.phone_rounded, validator: Validators.phone),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Adresse', controller: _addressController, prefixIcon: Icons.location_on_rounded, maxLines: 3),
                  const SizedBox(height: 24),
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  _buildSectionHeader(theme, Icons.work_rounded, 'Informations professionnelles'),
                  const SizedBox(height: 20),
                  AppTextField(label: 'Numéro enseignant', controller: _teacherNumberController, prefixIcon: Icons.badge_rounded, enabled: !isEdit && !_isGeneratingNumber, validator: (v) => Validators.required(v, 'Le numéro')),
                  const SizedBox(height: 16),
                  if (isEdit && teacher?.code != null)
                    AppTextField(
                      label: 'Code',
                      controller: TextEditingController(text: teacher!.code),
                      prefixIcon: Icons.qr_code_rounded,
                      enabled: false,
                    ),
                  if (isEdit && teacher?.code != null) const SizedBox(height: 16),
                  AppTextField(label: 'Spécialité', controller: _specialityController, prefixIcon: Icons.science_rounded),
                  const SizedBox(height: 16),
                  AppDropdownField<int>(
                    label: 'Département', value: _selectedDepartmentId, prefixIcon: Icons.business_rounded,
                    items: departmentState.departments.map((dept) => DropdownMenuItem(value: dept.id, child: Text(dept.name))).toList(),
                    onChanged: (v) => setState(() => _selectedDepartmentId = v),
                  ),
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
      'name': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'teacher_number': _teacherNumberController.text.trim(),
      'speciality': _specialityController.text.trim(),
      'department_id': _selectedDepartmentId,
    };

    bool success;
    if (widget.teacherId != null) {
      success = await ref.read(teacherProvider.notifier).updateTeacher(widget.teacherId!, data);
    } else {
      success = await ref.read(teacherProvider.notifier).createTeacher(data);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) context.pop();
    }
  }
}
