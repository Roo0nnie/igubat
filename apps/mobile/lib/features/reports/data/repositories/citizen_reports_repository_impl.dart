import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/base_repository.dart';
import '../../../../core/usecases/result.dart';
import '../../domain/entities/citizen_report.dart';
import '../../domain/repositories/citizen_reports_repository.dart';
import '../../domain/usecases/citizen_report_params.dart';
import '../datasources/citizen_reports_remote_data_source.dart';

part 'citizen_reports_repository_impl.g.dart';

class CitizenReportsRepositoryImpl
    with BaseRepository
    implements CitizenReportsRepository {
  CitizenReportsRepositoryImpl(this._remote);

  final CitizenReportsRemoteDataSource _remote;

  @override
  FutureResult<List<CitizenReport>> getMyReports() => execute(() async {
    final models = await _remote.list();
    return models.map((m) => m.toEntity()).toList();
  });

  @override
  FutureResult<CitizenReport> getReportById(int id) => execute(() async {
    final model = await _remote.byId(id);
    return model.toEntity();
  });

  @override
  FutureResult<CitizenReport> createReport(CreateCitizenReportParams params) =>
      execute(() async {
        final model = await _remote.create(params.toJson());
        return model.toEntity();
      });
}

@riverpod
CitizenReportsRepository citizenReportsRepository(Ref ref) =>
    CitizenReportsRepositoryImpl(
      ref.watch(citizenReportsRemoteDataSourceProvider),
    );
