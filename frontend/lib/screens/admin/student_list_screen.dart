import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/student_provider.dart';
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

class StudentListScreen extends ConsumerStatefulWidget {
  const StudentListScreen({super.key});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen> {
  int? _selectedProgramId;
  int? _selectedLevelId;
  List<ProgramModel> _programs = [];
  List<LevelModel> _levels = [];
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studentProvider.notifier).loadStudents();
      _loadFilters();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
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
    ref.read(studentProvider.notifier).loadStudents(
      programId: _selectedProgramId,
      levelId: _selectedLevelId,
      search: _codeController.text.isNotEmpty ? _codeController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(studentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Étudiants')),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/students/add'),
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
                  ..._programs.map((p) =>
                    FilterOption(value: p.id, label: p.name)),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Code',
                prefixIcon: Icon(Icons.qr_code_rounded, size: 18),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _onFilterChanged(),
            ),
          ),
          Expanded(child: _buildBody(theme, state)),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, StudentState state) {
    if (state.isLoading && state.students.isEmpty) {
      return const LoadingWidget(message: 'Chargement des étudiants...');
    }

    if (state.error != null && state.students.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(studentProvider.notifier).loadStudents(),
      );
    }

    if (state.students.isEmpty) {
      return EmptyState(
        title: 'Aucun étudiant',
        subtitle: 'Commencez par ajouter un étudiant.',
        icon: Icons.people_outlined,
        actionLabel: 'Ajouter un étudiant',
        onAction: () => context.push('/admin/students/add'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(studentProvider.notifier).loadStudents(),
      child: DataTableWidget(
        columns: const [
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Nom')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Niveau')),
          DataColumn(label: Text('Filière')),
          DataColumn(label: Text('Actions')),
        ],
        rows: state.students.map((student) {
          return DataRow(cells: [
            DataCell(Text(student.code ?? student.studentNumber)),
            DataCell(Text(student.fullName)),
            DataCell(Text(student.email ?? '')),
            DataCell(_buildStatusChip(student.levelName ?? '', Theme.of(context).colorScheme.primary)),
            DataCell(Text(student.programName ?? '')),
            DataCell(Row(
              children: [
                _buildTableActionButton(Icons.edit_rounded, Theme.of(context).colorScheme.primary,
                    () => context.push('/admin/students/edit/${student.id}')),
                const SizedBox(width: 8),
                _buildTableActionButton(Icons.delete_rounded, Theme.of(context).colorScheme.error,
                    () => _confirmDelete(student.id)),
              ],
            )),
          ]);
        }).toList(),
        currentPage: state.currentPage,
        lastPage: state.lastPage,
        total: state.total,
        isLoading: state.isLoading,
        items: state.students,
        cardBuilder: (item) => _buildMobileCard(Theme.of(context), item),
        onPageChanged: (page) {
          ref.read(studentProvider.notifier).loadStudents(page: page);
        },
      ),
    );
  }

  Widget _buildMobileCard(ThemeData theme, dynamic student) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            (student.firstName ?? '?')[0].toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(student.fullName, style: theme.textTheme.titleSmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student.code ?? student.studentNumber,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
            ),
            if (student.programName != null || student.levelName != null)
              Text(
                '${student.levelName ?? ''} ${student.programName ?? ''}'.trim(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withAlpha(180),
                ),
              ),
          ],
        ),
        trailing: ActionPopupMenu(
          actions: [
            PopupAction(
              value: 'edit',
              icon: Icons.edit_rounded,
              label: 'Modifier',
            ),
            const PopupAction(
              value: 'delete',
              icon: Icons.delete_rounded,
              label: 'Supprimer',
              color: Colors.red,
            ),
          ],
          onSelected: (value) async {
            if (value == 'edit') {
              context.push('/admin/students/edit/${student.id}');
            } else if (value == 'delete') {
              _confirmDelete(student.id);
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
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTableActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: color.withAlpha(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Supprimer',
      message: 'Supprimer cet étudiant?',
      isDestructive: true,
      confirmLabel: 'Supprimer',
    );
    if (confirmed == true) {
      ref.read(studentProvider.notifier).deleteStudent(id);
    }
  }
}
