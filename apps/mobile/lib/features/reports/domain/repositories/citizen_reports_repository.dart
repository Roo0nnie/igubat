import '../../../../core/usecases/result.dart';
import '../entities/citizen_report.dart';
import '../usecases/citizen_report_params.dart';

/// Citizen reports contract. Implemented in
/// `data/repositories/citizen_reports_repository_impl.dart`.
abstract interface class CitizenReportsRepository {
  FutureResult<List<CitizenReport>> getMyReports();

  FutureResult<CitizenReport> getReportById(int id);

  FutureResult<CitizenReport> createReport(CreateCitizenReportParams params);
}
