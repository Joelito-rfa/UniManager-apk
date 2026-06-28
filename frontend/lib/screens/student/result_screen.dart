import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../models/result_model.dart';
import '../../models/level_result_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/filter_bar.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  List<ResultModel> _results = [];
  List<LevelResultModel> _levelResults = [];
  Map<String, dynamic>? _summary;
  bool _isLoading = false;
  bool _isLoadingLevel = false;
  String? _error;
  String? _selectedSemester;
  String? _selectedAcademicYear;
  String _tab = 'results';

  @override
  void initState() {
    super.initState();
    _loadResults();
    _loadSummary();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioClientProvider);
      final params = <String, dynamic>{};
      if (_selectedSemester != null) params['semester'] = _selectedSemester;
      if (_selectedAcademicYear != null) params['academic_year'] = _selectedAcademicYear;
      final response = await dio.get(ApiConstants.studentResults, queryParameters: params);
      if (response.data['success'] == true) {
        _results = (response.data['data'] as List<dynamic>)
            .map((e) => ResultModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadLevelResults() async {
    setState(() => _isLoadingLevel = true);
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiConstants.studentLevelResults);
      if (response.data['success'] == true) {
        _levelResults = (response.data['data'] as List<dynamic>)
            .map((e) => LevelResultModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      // Silently fail for level results
    }
    if (mounted) setState(() => _isLoadingLevel = false);
  }

  Future<void> _loadSummary() async {
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiConstants.studentResultsSummary);
      if (response.data['success'] == true) {
        _summary = response.data['data'] as Map<String, dynamic>;
      }
    } catch (_) {}
  }

  Future<void> _downloadPdf() async {
    try {
      final dio = ref.read(dioClientProvider);
      final params = <String, dynamic>{};
      if (_selectedSemester != null) params['semester'] = _selectedSemester;
      if (_selectedAcademicYear != null) params['academic_year'] = _selectedAcademicYear;
      await dio.get(ApiConstants.studentResultsDownload, queryParameters: params);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relevé téléchargé avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes résultats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_rounded),
            tooltip: 'Télécharger le relevé',
            onPressed: _downloadPdf,
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            if (_summary != null) _buildSummaryCard(theme),
            TabBar(
              tabs: const [
                Tab(text: 'Par matière'),
                Tab(text: 'Résultat final'),
              ],
              onTap: (i) {
                setState(() => _tab = i == 0 ? 'results' : 'level');
                if (_tab == 'level' && _levelResults.isEmpty) _loadLevelResults();
              },
            ),
            if (_tab == 'results')
              FilterBar(
                dropdowns: [
                  FilterDropdown(
                    label: 'Semestre', value: _selectedSemester,
                    options: [
                      const FilterOption(value: null, label: 'Tous'),
                      const FilterOption(value: 'S1', label: 'Semestre 1'),
                      const FilterOption(value: 'S2', label: 'Semestre 2'),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedSemester = v as String?);
                      _loadResults();
                    },
                  ),
                  FilterDropdown(
                    label: 'Année', value: _selectedAcademicYear,
                    options: [
                      const FilterOption(value: null, label: 'Tous'),
                      const FilterOption(value: '2023/2024', label: '2023/2024'),
                      const FilterOption(value: '2024/2025', label: '2024/2025'),
                      const FilterOption(value: '2025/2026', label: '2025/2026'),
                      const FilterOption(value: '2026/2027', label: '2026/2027'),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedAcademicYear = v as String?);
                      _loadResults();
                    },
                  ),
                ],
              ),
            Expanded(
              child: _tab == 'results' ? _buildResultsBody(theme) : _buildLevelBody(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    final s = _summary!;
    final current = s['current_level_result'] as Map<String, dynamic>?;
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment_rounded, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('Récapitulatif', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statItem(theme, 'Crédits', '${s['validated_credits'] ?? 0}/${s['total_credits'] ?? 0}', const Color(0xFF10B981)),
                const SizedBox(width: 16),
                _statItem(theme, 'Moyenne', (s['overall_gpa'] as num?)?.toStringAsFixed(1) ?? '-', theme.colorScheme.primary),
                const SizedBox(width: 16),
                _statItem(theme, 'Validés', '${s['validated_count'] ?? 0}/${s['results_count'] ?? 0}', const Color(0xFF10B981)),
              ],
            ),
            if (current != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Icon(Icons.trending_up_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text('Niveau actuel: ', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                  Text('${(current['average_grade'] as num?)?.toStringAsFixed(1) ?? '-'}/20',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    (current['decision'] as String?) ?? '',
                    (current['decision'] as String?) == 'admis'
                        ? const Color(0xFF10B981)
                        : (current['decision'] as String?) == 'rattrapage'
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFEF4444),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statItem(ThemeData theme, String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildResultsBody(ThemeData theme) {
    if (_isLoading) return const LoadingWidget(message: 'Chargement...');
    if (_error != null) return AppErrorWidget(message: _error!, onRetry: _loadResults);
    if (_results.isEmpty) return const EmptyState(title: 'Aucun résultat', icon: Icons.assessment_outlined);

    final passed = _results.where((r) => r.isPassed).length;

    return RefreshIndicator(
      onRefresh: _loadResults,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_results.length} matière(s)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text('$passed validée(s)',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: passed == _results.length
                          ? const Color(0xFF10B981).withAlpha(15)
                          : const Color(0xFFF59E0B).withAlpha(15),
                    ),
                    child: Text(
                      passed == _results.length ? 'Tout validé' : '${(passed / _results.length * 100).round()}%',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: passed == _results.length ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._results.map((r) => _buildResultCard(theme, r)),
        ],
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme, ResultModel r) {
    final color = r.isPassed
        ? const Color(0xFF10B981)
        : r.isRetake
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color.withAlpha(25), color.withAlpha(10)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(r.average.toStringAsFixed(1),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.subjectName ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('${r.teacherName ?? ''} · Coef ${r.coefficient?.toStringAsFixed(1) ?? '-'}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                _buildStatusChip(r.decisionLabel, color),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (r.mentionLabel.isNotEmpty)
                  Text(r.mentionLabel, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                const Spacer(),
                Text('${r.earnedCredits?.toInt() ?? 0}/${r.totalCredits?.toInt() ?? 0} crédits',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                if (r.semester != null) ...[
                  const SizedBox(width: 8),
                  Text('S${r.semester}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBody(ThemeData theme) {
    if (_isLoadingLevel) return const LoadingWidget(message: 'Chargement...');
    if (_levelResults.isEmpty) return const EmptyState(title: 'Aucun résultat de niveau', icon: Icons.assessment_outlined);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: _levelResults.map((r) {
        final color = r.isAdmis ? const Color(0xFF10B981) : r.isRattrapage ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [color.withAlpha(25), color.withAlpha(10)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(r.averageGrade.toStringAsFixed(1),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${r.levelName ?? ''} · ${r.academicYear ?? ''}',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(r.mentionLabel,
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                        ],
                      ),
                    ),
                    _buildStatusChip(r.decisionLabel, color),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _miniStat(theme, 'Moyenne', r.averageGrade.toStringAsFixed(2)),
                    const SizedBox(width: 24),
                    _miniStat(theme, 'Crédits', '${r.totalCreditsObtained}/${r.totalCreditsRequired}'),
                    const SizedBox(width: 24),
                    _miniStat(theme, 'Points', r.totalPoints.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _miniStat(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
        Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
