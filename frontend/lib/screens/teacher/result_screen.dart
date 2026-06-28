import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../models/result_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/filter_bar.dart';

class TeacherResultScreen extends ConsumerStatefulWidget {
  const TeacherResultScreen({super.key});

  @override
  ConsumerState<TeacherResultScreen> createState() => _TeacherResultScreenState();
}

class _TeacherResultScreenState extends ConsumerState<TeacherResultScreen> {
  List<ResultModel> _results = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int? _selectedCourseId;
  String? _selectedSemester;
  String? _selectedAcademicYear;
  int _currentPage = 1;
  int _lastPage = 1;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioClientProvider);
      final params = <String, dynamic>{
        'page': _currentPage,
        'per_page': 10,
      };
      if (_searchQuery.isNotEmpty) params['search'] = _searchQuery;
      if (_selectedCourseId != null) params['course_id'] = _selectedCourseId;
      if (_selectedSemester != null) params['semester'] = _selectedSemester;
      if (_selectedAcademicYear != null) params['academic_year'] = _selectedAcademicYear;
      final response = await dio.get('/teacher/results', queryParameters: params);
      if (response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>?;
        final meta = response.data['meta'] as Map<String, dynamic>?;
        _results = (data ?? []).map((e) => ResultModel.fromJson(e)).toList();
        if (meta != null) {
          _currentPage = meta['current_page'] as int? ?? 1;
          _lastPage = meta['last_page'] as int? ?? 1;
        }
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Résultats')),
      body: Column(
        children: [
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
                  setState(() { _selectedAcademicYear = v as String?; _currentPage = 1; });
                  _loadResults();
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Rechercher un étudiant...',
                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (v) {
                _searchQuery = v;
                _currentPage = 1;
                _loadResults();
              },
            ),
          ),
          Expanded(child: _buildBody(theme)),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading && _results.isEmpty) return const LoadingWidget(message: 'Chargement des résultats...');
    if (_error != null && _results.isEmpty) return AppErrorWidget(message: _error!, onRetry: _loadResults);
    if (_results.isEmpty) return const EmptyState(title: 'Aucun résultat');

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
                  Text('${_results.length} résultat(s)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text('$passed validé(s)', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                  const Spacer(),
                  if (_lastPage > 1)
                    Text('Page $_currentPage/$_lastPage', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ..._results.map((r) {
            final color = r.isPassed ? const Color(0xFF10B981) : r.isRetake ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
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
                          Text(r.studentName ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          Text(r.subjectName ?? '', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(r.decisionLabel, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_lastPage > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: _currentPage > 1 ? () { _currentPage--; _loadResults(); } : null,
                  ),
                  Text('$_currentPage / $_lastPage'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: _currentPage < _lastPage ? () { _currentPage++; _loadResults(); } : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
