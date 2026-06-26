import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../entities/service_type.dart';
import '../repositories/services_repository.dart';

part 'get_service_type_by_slug.g.dart';

class GetServiceTypeBySlug extends UseCase<ServiceType, String> {
  GetServiceTypeBySlug(this._repository);

  final ServicesRepository _repository;

  @override
  FutureResult<ServiceType> call(String slug) =>
      _repository.getServiceTypeBySlug(slug);
}

@riverpod
GetServiceTypeBySlug getServiceTypeBySlugUseCase(Ref ref) =>
    GetServiceTypeBySlug(ref.watch(servicesRepositoryProvider));
