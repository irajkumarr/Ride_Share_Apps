import 'package:driver_app/src/data/local/auth_local_data_source.dart';
import 'package:driver_app/src/data/remote/auth_api_service.dart';
import 'package:driver_app/src/data/remote/driver_ride_api_service.dart';
import 'package:driver_app/src/data/remote/vehicle_api_service.dart';
import 'package:driver_app/src/data/repo/auth_repo.dart';
import 'package:driver_app/src/data/repo/driver_ride_repo.dart';
import 'package:driver_app/src/data/repo/vehicle_repo.dart';
import 'package:driver_app/src/modules/auth/blocs/current_user_cubit.dart';
import 'package:driver_app/src/modules/auth/blocs/login_cubit.dart';
import 'package:driver_app/src/modules/auth/blocs/register_cubit.dart';
import 'package:driver_app/src/modules/home/blocs/driver_status_cubit.dart';
import 'package:driver_app/src/modules/ride/blocs/ride_dispatch_cubit.dart';
import 'package:driver_app/src/modules/ride_history/blocs/driver_ride_history_cubit.dart';
import 'package:driver_app/src/modules/vehicle/blocs/vehicle_cubit.dart';
import 'package:shared_core/shared_core.dart' hide AppRouter;

import '../routing/app_router.dart';

/// Registers driver-specific dependencies into get_it service locator.
Future<void> configureDriverDependencies() async {
  // ── Api Services ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthApiService>(
    () => AuthApiService(sl<ApiClient>()),
  );
  sl.registerLazySingleton<VehicleApiService>(
    () => VehicleApiService(sl<ApiClient>()),
  );
  sl.registerLazySingleton<DriverRideApiService>(
    () => DriverRideApiService(sl<ApiClient>()),
  );

  // ── Local Data Sources ─────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(
      sl<LocalStorageService>(),
      sl<SecureStorageService>(),
    ),
  );

  // ── Repositories ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepo(api: sl<AuthApiService>(), local: sl<AuthLocalDataSource>()),
  );
  sl.registerLazySingleton<VehicleRepo>(
    () => VehicleRepo(api: sl<VehicleApiService>()),
  );
  sl.registerLazySingleton<DriverRideRepo>(
    () => DriverRideRepo(api: sl<DriverRideApiService>()),
  );

  // ── Blocs / Cubits ─────────────────────────────────────────────────────────
  sl.registerFactory<CurrentUserCubit>(() => CurrentUserCubit(sl<AuthRepo>()));
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl<AuthRepo>()));
  sl.registerFactory<RegisterCubit>(() => RegisterCubit(sl<AuthRepo>()));
  sl.registerFactory<VehicleCubit>(() => VehicleCubit(sl<VehicleRepo>()));
  sl.registerFactory<DriverRideHistoryCubit>(
    () => DriverRideHistoryCubit(sl<DriverRideRepo>()),
  );

  sl.registerLazySingleton<DriverStatusCubit>(
    () => DriverStatusCubit(
      driverRideApi: sl<DriverRideApiService>(),
      webSocketService: sl<WebSocketService>(),
      locationService: sl<LocationService>(),
      authLocal: sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<RideDispatchCubit>(
    () => RideDispatchCubit(
      driverRideApi: sl<DriverRideApiService>(),
      webSocketService: sl<WebSocketService>(),
      driverStatusCubit: sl<DriverStatusCubit>(),
    ),
  );

  // ── Router ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(sl<LocalStorageService>()),
  );
}
