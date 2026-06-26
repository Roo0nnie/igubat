import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/citizen_reports_repository_impl.dart';
import '../entities/citizen_report.dart';
import '../repositories/citizen_reports_repository.dart';

part 'get_report_by_id.g.dart';

class GetReportById extends UseCase<CitizenReport, int> {
  GetReportById(this._repository);

  final CitizenReportsRepository _repository;

  @override
  FutureResult<CitizenReport> call(int params) =>
      _repository.getReportById(params);
}

@riverpod
GetReportById getReportByIdUseCase(Ref ref) =>
    GetReportById(ref.watch(citizenReportsRepositoryProvider));
