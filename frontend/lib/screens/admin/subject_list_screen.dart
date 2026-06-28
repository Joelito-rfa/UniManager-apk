import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/subject_provider.dart';
import '../../providers/program_provider.dart';
import '../../providers/level_provider.dart';
import '../../models/program_model.dart';
import '../../models/level_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/filter_bar.dart';
import '../../widgets/common/action_popup_menu.dart';
import '../../widgets/common/data_table_widget.dart';

class SubjectListScreen extends ConsumerStatefulWidget {
  const SubjectListScreen({super.key});

  @override
  ConsumerState<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends ConsumerState<SubjectListScreen> {
  int? _selectedProgramId;
  int? _selectedLevelId;
  List<ProgramModel> _programs = [];
  List<LevelModel> _levels = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subjectProvider.notifier).loadSubjects();
      _loadFilters();
    });
  }

  Future<void> _loadFilters() async {
    final programNotifier = ref.read(programProvider.notifier);
    final levelsFuture = ref.read(allLevelsProvider.future);
    final programs = await programNotifier.getAllPrograms();
    if (!mounted) return;
    final levelsAsync = await levelsFuture;
    if (mounted) {
      setState(() {
        _programs = programs;
        _levels = levelsAsync;
      });
    }
  }

  void _onFilterChanged() {
    ref.read(subjectProvider.notifier).loadSubjects(
      programId: _selectedProgramId,
      levelId: _selectedLevelId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(subjectProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Matières')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/subjects/add'),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          FilterBar(
            dropdowns: [
              FilterDropdown(
                label: 'Filière',
                value: _selectedProgramId,
                options: [
                  const FilterOption(value: null, label: 'Toutes'),
                  ..._programs.map((p) => FilterOption(value: p.id, label: p.name)),
                ],
                onChanged: (v) {
                  setState(() => _selectedProgramId = v as int?);
                  _onFilterChanged();
                },
              ),
              FilterDropdown(
                label: 'Niveau',
                value: _selectedLevelId,
                options: [
                  const FilterOption(value: null, label: 'Tous'),
                  ..._levels.map((l) => FilterOption(value: l.id, label: '${l.code} - ${l.name}')),
                ],
                onChanged: (v) {
                  setState(() => _selectedLevelId = v as int?);
                  _onFilterChanged();
                },
              ),
            ],
          ),
          Expanded(child: _buildBody(theme, state)),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, SubjectState state) {
    if (state.isLoading && state.subjects.isEmpty) {
      return const LoadingWidget(message: 'Chargement des matières...');
    }
    if (state.error != null && state.subjects.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(subjectProvider.notifier).loadSubjects(),
      );
    }
    if (state.subjects.isEmpty) {
      return EmptyState(
        title: 'Aucune matière',
        icon: Icons.book_outlined,
        actionLabel: 'Ajouter une matière',
        onAction: () => context.push('/admin/subjects/add'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(subjectProvider.notifier).loadSubjects(),
      child: DataTableWidget(
        columns: const [
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Intitulé')),
          DataColumn(label: Text('Crédits')),
          DataColumn(label: Text('Niveau')),
          DataColumn(label: Text('Actions')),
        ],
        rows: state.subjects.map((subject) {
          return DataRow(cells: [
            DataCell(Text(subject.code ?? '')),
            DataCell(Text(subject.name)),
            DataCell(Text('${subject.credits ?? 0}')),
            DataCell(_buildStatusChip(subject.levelName ?? '', Theme.of(context).colorScheme.tertiary)),
            DataCell(Row(
              children: [
                _buildTableActionButton(Icons.edit_rounded, Theme.of(context).colorScheme.primary,
                    () => context.push('/admin/subjects/edit/${subject.id}')),
                const SizedBox(width: 8),
                _buildTableActionButton(Icons.delete_rounded, Theme.of(context).colorScheme.error,
                    () => _confirmDelete(subject.id)),
              ],
            )),
          ]);
        }).toList(),
        currentPage: state.currentPage,
        lastPage: state.lastPage,
        total: state.total,
        isLoading: state.isLoading,
        items: state.subjects,
        cardBuilder: (item) => _buildMobileCard(Theme.of(context), item),
        onPageChanged: (page) {
          ref.read(subjectProvider.notifier).loadSubjects(page: page);
        },
      ),
    );
  }

  Widget _buildMobileCard(ThemeData theme, dynamic subject) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.tertiaryContainer,
          child: Icon(Icons.book_rounded, color: theme.colorScheme.tertiary),
        ),
        title: Text(subject.name, style: theme.textTheme.titleSmall),
        subtitle: Text(
          '${subject.code ?? ''} - ${subject.credits ?? 0} crédits${subject.levelName != null ? ' - ${subject.levelName}' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
        ),
        trailing: ActionPopupMenu(
          actions: const [
            PopupAction(value: 'edit', icon: Icons.edit_rounded, label: 'Modifier'),
            PopupAction(value: 'delete', icon: Icons.delete_rounded, label: 'Supprimer', color: Colors.red),
          ],
          onSelected: (value) async {
            if (value == 'edit') {
              context.push('/admin/subjects/edit/${subject.id}');
            } else if (value == 'delete') {
              _confirmDelete(subject.id);
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(40), width: 0.5),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTableActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: color.withAlpha(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await ConfirmDialog.show(
      context, title: 'Supprimer', message: 'Supprimer cette matière?',
      isDestructive: true, confirmLabel: 'Supprimer',
    );
    if (confirmed == true) ref.read(subjectProvider.notifier).deleteSubject(id);
  }
}
