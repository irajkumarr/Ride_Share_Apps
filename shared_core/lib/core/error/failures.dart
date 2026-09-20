import 'package:equatable/equatable.dart';

/// Represents a domain-level failure returned from a repository.
///
/// Failures are the "left" side of the `Either<Failure, T>` pattern used
/// throughout the domain layer.  They are a clean, UI-friendly abstraction
/// over the raw [AppException] types from the data layer.
///
/// Example:
/// ```dart
/// final result = await loginUseCase(params);
/// result.fold(
///   (failure) => emit(AuthError(failure.message)),
///   (user)    => emit(AuthAuthenticated(user)),
/// );
/// ```
sealed class Failure extends Equatable {
  const Failure({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

// ── Network failures ──────────────────────────────────────────────────────────

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Request timed out'});
}

// ── Server failures ───────────────────────────────────────────────────────────

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error',
    super.statusCode,
  });
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Unauthorised'}) : super(statusCode: 401);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message = 'Access forbidden'}) : super(statusCode: 403);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Not found'}) : super(statusCode: 404);
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Validation failed',
    this.errors = const {},
  }) : super(statusCode: 422);

  final Map<String, List<String>> errors;

  @override
  List<Object?> get props => [...super.props, errors];
}

// ── Local / cache failures ────────────────────────────────────────────────────

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache failure'});
}

class StorageFailure extends Failure {
  const StorageFailure({super.message = 'Storage failure'});
}

// ── Auth failures ─────────────────────────────────────────────────────────────

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed'});
}

// ── Parse failures ────────────────────────────────────────────────────────────

class ParseFailure extends Failure {
  const ParseFailure({super.message = 'Data parsing failed'});
}

// ── Unknown ───────────────────────────────────────────────────────────────────

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unknown error occurred'});
}
