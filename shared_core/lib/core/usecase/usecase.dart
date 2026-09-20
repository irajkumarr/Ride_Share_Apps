import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base class for all use-cases that require input parameters [P]
/// and return an [Either<Failure, T>].
///
/// Example:
/// ```dart
/// class LoginUseCase extends UseCase<User, LoginParams> {
///   @override
///   Future<Either<Failure, User>> call(LoginParams params) async { … }
/// }
/// ```
abstract class UseCase<T, P> {
  const UseCase();
  Future<Either<Failure, T>> call(P params);
}

/// Base class for use-cases that take no parameters.
///
/// Example:
/// ```dart
/// class GetCurrentUserUseCase extends NoParamsUseCase<User?> {
///   @override
///   Future<Either<Failure, User?>> call() async { … }
/// }
/// ```
abstract class NoParamsUseCase<T> {
  const NoParamsUseCase();
  Future<Either<Failure, T>> call();
}

/// Base class for use-cases that return a [Stream].
abstract class StreamUseCase<T, P> {
  const StreamUseCase();
  Stream<Either<Failure, T>> call(P params);
}

/// Sentinel class used as parameter type when a use-case requires no params.
///
/// Pass `NoParams()` where a `P` type is needed but the use-case is actually
/// parameterless – prefer [NoParamsUseCase] when possible.
class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object?> get props => [];
}
