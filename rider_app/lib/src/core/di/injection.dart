import 'package:shared_core/shared_core.dart' hide AppRouter;
import '../routing/app_router.dart';

/// Registers rider-specific dependencies, overriding or augmenting shared_core.
Future<void> configureRiderDependencies() async {
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(sl<LocalStorageService>()),
  );
}

