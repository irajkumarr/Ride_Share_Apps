// import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_core/config/flavor/flavor_config.dart';
import 'package:shared_core/core/api/api_client.dart';
import 'package:shared_core/core/api/dio_client.dart';
import 'package:shared_core/core/cache/hive_cache_service.dart';
import 'package:shared_core/core/network/network_info.dart';
import 'package:shared_core/core/routing/app_router.dart';
import 'package:shared_core/core/storage/local_storage_service.dart';
import 'package:shared_core/core/storage/secure_storage_service.dart';
import 'package:shared_core/core/ui/blocs/network_cubit.dart';
import 'package:shared_core/core/utils/push_notification_service.dart';
import 'package:shared_core/services/location/location_service.dart';
import 'package:shared_core/services/web_socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global service-locator instance.
final GetIt sl = GetIt.instance;

/// Registers all application dependencies.
///
/// Call once during app bootstrap before [runApp].
///
/// Separation of concerns: each domain registers its own dependencies in a
/// dedicated `_register*` helper so this file stays easy to navigate.
Future<void> configureDependencies(AppFlavor flavor) async {
  await _registerExternalDependencies();
  _registerCore();
  _registerPushNotifications();
  _registerNetwork(flavor);
  _registerStorage();
  _registerNavigation();
  _registerLocation();
}

// ── External / third-party ──────────────────────────────────────────────────

Future<void> _registerExternalDependencies() async {
  // SharedPreferences – async, so we await before registering.
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPrefs);

  // sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());

  // FirebaseMessaging
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
}

// ── Core infrastructure ─────────────────────────────────────────────────────

void _registerCore() {
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnection>()),
  );
}

// ── Networking ──────────────────────────────────────────────────────────────

void _registerNetwork(AppFlavor flavor) {
  // Dio instance

  sl.registerLazySingleton<Dio>(
    () => DioClient.create(
      flavor: flavor,
      secureStorage: sl<SecureStorageService>(),
      localStorage: sl<LocalStorageService>(),
    ),
  );

  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>()));

  sl.registerFactory<NetworkCubit>(() => NetworkCubit(sl<NetworkInfo>()));
}

// Push Notifications
void _registerPushNotifications() {
  sl.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(
      sl<FirebaseMessaging>(),
      sl<LocalStorageService>(),
    ),
  );
}

// ── Storage ─────────────────────────────────────────────────────────────────

void _registerStorage() {
  sl.registerLazySingleton<LocalStorageService>(
    () => LocalStorageServiceImpl(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(),
  );

  sl.registerLazySingleton<HiveCacheService>(() => HiveCacheServiceImpl());
}

// ── Navigation ──────────────────────────────────────────────────────────────

void _registerNavigation() {
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(sl<LocalStorageService>()),
  );
}

// ── Auth feature ─────────────────────────────────────────────────────────────

void _registerLocation() {
  sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  sl.registerLazySingleton<WebSocketService>(() => WebSocketServiceImpl());
}
