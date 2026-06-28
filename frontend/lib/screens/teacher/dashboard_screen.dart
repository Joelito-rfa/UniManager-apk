import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/common/kpi_card.dart';
import '../../widgets/common/academic_calendar.dart';
import '../../widgets/common/activity_tile.dart';
import '../../widgets/common/quick_actions.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadTeacherDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(dashboardProvider);
    final now = DateTime.now();
    final today = DateFormat('EEEE d MMMM', 'fr_FR').format(now);

    if (state.isLoading) {
      return const LoadingWidget(message: 'Chargement...');
    }
    if (state.error != null) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(dashboardProvider.notifier).loadTeacherDashboard(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, today),
          const SizedBox(height: 24),
          _buildKpiGrid(theme, state),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final rowWidth = constraints.maxWidth;
              if (rowWidth >= 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: rowWidth * 0.65,
                      child: _buildScheduleSection(theme, now),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: rowWidth * 0.35 - 24,
                      child: Column(
                        children: [
                          _buildQuickActionsSection(theme),
                          const SizedBox(height: 16),
                          _buildActivitySection(theme),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScheduleSection(theme, now),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(theme),
                  const SizedBox(height: 16),
                  _buildActivitySection(theme),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String today) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour, ${ref.watch(authProvider).user?.name ?? ''}',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          today[0].toUpperCase() + today.substring(1),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(ThemeData theme, dynamic state) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      children: [
        KpiCard(
          title: 'Mes cours',
          value: '${state.stats?.totalCourses ?? 0}',
          icon: Icons.menu_book_rounded,
          color: const Color(0xFF4F46E5),
          evolution: 0.0,
          onTap: () => context.go('/teacher/courses'),
        ),
        KpiCard(
          title: 'Étudiants',
          value: '${state.stats?.totalStudents ?? 0}',
          icon: Icons.people_rounded,
          color: const Color(0xFF0D9488),
          evolution: 5.2,
          onTap: () => context.go('/teacher/students'),
        ),
        KpiCard(
          title: 'Séances',
          value: '${state.stats?.totalClassrooms ?? 0}',
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFFE11D48),
          evolution: 3.8,
          onTap: () => context.go('/teacher/schedule'),
        ),
        KpiCard(
          title: 'Notes à saisir',
          value: '${state.stats?.pendingResults ?? 0}',
          icon: Icons.grade_rounded,
          color: const Color(0xFFEF4444),
          evolution: -12.3,
          onTap: () => context.go('/teacher/grades'),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(ThemeData theme, DateTime now) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, Icons.schedule_rounded, 'Emploi du temps'),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AcademicCalendar(
              events: [
                CalendarEvent(
                  id: 1, title: 'Cours Maths', subtitle: 'L3 INFO - Salle 101',
                  date: DateTime(now.year, now.month, now.day + 1),
                  time: '08:00-10:00', color: const Color(0xFF4F46E5),
                ),
                CalendarEvent(
                  id: 2, title: 'Cours Algo', subtitle: 'L2 INFO - Salle 203',
                  date: DateTime(now.year, now.month, now.day + 2),
                  time: '10:00-12:00', color: const Color(0xFF0D9488),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, Icons.touch_app_rounded, 'Raccourcis'),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: QuickActions(
              actions: const [
                QuickAction(
                  icon: Icons.grade_rounded, label: 'Saisir notes',
                  route: '/teacher/grades', color: Color(0xFF4F46E5),
                ),
                QuickAction(
                  icon: Icons.quiz_rounded, label: 'Examens',
                  route: '/teacher/exams', color: Color(0xFFE11D48),
                ),
                QuickAction(
                  icon: Icons.people_rounded, label: 'Étudiants',
                  route: '/teacher/students', color: Color(0xFF0D9488),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, Icons.history_rounded, 'Activités'),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ActivityTile(
                  icon: Icons.grade_rounded, title: 'Note publiée',
                  subtitle: 'Moyenne Maths L3 publiée',
                  time: 'Il y a 2h', color: Color(0xFF4F46E5),
                ),
                const ActivityTile(
                  icon: Icons.person_add_rounded, title: 'Nouvel étudiant',
                  subtitle: 'Jean Dupont inscrit en L2 INFO',
                  time: 'Il y a 1j', color: Color(0xFF0D9488),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
