import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/dashboard_stats_model.dart';
import '../../widgets/common/kpi_card.dart';
import '../../widgets/common/activity_tile.dart';
import '../../widgets/common/quick_actions.dart';
import '../../widgets/common/academic_calendar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      if (auth.status == AuthStatus.authenticated) {
        ref.read(dashboardProvider.notifier).loadDashboard();
      }
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(dashboardProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).loadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: _buildContent(theme, state),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, DashboardState state) {
    final now = DateTime.now();

    if (state.isLoading) {
      return const SizedBox(
        height: 400,
        child: LoadingWidget(message: 'Chargement du tableau de bord...'),
      );
    }
    if (state.error != null) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(dashboardProvider.notifier).loadDashboard(),
      );
    }

    final stats = state.stats;
    if (stats == null) return const SizedBox();

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 1200;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, now),
          const SizedBox(height: 24),
          _buildKpiGrid(theme, stats, isWide),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final rowWidth = constraints.maxWidth;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: rowWidth * 0.65,
                      child: _buildChartsSection(theme, stats, rowWidth * 0.65),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: rowWidth * 0.35 - 24,
                      child: _buildCalendarSection(theme),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartsSection(theme, stats, rowWidth),
                  const SizedBox(height: 24),
                  _buildCalendarSection(theme),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final rowWidth = constraints.maxWidth;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: rowWidth * 0.65,
                      child: _buildRecentActivity(theme, stats),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: rowWidth * 0.35 - 24,
                      child: _buildQuickActions(theme),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecentActivity(theme, stats),
                  const SizedBox(height: 24),
                  _buildQuickActions(theme),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, DateTime now) {
    final today = DateFormat('EEEE d MMMM', 'fr_FR').format(now);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tableau de bord',
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
        ),
        FilledButton.icon(
          onPressed: () {
            _animController.reset();
            _animController.forward();
            ref.read(dashboardProvider.notifier).loadDashboard();
          },
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Actualiser'),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(ThemeData theme, DashboardStatsModel stats, bool isWide) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      children: [
        KpiCard(
          title: 'Étudiants',
          value: '${stats.totalStudents}',
          icon: Icons.people_rounded,
          color: const Color(0xFF4F46E5),
          evolution: 12.5,
          onTap: () => context.go('/admin/students'),
        ),
        KpiCard(
          title: 'Enseignants',
          value: '${stats.totalTeachers}',
          icon: Icons.person_rounded,
          color: const Color(0xFF0D9488),
          evolution: 8.3,
          onTap: () => context.go('/admin/teachers'),
        ),
        KpiCard(
          title: 'Filières',
          value: '${stats.totalPrograms}',
          icon: Icons.school_rounded,
          color: const Color(0xFFE11D48),
          evolution: 5.0,
          onTap: () => context.go('/admin/programs'),
        ),
        KpiCard(
          title: 'Cours',
          value: '${stats.totalCourses}',
          icon: Icons.menu_book_rounded,
          color: const Color(0xFF7C3AED),
          evolution: -2.1,
          onTap: () => context.go('/admin/courses'),
        ),
        KpiCard(
          title: 'Départements',
          value: '${stats.totalDepartments}',
          icon: Icons.business_rounded,
          color: const Color(0xFF0891B2),
          evolution: 0.0,
          onTap: () => context.go('/admin/departments'),
        ),
        KpiCard(
          title: 'Salles',
          value: '${stats.totalClassrooms}',
          icon: Icons.meeting_room_rounded,
          color: const Color(0xFFD97706),
          evolution: 15.0,
          onTap: () => context.go('/admin/classrooms'),
        ),
        KpiCard(
          title: 'Inscriptions',
          value: '${stats.activeEnrollments}',
          icon: Icons.assignment_rounded,
          color: const Color(0xFF059669),
          evolution: 22.7,
          onTap: () => context.go('/admin/enrollments'),
        ),
        KpiCard(
          title: 'En attente',
          value: '${stats.pendingResults}',
          icon: Icons.pending_rounded,
          color: const Color(0xFFEF4444),
          evolution: -8.5,
          onTap: () => context.go('/admin/results'),
        ),
      ],
    );
  }

  Widget _buildChartsSection(ThemeData theme, DashboardStatsModel stats, double availableWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, Icons.analytics_rounded, 'Analytiques'),
        const SizedBox(height: 16),
        if (stats.programDistribution.isNotEmpty || stats.gradeEvolution.isNotEmpty)
          _buildChartRow(theme, stats, availableWidth),
      ],
    );
  }

  final _levelDistribution = [
    _LevelData('L1', 85, 28.3),
    _LevelData('L2', 72, 24.0),
    _LevelData('L3', 68, 22.7),
    _LevelData('M1', 42, 14.0),
    _LevelData('M2', 33, 11.0),
  ];

  Widget _buildChartRow(ThemeData theme, DashboardStatsModel stats, double availableWidth) {
    final chartsSideBySide = availableWidth >= 780;
    final hasPie = stats.programDistribution.isNotEmpty;
    final hasLine = stats.gradeEvolution.isNotEmpty;

    if (chartsSideBySide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPie)
            Expanded(
              child: _buildPieCard(theme, 'Répartition par filière',
                  stats.programDistribution.map((d) => _LevelData(d.name, d.count, d.percentage)).toList()),
            ),
          if (hasPie) const SizedBox(width: 12),
          Expanded(
            child: _buildPieCard(theme, 'Répartition par niveau', _levelDistribution),
          ),
          if (hasLine) const SizedBox(width: 12),
          if (hasLine)
            Expanded(
              child: _buildLineChartCard(theme, stats),
            ),
        ],
      );
    }

    return Column(
      children: [
        if (hasPie)
          _buildPieCard(theme, 'Répartition par filière',
              stats.programDistribution.map((d) => _LevelData(d.name, d.count, d.percentage)).toList()),
        if (hasPie) const SizedBox(height: 16),
        _buildPieCard(theme, 'Répartition par niveau', _levelDistribution),
        if (hasLine) ...[
          const SizedBox(height: 16),
          _buildLineChartCard(theme, stats),
        ],
      ],
    );
  }

  Widget _buildLineChartCard(ThemeData theme, DashboardStatsModel stats) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Évolution des notes',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outlineVariant,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < stats.gradeEvolution.length) {
                            final period = stats.gradeEvolution[idx].period;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                period.length > 6 ? period.substring(0, 6) : period,
                                style: theme.textTheme.bodySmall,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: stats.gradeEvolution
                          .map((e) => FlSpot(
                                stats.gradeEvolution.indexOf(e).toDouble(),
                                e.average,
                              ))
                          .toList(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, _) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary.withAlpha(40),
                            theme.colorScheme.primary.withAlpha(5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildCalendarSection(ThemeData theme) {
    final now = DateTime.now();
    final mockEvents = [
      CalendarEvent(
        id: 1,
        title: 'Examen Mathématiques',
        subtitle: 'Salle 101 - Niveau L3',
        date: DateTime(now.year, now.month, now.day + 1),
        time: '08:00 - 10:00',
        color: const Color(0xFFE11D48),
        type: 'exam',
      ),
      CalendarEvent(
        id: 2,
        title: 'Cours Programmation',
        subtitle: 'Dr. Koné - Salle 203',
        date: DateTime(now.year, now.month, now.day + 2),
        time: '10:00 - 12:00',
        color: const Color(0xFF4F46E5),
        type: 'course',
      ),
      CalendarEvent(
        id: 3,
        title: 'Réunion pédagogique',
        subtitle: 'Salle de conférence',
        date: DateTime(now.year, now.month, now.day + 3),
        time: '14:00 - 15:30',
        color: const Color(0xFF0D9488),
        type: 'meeting',
      ),
      CalendarEvent(
        id: 4,
        title: 'Publication des résultats',
        subtitle: 'Semestre 2',
        date: DateTime(now.year, now.month, now.day + 5),
        time: 'Toute la journée',
        color: const Color(0xFF059669),
        type: 'result',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, Icons.calendar_month_rounded, 'Calendrier'),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AcademicCalendar(events: mockEvents),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(ThemeData theme, DashboardStatsModel stats) {
    final activities = <Widget>[];
    activities.addAll(stats.recentEnrollments.map<Widget>((enrollment) {
      return ActivityTile(
        icon: Icons.person_add_rounded,
        title: enrollment.studentName,
        subtitle: 'Inscrit en ${enrollment.programName} - ${enrollment.levelName}',
        time: enrollment.enrollmentDate,
        color: const Color(0xFF4F46E5),
      );
    }).toList());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, Icons.history_rounded, 'Activités récentes'),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: activities.isNotEmpty
              ? Column(children: activities)
              : Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 40,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aucune activité récente',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, Icons.touch_app_rounded, 'Raccourcis rapides'),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: QuickActions(
              actions: const [
                QuickAction(
                  icon: Icons.person_add_rounded,
                  label: 'Ajouter étudiant',
                  route: '/admin/students/add',
                  color: Color(0xFF4F46E5),
                ),
                QuickAction(
                  icon: Icons.person_add_rounded,
                  label: 'Ajouter enseignant',
                  route: '/admin/teachers/add',
                  color: Color(0xFF0D9488),
                ),
                QuickAction(
                  icon: Icons.menu_book_rounded,
                  label: 'Ajouter cours',
                  route: '/admin/courses/add',
                  color: Color(0xFF7C3AED),
                ),
                QuickAction(
                  icon: Icons.quiz_rounded,
                  label: 'Ajouter examen',
                  route: '/admin/exams',
                  color: Color(0xFFE11D48),
                ),
                QuickAction(
                  icon: Icons.grade_rounded,
                  label: 'Gérer notes',
                  route: '/admin/grades',
                  color: Color(0xFFD97706),
                ),
                QuickAction(
                  icon: Icons.calendar_month_rounded,
                  label: 'Emploi du temps',
                  route: '/admin/schedules',
                  color: Color(0xFF0891B2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getChartColor(int index) {
    const colors = [
      Color(0xFF4F46E5),
      Color(0xFF0D9488),
      Color(0xFFE11D48),
      Color(0xFF7C3AED),
      Color(0xFFD97706),
      Color(0xFF0891B2),
      Color(0xFF059669),
    ];
    return colors[index % colors.length];
  }

  Widget _buildPieCard(ThemeData theme, String title, List<_LevelData> data) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: data.map((d) {
                    return PieChartSectionData(
                      value: d.percentage,
                      title: '${d.percentage.toStringAsFixed(0)}%',
                      radius: 50,
                      color: _getChartColor(data.indexOf(d)),
                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...data.map((d) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: _getChartColor(data.indexOf(d)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(d.name, style: theme.textTheme.bodySmall),
                    ),
                    Text(
                      '${d.count}',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LevelData {
  final String name;
  final int count;
  final double percentage;
  _LevelData(this.name, this.count, this.percentage);
}
