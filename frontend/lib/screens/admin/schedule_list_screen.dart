import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/level_provider.dart';
import '../../models/level_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/action_popup_menu.dart';
import '../../core/constants/app_constants.dart';

const _dayToFrench = {
  'Monday': 'Lundi', 'Tuesday': 'Mardi', 'Wednesday': 'Mercredi',
  'Thursday': 'Jeudi', 'Friday': 'Vendredi', 'Saturday': 'Samedi', 'Sunday': 'Dimanche',
};

final _cardColors = [
  Color(0xFFE3F2FD),
  Color(0xFFFCE4EC),
  Color(0xFFE8F5E9),
  Color(0xFFFFF3E0),
  Color(0xFFF3E5F5),
  Color(0xFFE0F7FA),
  Color(0xFFFFFDE7),
  Color(0xFFEFEBE9),
  Color(0xFFF1F8E9),
  Color(0xFFFFF8E1),
];

class ScheduleListScreen extends ConsumerStatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  ConsumerState<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends ConsumerState<ScheduleListScreen> {
  int? _selectedLevelId;
  List<LevelModel> _levels = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scheduleProvider.notifier).loadSchedules();
      _loadLevels();
    });
  }

  Future<void> _loadLevels() async {
    final levelsFuture = ref.read(allLevelsProvider.future);
    final levelsAsync = await levelsFuture;
    if (mounted) setState(() => _levels = levelsAsync);
  }

  void _onFilterChanged() {
    final filters = <String, dynamic>{};
    if (_selectedLevelId != null) filters['level_id'] = _selectedLevelId;
    ref.read(scheduleProvider.notifier).loadSchedules(filters: filters);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Emplois du temps')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/schedules/add'),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButtonFormField<int?>(
              initialValue: _selectedLevelId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Niveau',
                prefixIcon: Icon(Icons.school_rounded, size: 20, color: theme.colorScheme.primary),
                border: InputBorder.none,
                fillColor: Colors.transparent,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tous les niveaux')),
                ..._levels.map((l) => DropdownMenuItem(value: l.id, child: Text('${l.code} - ${l.name}'))),
              ],
              onChanged: (v) {
                setState(() => _selectedLevelId = v);
                _onFilterChanged();
              },
            ),
          ),
          Expanded(child: _buildBody(state, theme)),
        ],
      ),
    );
  }

  Widget _buildBody(ScheduleState state, ThemeData theme) {
    if (state.isLoading && state.schedules.isEmpty) {
      return const LoadingWidget(message: 'Chargement des emplois du temps...');
    }
    if (state.error != null && state.schedules.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(scheduleProvider.notifier).loadSchedules(),
      );
    }
    if (state.schedules.isEmpty) {
      return EmptyState(
        title: 'Aucun emploi du temps',
        actionLabel: 'Ajouter',
        onAction: () => context.push('/admin/schedules/add'),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(60),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              tabs: AppConstants.weekDays.take(5).map((day) => Tab(text: day)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: AppConstants.weekDays.take(5).map((day) {
                final daySchedules = state.schedules
                    .where((s) => s.dayOfWeek.toLowerCase() == (_dayToFrench.keys.firstWhere(
                      (k) => _dayToFrench[k] == day, orElse: () => day,
                    )).toLowerCase())
                    .toList()
                  ..sort((a, b) => a.startTime.compareTo(b.startTime));

                if (daySchedules.isEmpty) {
                  return const EmptyState(
                    title: 'Aucun cours',
                    icon: Icons.event_busy,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(scheduleProvider.notifier).loadSchedules(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: daySchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = daySchedules[index];
                      final cardColor = _cardColors[((schedule.courseName ?? '').hashCode % _cardColors.length).abs()];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: cardColor,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 64,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer.withAlpha(120),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        schedule.startTime.length >= 5 ? schedule.startTime.substring(0, 5) : schedule.startTime,
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: theme.colorScheme.primary, height: 1.2),
                                      ),
                                      const SizedBox(height: 2),
                                      Text('-', style: TextStyle(fontSize: 10, color: theme.colorScheme.primary.withAlpha(120))),
                                      const SizedBox(height: 2),
                                      Text(
                                        schedule.endTime.length >= 5 ? schedule.endTime.substring(0, 5) : schedule.endTime,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: theme.colorScheme.primary, height: 1.2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(schedule.courseName ?? 'Cours', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          _buildInfoChip(Icons.meeting_room_rounded, schedule.classroomName ?? '', theme),
                                          _buildInfoChip(Icons.person_rounded, schedule.teacherName ?? '', theme),
                                          if (schedule.levelName != null)
                                            _buildInfoChip(Icons.school_rounded, schedule.levelName!, theme),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                ActionPopupMenu(
                                  actions: [
                                    const PopupAction(value: 'edit', icon: Icons.edit_rounded, label: 'Modifier'),
                                    const PopupAction(value: 'delete', icon: Icons.delete_rounded, label: 'Supprimer', color: Colors.red),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      context.push('/admin/schedules/edit/${schedule.id}');
                                    } else if (value == 'delete') {
                                      final confirmed = await ConfirmDialog.show(context, title: 'Supprimer', message: 'Supprimer ce créneau?', isDestructive: true, confirmLabel: 'Supprimer');
                                      if (confirmed == true) ref.read(scheduleProvider.notifier).deleteSchedule(schedule.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
