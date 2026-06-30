import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../models/course_model.dart';

const _dayToFrench = {
  'Monday': 'Lundi', 'Tuesday': 'Mardi', 'Wednesday': 'Mercredi',
  'Thursday': 'Jeudi', 'Friday': 'Vendredi', 'Saturday': 'Samedi', 'Sunday': 'Dimanche',
};

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  List<CourseModel> _courses = [];
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourses();
      ref.read(scheduleProvider.notifier).loadSchedules(role: 'teacher');
    });
  }

  Future<void> _loadCourses() async {
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiConstants.teacherCourses);
      final data = response.data;
      final list = (data['data'] as List)
          .map((json) => CourseModel.fromJson(json))
          .toList();
      if (mounted) setState(() { _courses = list; });
    } catch (_) {}
  }

  Future<void> _reload() async {
    ref.read(scheduleProvider.notifier).loadSchedules(
      role: 'teacher',
      filters: _selectedCourseId != null ? {'course_id': _selectedCourseId} : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Emploi du temps')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ScheduleState state) {
    final theme = Theme.of(context);
    if (state.isLoading) return const LoadingWidget(message: "Chargement de l'emploi du temps...");
    if (state.error != null && state.schedules.isEmpty) return AppErrorWidget(message: state.error!, onRetry: _reload);

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          if (_courses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: DropdownButtonFormField<int?>(
                initialValue: _selectedCourseId,
                decoration: InputDecoration(
                  labelText: 'Filtrer par matière',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                  isDense: true,
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text('Toutes les matières', style: theme.textTheme.bodyMedium)),
                  ..._courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.subjectName ?? '', overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium))),
                ],
                onChanged: (v) {
                  setState(() => _selectedCourseId = v);
                  ref.read(scheduleProvider.notifier).loadSchedules(
                    role: 'teacher',
                    filters: v != null ? {'course_id': v} : null,
                  );
                },
              ),
            ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(60),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              tabs: const [
                Tab(text: 'Lundi'), Tab(text: 'Mardi'), Tab(text: 'Mercredi'),
                Tab(text: 'Jeudi'), Tab(text: 'Vendredi'),
              ],
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
                    subtitle: 'Aucun cours programmé ce jour',
                    icon: Icons.event_busy,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: daySchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = daySchedules[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 72,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withAlpha(120),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      schedule.startTime.length >= 5 ? schedule.startTime.substring(0, 5) : schedule.startTime,
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: theme.colorScheme.primary, height: 1.2),
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
                                        if (schedule.teacherName != null)
                                          _buildInfoChip(Icons.person_rounded, schedule.teacherName!, theme),
                                        if (schedule.group != null && schedule.group!.isNotEmpty)
                                          _buildInfoChip(Icons.group_rounded, schedule.group!, theme),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
          Icon(icon, size: 11, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
