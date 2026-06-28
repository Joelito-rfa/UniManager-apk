import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExamFormScreen extends ConsumerStatefulWidget {
  final int? examId;
  final String role;

  const ExamFormScreen({super.key, this.examId, this.role = 'admin'});

  @override
  ConsumerState<ExamFormScreen> createState() => _ExamFormScreenState();
}

class _ExamFormScreenState extends ConsumerState<ExamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _subject;
  late String _level;
  late String _program;
  late String _classroom;
  late String _teacher;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late DateTime _date;
  late String _status;

  final _levels = ['L1', 'L2', 'L3', 'M1', 'M2'];
  final _programs = ['Informatique', 'Réseaux & Télécoms', 'Génie Logiciel', 'Cybersécurité'];
  final _classrooms = ['Salle 101', 'Salle 203', 'Salle 105', 'Amphi A', 'Labo Réseaux'];
  final _teachers = ['Dr. Koné', 'Dr. Diallo', 'Pr. Traoré', 'Mme. Coulibaly', 'Dr. Fofana'];
  final _statuses = ['Brouillon', 'Publié', 'Terminé'];

  @override
  void initState() {
    super.initState();
    _subject = '';
    _level = _levels[0];
    _program = _programs[0];
    _classroom = _classrooms[0];
    _teacher = _teachers[0];
    _startTime = const TimeOfDay(hour: 8, minute: 0);
    _endTime = const TimeOfDay(hour: 10, minute: 0);
    _date = DateTime.now().add(const Duration(days: 7));
    _status = _statuses[0];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.examId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Modifier examen' : 'Nouvel examen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, isEdit),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildSectionTitle(theme, Icons.info_rounded, 'Informations générales'),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Matière',
                      prefixIcon: Icon(Icons.book_rounded),
                    ),
                    initialValue: _subject,
                    onChanged: (v) => _subject = v,
                    validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _level,
                          decoration: const InputDecoration(
                            labelText: 'Niveau',
                            prefixIcon: Icon(Icons.school_rounded),
                          ),
                          items: _levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                          onChanged: (v) => setState(() => _level = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _program,
                          decoration: const InputDecoration(
                            labelText: 'Filière',
                            prefixIcon: Icon(Icons.business_rounded),
                          ),
                          items: _programs.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                          onChanged: (v) => setState(() => _program = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, Icons.access_time_rounded, 'Date & Horaire'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _date,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) setState(() => _date = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              prefixIcon: Icon(Icons.calendar_today_rounded),
                            ),
                            child: Text(
                              '${_date.day.toString().padLeft(2, '0')}/'
                              '${_date.month.toString().padLeft(2, '0')}/'
                              '${_date.year}',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _startTime,
                            );
                            if (picked != null) setState(() => _startTime = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Heure début',
                              prefixIcon: Icon(Icons.access_time_rounded),
                            ),
                            child: Text(_startTime.format(context)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _endTime,
                            );
                            if (picked != null) setState(() => _endTime = picked);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Heure fin',
                              prefixIcon: Icon(Icons.access_time_rounded),
                            ),
                            child: Text(_endTime.format(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, Icons.location_on_rounded, 'Lieu & Responsable'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _classroom,
                          decoration: const InputDecoration(
                            labelText: 'Salle',
                            prefixIcon: Icon(Icons.meeting_room_rounded),
                          ),
                          items: _classrooms.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _classroom = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _teacher,
                          decoration: const InputDecoration(
                            labelText: 'Enseignant',
                            prefixIcon: Icon(Icons.person_rounded),
                          ),
                          items: _teachers.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() => _teacher = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, Icons.info_rounded, 'Statut'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      prefixIcon: Icon(Icons.info_rounded),
                    ),
                    items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEdit ? 'Examen modifié avec succès' : 'Examen créé avec succès'),
                              ),
                            );
                            context.pop();
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: Text(isEdit ? 'Enregistrer' : "Créer l'examen"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isEdit) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.quiz_rounded, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? "Modifier l'examen" : 'Créer un examen',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              'Remplissez les informations ci-dessous',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, IconData icon, String title) {
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
}
