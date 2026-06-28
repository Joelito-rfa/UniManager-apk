import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/level_provider.dart';
import '../../models/level_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/action_popup_menu.dart';
import '../../widgets/common/data_table_widget.dart';
import '../../widgets/common/filter_bar.dart';

class EnrollmentListScreen extends ConsumerStatefulWidget {
  const EnrollmentListScreen({super.key});

  @override
  ConsumerState<EnrollmentListScreen> createState() => _EnrollmentListScreenState();
}

class _EnrollmentListScreenState extends ConsumerState<EnrollmentListScreen> {
  int? _selectedLevelId;
  List<LevelModel> _levels = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(enrollmentProvider.notifier).loadEnrollments();
      _loadFilters();
    });
  }

  Future<void> _loadFilters() async {
    final levels = await ref.read(allLevelsProvider.future);
    if (mounted) setState(() => _levels = levels);
  }

  void _onFilterChanged() {
    ref.read(enrollmentProvider.notifier).loadEnrollments(
      filters: {
        if (_selectedLevelId != null) 'level_id': _selectedLevelId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(enrollmentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inscriptions')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/enrollments/add'),
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
          Expanded(child: _buildBody(theme, state)),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, EnrollmentState state) {
    if (state.isLoading && state.enrollments.isEmpty) {
      return const LoadingWidget(message: 'Chargement des inscriptions...');
    }
    if (state.error != null && state.enrollments.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(enrollmentProvider.notifier).loadEnrollments(),
      );
    }
    if (state.enrollments.isEmpty) {
      return EmptyState(
        title: 'Aucune inscription',
        icon: Icons.assignment_outlined,
        actionLabel: 'Ajouter une inscription',
        onAction: () => context.push('/admin/enrollments/add'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(enrollmentProvider.notifier).loadEnrollments(),
      child: DataTableWidget(
        columns: const [
          DataColumn(label: Text('Étudiant')),
          DataColumn(label: Text('Filière')),
          DataColumn(label: Text('Statut')),
          DataColumn(label: Text('Actions')),
        ],
        rows: state.enrollments.map((enrollment) {
          return DataRow(cells: [
            DataCell(Text(enrollment.studentName ?? '')),
            DataCell(Text(enrollment.programName ?? '')),
            DataCell(_buildStatusChip(
              enrollment.status == 'active' ? 'Actif' : (enrollment.status ?? ''),
              enrollment.status == 'active'
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
            )),
            DataCell(
              ActionPopupMenu(
                actions: const [
                  PopupAction(
                    value: 'delete', icon: Icons.delete_rounded,
                    label: 'Supprimer', color: Colors.red,
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirmed = await ConfirmDialog.show(
                      context, title: 'Supprimer',
                      message: 'Supprimer cette inscription?',
                      isDestructive: true, confirmLabel: 'Supprimer',
                    );
                    if (confirmed == true) {
                      ref.read(enrollmentProvider.notifier).deleteEnrollment(enrollment.id);
                    }
                  }
                },
              ),
            ),
          ]);
        }).toList(),
        currentPage: 1,
        lastPage: 1,
        total: state.enrollments.length,
        isLoading: state.isLoading,
        items: state.enrollments,
        cardBuilder: (item) {
          final enrollment = item;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  enrollment.studentName?.isNotEmpty == true
                      ? enrollment.studentName![0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              title: Text(enrollment.studentName ?? '', style: Theme.of(context).textTheme.titleSmall),
              subtitle: Text(
                enrollment.programName ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusChip(
                    enrollment.status == 'active' ? 'Actif' : (enrollment.status ?? ''),
                    enrollment.status == 'active'
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 8),
                  ActionPopupMenu(
                    actions: const [
                      PopupAction(
                        value: 'delete', icon: Icons.delete_rounded,
                        label: 'Supprimer', color: Colors.red,
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirmed = await ConfirmDialog.show(
                          context, title: 'Supprimer',
                          message: 'Supprimer cette inscription?',
                          isDestructive: true, confirmLabel: 'Supprimer',
                        );
                        if (confirmed == true) {
                          ref.read(enrollmentProvider.notifier).deleteEnrollment(enrollment.id);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
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
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
