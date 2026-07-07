import '../../../../core/usecases/result.dart';
import '../entities/service_request.dart';
import '../usecases/service_request_params.dart';

/// Service-requests contract. Implemented in
/// `data/repositories/service_requests_repository_impl.dart`.
abstract interface class ServiceRequestsRepository {
  FutureResult<List<ServiceRequest>> getMyRequests();

  FutureResult<ServiceRequest> getRequest(int id);

  FutureResult<ServiceRequest> createRequest(CreateServiceRequestParams params);

  FutureResult<Unit> cancelRequest(int id);
}
