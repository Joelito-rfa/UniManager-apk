import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ExamData {
  final int id;
  final String subject;
  final String level;
  final String program;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String classroom;
  final String teacher;
  final String status;

  const ExamData({
    required this.id,
    required this.subject,
    required this.level,
    required this.program,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.classroom,
    required this.teacher,
    required this.status,
  });
}

final _mockExams = [
  ExamData(id: 1, subject: 'Mathématiques', level: 'L3', program: 'Informatique',
      date: DateTime(2026, 6, 22), startTime: '08:00', endTime: '10:00',
      classroom: 'Salle 101', teacher: 'Dr. Koné', status: 'Publié'),
  ExamData(id: 2, subject: 'Algorithmique', level: 'L2', program: 'Informatique',
      date: DateTime(2026, 6, 24), startTime: '10:00', endTime: '12:00',
      classroom: 'Salle 203', teacher: 'Dr. Diallo', status: 'Brouillon'),
  ExamData(id: 3, subject: 'Base de données', level: 'L3', program: 'Informatique',
      date: DateTime(2026, 6, 26), startTime: '14:00', endTime: '16:00',
      classroom: 'Amphi A', teacher: 'Pr. Traoré', status: 'Publié'),
  ExamData(id: 4, subject: 'Anglais', level: 'L1', program: 'Informatique',
      date: DateTime(2026, 6, 15), startTime: '08:00', endTime: '09:30',
      classroom: 'Salle 105', teacher: 'Mme. Coulibaly', status: 'Terminé'),
  ExamData(id: 5, subject: 'Réseaux', level: 'M1', program: 'Réseaux & Télécoms',
      date: DateTime(2026, 7, 1), startTime: '14:00', endTime: '16:00',
      classroom: 'Labo Réseaux', teacher: 'Dr. Fofana', status: 'Brouillon'),
];

class ExamListScreen extends ConsumerStatefulWidget {
  final String role;

  const ExamListScreen({super.key, this.role = 'admin'});

  @override
  ConsumerState<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends ConsumerState<ExamListScreen> {
  List<ExamData> get exams => _mockExams;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 900;
    final canManage = widget.role == 'admin' || widget.role == 'teacher';
    Color statusColor(String status) {
      switch (status) {
        case 'Publié': return const Color(0xFF059669);
        case 'Brouillon': return const Color(0xFFD97706);
        case 'Terminé': return const Color(0xFF64748B);
        default: return theme.colorScheme.outline;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Examens'),
        actions: canManage
            ? [
                FilledButton.icon(
                  onPressed: () => context.go('/${widget.role}/exams/add'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Nouvel examen'),
                ),
                const SizedBox(width: 16),
              ]
            : null,
      ),
      body: exams.isEmpty
          ? _buildEmptyState(theme)
          : isWide
              ? _buildDataTable(theme, statusColor, canManage)
              : _buildCardList(theme, statusColor, canManage),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.quiz_outlined, size: 48, color: theme.colorScheme.outlineVariant),
          ),
          const SizedBox(height: 16),
          Text('Aucun examen', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Les examens programmés apparaîtront ici',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(ThemeData theme, Color Function(String) statusColor, bool canManage) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.quiz_rounded, size: 16, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Text('Liste des examens', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              DataTable(
                headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withAlpha(80)),
                columns: [
                  DataColumn(label: Text('Matière', style: theme.textTheme.labelLarge)),
                  DataColumn(label: Text('Niveau', style: theme.textTheme.labelLarge)),
                  DataColumn(label: Text('Date', style: theme.textTheme.labelLarge)),
                  DataColumn(label: Text('Horaire', style: theme.textTheme.labelLarge)),
                  DataColumn(label: Text('Salle', style: theme.textTheme.labelLarge)),
                  DataColumn(label: Text('Enseignant', style: theme.textTheme.labelLarge)),
                  DataColumn(label: Text('Statut', style: theme.textTheme.labelLarge)),
                  if (canManage) DataColumn(label: Text('Actions', style: theme.textTheme.labelLarge)),
                ],
                rows: exams.map((exam) {
                  return DataRow(cells: [
                    DataCell(Text(exam.subject, style: theme.textTheme.bodyMedium)),
                    DataCell(_buildStatusChip(exam.level, theme.colorScheme.primary, theme)),
                    DataCell(Text(DateFormat('dd/MM/yyyy').format(exam.date), style: theme.textTheme.bodyMedium)),
                    DataCell(Text('${exam.startTime}-${exam.endTime}', style: theme.textTheme.bodyMedium)),
                    DataCell(Text(exam.classroom, style: theme.textTheme.bodyMedium)),
                    DataCell(Text(exam.teacher, style: theme.textTheme.bodyMedium)),
                    DataCell(_buildStatusChip(exam.status, statusColor(exam.status), theme)),
                    if (canManage)
                      DataCell(_buildActionMenu(exam, statusColor)),
                  ]);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardList(ThemeData theme, Color Function(String) statusColor, bool canManage) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(exam.subject, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      _buildStatusChip(exam.status, statusColor(exam.status), theme),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.school_rounded, exam.level, theme),
                      _buildInfoChip(Icons.business_rounded, exam.program, theme),
                      _buildInfoChip(Icons.meeting_room_rounded, exam.classroom, theme),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(DateFormat('dd MMM yyyy').format(exam.date), style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('${exam.startTime} - ${exam.endTime}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                    ],
                  ),
                  if (canManage) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (exam.status == 'Brouillon')
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${exam.subject} publié')),
                              );
                            },
                            icon: const Icon(Icons.publish_rounded, size: 16),
                            label: const Text('Publier'),
                          ),
                        TextButton.icon(
                          onPressed: () => context.go('/${widget.role}/exams/edit/${exam.id}'),
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: const Text('Modifier'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionMenu(ExamData exam, Color Function(String) statusColor) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      onSelected: (value) {
        if (value == 'publish' && exam.status == 'Brouillon') {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${exam.subject} publié')),
          );
        } else if (value == 'edit') {
          context.go('/${widget.role}/exams/edit/${exam.id}');
        } else if (value == 'delete') {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${exam.subject} supprimé')),
          );
        }
      },
      itemBuilder: (context) => [
        if (exam.status == 'Brouillon')
          const PopupMenuItem(
            value: 'publish',
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.publish_rounded, size: 20),
                  SizedBox(width: 16),
                  Text('Publier'),
                ],
              ),
            ),
          ),
        const PopupMenuItem(
          value: 'edit',
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(Icons.edit_rounded, size: 20),
                SizedBox(width: 16),
                Text('Modifier'),
              ],
            ),
          ),
        ),
        if (exam.status != 'Terminé')
          const PopupMenuItem(
            value: 'delete',
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.delete_rounded, size: 20, color: Color(0xFFDC2626)),
                  SizedBox(width: 16),
                  Text('Supprimer', style: TextStyle(color: Color(0xFFDC2626))),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(40), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(text, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
