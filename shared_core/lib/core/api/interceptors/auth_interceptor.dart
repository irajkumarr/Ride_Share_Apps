// import 'package:dio/dio.dart';
// import '../../storage/local_storage_service.dart';
// import '../../storage/secure_storage_service.dart';
// import '../../utils/app_logger.dart';

// /// Attaches the Bearer token to every outgoing request.
// ///
// /// On a 401 response the interceptor attempts a token refresh once.  If the
// /// refresh also fails it clears local auth state so the app can redirect the
// /// user to the login screen.
// class AuthInterceptor extends Interceptor {
//   AuthInterceptor(this.dio, this._secureStorage, this._localStorage);

//   final Dio dio;
//   final SecureStorageService _secureStorage;
//   final LocalStorageService _localStorage;

//   /// Flag that prevents infinite retry loops during token refresh.
//   bool _isRefreshing = false;

//   @override
//   Future<void> onRequest(
//     RequestOptions options,
//     RequestInterceptorHandler handler,
//   ) async {
//     // Skip auth header for public endpoints (login, register, etc.)
//     if (options.extra['skipAuth'] == true) {
//       return handler.next(options);
//     }

//     final token = await _secureStorage.getAccessToken();
//     if (token != null && token.isNotEmpty) {
//       options.headers['Authorization'] = 'Bearer $token';
//       AppLogger.debug('AuthInterceptor: token attached');
//     }

//     return handler.next(options);
//   }

//   @override
//   Future<void> onError(
//     DioException err,
//     ErrorInterceptorHandler handler,
//   ) async {
//     if (err.response?.statusCode == 401 && !_isRefreshing) {
//       _isRefreshing = true;

//       try {
//         final refreshed = await _attemptTokenRefresh(err.requestOptions);
//         if (refreshed) {
//           // Retry the original request with the new token.
//           final retryResponse = await _retry(err.requestOptions);
//           _isRefreshing = false;
//           return handler.resolve(retryResponse);
//         }
//       } catch (e) {
//         AppLogger.error('Token refresh failed', error: e);
//       }

//       // Refresh failed – clear tokens so router redirects to login.
//       await _clearAuth();
//       _isRefreshing = false;
//     }

//     return handler.next(err);
//   }

//   Future<bool> _attemptTokenRefresh(RequestOptions original) async {
//     final refreshToken = await _secureStorage.getRefreshToken();
//     if (refreshToken == null) return false;

//     // TODO: Replace with your actual refresh endpoint call.
//     // final response = await Dio().post('/auth/refresh',
//     //     data: {'refresh_token': refreshToken});
//     // await _secureStorage.saveTokens(
//     //     accessToken: response.data['access_token'],
//     //     refreshToken: response.data['refresh_token']);
//     return false; // placeholder
//   }

//   Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
//     final token = await _secureStorage.getAccessToken();
//     requestOptions.headers['Authorization'] = 'Bearer $token';

//     // final dio = Dio();
//     return dio.request<dynamic>(
//       requestOptions.path,
//       data: requestOptions.data,
//       queryParameters: requestOptions.queryParameters,
//       options: Options(
//         method: requestOptions.method,
//         headers: requestOptions.headers,
//       ),
//     );
//   }

//   Future<void> _clearAuth() async {
//     await _secureStorage.deleteTokens();
//     await _localStorage.setBool(LocalStorageKeys.isLoggedIn, value: false);
//     AppLogger.info('AuthInterceptor: tokens cleared – session ended');
//   }
// }

// final skipAuthOptions = Options(extra: const {'skipAuth': true});

//updated
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/config/global/app_global.dart';
import 'package:shared_core/core/routing/app_routes.dart';

import '../../storage/local_storage_service.dart';
import '../../storage/secure_storage_service.dart';
import '../../utils/app_logger.dart';

final skipAuthOptions = Options(extra: const {'skipAuth': true});

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage, this._localStorage);

  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  /// Prevent multiple redirects
  bool _isRedirecting = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    final token = await _secureStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      AppLogger.debug('AuthInterceptor: token attached');
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRedirecting) {
      _isRedirecting = true;

      AppLogger.warning('401 Unauthorized → Logging out user');

      await _clearAuth();

      //  Navigate to login
      if (AppGlobal.navigatorKey.currentContext != null) {
        GoRouter.of(AppGlobal.navigatorKey.currentContext!).go(AppRoutes.login);
      }

      _isRedirecting = false;
    }

    handler.next(err);
  }

  Future<void> _clearAuth() async {
    await _secureStorage.deleteTokens();
    await _localStorage.remove('cached_user');
    await _localStorage.setBool(LocalStorageKeys.isLoggedIn, value: false);

    AppLogger.info('AuthInterceptor: session cleared');
  }
}
