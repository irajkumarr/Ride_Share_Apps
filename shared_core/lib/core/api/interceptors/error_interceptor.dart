import 'package:dio/dio.dart';
import '../../utils/app_logger.dart';

/// Intercepts all Dio errors and logs them centrally.
///
/// Actual error-to-exception mapping is done in [ApiClient._mapDioError].
/// This interceptor is solely responsible for side-effects (logging, analytics).
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'HTTP ${err.response?.statusCode ?? "N/A"} '
      '${err.requestOptions.method} ${err.requestOptions.path}',
      error: err,
    );
    handler.next(err);
  }
}
