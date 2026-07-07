import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

export 'package:fpdart/fpdart.dart' show Either, Left, Right, Unit, unit;

/// A synchronous result that is either a [Failure] or a value of type `T`.
typedef Result<T> = Either<Failure, T>;

/// An asynchronous [Result].
typedef FutureResult<T> = Future<Either<Failure, T>>;
