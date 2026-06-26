import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../entities/service_type.dart';
import '../repositories/services_repository.dart';

part 'get_service_types.g.dart';

class GetServiceTypes extends UseCase<List<ServiceType>, NoParams> {
  GetServiceTypes(this._repository);

  final ServicesRepository _repository;

  @override
  FutureResult<List<ServiceType>> call(NoParams params) =>
      _repository.getServiceTypes();
}

@riverpod
GetServiceTypes getServiceTypesUseCase(Ref ref) =>
    GetServiceTypes(ref.watch(servicesRepositoryProvider));
