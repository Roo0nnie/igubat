import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../models/citizen_report_model.dart';

part 'citizen_reports_remote_data_source.g.dart';

/// Talks to the citizen reports endpoints (`/me/reports`). Returns
/// [CitizenReportModel] DTOs.
class CitizenReportsRemoteDataSource with BaseRemoteDataSource {
  CitizenReportsRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<CitizenReportModel>> list() => guard(
    () => _client.getList(ApiConstants.myReports, CitizenReportModel.fromJson),
  );

  Future<CitizenReportModel> byId(int id) => guard(
    () => _client.getOne(ApiConstants.myReport(id), CitizenReportModel.fromJson),
  );

  Future<CitizenReportModel> create(Map<String, dynamic> body) => guard(
    () => _client.post(
      ApiConstants.myReports,
      CitizenReportModel.fromJson,
      data: body,
    ),
  );
}

@riverpod
CitizenReportsRemoteDataSource citizenReportsRemoteDataSource(Ref ref) =>
    CitizenReportsRemoteDataSource(ref.watch(dioClientProvider));
