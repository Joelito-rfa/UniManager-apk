import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/classroom_provider.dart';
import '../../providers/level_provider.dart';
import '../../widgets/forms/app_text_field.dart';
import '../../widgets/forms/app_dropdown_field.dart';
import '../../models/level_model.dart';
import '../../core/utils/validators.dart';
import '../../core/constants/app_constants.dart';

class ScheduleFormScreen extends ConsumerStatefulWidget {
  final int? scheduleId;
  const ScheduleFormScreen({super.key, this.scheduleId});

  @override
  ConsumerState<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends ConsumerState<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _groupController = TextEditingController();
  int? _selectedCourseId;
  int? _selectedClassroomId;
  String? _selectedDay;
  String? _selectedSession;
  int? _selectedLevelId;
  List<LevelModel> _filteredLevels = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(courseProvider.notifier).loadCourses();
      ref.read(classroomProvider.notifier).loadClassrooms();
    });
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courseState = ref.watch(courseProvider);
    final classroomState = ref.watch(classroomProvider);
    final levelsAsync = ref.watch(allLevelsProvider);
    final isEdit = widget.scheduleId != null;

    final allLevels = levelsAsync.valueOrNull ?? [];
    _filteredLevels = allLevels;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier créneau' : 'Ajouter créneau')),
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
                  _buildSectionHeader(theme, Icons.calendar_month_rounded, 'Planning'),
                  const SizedBox(height: 20),
                  AppDropdownField<int>(label: 'Cours', value: _selectedCourseId, prefixIcon: Icons.menu_book_rounded, items: courseState.courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.subjectName ?? ''))).toList(), onChanged: (v) => setState(() => _selectedCourseId = v)),
                  const SizedBox(height: 16),
                  AppDropdownField<int>(label: 'Salle', value: _selectedClassroomId, prefixIcon: Icons.meeting_room_rounded, items: classroomState.classrooms.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (v) => setState(() => _selectedClassroomId = v)),
                  const SizedBox(height: 16),
                  AppDropdownField<String>(label: 'Jour', value: _selectedDay, prefixIcon: Icons.calendar_today_rounded, items: AppConstants.weekDays.map((d) => DropdownMenuItem(value: _dayToEnglish(d), child: Text(d))).toList(), onChanged: (v) => setState(() => _selectedDay = v)),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Heure début (HH:mm)', controller: _startTimeController, prefixIcon: Icons.schedule_rounded, hintText: '08:00', validator: (v) => Validators.required(v, "L'heure de début")),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Heure fin (HH:mm)', controller: _endTimeController, prefixIcon: Icons.schedule_rounded, hintText: '10:00', validator: (v) => Validators.required(v, "L'heure de fin")),
                  const SizedBox(height: 16),
                  AppDropdownField<String>(label: 'Session', value: _selectedSession, prefixIcon: Icons.wb_sunny_rounded, items: [
                    const DropdownMenuItem(value: 'morning', child: Text('Matin')),
                    const DropdownMenuItem(value: 'afternoon', child: Text('Après-midi')),
                    const DropdownMenuItem(value: 'evening', child: Text('Soir')),
                  ], onChanged: (v) => setState(() => _selectedSession = v)),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Groupe', controller: _groupController, prefixIcon: Icons.group_rounded),
                  const SizedBox(height: 16),
                  AppDropdownField<int>(label: 'Niveau', value: _selectedLevelId, prefixIcon: Icons.grade_rounded, items: _filteredLevels.map((l) => DropdownMenuItem(value: l.id, child: Text(l.name))).toList(), onChanged: (v) => setState(() => _selectedLevelId = v)),
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

  String _dayToEnglish(String frenchDay) {
    const map = {
      'Lundi': 'Monday', 'Mardi': 'Tuesday', 'Mercredi': 'Wednesday',
      'Jeudi': 'Thursday', 'Vendredi': 'Friday', 'Samedi': 'Saturday', 'Dimanche': 'Sunday',
    };
    return map[frenchDay] ?? frenchDay;
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
      'course_id': _selectedCourseId,
      'classroom_id': _selectedClassroomId,
      'level_id': _selectedLevelId,
      'day_of_week': _selectedDay,
      'start_time': _startTimeController.text.trim(),
      'end_time': _endTimeController.text.trim(),
      'session': _selectedSession,
      'group': _groupController.text.trim(),
    };

    final isEdit = widget.scheduleId != null;
    bool success;
    if (isEdit) {
      success = await ref.read(scheduleProvider.notifier).updateSchedule(widget.scheduleId!, data);
    } else {
      success = await ref.read(scheduleProvider.notifier).createSchedule(data);
    }

    setState(() => _isLoading = false);

    if (mounted && success) {
      if (context.mounted) context.pop();
    } else if (mounted) {
      final error = ref.read(scheduleProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Erreur lors de la création du créneau')),
      );
    }
  }
}
