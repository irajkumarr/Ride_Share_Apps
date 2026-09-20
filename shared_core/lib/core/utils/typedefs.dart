import 'package:dartz/dartz.dart';
import 'package:shared_core/core/error/failures.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureEitherVoid = FutureEither<void>;
typedef StreamEither<T> = Stream<Either<Failure, T>>;
typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<dynamic>;
