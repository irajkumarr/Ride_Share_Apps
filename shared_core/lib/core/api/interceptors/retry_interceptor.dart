import 'package:dio/dio.dart';
import '../../utils/app_logger.dart';

/// Automatically retries idempotent requests on transient network failures.
///
/// Only GET / HEAD / OPTIONS requests are retried.
/// Max retries = [maxRetries] with exponential back-off.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this.dio, {this.maxRetries = 3});

  final Dio dio;
  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final isIdempotent = const {
      'GET',
      'HEAD',
      'OPTIONS',
    }.contains(requestOptions.method.toUpperCase());
    final isTransient =
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout;

    if (!isIdempotent || !isTransient) {
      return handler.next(err);
    }

    final retryCount = requestOptions.extra['retryCount'] as int? ?? 0;
    if (retryCount >= maxRetries) {
      AppLogger.warning(
        'RetryInterceptor: max retries ($maxRetries) reached for '
        '${requestOptions.path}',
      );
      return handler.next(err);
    }

    // Exponential back-off: 1s, 2s, 4s, ...
    final delay = Duration(seconds: 1 << retryCount);
    AppLogger.info(
      'RetryInterceptor: retrying in ${delay.inSeconds}s '
      '(attempt ${retryCount + 1}/$maxRetries)',
    );

    await Future<void>.delayed(delay);

    requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      // final dio = Dio();
      //  final response = await dio.fetch(requestOptions);
      final response = await dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
        ),
      );
      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    }
  }
}
