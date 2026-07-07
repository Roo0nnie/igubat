import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../entities/service_category.dart';
import '../repositories/services_repository.dart';

part 'get_service_categories.g.dart';

class GetServiceCategories extends UseCase<List<ServiceCategory>, NoParams> {
  GetServiceCategories(this._repository);

  final ServicesRepository _repository;

  @override
  FutureResult<List<ServiceCategory>> call(NoParams params) =>
      _repository.getCategories();
}

@riverpod
GetServiceCategories getServiceCategoriesUseCase(Ref ref) =>
    GetServiceCategories(ref.watch(servicesRepositoryProvider));
