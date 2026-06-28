import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/department_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/action_popup_menu.dart';
import '../../widgets/common/data_table_widget.dart';

class DepartmentListScreen extends ConsumerStatefulWidget {
  const DepartmentListScreen({super.key});

  @override
  ConsumerState<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends ConsumerState<DepartmentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(departmentProvider.notifier).loadDepartments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(departmentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Départements')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/departments/add'),
        child: const Icon(Icons.add_rounded),
      ),
      body: _buildBody(theme, state),
    );
  }

  Widget _buildBody(ThemeData theme, DepartmentState state) {
    if (state.isLoading && state.departments.isEmpty) {
      return const LoadingWidget(message: 'Chargement des départements...');
    }
    if (state.error != null && state.departments.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(departmentProvider.notifier).loadDepartments(),
      );
    }
    if (state.departments.isEmpty) {
      return EmptyState(
        title: 'Aucun département',
        icon: Icons.business_outlined,
        actionLabel: 'Ajouter un département',
        onAction: () => context.push('/admin/departments/add'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(departmentProvider.notifier).loadDepartments(),
      child: DataTableWidget(
        columns: const [
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Nom')),
          DataColumn(label: Text('Actions')),
        ],
        rows: state.departments.map((dept) {
          return DataRow(cells: [
            DataCell(Text(dept.code ?? '')),
            DataCell(Text(dept.name)),
            DataCell(Row(
              children: [
                _buildTableActionButton(Icons.edit_rounded, Theme.of(context).colorScheme.primary,
                    () => context.push('/admin/departments/edit/${dept.id}')),
                const SizedBox(width: 8),
                _buildTableActionButton(Icons.delete_rounded, Theme.of(context).colorScheme.error,
                    () => _confirmDelete(dept.id)),
              ],
            )),
          ]);
        }).toList(),
        currentPage: 1,
        lastPage: 1,
        total: state.departments.length,
        isLoading: state.isLoading,
        items: state.departments,
        cardBuilder: (item) => _buildMobileCard(Theme.of(context), item),
      ),
    );
  }

  Widget _buildMobileCard(ThemeData theme, dynamic dept) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.business_rounded, color: theme.colorScheme.primary),
        ),
        title: Text(dept.name, style: theme.textTheme.titleSmall),
        subtitle: Text(dept.code ?? '', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
        trailing: ActionPopupMenu(
          actions: const [
            PopupAction(value: 'edit', icon: Icons.edit_rounded, label: 'Modifier'),
            PopupAction(value: 'delete', icon: Icons.delete_rounded, label: 'Supprimer', color: Colors.red),
          ],
          onSelected: (value) async {
            if (value == 'edit') {
              context.push('/admin/departments/edit/${dept.id}');
            } else if (value == 'delete') {
              _confirmDelete(dept.id);
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
      context, title: 'Supprimer', message: 'Supprimer ce département?',
      isDestructive: true, confirmLabel: 'Supprimer',
    );
    if (confirmed == true) ref.read(departmentProvider.notifier).deleteDepartment(id);
  }
}
