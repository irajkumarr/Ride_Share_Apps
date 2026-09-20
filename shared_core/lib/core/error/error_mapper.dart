import 'exceptions.dart';
import 'failures.dart';

/// Maps [AppException] instances from the data layer to [Failure] instances
/// consumed by the domain / presentation layers.
///
/// Usage (inside a repository catch block):
/// ```dart
/// on AppException catch (e) {
///   return Left(ErrorMapper.map(e));
/// }
/// ```
abstract final class ErrorMapper {
  /// Converts any [AppException] to the appropriate [Failure].
  static Failure map(AppException exception) => switch (exception) {
    NetworkException() => const NetworkFailure(),
    UnauthorizedException() => const UnauthorizedFailure(),
    ForbiddenException() => const ForbiddenFailure(),
    NotFoundException(:final message) => NotFoundFailure(message: message),
    ValidationException(:final message, :final errors) => ValidationFailure(
      message: message,
      errors: errors,
    ),
    BadRequestException(:final message) => ServerFailure(
      message: message,
      statusCode: 400,
    ),
    ConflictException(:final message) => ServerFailure(
      message: message,
      statusCode: 409,
    ),
    TooManyRequestsException(:final message) => ServerFailure(
      message: message,
      statusCode: 429,
    ),
    ServerException(:final message, :final statusCode) => ServerFailure(
      message: message,
      statusCode: statusCode,
    ),
    CacheException(:final message) => CacheFailure(message: message),
    StorageException(:final message) => StorageFailure(message: message),
    AuthException(:final message) => AuthFailure(message: message),
    ParseException(:final message) => ParseFailure(message: message),
  };

  /// Converts any generic [Exception] to an [UnknownFailure].
  static Failure mapUnknown(Object e) {
    if (e is AppException) return map(e);
    return UnknownFailure(message: e.toString());
  }
}
