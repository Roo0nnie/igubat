import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/citizen_reports_repository_impl.dart';
import '../entities/citizen_report.dart';
import '../repositories/citizen_reports_repository.dart';
import 'citizen_report_params.dart';

part 'create_report.g.dart';

class CreateReport extends UseCase<CitizenReport, CreateCitizenReportParams> {
  CreateReport(this._repository);

  final CitizenReportsRepository _repository;

  @override
  FutureResult<CitizenReport> call(CreateCitizenReportParams params) =>
      _repository.createReport(params);
}

@riverpod
CreateReport createReportUseCase(Ref ref) =>
    CreateReport(ref.watch(citizenReportsRepositoryProvider));
