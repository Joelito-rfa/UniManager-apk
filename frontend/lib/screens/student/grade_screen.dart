import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/grade_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';

class GradeScreen extends ConsumerStatefulWidget {
  const GradeScreen({super.key});

  @override
  ConsumerState<GradeScreen> createState() => _GradeScreenState();
}

class _GradeScreenState extends ConsumerState<GradeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gradeProvider.notifier).loadGrades(role: 'student');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gradeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes notes')),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(GradeState state, ThemeData theme) {
    if (state.isLoading) return const LoadingWidget(message: 'Chargement de vos notes...');
    if (state.error != null) return AppErrorWidget(message: state.error!, onRetry: () => ref.read(gradeProvider.notifier).loadGrades(role: 'student'));
    if (state.grades.isEmpty) return const EmptyState(title: 'Aucune note', subtitle: "Vous n'avez pas encore de notes.", icon: Icons.grade_outlined);

    final groupedBySubject = <String, List>{};
    for (final grade in state.grades) {
      final subject = grade.subjectName ?? 'Général';
      groupedBySubject.putIfAbsent(subject, () => []);
      groupedBySubject[subject]!.add(grade);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(gradeProvider.notifier).loadGrades(role: 'student'),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryHeader(theme, state.grades),
          const SizedBox(height: 16),
          ...groupedBySubject.entries.map((entry) {
            final subject = entry.key;
            final grades = entry.value;
            final avg = grades.fold<double>(0, (sum, g) => sum + (g as dynamic).grade) / grades.length;
            final pass = avg >= 10;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (pass ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withAlpha(25),
                        (pass ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withAlpha(10),
                      ],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      avg.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13,
                        color: pass ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ),
                title: Text(subject, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('${grades.length} évaluation(s) - Moy. ${avg.toStringAsFixed(1)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                children: grades.map((g) {
                  final grade = g as dynamic;
                  final gradePass = grade.grade >= 10;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(grade.gradeType ?? 'Évaluation', style: theme.textTheme.bodyMedium),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (gradePass ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withAlpha(15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (gradePass ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withAlpha(40),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            grade.grade.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13,
                              color: gradePass ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(ThemeData theme, List grades) {
    final totalAvg = grades.fold<double>(0, (sum, g) => sum + (g as dynamic).grade) / grades.length;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${grades.length} note(s)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Moyenne générale ${totalAvg.toStringAsFixed(1)}/20',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const Spacer(),
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (totalAvg >= 10 ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withAlpha(25),
                    (totalAvg >= 10 ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withAlpha(10),
                  ],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  totalAvg.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: totalAvg >= 10 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
