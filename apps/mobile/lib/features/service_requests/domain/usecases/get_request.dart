import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/service_requests_repository_impl.dart';
import '../entities/service_request.dart';
import '../repositories/service_requests_repository.dart';

part 'get_request.g.dart';

class GetRequest extends UseCase<ServiceRequest, int> {
  GetRequest(this._repository);

  final ServiceRequestsRepository _repository;

  @override
  FutureResult<ServiceRequest> call(int id) => _repository.getRequest(id);
}

@riverpod
GetRequest getRequestUseCase(Ref ref) =>
    GetRequest(ref.watch(serviceRequestsRepositoryProvider));
