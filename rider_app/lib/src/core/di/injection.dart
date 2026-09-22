import 'package:dio/dio.dart';
import 'package:rider_app/src/data/remote/auth_api_service.dart';
import 'package:rider_app/src/data/remote/places_api_service.dart';
import 'package:rider_app/src/data/remote/ride_api_service.dart';
import 'package:rider_app/src/data/repo/auth_repo.dart';
import 'package:rider_app/src/data/repo/places_repo.dart';
import 'package:rider_app/src/data/repo/ride_repo.dart';
import 'package:rider_app/src/modules/auth/blocs/login_cubit.dart';
import 'package:rider_app/src/modules/auth/blocs/register_cubit.dart';
import 'package:rider_app/src/modules/home/blocs/active_ride_cubit.dart';
import 'package:rider_app/src/modules/home/blocs/ride_search_cubit.dart';
import 'package:shared_core/shared_core.dart' hide AppRouter;

import '../../data/local/auth_local_data_source.dart';
import '../routing/app_router.dart';

/// Registers rider-specific dependencies, overriding or augmenting shared_core.
Future<void> configureRiderDependencies() async {
  // ── Api Services ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthApiService>(
    () => AuthApiService(sl<ApiClient>()),
  );
  sl.registerLazySingleton<PlacesApiService>(
    () => PlacesApiService(
      apiClient: sl<ApiClient>(),
      dio: sl<Dio>(),
    ),
  );
  sl.registerLazySingleton<RideApiService>(
    () => RideApiService(
      apiClient: sl<ApiClient>(),
      dio: sl<Dio>(),
    ),
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
  sl.registerLazySingleton<PlacesRepo>(
    () => PlacesRepo(api: sl<PlacesApiService>()),
  );
  sl.registerLazySingleton<RideRepo>(
    () => RideRepo(api: sl<RideApiService>()),
  );

  // ── Blocs / Cubits (Presentation) ──────────────────────────────────────────
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl<AuthRepo>()));
  sl.registerFactory<RegisterCubit>(() => RegisterCubit(sl<AuthRepo>()));
  sl.registerFactory<RideSearchCubit>(() => RideSearchCubit(sl<PlacesRepo>()));
  sl.registerFactory<ActiveRideCubit>(
    () => ActiveRideCubit(
      rideRepo: sl<RideRepo>(),
      webSocketService: sl<WebSocketService>(),
      authLocalDataSource: sl<AuthLocalDataSource>(),
    ),
  );


  // ── Router ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(sl<LocalStorageService>()),
  );
}
