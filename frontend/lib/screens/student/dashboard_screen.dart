import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/common/kpi_card.dart';
import '../../widgets/common/academic_calendar.dart';
import '../../widgets/common/activity_tile.dart';
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
      ref.read(dashboardProvider.notifier).loadStudentDashboard();
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
        onRetry: () => ref.read(dashboardProvider.notifier).loadStudentDashboard(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, today),
          const SizedBox(height: 24),
          _buildKpiGrid(theme),
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
                      child: _buildActivitySection(theme),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScheduleSection(theme, now),
                  const SizedBox(height: 24),
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

  Widget _buildKpiGrid(ThemeData theme) {
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
          title: 'Mes notes',
          value: 'Voir',
          icon: Icons.grade_rounded,
          color: const Color(0xFF4F46E5),
          evolution: 7.2,
          onTap: () => context.go('/student/grades'),
        ),
        KpiCard(
          title: 'Emploi du temps',
          value: 'Voir',
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFF0D9488),
          evolution: 0.0,
          onTap: () => context.go('/student/schedule'),
        ),
        KpiCard(
          title: 'Résultats',
          value: 'Voir',
          icon: Icons.assessment_rounded,
          color: const Color(0xFFE11D48),
          evolution: 0.0,
          onTap: () => context.go('/student/results'),
        ),
        KpiCard(
          title: 'Ressources',
          value: 'Voir',
          icon: Icons.folder_rounded,
          color: const Color(0xFF7C3AED),
          evolution: 0.0,
          onTap: () => context.go('/student/resources'),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(ThemeData theme, DateTime now) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, Icons.calendar_month_rounded, 'Emploi du temps'),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AcademicCalendar(
              events: [
                CalendarEvent(
                  id: 1, title: 'Cours Maths', subtitle: 'Salle 101',
                  date: DateTime(now.year, now.month, now.day + 1),
                  time: '08:00-10:00', color: const Color(0xFF4F46E5),
                ),
                CalendarEvent(
                  id: 2, title: 'Cours Français', subtitle: 'Salle 203',
                  date: DateTime(now.year, now.month, now.day + 2),
                  time: '10:00-12:00', color: const Color(0xFF0D9488),
                ),
                CalendarEvent(
                  id: 3, title: 'Examen Anglais', subtitle: 'Amphi A',
                  date: DateTime(now.year, now.month, now.day + 4),
                  time: '14:00-16:00', color: const Color(0xFFE11D48),
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
        _buildSectionHeader(theme, Icons.history_rounded, 'Activités récentes'),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: const [
              ActivityTile(
                icon: Icons.grade_rounded, title: 'Note publiée',
                subtitle: 'Moyenne semestre disponible',
                time: 'Il y a 2h', color: Color(0xFF4F46E5),
              ),
              ActivityTile(
                icon: Icons.quiz_rounded, title: 'Examen à venir',
                subtitle: 'Anglais L3 - 14 Juin',
                time: 'Il y a 1j', color: Color(0xFFE11D48),
              ),
            ],
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
