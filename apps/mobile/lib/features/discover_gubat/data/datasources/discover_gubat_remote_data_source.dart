import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../models/discover_gubat_item_model.dart';

class DiscoverGubatRemoteDataSource with BaseRemoteDataSource {
  DiscoverGubatRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<DiscoverGubatItemModel>> list() => guard(
    () => _client.getList(
      ApiConstants.publicDiscoverGubat,
      DiscoverGubatItemModel.fromJson,
    ),
  );

  Future<DiscoverGubatItemModel> getBySlug(String slug) => guard(
    () => _client.getOne(
      ApiConstants.publicDiscoverGubatItem(slug),
      DiscoverGubatItemModel.fromJson,
    ),
  );
}

final discoverGubatRemoteDataSourceProvider =
    Provider<DiscoverGubatRemoteDataSource>(
  (ref) => DiscoverGubatRemoteDataSource(ref.watch(dioClientProvider)),
);
