/// Base class for all application-level exceptions.
///
/// All exceptions thrown within the app should extend [AppException] so
/// that error-handling code can catch a single type and inspect the details.
sealed class AppException implements Exception {
  const AppException({
    required this.message,
    this.statusCode,
    this.data,
  });

  /// Human-readable error message (may be shown in the UI).
  final String message;

  /// HTTP status code if the error originated from a network response.
  final int? statusCode;

  /// Optional raw payload for debugging purposes.
  final dynamic data;

  @override
  String toString() => '${runtimeType}(statusCode: $statusCode, message: $message)';
}

// ── Network ───────────────────────────────────────────────────────────────────

/// Thrown when there is no internet connectivity or the request timed out.
class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection'});
}

// ── HTTP 4xx ──────────────────────────────────────────────────────────────────

/// HTTP 400
class BadRequestException extends AppException {
  const BadRequestException({super.message = 'Bad request'}) : super(statusCode: 400);
}

/// HTTP 401
class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Unauthorised'}) : super(statusCode: 401);
}

/// HTTP 403
class ForbiddenException extends AppException {
  const ForbiddenException({super.message = 'Access forbidden'}) : super(statusCode: 403);
}

/// HTTP 404
class NotFoundException extends AppException {
  const NotFoundException({super.message = 'Resource not found'}) : super(statusCode: 404);
}

/// HTTP 409
class ConflictException extends AppException {
  const ConflictException({super.message = 'Conflict'}) : super(statusCode: 409);
}

/// HTTP 422 – carries field-level validation errors.
class ValidationException extends AppException {
  const ValidationException({
    super.message = 'Validation failed',
    this.errors = const {},
  }) : super(statusCode: 422);

  /// Field → list of error messages map returned by the server.
  final Map<String, List<String>> errors;
}

/// HTTP 429
class TooManyRequestsException extends AppException {
  const TooManyRequestsException({super.message = 'Too many requests'}) : super(statusCode: 429);
}

// ── HTTP 5xx ──────────────────────────────────────────────────────────────────

/// HTTP 5xx or unknown server error.
class ServerException extends AppException {
  const ServerException({
    super.message = 'Internal server error',
    super.statusCode = 500,
  });
}

// ── Local / cache ─────────────────────────────────────────────────────────────

/// Thrown when a cache read or write operation fails.
class CacheException extends AppException {
  const CacheException({super.message = 'Cache error'});
}

/// Thrown when a local storage operation fails.
class StorageException extends AppException {
  const StorageException({super.message = 'Storage error'});
}

// ── Auth ──────────────────────────────────────────────────────────────────────

/// Thrown during sign-in / sign-up flow for domain-level failures.
class AuthException extends AppException {
  const AuthException({super.message = 'Authentication failed'});
}

// ── Parse ─────────────────────────────────────────────────────────────────────

/// Thrown when JSON-to-model parsing fails.
class ParseException extends AppException {
  const ParseException({super.message = 'Data parsing error'});
}
