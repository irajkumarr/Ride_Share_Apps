import 'package:flutter/material.dart';
import 'custom_loader.dart';
import 'empty_view.dart';
import 'no_internet_screen.dart';

/// A flexible wrapper that works with Dart states instead of enums.
class AppStateWrapper<T> extends StatelessWidget {
  final T state;

  /// Builders
  final Widget Function()? onLoading;
  final Widget Function(String message)? onError;
  final Widget Function()? onEmpty;
  final Widget Function()? onNoInternet;

  /// Default (success UI)
  final Widget child;

  /// Extract message from state (optional)
  final String? Function(T state)? errorMessage;

  /// State matchers (VERY IMPORTANT)
  final bool Function(T state) isLoading;
  final bool Function(T state) isError;
  final bool Function(T state) isEmpty;
  final bool Function(T state) isNoInternet;

  /// Retry callback
  final VoidCallback? onRetry;

  const AppStateWrapper({
    super.key,
    required this.state,
    required this.child,

    required this.isLoading,
    required this.isError,
    required this.isEmpty,
    required this.isNoInternet,

    this.onLoading,
    this.onError,
    this.onEmpty,
    this.onNoInternet,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    if (isLoading(state)) {
      return onLoading?.call() ?? const Center(child: CustomLoader());
    }

    if (isError(state)) {
      final message = errorMessage?.call(state);

      return onError?.call(message ?? '') ??
          Center(
            child: EmptyView(
              message: message ?? 'Something went wrong',
              onRetry: onRetry,
            ),
          );
    }

    if (isEmpty(state)) {
      return onEmpty?.call() ??
          Center(
            child: EmptyView(
              message: 'No data found',
              onRetry: onRetry,
            ),
          );
    }

    if (isNoInternet(state)) {
      return onNoInternet?.call() ?? const NoInternetScreen();
    }

    return child;
  }
}

//Usage

// BlocBuilder<FoodCubit, FoodState>(
//   builder: (context, state) {
//     return AppStateWrapper<FoodState>(
//       state: state,

//       /// 🔥 State matchers
//       isLoading: (s) => s is FoodLoading,
//       isError: (s) => s is FoodError,
//       isEmpty: (s) => s is FoodEmpty,
//       isNoInternet: (s) => false,

//       /// 🔥 Extract message
//       errorMessage: (s) =>
//           s is FoodError ? s.message : null,

//       /// Retry
//       onRetry: () =>
//           context.read<FoodCubit>().fetchFoods(),

//       /// Success UI
//       child: state is FoodLoaded
//           ? ListView.builder(
//               itemCount: state.foods.length,
//               itemBuilder: (_, i) =>
//                   Text(state.foods[i].title),
//             )
//           : const SizedBox(),
//     );
//   },
// )

// abstract class FoodState {}

// class FoodLoading extends FoodState {}
// class FoodLoaded extends FoodState {
//   final List foods;
//   FoodLoaded(this.foods);
// }
// class FoodEmpty extends FoodState {}
// class FoodError extends FoodState {
//   final String message;
//   FoodError(this.message);
// }
