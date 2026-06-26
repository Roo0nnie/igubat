import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/transparency_type.dart';
import '../../data/repositories/transparency_repository_impl.dart';
import '../entities/transparency_item.dart';
import '../repositories/transparency_repository.dart';

part 'list_disclosures_by_type.g.dart';

class ListDisclosuresByType
    extends UseCase<List<TransparencyItem>, TransparencyType> {
  ListDisclosuresByType(this._repository);

  final TransparencyRepository _repository;

  @override
  FutureResult<List<TransparencyItem>> call(TransparencyType type) =>
      _repository.listByType(type);
}

@riverpod
ListDisclosuresByType listDisclosuresByTypeUseCase(Ref ref) =>
    ListDisclosuresByType(ref.watch(transparencyRepositoryProvider));
