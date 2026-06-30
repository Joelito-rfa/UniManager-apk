import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/course_provider.dart';
import '../../providers/level_provider.dart';
import '../../models/level_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/filter_bar.dart';
import '../../widgets/common/action_popup_menu.dart';
import '../../widgets/common/data_table_widget.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  int? _selectedLevelId;
  List<LevelModel> _levels = [];
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(courseProvider.notifier).loadCourses();
      _loadLevels();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadLevels() async {
    final levelsFuture = ref.read(allLevelsProvider.future);
    final levelsAsync = await levelsFuture;
    if (mounted) setState(() => _levels = levelsAsync);
  }

  void _onFilterChanged() {
    ref.read(courseProvider.notifier).loadCourses(
      levelId: _selectedLevelId,
      search: _codeController.text.isNotEmpty ? _codeController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(courseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cours')),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/courses/add'),
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

  Widget _buildBody(ThemeData theme, CourseState state) {
    if (state.isLoading && state.courses.isEmpty) {
      return const LoadingWidget(message: 'Chargement des cours...');
    }
    if (state.error != null && state.courses.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(courseProvider.notifier).loadCourses(),
      );
    }
    if (state.courses.isEmpty) {
      return EmptyState(
        title: 'Aucun cours',
        subtitle: 'Commencez par ajouter un cours.',
        icon: Icons.menu_book_outlined,
        actionLabel: 'Ajouter un cours',
        onAction: () => context.push('/admin/courses/add'),
      );
    }

    final columns = [
      const DataColumn(label: Text('Code')),
      const DataColumn(label: Text('Matière')),
      const DataColumn(label: Text('Enseignant')),
      const DataColumn(label: Text('Semestre')),
      const DataColumn(label: Text('Année')),
      DataColumn(label: Text('Statut')),
      const DataColumn(label: Text('Actions')),
    ];

    final rows = state.courses.map((course) {
      return DataRow(cells: [
        DataCell(Text(course.code ?? '')),
        DataCell(Text(course.subjectName ?? '')),
        DataCell(Text(course.teacherName ?? '')),
        DataCell(Text(course.semester ?? '')),
        DataCell(Text(course.academicYear ?? '')),
        DataCell(_buildStatusChip(
          course.status == 'active' ? 'Actif' : 'Inactif',
          course.status == 'active'
              ? const Color(0xFF10B981)
              : theme.colorScheme.outline,
        )),
        DataCell(Row(
          children: [
            _buildTableActionButton(
              Icons.folder_outlined,
              const Color(0xFF6366F1),
              () => context.push('/admin/courses/${course.id}/resources', extra: course),
            ),
            const SizedBox(width: 4),
            _buildTableActionButton(
              Icons.edit_rounded,
              theme.colorScheme.primary,
              () => context.push('/admin/courses/edit/${course.id}'),
            ),
            const SizedBox(width: 4),
            _buildTableActionButton(
              Icons.delete_rounded,
              theme.colorScheme.error,
              () => _confirmDelete(course.id),
            ),
          ],
        )),
      ]);
    }).toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(courseProvider.notifier).loadCourses(),
      child: DataTableWidget(
        columns: columns,
        rows: rows,
        currentPage: state.currentPage,
        lastPage: state.lastPage,
        total: state.total,
        isLoading: state.isLoading,
        onPageChanged: (page) {
          ref.read(courseProvider.notifier).loadCourses(page: page);
        },
        items: state.courses,
        cardBuilder: (item) => _buildMobileCard(theme, item as dynamic),
      ),
    );
  }

  Widget _buildMobileCard(ThemeData theme, dynamic course) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary),
        ),
        title: Text(course.subjectName ?? '', style: theme.textTheme.titleSmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${course.teacherName ?? ''} · ${course.levelName ?? ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${course.semester ?? ''} ${course.academicYear ?? ''}'.trim(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withAlpha(180),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.folder_outlined, size: 20),
              color: const Color(0xFF6366F1),
              tooltip: 'Ressources',
              onPressed: () => context.push('/admin/courses/${course.id}/resources', extra: course),
            ),
            ActionPopupMenu(
              actions: [
                const PopupAction(
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
                  context.push('/admin/courses/edit/${course.id}');
                } else if (value == 'delete') {
                  _confirmDelete(course.id);
                }
              },
            ),
          ],
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
      message: 'Supprimer ce cours?',
      isDestructive: true,
      confirmLabel: 'Supprimer',
    );
    if (confirmed == true) {
      ref.read(courseProvider.notifier).deleteCourse(id);
    }
  }
}
