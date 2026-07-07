import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../entities/session.dart';
import '../repositories/auth_repository.dart';

part 'get_current_session.g.dart';

/// Restores the current session from the backend cookie (or `null`).
class GetCurrentSession extends UseCase<Session?, NoParams> {
  GetCurrentSession(this._repository);

  final AuthRepository _repository;

  @override
  FutureResult<Session?> call(NoParams params) =>
      _repository.getCurrentSession();
}

@riverpod
GetCurrentSession getCurrentSessionUseCase(Ref ref) =>
    GetCurrentSession(ref.watch(authRepositoryProvider));
