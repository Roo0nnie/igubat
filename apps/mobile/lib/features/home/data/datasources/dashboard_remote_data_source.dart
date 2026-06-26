import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

part 'dashboard_remote_data_source.g.dart';

class DashboardRemoteDataSource with BaseRemoteDataSource {
  DashboardRemoteDataSource(this._client);

  final DioClient _client;

  Future<DashboardModel> fetch() => guard(
    () => _client.getOne(ApiConstants.publicDashboard, DashboardModel.fromJson),
  );
}

@riverpod
DashboardRemoteDataSource dashboardRemoteDataSource(Ref ref) =>
    DashboardRemoteDataSource(ref.watch(dioClientProvider));
