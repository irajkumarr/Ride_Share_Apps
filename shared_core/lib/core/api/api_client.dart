import 'package:dio/dio.dart';
import '../error/exceptions.dart';
import '../utils/app_logger.dart';

/// Thin wrapper around [Dio] that provides a consistent API for HTTP calls.
///
/// All methods return the decoded [T] directly; errors are mapped to typed
/// [AppException] subtypes by [ErrorInterceptor] and re-thrown here.
///
/// Example:
/// ```dart
/// final data = await apiClient.get<Map<String, dynamic>>('/users/1');
/// ```
class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  // ── GET ───────────────────────────────────────────────────────────────────

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ── POST ──────────────────────────────────────────────────────────────────

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ── PUT ───────────────────────────────────────────────────────────────────

  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ── PATCH ─────────────────────────────────────────────────────────────────

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ── Multipart upload ──────────────────────────────────────────────────────

  /// Upload a file using `multipart/form-data`.
  Future<T> uploadFile<T>(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options ?? Options(contentType: 'multipart/form-data'),
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  T _handleResponse<T>(Response<T> response) {
    if (response.data == null) {
      throw const ServerException(message: 'Empty response from server');
    }
    return response.data as T;
  }

  static AppException _mapDioError(DioException e) {
    AppLogger.error('DioException', error: e, stackTrace: e.stackTrace);

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const NetworkException(
        message: 'Connection timed out',
      ),
      DioExceptionType.connectionError => const NetworkException(
        message: 'No internet connection',
      ),
      DioExceptionType.badResponse => _mapStatusCode(e),
      DioExceptionType.cancel => const NetworkException(
        message: 'Request was cancelled',
      ),
      _ => ServerException(
        message: e.message ?? 'An unexpected error occurred',
      ),
    };
  }

  static AppException _mapStatusCode(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = _extractErrorMessage(e.response?.data);

    return switch (statusCode) {
      400 => BadRequestException(message: message),
      401 => const UnauthorizedException(),
      403 => const ForbiddenException(),
      404 => NotFoundException(message: message),
      409 => ConflictException(message: message),
      422 => ValidationException(
        message: message,
        errors: _extractValidationErrors(e.response?.data),
      ),
      429 => const TooManyRequestsException(),
      500 || 502 || 503 => ServerException(message: message),
      _ => ServerException(message: message, statusCode: statusCode),
    };
  }

  static String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String? ?? 'An error occurred';
    }
    return 'An error occurred';
  }

  static Map<String, List<String>> _extractValidationErrors(dynamic data) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        return errors.map(
          (key, value) => MapEntry(
            key,
            (value as List<dynamic>).map((e) => e.toString()).toList(),
          ),
        );
      }
    }
    return {};
  }

  // If using retrofit can wrap the repository layer with this
  static Future<T> safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e, st) {
      AppLogger.error('Unknown API error', error: e, stackTrace: st);
      throw const ServerException();
    }
  }
}

extension ApiObjectExtension on Object {
  String get apiMessage {
    if (this is AppException) {
      return (this as AppException).message;
    } else if (this is AppException) {
      return (this as AppException).message[1];
    } else {
      return 'Something went wrong. Please try again later.';
    }
  }
}
