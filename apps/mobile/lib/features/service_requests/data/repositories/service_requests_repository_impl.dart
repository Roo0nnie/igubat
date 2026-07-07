import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/base_repository.dart';
import '../../../../core/usecases/result.dart';
import '../../domain/entities/service_request.dart';
import '../../domain/repositories/service_requests_repository.dart';
import '../../domain/usecases/service_request_params.dart';
import '../datasources/service_requests_remote_data_source.dart';

part 'service_requests_repository_impl.g.dart';

class ServiceRequestsRepositoryImpl
    with BaseRepository
    implements ServiceRequestsRepository {
  ServiceRequestsRepositoryImpl(this._remote);

  final ServiceRequestsRemoteDataSource _remote;

  @override
  FutureResult<List<ServiceRequest>> getMyRequests() => execute(() async {
    final models = await _remote.list();
    return models.map((m) => m.toEntity()).toList();
  });

  @override
  FutureResult<ServiceRequest> getRequest(int id) => execute(() async {
    final model = await _remote.byId(id);
    return model.toEntity();
  });

  @override
  FutureResult<ServiceRequest> createRequest(
    CreateServiceRequestParams params,
  ) => execute(() async {
    final model = await _remote.create(params.toJson());
    return model.toEntity();
  });

  @override
  FutureResult<Unit> cancelRequest(int id) => execute(() async {
    await _remote.cancel(id);
    return unit;
  });
}

@riverpod
ServiceRequestsRepository serviceRequestsRepository(Ref ref) =>
    ServiceRequestsRepositoryImpl(
      ref.watch(serviceRequestsRemoteDataSourceProvider),
    );
