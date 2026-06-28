import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class SearchResultItem {
  final int id;
  final String name;
  final String? code;
  final String? secondary;
  final String type;

  SearchResultItem({
    required this.id,
    required this.name,
    this.code,
    this.secondary,
    required this.type,
  });

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      secondary: json['secondary'] as String?,
      type: json['type'] as String? ?? '',
    );
  }
}

class SearchResults {
  final List<SearchResultItem> students;
  final List<SearchResultItem> teachers;
  final List<SearchResultItem> departments;
  final List<SearchResultItem> programs;
  final List<SearchResultItem> levels;
  final List<SearchResultItem> subjects;
  final List<SearchResultItem> courses;
  final List<SearchResultItem> classrooms;

  SearchResults({
    this.students = const [],
    this.teachers = const [],
    this.departments = const [],
    this.programs = const [],
    this.levels = const [],
    this.subjects = const [],
    this.courses = const [],
    this.classrooms = const [],
  });

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    return SearchResults(
      students: (json['students'] as List?)?.map((e) => SearchResultItem.fromJson(e)).toList() ?? [],
      teachers: (json['teachers'] as List?)?.map((e) => SearchResultItem.fromJson(e)).toList() ?? [],
      departments: (json['departments'] as List?)?.map((e) => SearchResultItem.fromJson(e)).toList() ?? [],
      programs: (json['programs'] as List?)?.map((e) => SearchResultItem.fromJson(e)).toList() ?? [],
      levels: (json['levels'] as List?)?.map((e) => SearchResultItem.fromJson(e)).toList() ?? [],
      subjects: (json['subjects'] as List?)?.map((e) => SearchResultItem.fromJson(e)).toList() ?? [],
      courses: (json['courses'] as List?)?.map((e) => SearchResultItem.fromJson(e)).toList() ?? [],
      classrooms: (json['classrooms'] as List?)?.map((e) => SearchResultItem.fromJson(e)).toList() ?? [],
    );
  }

  bool get isEmpty =>
      students.isEmpty &&
      teachers.isEmpty &&
      departments.isEmpty &&
      programs.isEmpty &&
      levels.isEmpty &&
      subjects.isEmpty &&
      courses.isEmpty &&
      classrooms.isEmpty;

  int get totalCount =>
      students.length +
      teachers.length +
      departments.length +
      programs.length +
      levels.length +
      subjects.length +
      courses.length +
      classrooms.length;
}

class SearchState {
  final String query;
  final SearchResults? results;
  final bool isLoading;
  final String? error;

  SearchState({
    this.query = '',
    this.results,
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    SearchResults? results,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final DioClient _dio;
  Timer? _debounce;

  SearchNotifier(this._dio) : super(SearchState());

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      state = state.copyWith(query: '', results: null, isLoading: false);
      return;
    }
    state = state.copyWith(query: query, isLoading: true);
    _debounce = Timer(const Duration(milliseconds: 300), () => _performSearch(query));
  }

  Future<void> _performSearch(String query) async {
    try {
      final response = await _dio.get(ApiConstants.search, queryParameters: {'q': query});
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      state = state.copyWith(
        results: SearchResults.fromJson(data),
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    _debounce?.cancel();
    state = SearchState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final dio = ref.read(dioClientProvider);
  return SearchNotifier(dio);
});
