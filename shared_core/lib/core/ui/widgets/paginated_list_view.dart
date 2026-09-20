import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/pagination_cubit.dart';
import '../../../common/mixins/form_mixin.dart';
import 'shimmer_loader.dart';
import 'empty_view.dart';

/// A generic wrapper around a RefreshIndicator and ListView.builder
/// automatically connected to a PaginationCubit to handle mapping
/// the loaded, loading, and failure states natively.
class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.cubit,
    required this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.shimmerItemCount = 6,
    this.shimmerItemHeight = 80,
    this.separatorBuilder,
    this.emptyTitle = 'No Result Found',
    this.emptySubtitle = 'Try pulling to refresh.',
  });

  final PaginationCubit<T> cubit;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final int shimmerItemCount;
  final double shimmerItemHeight;
  final EdgeInsetsGeometry padding;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> with ScrollMixin {
  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // If we're near the bottom, load more
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      widget.cubit.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaginationCubit<T>, PaginationState<T>>(
      bloc: widget.cubit,
      builder: (context, state) {
        // 1. Initial Loading
        if (state is PaginationLoading<T> || state is PaginationInitial<T>) {
          return ShimmerListLoader(
            itemCount: widget.shimmerItemCount,
            itemHeight: widget.shimmerItemHeight,
          );
        }

        // 2. Failure Handling
        if (state is PaginationFailure<T>) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => widget.cubit.fetchInitial(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // 3. Loaded / Empty / Loading More
        if (state is PaginationLoaded<T>) {
          final items = state.data;
          final isLoadingMore = state is PaginationLoadingMore<T>;

          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => widget.cubit.refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: EmptyView(
                    message: widget.emptyTitle,
                    // description: widget.emptySubtitle,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => widget.cubit.refresh(),
            child: ListView.separated(
              controller: scrollController,
              padding: widget.padding,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length + (isLoadingMore ? 1 : 0),
              separatorBuilder:
                  widget.separatorBuilder ?? (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index < items.length) {
                  return widget.itemBuilder(context, items[index], index);
                }
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DEMONSTRATION & USE CASE (AS REQUESTED)
// ─────────────────────────────────────────────────────────────────────────────
/*

import 'package:dio/dio.dart';
import '../../core/utils/pagination.dart';
import '../../core/utils/general_imports.dart';

/// 1. Data Model
class PostModel {
  const PostModel({required this.id, required this.title, required this.body});
  final int id;
  final String title;
  final String body;

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

/// 2. Api Service hitting JSONPlaceholder directly with a new Dio client
class DemoPostsApiService {
  Future<({List<PostModel> posts, int total})> getPosts({required int page, int limit = 10}) async {
    final dio = Dio();
    final response = await dio.get<List<dynamic>>(
      'https://jsonplaceholder.typicode.com/posts',
      queryParameters: {'_page': page, '_limit': limit},
    );
    final total = int.tryParse(response.headers.value('X-Total-Count') ?? '100') ?? 100;
    final posts = (response.data as List<dynamic>).map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
    return (posts: posts, total: total);
  }
}

/// 3. The UI (Simplified vastly using PaginatedListView)
class DemoPostsScreen extends StatefulWidget {
  @override
  State<DemoPostsScreen> createState() => _DemoPostsScreenState();
}

class _DemoPostsScreenState extends State<DemoPostsScreen> {
  late final PaginationCubit<PostModel> _cubit;

  @override
  void initState() {
    super.initState();
    final apiService = DemoPostsApiService();
    
    _cubit = PaginationCubit<PostModel>((params) async {
      // Simulate slow network to see the gorgeous ShimmerListLoader
      await Future.delayed(const Duration(milliseconds: 800));
      
      final result = await apiService.getPosts(page: params.page, limit: params.perPage);
      final lastPage = (result.total / params.perPage).ceil().clamp(1, 9999);
      
      return PaginatedResponse<PostModel>(
        data: result.posts,
        meta: PaginationMeta(
          currentPage: params.page, 
          perPage: params.perPage, 
          total: result.total, 
          lastPage: lastPage
        ),
      );
    })..fetchInitial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paginated Posts List')),
      body: PaginatedListView<PostModel>(
        cubit: _cubit,
        itemBuilder: (context, post, index) {
          return ListTile(
            leading: CircleAvatar(child: Text('${post.id}')),
            title: Text(post.title, maxLines: 1),
            subtitle: Text(post.body, maxLines: 2),
          );
        },
      ),
    );
  }
}
*/
