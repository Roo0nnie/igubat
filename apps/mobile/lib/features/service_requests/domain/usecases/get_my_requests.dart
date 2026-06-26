import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/service_requests_repository_impl.dart';
import '../entities/service_request.dart';
import '../repositories/service_requests_repository.dart';

part 'get_my_requests.g.dart';

class GetMyRequests extends UseCase<List<ServiceRequest>, NoParams> {
  GetMyRequests(this._repository);

  final ServiceRequestsRepository _repository;

  @override
  FutureResult<List<ServiceRequest>> call(NoParams params) =>
      _repository.getMyRequests();
}

@riverpod
GetMyRequests getMyRequestsUseCase(Ref ref) =>
    GetMyRequests(ref.watch(serviceRequestsRepositoryProvider));
