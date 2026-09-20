import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/core/utils/pagination.dart';

abstract class PaginationState<T> extends Equatable {
  const PaginationState();

  @override
  List<Object?> get props => [];
}

class PaginationInitial<T> extends PaginationState<T> {}

class PaginationLoading<T> extends PaginationState<T> {}

class PaginationLoaded<T> extends PaginationState<T> {
  final List<T> data;
  final bool hasReachedMax;
  final int currentPage;

  const PaginationLoaded({
    required this.data,
    required this.hasReachedMax,
    required this.currentPage,
  });

  PaginationLoaded<T> copyWith({
    List<T>? data,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return PaginationLoaded<T>(
      data: data ?? this.data,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [data, hasReachedMax, currentPage];
}

class PaginationLoadingMore<T> extends PaginationLoaded<T> {
  const PaginationLoadingMore({
    required super.data,
    required super.hasReachedMax,
    required super.currentPage,
  });
}

class PaginationFailure<T> extends PaginationState<T> {
  final String message;

  const PaginationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

typedef FetchPage<T> =
    Future<PaginatedResponse<T>> Function(
      PaginationParams params,
    );

class PaginationCubit<T> extends Cubit<PaginationState<T>> {
  final FetchPage<T> fetchPage;

  PaginationCubit(this.fetchPage) : super(PaginationInitial<T>());

  PaginationParams _params = const PaginationParams();

  /// Initial fetch
  Future<void> fetchInitial() async {
    try {
      emit(PaginationLoading<T>());

      _params = const PaginationParams();

      final response = await fetchPage(_params);

      emit(
        PaginationLoaded<T>(
          data: response.data,
          currentPage: response.meta.currentPage,
          hasReachedMax: !response.hasNextPage,
        ),
      );
    } catch (e) {
      emit(PaginationFailure<T>(e.toString()));
    }
  }

  /// Load more
  Future<void> loadMore() async {
    if (state is! PaginationLoaded<T>) return;

    final currentState = state as PaginationLoaded<T>;

    if (currentState.hasReachedMax) return;

    try {
      emit(
        PaginationLoadingMore<T>(
          data: currentState.data,
          currentPage: currentState.currentPage,
          hasReachedMax: currentState.hasReachedMax,
        ),
      );

      _params = _params.nextPage();

      final response = await fetchPage(_params);

      emit(
        PaginationLoaded<T>(
          data: [...currentState.data, ...response.data],
          currentPage: response.meta.currentPage,
          hasReachedMax: !response.hasNextPage,
        ),
      );
    } catch (e) {
      emit(PaginationFailure<T>(e.toString()));
    }
  }

  /// Refresh
  Future<void> refresh() async {
    await fetchInitial();
  }
}

// Usage

// class PostsScreen extends StatefulWidget {
//   const PostsScreen({super.key});

//   @override
//   State<PostsScreen> createState() => _PostsScreenState();
// }

// class _PostsScreenState extends State<PostsScreen> with ScrollMixin {
//   late final PaginationCubit<PostModel> _cubit;

//   @override
//   void initState() {
//     super.initState();
//     _cubit = PaginationCubit<PostModel>(
//       (params) => sl<PostsRepository>().fetchPosts(params),
//     )..fetchInitial();
//     scrollController.addListener(_onScroll);
//   }

//   void _onScroll() {
//     if (scrollController.position.pixels >=
//         scrollController.position.maxScrollExtent - 300) {
//       _cubit.loadMore();
//     }
//   }

//   @override
//   void dispose() {
//     _cubit.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return BlocProvider.value(
//       value: _cubit,
//       child: Scaffold(
//         backgroundColor: colorScheme.surfaceContainerLowest,
//         appBar: AppBar(
//           title: const Text('Posts'),
//           centerTitle: true,
//           elevation: 0,
//           backgroundColor: colorScheme.surface,
//           actions: [
//             BlocBuilder<PaginationCubit<PostModel>, PaginationState<PostModel>>(
//               builder: (context, state) {
//                 if (state is PaginationLoaded<PostModel>) {
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 16),
//                     child: Center(
//                       child: Text(
//                         '${state.data.length} / ${state.data.length + (state.hasReachedMax ? 0 : 1)} posts',
//                         style: theme.textTheme.labelMedium?.copyWith(
//                           color: colorScheme.primary,
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ],
//         ),
//         body: BlocBuilder<PaginationCubit<PostModel>, PaginationState<PostModel>>(
//           builder: (context, state) {
//             // ── Initial loading ─────────────────────────────────────────────
//             if (state is PaginationLoading<PostModel>) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             // ── Error ────────────────────────────────────────────────────────
//             if (state is PaginationFailure<PostModel>) {
//               return Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.error_outline_rounded,
//                       size: 56,
//                       color: colorScheme.error,
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       'Something went wrong',
//                       style: theme.textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       state.message,
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: colorScheme.onSurfaceVariant,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 20),
//                     FilledButton.icon(
//                       onPressed: () => _cubit.fetchInitial(),
//                       icon: const Icon(Icons.refresh),
//                       label: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             // ── Data loaded ───────────────────────────────────────────────────
//             if (state is PaginationLoaded<PostModel>) {
//               final posts = state.data;
//               final isLoadingMore = state is PaginationLoadingMore<PostModel>;

//               return RefreshIndicator(
//                 onRefresh: () => _cubit.refresh(),
//                 child: ListView.builder(
//                   controller: scrollController,
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   itemCount: posts.length + (isLoadingMore ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     if (index < posts.length) {
//                       return PostCard(
//                         post: posts[index],
//                         index: index + 1,
//                       );
//                     }
//                     // ── Loading-more indicator ────────────────────────────────
//                     return const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 24),
//                       child: Center(child: CircularProgressIndicator()),
//                     );
//                   },
//                 ),
//               );
//             }

//             return const SizedBox.shrink();
//           },
//         ),
//         floatingActionButton: BlocBuilder<PaginationCubit<PostModel>,
//             PaginationState<PostModel>>(
//           builder: (context, state) {
//             if (state is PaginationLoaded<PostModel>) {
//               return FloatingActionButton.small(
//                 heroTag: 'scroll_top',
//                 onPressed: scrollToTop,
//                 tooltip: 'Back to top',
//                 child: const Icon(Icons.keyboard_arrow_up_rounded),
//               );
//             }
//             return const SizedBox.shrink();
//           },
//         ),
//       ),
//     );
//   }
// }

/// Hits the real JSONPlaceholder REST API for posts with pagination.
///
/// JSONPlaceholder supports `_page` and `_limit` query params and returns
/// `X-Total-Count` in the response headers.
// class PostsApiService {
//   PostsApiService(this._dio);

//   static const _baseUrl = 'https://jsonplaceholder.typicode.com';

//   final Dio _dio;

//   Future<({List<PostModel> posts, int total})> getPosts({
//     required int page,
//     int perPage = 10,
//   }) async {
//     final response = await _dio.get<List<dynamic>>(
//       '$_baseUrl/posts',
//       queryParameters: {
//         '_page': page,
//         '_limit': perPage,
//       },
//     );

//     final total =
//         int.tryParse(response.headers.value('X-Total-Count') ?? '100') ?? 100;

//     final posts = (response.data as List<dynamic>)
//         .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
//         .toList();

//     return (posts: posts, total: total);
//   }
// }

/// Repository that converts [PostsApiService] responses into
/// [PaginatedResponse]<[PostModel]> for the [PaginationCubit].
// class PostsRepository {
//   PostsRepository(this._apiService);

//   final PostsApiService _apiService;

//   Future<PaginatedResponse<PostModel>> fetchPosts(
//     PaginationParams params,
//   ) async {
//     final result = await _apiService.getPosts(
//       page: params.page,
//       perPage: params.perPage,
//     );

//     final lastPage = (result.total / params.perPage).ceil().clamp(1, 9999);

//     return PaginatedResponse<PostModel>(
//       data: result.posts,
//       meta: PaginationMeta(
//         currentPage: params.page,
//         perPage: params.perPage,
//         total: result.total,
//         lastPage: lastPage,
//       ),
//     );
//   }
// }
