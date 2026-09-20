import 'package:dio/dio.dart';
import '../../config/flavor/flavor_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  static Dio create({
    required AppFlavor flavor,
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
  }) {
    final dio = Dio(
      BaseOptions(
        // baseUrl: Environment.apiBaseUrl,
        connectTimeout: Duration(seconds: 15),
        receiveTimeout: Duration(seconds: 15),
        sendTimeout: Duration(seconds: 15),
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(secureStorage, localStorage),
      RetryInterceptor(dio),
      ErrorInterceptor(),
      if (AppConfig.isDev) LoggingInterceptor(),
    ]);

    return dio;
  }
}
