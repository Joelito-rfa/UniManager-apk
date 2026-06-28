import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _AdmissionStudent {
  final int id;
  final String name;
  final String program;
  final String currentLevel;
  final double average;
  final String decision;
  bool promoted = false;

  _AdmissionStudent({
    required this.id,
    required this.name,
    required this.program,
    required this.currentLevel,
    required this.average,
    required this.decision,
  });

  bool get isPassed => decision == 'Admis';

  String get nextLevel {
    const map = {'L1': 'L2', 'L2': 'L3', 'L3': 'M1', 'M1': 'M2', 'M2': 'Diplômé'};
    return map[currentLevel] ?? currentLevel;
  }
}

final _mockStudents = <_AdmissionStudent>[
  _AdmissionStudent(id: 1, name: 'Jean Dupont', program: 'Informatique', currentLevel: 'L1', average: 14.5, decision: 'Admis'),
  _AdmissionStudent(id: 2, name: 'Marie Koné', program: 'Informatique', currentLevel: 'L1', average: 11.2, decision: 'Admis'),
  _AdmissionStudent(id: 3, name: 'Paul Diallo', program: 'Informatique', currentLevel: 'L1', average: 8.0, decision: 'Échoué'),
  _AdmissionStudent(id: 4, name: 'Sophie Traoré', program: 'Réseaux & Télécoms', currentLevel: 'L2', average: 13.8, decision: 'Admis'),
  _AdmissionStudent(id: 5, name: 'Amadou Coulibaly', program: 'Informatique', currentLevel: 'L2', average: 10.5, decision: 'Admis'),
  _AdmissionStudent(id: 6, name: 'Fatoumata Diarra', program: 'Génie Logiciel', currentLevel: 'L2', average: 7.5, decision: 'Échoué'),
  _AdmissionStudent(id: 7, name: 'Ousmane Sylla', program: 'Informatique', currentLevel: 'L3', average: 15.2, decision: 'Admis'),
  _AdmissionStudent(id: 8, name: 'Aminata Bamba', program: 'Cybersécurité', currentLevel: 'L3', average: 12.0, decision: 'Admis'),
  _AdmissionStudent(id: 9, name: 'Drissa Kone', program: 'Réseaux & Télécoms', currentLevel: 'L3', average: 9.8, decision: 'Échoué'),
  _AdmissionStudent(id: 10, name: 'Kadiatou Touré', program: 'Informatique', currentLevel: 'M1', average: 14.0, decision: 'Admis'),
  _AdmissionStudent(id: 11, name: 'Mamadou Camara', program: 'Génie Logiciel', currentLevel: 'M1', average: 11.5, decision: 'Admis'),
  _AdmissionStudent(id: 12, name: 'Aïssatou Fofana', program: 'Cybersécurité', currentLevel: 'M2', average: 16.0, decision: 'Admis'),
  _AdmissionStudent(id: 13, name: 'Ibrahim Sangaré', program: 'Informatique', currentLevel: 'M2', average: 13.2, decision: 'Admis'),
];

const _levelColors = {
  'L1': Color(0xFF4F46E5),
  'L2': Color(0xFF0D9488),
  'L3': Color(0xFFE11D48),
  'M1': Color(0xFF7C3AED),
  'M2': Color(0xFFD97706),
};

class AdmissionScreen extends ConsumerStatefulWidget {
  const AdmissionScreen({super.key});

  @override
  ConsumerState<AdmissionScreen> createState() => _AdmissionScreenState();
}

class _AdmissionScreenState extends ConsumerState<AdmissionScreen> {
  final _students = _mockStudents.map((s) => _AdmissionStudent(
    id: s.id, name: s.name, program: s.program,
    currentLevel: s.currentLevel, average: s.average,
    decision: s.decision,
  )).toList();

  String _selectedLevel = 'Tous';
  final _levels = ['Tous', 'L1', 'L2', 'L3', 'M1', 'M2'];

  List<_AdmissionStudent> get _filteredStudents {
    if (_selectedLevel == 'Tous') return _students;
    return _students.where((s) => s.currentLevel == _selectedLevel).toList();
  }

  int _countByLevel(String level) => _students.where((s) => s.currentLevel == level).length;
  int _passedByLevel(String level) => _students.where((s) => s.currentLevel == level && s.isPassed).length;
  int get _totalPromoted => _students.where((s) => s.promoted).length;
  int get _totalPassed => _students.where((s) => s.isPassed).length;
  int get _totalNotPromoted => _students.where((s) => s.isPassed && !s.promoted && s.currentLevel != 'M2').length;

