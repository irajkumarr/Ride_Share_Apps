import 'package:rider_app/src/data/remote/auth_api_service.dart';
import 'package:rider_app/src/data/repo/auth_repo.dart';
import 'package:rider_app/src/modules/auth/blocs/login_cubit.dart';
import 'package:rider_app/src/modules/auth/blocs/register_cubit.dart';
import 'package:shared_core/shared_core.dart' hide AppRouter;

import '../../data/local/auth_local_data_source.dart';
import '../routing/app_router.dart';

/// Registers rider-specific dependencies, overriding or augmenting shared_core.
Future<void> configureRiderDependencies() async {
  // Api Service
  sl.registerLazySingleton<AuthApiService>(
    () => AuthApiService(sl<ApiClient>()),
  );

  // Repo
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepo(api: sl<AuthApiService>(), local: sl<AuthLocalDataSource>()),
  );

  // local
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(
      sl<LocalStorageService>(),
      sl<SecureStorageService>(),
    ),
  );

  // Blocs / Cubits
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl<AuthRepo>()));
  sl.registerFactory<RegisterCubit>(() => RegisterCubit(sl<AuthRepo>()));

  // Router
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(sl<LocalStorageService>()),
  );
}
