import 'package:flutter/material.dart';


import 'package:pull_to_refresh/pull_to_refresh.dart' hide RefreshIndicator;
import 'package:shared_core/core/utils/colors.dart';

class CustomRefreshIndicator extends StatelessWidget {
  const CustomRefreshIndicator({
    required this.onRefreshCallback,
    required this.child,
    required this.displacment,
     super.key,
  });
  final Widget child;
  final Function onRefreshCallback;
  final double displacment;

  @override
  Widget build( BuildContext context) => RefreshIndicator(
    displacement: displacment,
    color: AppColor.secondary,
    onRefresh: () async {
      onRefreshCallback();
    },
    child: child,
  );
}

/// A reusable pull-to-refresh widget using WaterDropHeader style.
///
/// 🔥 Features:
/// - Clean reusable wrapper
/// - Supports refresh + load more (optional)
/// - Works with ListView, GridView, etc.
/// - Easily integrates with Cubit
class CustomPullToRefresh extends StatefulWidget {
  /// Main scrollable content (ListView, GridView, etc.)
  final Widget child;

  /// Callback when user pulls down to refresh
  final Future<void> Function() onRefresh;

  /// Optional: Load more callback (pagination)
  final Future<void> Function()? onLoadMore;

  /// Enable/disable load more
  final bool enableLoadMore;

  /// Optional controller (if you want external control)
  final RefreshController? controller;

  const CustomPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.onLoadMore,
    this.enableLoadMore = false,
    this.controller,
  });

  @override
  State<CustomPullToRefresh> createState() => _CustomPullToRefreshState();
}

class _CustomPullToRefreshState extends State<CustomPullToRefresh> {
  late final RefreshController _controller;

  @override
  void initState() {
    super.initState();

    /// If external controller is provided use it
    /// otherwise create internal one
    _controller = widget.controller ?? RefreshController();
  }

  /// Handle pull-down refresh
  Future<void> _handleRefresh() async {
    try {
      await widget.onRefresh();

      /// Notify success
      _controller.refreshCompleted();
    } catch (e) {
      /// Notify failure
      _controller.refreshFailed();
    }
  }

  /// Handle load more (pagination)
  Future<void> _handleLoadMore() async {
    if (widget.onLoadMore == null) return;

    try {
      await widget.onLoadMore!();

      /// Notify success
      _controller.loadComplete();
    } catch (e) {
      _controller.loadFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _controller,

      /// Enable pull-down
      enablePullDown: true,

      /// Enable load more if required
      enablePullUp: widget.enableLoadMore,

      ///  WaterDrop Header (clean modern animation)
      header: const WaterDropHeader(
        waterDropColor: AppColor.secondary,

        ///  Remove "Refresh completed" text + icon
        complete: SizedBox.shrink(),

        ///  Remove "Refresh failed" text
        failed: SizedBox.shrink(),
      ),

      /// Optional footer for load more
      footer: const ClassicFooter(),

      onRefresh: _handleRefresh,
      onLoading: _handleLoadMore,

      child: widget.child,
    );
  }
}

// Usage:

// BlocBuilder<FoodCubit, FoodState>(
//   builder: (context, state) {
//     return CustomPullToRefresh(
//       /// 🔥 Pull to refresh
//       onRefresh: () async {
//         context.read<FoodCubit>().fetchFoods();
//       },

//       /// Optional pagination
//       onLoadMore: () async {
//         context.read<FoodCubit>().loadMoreFoods();
//       },

//       enableLoadMore: true,

//       /// Your content
//       child: ListView.builder(
//         itemCount: state is FoodLoaded
//             ? state.foods.length
//             : 0,
//         itemBuilder: (_, i) {
//           final food = (state as FoodLoaded).foods[i];
//           return Text(food.title);
//         },
//       ),
//     );
//   },
// )
