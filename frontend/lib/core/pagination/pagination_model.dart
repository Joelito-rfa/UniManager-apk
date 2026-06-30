class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    required this.hasMore,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final data = json['data'];
    List<dynamic> itemsData;
    Map<String, dynamic>? meta;

    if (data is Map<String, dynamic> && data['data'] is List) {
      itemsData = data['data'] as List<dynamic>;
      meta = data['meta'] as Map<String, dynamic>?;
    } else if (data is List) {
      itemsData = data;
    } else {
      itemsData = [];
    }

    meta ??= json;

    return PaginatedResponse(
      items: itemsData.map((e) => fromJsonT(e)).toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? itemsData.length,
      perPage: meta['per_page'] as int? ?? itemsData.length,
      hasMore: (meta['current_page'] as int? ?? 1) < (meta['last_page'] as int? ?? 1),
    );
  }
}

class PaginationParams {
  final int page;
  final int perPage;
  final Map<String, dynamic>? filters;

  PaginationParams({
    this.page = 1,
    this.perPage = 20,
    this.filters,
  });

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': perPage,
      if (filters != null) ...filters!,
    };
  }

  PaginationParams copyWith({
    int? page,
    int? perPage,
    Map<String, dynamic>? filters,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      filters: filters ?? this.filters,
    );
  }

  PaginationParams nextPage() {
    return copyWith(page: page + 1);
  }
}
