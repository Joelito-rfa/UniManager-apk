class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  factory ApiResponse.success(T? data, {String? message}) {
    return ApiResponse(success: true, data: data, message: message);
  }

  factory ApiResponse.error(String message, {List<String>? errors}) {
    return ApiResponse(success: false, message: message, errors: errors);
  }

  factory ApiResponse.fromList(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final dataList = json['data'] as List<dynamic>?;
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: dataList?.map((e) => fromJsonT(e)).toList() as T?,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T)? toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
      'errors': errors,
    };
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasMore => currentPage < lastPage;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    List<dynamic> dataList;

    // Cas 1: { data: [items], current_page: ..., last_page: ..., total: ... }
    // Cas 2: { data: { data: [items], meta: { current_page: ..., last_page: ..., total: ... } } }
    final rawData = json['data'];
    if (rawData is List) {
      dataList = rawData;
    } else if (rawData is Map<String, dynamic> && rawData['data'] is List) {
      dataList = rawData['data'] as List<dynamic>;
    } else {
      dataList = [];
    }

    // Extraire les infos de pagination depuis la racine ou depuis data.meta
    int currentPage, lastPage, total, perPage;
    final rawMeta = json['meta'];
    if (rawMeta is Map<String, dynamic>) {
      currentPage = rawMeta['current_page'] as int? ?? 1;
      lastPage = rawMeta['last_page'] as int? ?? 1;
      total = rawMeta['total'] as int? ?? 0;
      perPage = rawMeta['per_page'] as int? ?? 10;
    } else {
      currentPage = json['current_page'] as int? ?? 1;
      lastPage = json['last_page'] as int? ?? 1;
      total = json['total'] as int? ?? 0;
      perPage = json['per_page'] as int? ?? 10;
    }

    return PaginatedResponse(
      items: dataList.map((e) => fromJsonT(e)).toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      perPage: perPage,
    );
  }
}
