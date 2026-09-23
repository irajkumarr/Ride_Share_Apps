import 'package:driver_app/src/modules/auth/blocs/current_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_app/src/modules/auth/blocs/login_cubit.dart';
import 'package:driver_app/src/modules/auth/blocs/register_cubit.dart';
import 'package:driver_app/src/modules/home/blocs/driver_status_cubit.dart';
import 'package:driver_app/src/modules/ride/blocs/ride_dispatch_cubit.dart';
import 'package:driver_app/src/modules/ride_history/blocs/driver_ride_history_cubit.dart';
import 'package:driver_app/src/modules/vehicle/blocs/vehicle_cubit.dart';
import 'package:shared_core/shared_core.dart' hide AppRouter;

import 'src/core/routing/app_router.dart';

class App extends StatelessWidget {
  const App({required this.flavor, super.key});

  final AppFlavor flavor;

  @override
  Widget build(BuildContext context) {
    final appRouter = sl<AppRouter>();

    return MaterialApp.router(
      title: _appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerDelegate: appRouter.router.routerDelegate,
      routeInformationProvider: appRouter.router.routeInformationProvider,
      routeInformationParser: appRouter.router.routeInformationParser,
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

  List<BlocProvider> get _globalProviders => [
    BlocProvider<NetworkCubit>(create: (_) => sl<NetworkCubit>(), lazy: false),
    BlocProvider<CurrentUserCubit>(create: (_) => sl<CurrentUserCubit>(), lazy: false),
    BlocProvider<LoginCubit>(create: (_) => sl<LoginCubit>(), lazy: false),
    BlocProvider<RegisterCubit>(
      create: (_) => sl<RegisterCubit>(),
      lazy: false,
    ),
    BlocProvider<VehicleCubit>(create: (_) => sl<VehicleCubit>(), lazy: false),
    BlocProvider<DriverRideHistoryCubit>(
      create: (_) => sl<DriverRideHistoryCubit>(),
      lazy: false,
    ),
    BlocProvider<DriverStatusCubit>(
      create: (_) => sl<DriverStatusCubit>(),
      lazy: false,
    ),
    BlocProvider<RideDispatchCubit>(
      create: (_) => sl<RideDispatchCubit>(),
      lazy: false,
    ),
  ];


  String get _appTitle => switch (flavor) {
    AppFlavor.dev => 'RideNest Driver (Dev)',
    AppFlavor.prod => 'RideNest Driver',
  };
}
