import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../models/service_request_model.dart';

part 'service_requests_remote_data_source.g.dart';

/// Talks to the citizen `/me/requests` endpoints. Returns
/// [ServiceRequestModel] DTOs.
class ServiceRequestsRemoteDataSource with BaseRemoteDataSource {
  ServiceRequestsRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<ServiceRequestModel>> list() => guard(
    () => _client.getList(ApiConstants.myRequests, ServiceRequestModel.fromJson),
  );

  Future<ServiceRequestModel> byId(int id) => guard(
    () => _client.getOne(ApiConstants.myRequest(id), ServiceRequestModel.fromJson),
  );

  Future<ServiceRequestModel> create(Map<String, dynamic> body) => guard(
    () => _client.post(
      ApiConstants.myRequests,
      ServiceRequestModel.fromJson,
      data: body,
    ),
  );

  Future<void> cancel(int id) =>
      guard(() => _client.postVoid(ApiConstants.cancelRequest(id)));
}

@riverpod
ServiceRequestsRemoteDataSource serviceRequestsRemoteDataSource(Ref ref) =>
    ServiceRequestsRemoteDataSource(ref.watch(dioClientProvider));
