import 'package:equatable/equatable.dart';

/// Generic wrapper for paginated API responses.
///
/// Usage in a repository:
/// ```dart
/// final page = PaginatedResponse<ProductModel>.fromJson(
///   json,
///   (item) => ProductModel.fromJson(item),
/// );
/// ```
class PaginatedResponse<T> extends Equatable {
  const PaginatedResponse({
    required this.data,
    required this.meta,
  });

  /// The list of items for the current page.
  final List<T> data;

  /// Pagination metadata.
  final PaginationMeta meta;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  bool get hasNextPage => meta.currentPage < meta.lastPage;
  bool get isFirstPage => meta.currentPage == 1;

  @override
  List<Object?> get props => [data, meta];
}

/// Metadata returned alongside a paginated list.
class PaginationMeta extends Equatable {
  const PaginationMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'per_page': perPage,
    'total': total,
    'last_page': lastPage,
  };

  @override
  List<Object?> get props => [currentPage, perPage, total, lastPage];
}

/// Query parameters for paginated requests.
class PaginationParams extends Equatable {
  const PaginationParams({
    this.page = 1,
    this.perPage = 20,
    this.search,
    this.sortBy,
    this.sortOrder = SortOrder.desc,
  });

  final int page;
  final int perPage;
  final String? search;
  final String? sortBy;
  final SortOrder sortOrder;

  Map<String, dynamic> toQueryParams() => {
    'page': page,
    'per_page': perPage,
    if (search != null && search!.isNotEmpty) 'search': search,
    if (sortBy != null) 'sort_by': sortBy,
    'sort_order': sortOrder.value,
  };

  PaginationParams nextPage() => PaginationParams(
    page: page + 1,
    perPage: perPage,
    search: search,
    sortBy: sortBy,
    sortOrder: sortOrder,
  );

  @override
  List<Object?> get props => [page, perPage, search, sortBy, sortOrder];
}

enum SortOrder {
  asc('asc'),
  desc('desc');

  const SortOrder(this.value);
  final String value;
}
