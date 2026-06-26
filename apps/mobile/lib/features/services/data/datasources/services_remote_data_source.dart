import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../models/service_category_model.dart';
import '../models/service_type_model.dart';

part 'services_remote_data_source.g.dart';

/// Talks to the public Services Catalog endpoints. The list endpoints return
/// bare arrays; the detail endpoint returns a bare object.
class ServicesRemoteDataSource with BaseRemoteDataSource {
  ServicesRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<ServiceCategoryModel>> categories() => guard(
    () => _client.getList(
      ApiConstants.serviceCategories,
      ServiceCategoryModel.fromJson,
    ),
  );

  Future<List<ServiceTypeModel>> serviceTypes() => guard(
    () => _client.getList(ApiConstants.services, ServiceTypeModel.fromJson),
  );

  Future<ServiceTypeModel> serviceType(String slug) => guard(
    () => _client.getOne(
      ApiConstants.service(slug),
      ServiceTypeModel.fromJson,
    ),
  );
}

@riverpod
ServicesRemoteDataSource servicesRemoteDataSource(Ref ref) =>
    ServicesRemoteDataSource(ref.watch(dioClientProvider));
