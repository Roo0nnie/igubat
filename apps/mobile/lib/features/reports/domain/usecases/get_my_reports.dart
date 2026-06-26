import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/citizen_reports_repository_impl.dart';
import '../entities/citizen_report.dart';
import '../repositories/citizen_reports_repository.dart';

part 'get_my_reports.g.dart';

class GetMyReports extends UseCase<List<CitizenReport>, NoParams> {
  GetMyReports(this._repository);

  final CitizenReportsRepository _repository;

  @override
  FutureResult<List<CitizenReport>> call(NoParams params) =>
      _repository.getMyReports();
}

@riverpod
GetMyReports getMyReportsUseCase(Ref ref) =>
    GetMyReports(ref.watch(citizenReportsRepositoryProvider));
