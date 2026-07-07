import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../entities/dashboard.dart';
import '../repositories/dashboard_repository.dart';

part 'get_dashboard.g.dart';

class GetDashboard extends UseCase<Dashboard, NoParams> {
  GetDashboard(this._repository);

  final DashboardRepository _repository;

  @override
  FutureResult<Dashboard> call(NoParams params) => _repository.getDashboard();
}

@riverpod
GetDashboard getDashboardUseCase(Ref ref) =>
    GetDashboard(ref.watch(dashboardRepositoryProvider));
