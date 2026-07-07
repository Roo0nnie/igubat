import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/service_requests_repository_impl.dart';
import '../entities/service_request.dart';
import '../repositories/service_requests_repository.dart';
import 'service_request_params.dart';

part 'create_service_request.g.dart';

class CreateServiceRequest
    extends UseCase<ServiceRequest, CreateServiceRequestParams> {
  CreateServiceRequest(this._repository);

  final ServiceRequestsRepository _repository;

  @override
  FutureResult<ServiceRequest> call(CreateServiceRequestParams params) =>
      _repository.createRequest(params);
}

@riverpod
CreateServiceRequest createServiceRequestUseCase(Ref ref) =>
    CreateServiceRequest(ref.watch(serviceRequestsRepositoryProvider));
