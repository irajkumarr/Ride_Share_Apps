import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Pretty-prints HTTP request/response details in debug builds.
///
/// Wraps [PrettyDioLogger] so configuration is centralised here.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor()
    : _inner = PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      );

  final PrettyDioLogger _inner;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _inner.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _inner.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _inner.onError(err, handler);
  }
}
