import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/result_provider.dart';
import '../../providers/level_result_provider.dart';
import '../../providers/program_provider.dart';
import '../../providers/level_provider.dart';
import '../../providers/department_provider.dart';

import '../../models/result_model.dart';
import '../../models/level_result_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/data_table_widget.dart';
import '../../widgets/common/filter_bar.dart';


class ResultListScreen extends ConsumerStatefulWidget {
  const ResultListScreen({super.key});

  @override
  ConsumerState<ResultListScreen> createState() => _ResultListScreenState();
}

class _ResultListScreenState extends ConsumerState<ResultListScreen> {
  String _searchQuery = '';
  int? _selectedLevelId;
  int? _selectedProgramId;
  int? _selectedDepartmentId;
  String? _selectedSemester;
  String? _selectedAcademicYear;
  String? _selectedDecision;
  int _currentPage = 1;
  String _viewMode = 'results';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    if (_viewMode == 'results') {
      ref.read(resultProvider.notifier).loadResults(
        page: _currentPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        levelId: _selectedLevelId,
        programId: _selectedProgramId,
        departmentId: _selectedDepartmentId,
        semester: _selectedSemester,
        academicYear: _selectedAcademicYear,
        decision: _selectedDecision,
      );
    } else {
      ref.read(levelResultProvider.notifier).loadResults(
        page: _currentPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        levelId: _selectedLevelId,
        programId: _selectedProgramId,
        departmentId: _selectedDepartmentId,
        academicYear: _selectedAcademicYear,
        decision: _selectedDecision,
      );
    }
  }

  Future<void> _publishResults() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Publier les résultats',
      message: _viewMode == 'results'
          ? 'Publier les résultats affichés ?'
          : 'Publier les résultats de niveau affichés ?',
      confirmLabel: 'Publier',
      isDestructive: false,
    );
    if (confirmed != true || !mounted) return;

    bool success;
    if (_viewMode == 'results') {
      success = await ref.read(resultProvider.notifier).publish(
        levelId: _selectedLevelId,
      );
    } else {
      success = await ref.read(levelResultProvider.notifier).publish(
        levelId: _selectedLevelId,
        programId: _selectedProgramId,
        academicYear: _selectedAcademicYear,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Résultats publiés avec succès' : 'Erreur lors de la publication'),
      ));
      if (success) _loadData();
    }
  }

  Future<void> _calculateResults() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Calculer les résultats',
      message: _viewMode == 'results'
          ? 'Recalculer tous les résultats à partir des notes ?'
          : 'Calculer les résultats finaux de niveau ?',
      confirmLabel: 'Calculer',
      isDestructive: false,
    );
    if (confirmed != true || !mounted) return;

    bool success;
    if (_viewMode == 'results') {
      success = await ref.read(resultProvider.notifier).recalculateAll();
    } else {
      success = await ref.read(levelResultProvider.notifier).calculate(
        levelId: _selectedLevelId,
        programId: _selectedProgramId,
        academicYear: _selectedAcademicYear,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Calcul effectué avec succès' : 'Erreur lors du calcul'),
      ));
      if (success) _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultState = ref.watch(resultProvider);
    final levelResultState = ref.watch(levelResultProvider);

    final state = _viewMode == 'results' ? resultState : levelResultState;
    final items = _viewMode == 'results'
        ? resultState.results as List<dynamic>
        : levelResultState.results as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des résultats'),
        actions: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'results', label: Text('Matières')),
              ButtonSegment(value: 'levels', label: Text('Niveaux')),
            ],
            selected: {_viewMode},
            onSelectionChanged: (v) {
              setState(() {
                _viewMode = v.first;
                _currentPage = 1;
              });
              _loadData();
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (v) {
              if (v == 'publish') _publishResults();
              if (v == 'calculate') _calculateResults();
              if (v == 'export') _exportResults();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'calculate',
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.calculate_rounded, size: 20),
                      SizedBox(width: 16),
                      Text('Calculer'),
                    ],
                  ),
                ),
              ),
              const PopupMenuItem(
                value: 'publish',
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.publish_rounded, size: 20),
                      SizedBox(width: 16),
                      Text('Publier'),
                    ],
                  ),
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.file_download_rounded, size: 20),
                      SizedBox(width: 16),
                      Text('Export'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          FilterBar(
            dropdowns: [
              FilterDropdown(
                label: 'Département', value: _selectedDepartmentId,
                options: _buildDepartmentOptions(),
                onChanged: (v) {
                  setState(() { _selectedDepartmentId = v as int?; _currentPage = 1; });
                  _loadData();
                },
              ),
              FilterDropdown(
                label: 'Filière', value: _selectedProgramId,
                options: _buildProgramOptions(),
                onChanged: (v) {
                  setState(() { _selectedProgramId = v as int?; _currentPage = 1; });
                  _loadData();
                },
              ),
              FilterDropdown(
                label: 'Niveau', value: _selectedLevelId,
                options: _buildLevelOptions(),
                onChanged: (v) {
                  setState(() { _selectedLevelId = v as int?; _currentPage = 1; });
                  _loadData();
                },
              ),
              FilterDropdown(
                label: 'Année', value: _selectedAcademicYear,
                options: _buildYearOptions(),
                onChanged: (v) {
                  setState(() { _selectedAcademicYear = v as String?; _currentPage = 1; });
                  _loadData();
                },
              ),
            ],
          ),
          if (_viewMode == 'results')
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
                    setState(() { _selectedSemester = v as String?; _currentPage = 1; });
                    _loadData();
                  },
                ),
                FilterDropdown(
                  label: 'Statut', value: _selectedDecision,
                  options: [
                    const FilterOption(value: null, label: 'Tous'),
                    const FilterOption(value: 'validated', label: 'Validée'),
                    const FilterOption(value: 'retake', label: 'Rattrapage'),
                    const FilterOption(value: 'failed', label: 'Non validée'),
                  ],
                  onChanged: (v) {
                    setState(() { _selectedDecision = v as String?; _currentPage = 1; });
                    _loadData();
                  },
                ),
              ],
            ),
          if (_viewMode == 'levels')
            FilterBar(
              dropdowns: [
                FilterDropdown(
                  label: 'Décision', value: _selectedDecision,
                  options: [
                    const FilterOption(value: null, label: 'Tous'),
                    const FilterOption(value: 'admis', label: 'Admis'),
                    const FilterOption(value: 'rattrapage', label: 'Rattrapage'),
                    const FilterOption(value: 'ajourne', label: 'Ajourné'),
                  ],
                  onChanged: (v) {
                    setState(() { _selectedDecision = v as String?; _currentPage = 1; });
                    _loadData();
                  },
                ),
              ],
            ),
          Expanded(
            child: _buildBody(theme, state, items),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, dynamic state, List<dynamic> items) {
    if (state.isLoading && items.isEmpty) {
      return const LoadingWidget(message: 'Chargement des résultats...');
    }
    if (state.error != null && items.isEmpty) {
      return AppErrorWidget(message: state.error, onRetry: _loadData);
    }
    if (items.isEmpty) {
      return const EmptyState(title: 'Aucun résultat');
    }

    final total = state.total;
    final currentPage = state.currentPage;
    final lastPage = state.lastPage;

    DataTableWidget(
      columns: _viewMode == 'results' ? _resultColumns(theme) : _levelColumns(theme),
      rows: _viewMode == 'results'
          ? _buildResultRows(theme, state.results as List<ResultModel>)
          : _buildLevelRows(theme, state.results as List<LevelResultModel>),
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      searchQuery: _searchQuery,
      onSearch: (v) {
        _searchQuery = v;
        _currentPage = 1;
        _loadData();
      },
      onPageChanged: (p) {
        _currentPage = p;
        _loadData();
      },
      items: items,
      cardBuilder: (item) => _viewMode == 'results'
          ? _buildResultCard(theme, item as ResultModel)
          : _buildLevelCard(theme, item as LevelResultModel),
    );

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return ListView(
              padding: const EdgeInsets.all(12),
              children: _viewMode == 'results'
                  ? (state.results as List<ResultModel>).map((r) => _buildResultCard(theme, r)).toList()
                  : (state.results as List<LevelResultModel>).map((r) => _buildLevelCard(theme, r)).toList(),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryCard(theme, state),
                const SizedBox(height: 16),
                DataTable(
                  headingRowHeight: 48,
                  dataRowMinHeight: 44,
                  dataRowMaxHeight: 60,
                  columnSpacing: 24,
                  columns: _viewMode == 'results' ? _resultColumns(theme) : _levelColumns(theme),
                  rows: _viewMode == 'results'
                      ? _buildResultRows(theme, state.results as List<ResultModel>)
                      : _buildLevelRows(theme, state.results as List<LevelResultModel>),
                ),
                if (lastPage > 1) _buildPagination(currentPage, lastPage, total),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, dynamic state) {
    final items = _viewMode == 'results'
        ? (state.results as List<ResultModel>)
        : (state.results as List<LevelResultModel>);

    final total = items.length;
    int successCount;
    if (_viewMode == 'results') {
      successCount = (items as List<ResultModel>).where((r) => r.isPassed).length;
    } else {
      successCount = (items as List<LevelResultModel>).where((r) => r.isAdmis).length;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$total résultat(s)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('$successCount validé(s)',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
              ],
            ),
            const Spacer(),
            _buildStatusChip(
              successCount == total ? '100% succès' : '${(successCount / total * 100).round()}% succès',
              successCount == total ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme, ResultModel result) {
    final color = result.isPassed
        ? const Color(0xFF10B981)
        : result.isRetake
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showResultDetail(result),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withAlpha(25), color.withAlpha(10)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(result.average.toStringAsFixed(1),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.studentName ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(result.subjectName ?? '', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: [
                        _buildSmallChip(result.decisionLabel, color),
                        if (result.isPublished) _buildSmallChip('Publié', const Color(0xFF3B82F6)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(ThemeData theme, LevelResultModel result) {
    final color = result.isAdmis
        ? const Color(0xFF10B981)
        : result.isRattrapage
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLevelResultDetail(result),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withAlpha(25), color.withAlpha(10)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(result.averageGrade.toStringAsFixed(1),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.studentName ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('${result.levelName ?? ''} · ${result.academicYear ?? ''}',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: [
                        _buildSmallChip(result.decisionLabel, color),
                        if (result.isPublished) _buildSmallChip('Publié', const Color(0xFF3B82F6)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  List<DataColumn> _resultColumns(ThemeData theme) => [
    DataColumn(label: Text('Étudiant', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
    DataColumn(label: Text('Matière', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
    DataColumn(label: Text('Note', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)), numeric: true),
    DataColumn(label: Text('Mention', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
    DataColumn(label: Text('Crédits', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)), numeric: true),
    DataColumn(label: Text('Statut', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
  ];

  List<DataColumn> _levelColumns(ThemeData theme) => [
    DataColumn(label: Text('Étudiant', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
    DataColumn(label: Text('Niveau', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
    DataColumn(label: Text('Moyenne', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)), numeric: true),
    DataColumn(label: Text('Crédits', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)), numeric: true),
    DataColumn(label: Text('Mention', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
    DataColumn(label: Text('Décision', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
  ];

  List<DataRow> _buildResultRows(ThemeData theme, List<ResultModel> results) {
    return results.map((r) {
      final color = r.isPassed
          ? const Color(0xFF10B981)
          : r.isRetake
              ? const Color(0xFFF59E0B)
              : const Color(0xFFEF4444);
      return DataRow(
        onSelectChanged: (_) => _showResultDetail(r),
        cells: [
          DataCell(Text(r.studentName ?? '', style: const TextStyle(fontSize: 13))),
          DataCell(Text(r.subjectName ?? '', style: const TextStyle(fontSize: 13))),
          DataCell(Text(r.average.toStringAsFixed(1), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color))),
          DataCell(Text(r.mentionLabel, style: const TextStyle(fontSize: 13))),
          DataCell(Text('${r.earnedCredits?.toInt() ?? 0}/${r.totalCredits?.toInt() ?? 0}', style: const TextStyle(fontSize: 13))),
          DataCell(_buildStatusChip(r.decisionLabel, color)),
        ],
      );
    }).toList();
  }

  List<DataRow> _buildLevelRows(ThemeData theme, List<LevelResultModel> results) {
    return results.map((r) {
      final color = r.isAdmis
          ? const Color(0xFF10B981)
          : r.isRattrapage
              ? const Color(0xFFF59E0B)
              : const Color(0xFFEF4444);
      return DataRow(
        onSelectChanged: (_) => _showLevelResultDetail(r),
        cells: [
          DataCell(Text(r.studentName ?? '', style: const TextStyle(fontSize: 13))),
          DataCell(Text(r.levelName ?? '', style: const TextStyle(fontSize: 13))),
          DataCell(Text(r.averageGrade.toStringAsFixed(1), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color))),
          DataCell(Text('${r.totalCreditsObtained}/${r.totalCreditsRequired}', style: const TextStyle(fontSize: 13))),
          DataCell(Text(r.mentionLabel, style: const TextStyle(fontSize: 13))),
          DataCell(_buildStatusChip(r.decisionLabel, color)),
        ],
      );
    }).toList();
  }

  Widget _buildPagination(int currentPage, int lastPage, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$total résultat(s) · Page $currentPage/$lastPage',
            style: TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: currentPage > 1 ? () { _currentPage--; _loadData(); } : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: currentPage < lastPage ? () { _currentPage++; _loadData(); } : null,
          ),
        ],
      ),
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

  Widget _buildSmallChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(40), width: 0.5),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  List<FilterOption> _buildDepartmentOptions() {
    final depts = ref.watch(departmentProvider);
    return [
      const FilterOption(value: null, label: 'Tous'),
      ...depts.departments.map((d) => FilterOption(value: d.id, label: d.name)),
    ];
  }

  List<FilterOption> _buildProgramOptions() {
    final progs = ref.watch(programProvider);
    return [
      const FilterOption(value: null, label: 'Tous'),
      ...progs.programs.map((p) => FilterOption(value: p.id, label: p.name)),
    ];
  }

  List<FilterOption> _buildLevelOptions() {
    final levelsAsync = ref.watch(allLevelsProvider);
    final levels = levelsAsync.valueOrNull ?? [];
    return [
      const FilterOption(value: null, label: 'Tous'),
      ...levels.map((l) => FilterOption(value: l.id, label: l.name)),
    ];
  }

  List<FilterOption> _buildYearOptions() {
    final years = <String>['2023/2024', '2024/2025', '2025/2026', '2026/2027'];
    return [
      const FilterOption(value: null, label: 'Tous'),
      ...years.map((y) => FilterOption(value: y, label: y)),
    ];
  }

  void _showResultDetail(ResultModel result) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultDetailScreen(result: result),
      ),
    );
  }

  void _showLevelResultDetail(LevelResultModel result) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LevelResultDetailScreen(result: result),
      ),
    );
  }

  Future<void> _exportResults() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export PDF et Excel disponibles')),
    );
  }
}

class ResultDetailScreen extends ConsumerStatefulWidget {
  final ResultModel result;
  final int? studentId;
  final String? studentName;

  const ResultDetailScreen({super.key, required this.result, this.studentId, this.studentName});

  @override
  ConsumerState<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends ConsumerState<ResultDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = widget.result;
    final color = r.isPassed ? const Color(0xFF10B981) : r.isRetake ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);

    return Scaffold(
      appBar: AppBar(title: Text('Détail du résultat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [color.withAlpha(30), color.withAlpha(10)],
                        ),
                        border: Border.all(color: color.withAlpha(60), width: 2),
                      ),
                      child: Center(
                        child: Text(r.average.toStringAsFixed(1),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withAlpha(15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(r.decisionLabel, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _infoRow(theme, 'Étudiant', r.studentName ?? ''),
                    _infoRow(theme, 'Matricule', r.studentNumber ?? ''),
                    _infoRow(theme, 'Matière', r.subjectName ?? ''),
                    _infoRow(theme, 'Enseignant', r.teacherName ?? 'Non assigné'),
                    _infoRow(theme, 'Semestre', r.semester ?? ''),
                    _infoRow(theme, 'Année', r.academicYear ?? ''),
                    _infoRow(theme, 'Coefficient', r.coefficient?.toStringAsFixed(1) ?? '-'),
                    _infoRow(theme, 'Crédits', '${r.earnedCredits?.toInt() ?? 0}/${r.totalCredits?.toInt() ?? 0}'),
                    _infoRow(theme, 'Mention', r.mentionLabel),
                    _infoRow(theme, 'Statut', r.decisionLabel),
                    if (r.publishedAt != null)
                      _infoRow(theme, 'Publié le', '${r.publishedAt!.day}/${r.publishedAt!.month}/${r.publishedAt!.year}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}

class LevelResultDetailScreen extends ConsumerStatefulWidget {
  final LevelResultModel result;

  const LevelResultDetailScreen({super.key, required this.result});

  @override
  ConsumerState<LevelResultDetailScreen> createState() => _LevelResultDetailScreenState();
}

class _LevelResultDetailScreenState extends ConsumerState<LevelResultDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = widget.result;
    final color = r.isAdmis ? const Color(0xFF10B981) : r.isRattrapage ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);

    return Scaffold(
      appBar: AppBar(title: Text('Résultat niveau')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [color.withAlpha(30), color.withAlpha(10)]),
                        border: Border.all(color: color.withAlpha(60), width: 2),
                      ),
                      child: Center(
                        child: Text(r.averageGrade.toStringAsFixed(1),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(r.decisionLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                    const SizedBox(height: 4),
                    Text(r.mentionLabel, style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Récapitulatif', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _infoRow(theme, 'Étudiant', r.studentName ?? ''),
                    _infoRow(theme, 'Matricule', r.studentNumber ?? ''),
                    _infoRow(theme, 'Niveau', r.levelName ?? ''),
                    _infoRow(theme, 'Filière', r.programName ?? ''),
                    _infoRow(theme, 'Année académique', r.academicYear ?? ''),
                    const Divider(height: 24),
                    _infoRow(theme, 'Total des points', r.totalPoints.toStringAsFixed(1)),
                    _infoRow(theme, 'Total des coefficients', r.totalCoefficients.toStringAsFixed(1)),
                    _infoRow(theme, 'Moyenne générale', r.averageGrade.toStringAsFixed(2)),
                    const Divider(height: 24),
                    _infoRow(theme, 'Crédits obtenus', '${r.totalCreditsObtained}'),
                    _infoRow(theme, 'Crédits requis', '${r.totalCreditsRequired}'),
                    _infoRow(theme, 'Mention', r.mentionLabel),
                    _infoRow(theme, 'Décision', r.decisionLabel),
                    if (r.publishedAt != null)
                      _infoRow(theme, 'Publié le', '${r.publishedAt!.day}/${r.publishedAt!.month}/${r.publishedAt!.year}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}
