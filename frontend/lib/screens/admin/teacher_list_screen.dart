import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/teacher_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/action_popup_menu.dart';
import '../../widgets/common/data_table_widget.dart';

class TeacherListScreen extends ConsumerStatefulWidget {
  const TeacherListScreen({super.key});

  @override
  ConsumerState<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends ConsumerState<TeacherListScreen> {
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teacherProvider.notifier).loadTeachers();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    ref.read(teacherProvider.notifier).loadTeachers(
      search: _codeController.text.isNotEmpty ? _codeController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(teacherProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Enseignants')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/teachers/add'),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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

  Widget _buildBody(ThemeData theme, TeacherState state) {
    if (state.isLoading && state.teachers.isEmpty) {
      return const LoadingWidget(message: 'Chargement des enseignants...');
    }
    if (state.error != null && state.teachers.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(teacherProvider.notifier).loadTeachers(),
      );
    }
    if (state.teachers.isEmpty) {
      return EmptyState(
        title: 'Aucun enseignant',
        subtitle: 'Commencez par ajouter un enseignant.',
        icon: Icons.person_outlined,
        actionLabel: 'Ajouter un enseignant',
        onAction: () => context.push('/admin/teachers/add'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(teacherProvider.notifier).loadTeachers(),
      child: DataTableWidget(
        columns: const [
          DataColumn(label: Text('Code')),
          DataColumn(label: Text('Nom')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Département')),
          DataColumn(label: Text('Actions')),
        ],
        rows: state.teachers.map((teacher) {
          return DataRow(cells: [
            DataCell(Text(teacher.code ?? teacher.teacherNumber)),
            DataCell(Text(teacher.fullName)),
            DataCell(Text(teacher.email ?? '')),
            DataCell(_buildStatusChip(teacher.departmentName ?? '', Theme.of(context).colorScheme.secondary)),
            DataCell(Row(
              children: [
                _buildTableActionButton(Icons.edit_rounded, Theme.of(context).colorScheme.primary,
                    () => context.push('/admin/teachers/edit/${teacher.id}')),
                const SizedBox(width: 8),
                _buildTableActionButton(Icons.delete_rounded, Theme.of(context).colorScheme.error,
                    () => _confirmDelete(teacher.id)),
              ],
            )),
          ]);
        }).toList(),
        currentPage: 1,
        lastPage: 1,
        total: state.teachers.length,
        isLoading: state.isLoading,
        items: state.teachers,
        cardBuilder: (item) => _buildMobileCard(Theme.of(context), item),
      ),
    );
  }

  Widget _buildMobileCard(ThemeData theme, dynamic teacher) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Text(
            (teacher.firstName ?? '?')[0].toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(teacher.fullName, style: theme.textTheme.titleSmall),
        subtitle: Text(
          '${teacher.code ?? teacher.teacherNumber} - ${teacher.departmentName ?? ''}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white,
          ),
        ),
        trailing: ActionPopupMenu(
          actions: const [
            PopupAction(value: 'edit', icon: Icons.edit_rounded, label: 'Modifier'),
            PopupAction(value: 'delete', icon: Icons.delete_rounded, label: 'Supprimer', color: Colors.red),
          ],
          onSelected: (value) async {
            if (value == 'edit') {
              context.push('/admin/teachers/edit/${teacher.id}');
            } else if (value == 'delete') {
              _confirmDelete(teacher.id);
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
      context, title: 'Supprimer', message: 'Supprimer cet enseignant?',
      isDestructive: true, confirmLabel: 'Supprimer',
    );
    if (confirmed == true) ref.read(teacherProvider.notifier).deleteTeacher(id);
  }
}
