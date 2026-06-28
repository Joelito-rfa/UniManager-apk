import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/classroom_provider.dart';
import '../../providers/level_provider.dart';
import '../../models/level_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/filter_bar.dart';
import '../../widgets/common/action_popup_menu.dart';
import '../../widgets/common/data_table_widget.dart';

class ClassroomListScreen extends ConsumerStatefulWidget {
  const ClassroomListScreen({super.key});

  @override
  ConsumerState<ClassroomListScreen> createState() => _ClassroomListScreenState();
}

class _ClassroomListScreenState extends ConsumerState<ClassroomListScreen> {
  int? _selectedLevelId;
  List<LevelModel> _levels = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(classroomProvider.notifier).loadClassrooms();
      _loadLevels();
    });
  }

  Future<void> _loadLevels() async {
    final levelsFuture = ref.read(allLevelsProvider.future);
    final levelsAsync = await levelsFuture;
    if (mounted) setState(() => _levels = levelsAsync);
  }

  void _onFilterChanged() {
    ref.read(classroomProvider.notifier).loadClassrooms(levelId: _selectedLevelId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(classroomProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Salles')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/classrooms/add'),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          FilterBar(
            dropdowns: [
              FilterDropdown(
                label: 'Niveau',
                value: _selectedLevelId,
                options: [
                  const FilterOption(value: null, label: 'Tous les niveaux'),
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

  Widget _buildBody(ThemeData theme, ClassroomState state) {
    if (state.isLoading && state.classrooms.isEmpty) {
      return const LoadingWidget(message: 'Chargement des salles...');
    }
    if (state.error != null && state.classrooms.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(classroomProvider.notifier).loadClassrooms(),
      );
    }
    if (state.classrooms.isEmpty) {
      return EmptyState(
        title: 'Aucune salle',
        icon: Icons.meeting_room_outlined,
        actionLabel: 'Ajouter une salle',
        onAction: () => context.push('/admin/classrooms/add'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(classroomProvider.notifier).loadClassrooms(),
      child: DataTableWidget(
        columns: const [
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Nom')),
          DataColumn(label: Text('Capacité')),
          DataColumn(label: Text('Actions')),
        ],
        rows: state.classrooms.map((room) {
          return DataRow(cells: [
            DataCell(Text(room.code ?? '')),
            DataCell(Text(room.name)),
            DataCell(Text('${room.capacity ?? 'N/A'}')),
            DataCell(Row(
              children: [
                _buildTableActionButton(Icons.edit_rounded, Theme.of(context).colorScheme.primary,
                    () => context.push('/admin/classrooms/edit/${room.id}')),
                const SizedBox(width: 8),
                _buildTableActionButton(Icons.delete_rounded, Theme.of(context).colorScheme.error,
                    () => _confirmDelete(room.id)),
              ],
            )),
          ]);
        }).toList(),
        currentPage: 1,
        lastPage: 1,
        total: state.classrooms.length,
        isLoading: state.isLoading,
        items: state.classrooms,
        cardBuilder: (item) => _buildMobileCard(Theme.of(context), item),
      ),
    );
  }

  Widget _buildMobileCard(ThemeData theme, dynamic room) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.meeting_room_rounded, color: theme.colorScheme.primary),
        ),
        title: Text(room.name, style: theme.textTheme.titleSmall),
        subtitle: Text(
          '${room.code ?? ''} - Capacité: ${room.capacity ?? 'N/A'}',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
        ),
        trailing: ActionPopupMenu(
          actions: const [
            PopupAction(value: 'edit', icon: Icons.edit_rounded, label: 'Modifier'),
            PopupAction(value: 'delete', icon: Icons.delete_rounded, label: 'Supprimer', color: Colors.red),
          ],
          onSelected: (value) async {
            if (value == 'edit') {
              context.push('/admin/classrooms/edit/${room.id}');
            } else if (value == 'delete') {
              _confirmDelete(room.id);
            }
          },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await ConfirmDialog.show(
      context, title: 'Supprimer', message: 'Supprimer cette salle?',
      isDestructive: true, confirmLabel: 'Supprimer',
    );
    if (confirmed == true) ref.read(classroomProvider.notifier).deleteClassroom(id);
  }
}