  void _promoteStudent(_AdmissionStudent student) {
    setState(() => student.promoted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${student.name} promu(e) en ${student.nextLevel}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF059669),
      ),
    );
  }

  Future<void> _promoteAllByLevel(String level) async {
    final toPromote = _students.where((s) => s.currentLevel == level && s.isPassed && !s.promoted).toList();
    if (toPromote.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun étudiant à promouvoir'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmer la promotion'),
        content: Text('${toPromote.length} étudiant(s) $level → ${_getNextLevel(level)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmer')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() { for (final s in toPromote) { s.promoted = true; } });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${toPromote.length} étudiant(s) promu(s) en ${_getNextLevel(level)}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF059669),
      ),
    );
  }

  String _getNextLevel(String level) {
    const map = {'L1': 'L2', 'L2': 'L3', 'L3': 'M1', 'M1': 'M2', 'M2': 'Diplômé'};
    return map[level] ?? level;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Admissions')),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 20),
              _buildLevelSummaryBar(theme),
              const SizedBox(height: 24),
              _buildStatsRow(theme),
              const SizedBox(height: 24),
              _buildFilterRow(theme),
              const SizedBox(height: 20),
              ..._filteredStudents.map((s) => _buildStudentCard(theme, s)),
              if (_filteredStudents.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(Icons.search_off_rounded, size: 48, color: theme.colorScheme.outlineVariant),
                        ),
                        const SizedBox(height: 16),
                        Text('Aucun étudiant dans ce niveau', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.primary.withAlpha(180)],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(50),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gestion des admissions', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Promouvez les étudiants au niveau supérieur', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelSummaryBar(ThemeData theme) {
    final total = _students.length;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Répartition par niveau', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('$total étudiants', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 36,
                child: Row(
                  children: _levels.where((l) => l != 'Tous').map((level) {
                    final count = _countByLevel(level);
                    final fraction = total > 0 ? count / total : 0.0;
                    return Expanded(
                      flex: (fraction * 100).round().clamp(1, 100),
                      child: Container(
                        decoration: BoxDecoration(color: _levelColors[level]!.withAlpha(200)),
                        alignment: Alignment.center,
                        child: Text(
                          count > 0 ? '$level $count' : '',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: _levels.where((l) => l != 'Tous').map((level) {
                final color = _levelColors[level]!;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 6),
                    Text('$level: ${_countByLevel(level)} (${_passedByLevel(level)} admis)',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(
          theme, icon: Icons.check_circle_rounded, label: 'Admis',
          value: '$_totalPassed', sub: '${_totalPassed * 100 ~/ _students.length}%',
          color: const Color(0xFF059669),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          theme, icon: Icons.pending_rounded, label: 'En attente',
          value: '$_totalNotPromoted', sub: 'à promouvoir',
          color: const Color(0xFFD97706),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(
          theme, icon: Icons.celebration_rounded, label: 'Promus',
          value: '$_totalPromoted', sub: 'niveau supérieur',
          color: const Color(0xFF4F46E5),
        )),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, {required IconData icon, required String label, required String value, required String sub, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withAlpha(8),
        border: Border.all(color: color.withAlpha(20), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: color, height: 1)),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
          Text(sub, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, color: color.withAlpha(180))),
        ],
      ),
    );
  }

  Widget _buildFilterRow(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ..._levels.map((level) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(level == 'Tous' ? 'Tous' : level),
                selected: _selectedLevel == level,
                onSelected: (v) => setState(() => _selectedLevel = level),
                selectedColor: theme.colorScheme.primaryContainer,
              ),
            );
          }),
          const SizedBox(width: 16),
          if (_selectedLevel != 'Tous')
            FilledButton.tonalIcon(
              onPressed: () => _promoteAllByLevel(_selectedLevel),
              icon: const Icon(Icons.arrow_upward_rounded, size: 18),
              label: const Text('Tout promouvoir'),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(ThemeData theme, _AdmissionStudent student) {
    final levelColor = _levelColors[student.currentLevel]!;
    final passColor = student.isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: student.promoted
              ? Border.all(color: const Color(0xFF4F46E5).withAlpha(50), width: 1)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: student.isPassed
                            ? [const Color(0xFF059669), const Color(0xFF34D399)]
                            : [const Color(0xFFE11D48), const Color(0xFFFB7185)],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.colorScheme.surface,
                      child: Text(
                        student.name.split(' ').map((e) => e[0]).take(2).join(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: passColor,
                        ),
                      ),
                    ),
                  ),
                  if (student.promoted)
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4F46E5),
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                        ),
                        child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(student.name,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: levelColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(student.currentLevel,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: levelColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.school_rounded, size: 13, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(student.program,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: passColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: passColor.withAlpha(40), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(student.average.toStringAsFixed(1),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: passColor)),
                    const SizedBox(width: 4),
                    Text('/20',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w400, color: passColor.withAlpha(120))),
                  ],
                ),
              ),
              if (student.currentLevel != 'M2') ...[
                const SizedBox(width: 12),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: student.promoted
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withAlpha(15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF4F46E5).withAlpha(40), width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_upward_rounded, size: 13, color: Color(0xFF4F46E5)),
                              const SizedBox(width: 4),
                              Text(student.nextLevel,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5))),
                            ],
                          ),
                        )
                      : FilledButton.tonal(
                          onPressed: student.isPassed ? () => _promoteStudent(student) : null,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_upward_rounded, size: 14,
                                color: student.isPassed ? null : theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(student.nextLevel,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                  color: student.isPassed ? null : theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
