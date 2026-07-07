import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/service_requests_repository_impl.dart';
import '../repositories/service_requests_repository.dart';

part 'cancel_service_request.g.dart';

class CancelServiceRequest extends UseCase<Unit, int> {
  CancelServiceRequest(this._repository);

  final ServiceRequestsRepository _repository;

  @override
  FutureResult<Unit> call(int id) => _repository.cancelRequest(id);
}

@riverpod
CancelServiceRequest cancelServiceRequestUseCase(Ref ref) =>
    CancelServiceRequest(ref.watch(serviceRequestsRepositoryProvider));
