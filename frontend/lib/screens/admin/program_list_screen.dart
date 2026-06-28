import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/program_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/action_popup_menu.dart';
import '../../widgets/common/data_table_widget.dart';

class ProgramListScreen extends ConsumerStatefulWidget {
  const ProgramListScreen({super.key});

  @override
  ConsumerState<ProgramListScreen> createState() => _ProgramListScreenState();
}

class _ProgramListScreenState extends ConsumerState<ProgramListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(programProvider.notifier).loadPrograms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(programProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Filières')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/programs/add'),
        child: const Icon(Icons.add_rounded),
      ),
      body: _buildBody(theme, state),
    );
  }

  Widget _buildBody(ThemeData theme, ProgramState state) {
    if (state.isLoading && state.programs.isEmpty) {
      return const LoadingWidget(message: 'Chargement des filières...');
    }
    if (state.error != null && state.programs.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(programProvider.notifier).loadPrograms(),
      );
    }
    if (state.programs.isEmpty) {
      return EmptyState(
        title: 'Aucune filière',
        icon: Icons.school_outlined,
        actionLabel: 'Ajouter une filière',
        onAction: () => context.push('/admin/programs/add'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(programProvider.notifier).loadPrograms(),
      child: DataTableWidget(
        columns: const [
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Nom')),
          DataColumn(label: Text('Département')),
          DataColumn(label: Text('Actions')),
        ],
        rows: state.programs.map((program) {
          return DataRow(cells: [
            DataCell(Text(program.code ?? '')),
            DataCell(Text(program.name)),
            DataCell(_buildStatusChip(program.departmentName ?? '', Theme.of(context).colorScheme.secondary)),
            DataCell(Row(
              children: [
                _buildTableActionButton(Icons.edit_rounded, Theme.of(context).colorScheme.primary,
                    () => context.push('/admin/programs/edit/${program.id}')),
                const SizedBox(width: 8),
                _buildTableActionButton(Icons.delete_rounded, Theme.of(context).colorScheme.error,
                    () => _confirmDelete(program.id)),
              ],
            )),
          ]);
        }).toList(),
        currentPage: 1,
        lastPage: 1,
        total: state.programs.length,
        isLoading: state.isLoading,
        items: state.programs,
        cardBuilder: (item) => _buildMobileCard(Theme.of(context), item),
      ),
    );
  }

  Widget _buildMobileCard(ThemeData theme, dynamic program) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(Icons.school_rounded, color: theme.colorScheme.secondary),
        ),
        title: Text(program.name, style: theme.textTheme.titleSmall),
        subtitle: Text(
          '${program.code ?? ''} - ${program.departmentName ?? ''}',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
        ),
        trailing: ActionPopupMenu(
          actions: const [
            PopupAction(value: 'edit', icon: Icons.edit_rounded, label: 'Modifier'),
            PopupAction(value: 'delete', icon: Icons.delete_rounded, label: 'Supprimer', color: Colors.red),
          ],
          onSelected: (value) async {
            if (value == 'edit') {
              context.push('/admin/programs/edit/${program.id}');
            } else if (value == 'delete') {
              _confirmDelete(program.id);
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
      context, title: 'Supprimer', message: 'Supprimer cette filière?',
      isDestructive: true, confirmLabel: 'Supprimer',
    );
    if (confirmed == true) ref.read(programProvider.notifier).deleteProgram(id);
  }
}
