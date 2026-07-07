import '../../../../core/usecases/result.dart';
import '../entities/dashboard.dart';

abstract interface class DashboardRepository {
  FutureResult<Dashboard> getDashboard();
}
