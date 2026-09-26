import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider_app/src/modules/auth/blocs/current_user_cubit.dart';
import 'package:rider_app/src/modules/auth/blocs/login_cubit.dart';
import 'package:rider_app/src/modules/auth/blocs/register_cubit.dart';
import 'package:rider_app/src/modules/home/blocs/active_ride_cubit.dart';
import 'package:rider_app/src/modules/home/blocs/ride_search_cubit.dart';
import 'package:rider_app/src/modules/ride_history/blocs/rider_ride_history_cubit.dart';
import 'package:shared_core/shared_core.dart' hide AppRouter;

import 'src/core/routing/app_router.dart';

/// Root widget of the application.
///
/// Responsible for:
/// - Providing all global BLoC instances via [MultiBlocProvider].
/// - Configuring the [MaterialApp.router] with [GoRouter].
/// - Setting up localisation delegates.
/// - Applying the design-system theme.
class App extends StatelessWidget {
  const App({required this.flavor, super.key});

  final AppFlavor flavor;

  @override
  Widget build(BuildContext context) {
    final appRouter = sl<AppRouter>();

    return MaterialApp.router(
      title: _appTitle,
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,

      // ── Router ─────────────────────────────────────────────────────
      routerDelegate: appRouter.router.routerDelegate,
      routeInformationProvider: appRouter.router.routeInformationProvider,
      routeInformationParser: appRouter.router.routeInformationParser,

      // ── Builder for SafeArea + fixed text scaling ──────────
      builder: (context, child) {
        return MultiBlocProvider(
          providers: _globalProviders,
          child: BlocBuilder<NetworkCubit, NetworkState>(
            builder: (context, state) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.noScaling),
                child: SafeArea(
                  top: false,
                  child: Stack(
                    children: [
                      child ?? const SizedBox.shrink(),
                      if (state is NetworkStatusChanged && !state.isConnected)
                        const Positioned.fill(child: NoInternetScreen()),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Global BLoC / Cubit providers accessible throughout the widget tree.
  List<BlocProvider> get _globalProviders => [
    BlocProvider<NetworkCubit>(create: (_) => sl<NetworkCubit>(), lazy: false),
    BlocProvider<CurrentUserCubit>(create: (_) => sl<CurrentUserCubit>(), lazy: false),
    BlocProvider<LoginCubit>(create: (_) => sl<LoginCubit>(), lazy: false),
    BlocProvider<RegisterCubit>(
      create: (_) => sl<RegisterCubit>(),
      lazy: false,
    ),
    BlocProvider<RideSearchCubit>(
      create: (_) => sl<RideSearchCubit>(),
      lazy: false,
    ),
    BlocProvider<ActiveRideCubit>(
      create: (_) => sl<ActiveRideCubit>(),
      lazy: false,
    ),
    BlocProvider<RiderRideHistoryCubit>(
      create: (_) => sl<RiderRideHistoryCubit>(),
      lazy: false,
    ),
  ];

  String get _appTitle => switch (flavor) {
    AppFlavor.dev => 'MyApp (Dev)',
    AppFlavor.prod => 'MyApp',
  };
}
