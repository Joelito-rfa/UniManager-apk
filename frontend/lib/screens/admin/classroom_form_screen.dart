import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/classroom_provider.dart';
import '../../widgets/forms/app_text_field.dart';
import '../../widgets/forms/app_dropdown_field.dart';
import '../../core/utils/validators.dart';

class ClassroomFormScreen extends ConsumerStatefulWidget {
  final int? classroomId;
  const ClassroomFormScreen({super.key, this.classroomId});

  @override
  ConsumerState<ClassroomFormScreen> createState() => _ClassroomFormScreenState();
}

class _ClassroomFormScreenState extends ConsumerState<ClassroomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  String? _selectedType;
  bool _isLoading = false;
  bool _isGeneratingCode = false;

  final _types = {
    'amphi': 'Amphithéâtre',
    'cours': 'Salle de cours',
    'td': 'Salle de TD',
    'tp': 'Salle de TP',
    'labo': 'Laboratoire',
    'info': 'Salle informatique',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.classroomId == null) {
        _generateNextCode();
      }
    });
  }

  Future<void> _generateNextCode() async {
    setState(() => _isGeneratingCode = true);
    final code = await ref.read(classroomProvider.notifier).getNextClassroomCode();
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
    _capacityController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(classroomProvider);
    final isEdit = widget.classroomId != null;

    if (isEdit && _nameController.text.isEmpty) {
      final room = state.classrooms.where((c) => c.id == widget.classroomId).firstOrNull;
      if (room != null) {
        _nameController.text = room.name;
        _codeController.text = room.code ?? '';
        _capacityController.text = room.capacity?.toString() ?? '';
        _buildingController.text = room.building ?? '';
        _floorController.text = room.floor?.toString() ?? '';
        _selectedType = room.type;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier salle' : 'Ajouter salle')),
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
                  _buildSectionHeader(theme, Icons.meeting_room_rounded, 'Informations générales'),
                  const SizedBox(height: 20),
                  AppTextField(label: 'Nom', controller: _nameController, prefixIcon: Icons.meeting_room_rounded, validator: (v) => Validators.name(v, 'Le nom')),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Code', controller: _codeController, prefixIcon: Icons.code_rounded, enabled: !isEdit && !_isGeneratingCode),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Capacité', controller: _capacityController, keyboardType: TextInputType.number, prefixIcon: Icons.people_rounded),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Bâtiment', controller: _buildingController, prefixIcon: Icons.location_on_rounded),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Étage', controller: _floorController, keyboardType: TextInputType.number, prefixIcon: Icons.stairs_rounded),
                  const SizedBox(height: 16),
                  AppDropdownField<String>(label: 'Type', value: _selectedType, prefixIcon: Icons.category_rounded, items: _types.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(), onChanged: (v) => setState(() => _selectedType = v)),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : Text(isEdit ? 'Mettre à jour' : 'Ajouter'),
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
      'capacity': int.tryParse(_capacityController.text.trim()),
      'building': _buildingController.text.trim(),
      'floor': int.tryParse(_floorController.text.trim()),
      'type': _selectedType,
    };

    bool success;
    if (widget.classroomId != null) {
      success = await ref.read(classroomProvider.notifier).updateClassroom(widget.classroomId!, data);
    } else {
      success = await ref.read(classroomProvider.notifier).createClassroom(data);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) context.pop();
    }
  }
}
