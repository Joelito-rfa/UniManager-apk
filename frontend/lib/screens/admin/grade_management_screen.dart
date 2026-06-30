import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/grade_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/level_provider.dart';
import '../../models/level_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/action_popup_menu.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/filter_bar.dart';

class GradeManagementScreen extends ConsumerStatefulWidget {
  const GradeManagementScreen({super.key});

  @override
  ConsumerState<GradeManagementScreen> createState() => _GradeManagementScreenState();
}

class _GradeManagementScreenState extends ConsumerState<GradeManagementScreen> {
  int? _selectedCourseId;
  int? _selectedLevelId;
  List<LevelModel> _levels = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(courseProvider.notifier).loadCourses();
      _loadFilters();
    });
  }

  Future<void> _loadFilters() async {
    final levels = await ref.read(allLevelsProvider.future);
    if (mounted) setState(() => _levels = levels);
  }

  void _onFilterChanged() {
    final filters = <String, dynamic>{
      if (_selectedCourseId != null) 'course_id': _selectedCourseId,
      if (_selectedLevelId != null) 'level_id': _selectedLevelId,
    };
    if (filters.isNotEmpty) {
      ref.read(gradeProvider.notifier).loadGrades(filters: filters);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradeState = ref.watch(gradeProvider);
    final courseState = ref.watch(courseProvider);
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des notes')),
      body: Column(
        children: [
          FilterBar(
            dropdowns: [
              FilterDropdown(
                label: 'Niveau',
                value: _selectedLevelId,
                options: [
                  const FilterOption(value: null, label: 'Tous'),
                  ..._levels.map((l) =>
                    FilterOption(value: l.id, label: '${l.code} - ${l.name}')),
                ],
                onChanged: (v) {
                  setState(() => _selectedLevelId = v as int?);
                  _onFilterChanged();
                },
              ),
            ],
          ),
          _buildFilter(courseState, theme),
          Expanded(child: _buildBody(gradeState, theme, isWide)),
        ],
      ),
    );
  }

  Widget _buildFilter(CourseState courseState, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonFormField<int>(
                initialValue: _selectedCourseId,
                decoration: InputDecoration(
                  labelText: 'Filtrer par cours',
                  prefixIcon: Icon(Icons.menu_book_rounded, size: 20, color: theme.colorScheme.primary),
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
                items: courseState.courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.subjectName ?? ''))).toList(),
                onChanged: (v) {
                  setState(() => _selectedCourseId = v);
                  if (v != null) {
                    ref.read(gradeProvider.notifier).loadGrades(filters: {'course_id': v});
                  }
                },
              ),
            ),
          ),
          if (_selectedCourseId != null) ...[
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => context.push('/admin/grades/input/$_selectedCourseId'),
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text('Saisir'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(GradeState state, ThemeData theme, bool isWide) {
    if (state.isLoading && state.grades.isEmpty) {
      return const LoadingWidget(message: 'Chargement des notes...');
    }
    if (state.error != null && state.grades.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(gradeProvider.notifier).loadGrades(),
      );
    }
    if (_selectedCourseId == null) {
      return EmptyState(
        title: 'Sélectionnez un cours',
        icon: Icons.touch_app_rounded,
        subtitle: 'Choisissez un cours pour voir les notes',
      );
    }
    if (state.grades.isEmpty) {
      return EmptyState(
        title: 'Aucune note',
        icon: Icons.grade_outlined,
        subtitle: 'Aucune note trouvée pour ce cours',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(gradeProvider.notifier).loadGrades(filters: {'course_id': _selectedCourseId}),
      child: isWide ? _buildDataTable(state, theme) : _buildCardList(state, theme),
    );
  }

  Widget _buildDataTable(GradeState state, ThemeData theme) {
    final passedGrades = state.grades.where((g) => g.grade >= 10).length;
    final avg = state.grades.isEmpty
        ? 0.0
        : state.grades.map((g) => g.grade).reduce((a, b) => a + b) / state.grades.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                    child: Icon(Icons.grade_rounded, size: 16, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notes', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                      Text('${state.grades.length} notes · $passedGrades validées · Moy. ${avg.toStringAsFixed(1)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DataTable(
                headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withAlpha(80)),
                columns: const [DataColumn(label: Text('Matière')), DataColumn(label: Text('Type')), DataColumn(label: Text('Note')), DataColumn(label: Text('Coef.')), DataColumn(label: Text('Appréciation')), DataColumn(label: Text('')), DataColumn(label: Text('Actions'))],
                rows: state.grades.map((g) {
                  final pass = g.grade >= 10;
                  return DataRow(cells: [
                    DataCell(Text(g.subjectName ?? '?', style: theme.textTheme.bodyMedium)),
                    DataCell(_buildTypeChip(g.gradeType, theme)),
                    DataCell(_buildGradeValue(g.grade, pass, theme)),
                    DataCell(Text(g.coefficient?.toStringAsFixed(1) ?? '1.0', style: theme.textTheme.bodyMedium)),
                    DataCell(Text(g.comment ?? '—', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                    DataCell(_buildStatusChip(pass ? 'Validée' : 'Échouée', pass ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                    DataCell(
                      ActionPopupMenu(
                        actions: const [
                          PopupAction(value: 'edit', icon: Icons.edit_rounded, label: 'Modifier'),
                          PopupAction(value: 'delete', icon: Icons.delete_rounded, label: 'Supprimer', color: Colors.red),
                        ],
                        onSelected: (value) async {
                          if (value == 'edit') {
                            context.push('/admin/grades/edit/${g.id}', extra: g);
                          } else if (value == 'delete') {
                            final confirmed = await ConfirmDialog.show(context, title: 'Supprimer', message: 'Supprimer cette note?', isDestructive: true, confirmLabel: 'Supprimer');
                            if (confirmed == true) {
                              ref.read(gradeProvider.notifier).deleteGrade(g.id);
                            }
                          }
                        },
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardList(GradeState state, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.grades.length,
      itemBuilder: (context, index) {
        final g = state.grades[index];
        final pass = g.grade >= 10;
        final gradeColor = pass ? const Color(0xFF10B981) : const Color(0xFFEF4444);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradeColor.withAlpha(25), gradeColor.withAlpha(10)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        g.grade.toStringAsFixed(1),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: gradeColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.subjectName ?? '?', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildTypeChip(g.gradeType, theme),
                            const SizedBox(width: 8),
                            Text('Coef. ${g.coefficient?.toStringAsFixed(1) ?? '1.0'}',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            const SizedBox(width: 8),
                            _buildStatusChip(pass ? 'Validée' : 'Échouée', gradeColor),
                          ],
                        ),
                        if (g.comment != null && g.comment!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('"${g.comment}"',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            )),
                        ],
                        if (g.gradedByName != null) ...[
                          const SizedBox(height: 2),
                          Text('Noté par ${g.gradedByName}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                        ],
                      ],
                    ),
                  ),
                  ActionPopupMenu(
                    actions: const [
                      PopupAction(value: 'edit', icon: Icons.edit_rounded, label: 'Modifier'),
                      PopupAction(value: 'delete', icon: Icons.delete_rounded, label: 'Supprimer', color: Colors.red),
                    ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        context.push('/admin/grades/edit/${g.id}', extra: g);
                      } else if (value == 'delete') {
                        final confirmed = await ConfirmDialog.show(context, title: 'Supprimer', message: 'Supprimer cette note?', isDestructive: true, confirmLabel: 'Supprimer');
                        if (confirmed == true) {
                          ref.read(gradeProvider.notifier).deleteGrade(g.id);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradeValue(double grade, bool pass, ThemeData theme) {
    final color = pass ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(grade.toStringAsFixed(1),
        style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
    );
  }

  Widget _buildTypeChip(String? type, ThemeData theme) {
    if (type == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withAlpha(100),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: theme.colorScheme.onTertiaryContainer)),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(40), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
