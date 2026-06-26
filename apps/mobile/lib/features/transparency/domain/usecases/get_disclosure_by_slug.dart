import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/transparency_repository_impl.dart';
import '../entities/transparency_item.dart';
import '../repositories/transparency_repository.dart';

part 'get_disclosure_by_slug.g.dart';

class GetDisclosureBySlug extends UseCase<TransparencyItem?, String> {
  GetDisclosureBySlug(this._repository);

  final TransparencyRepository _repository;

  @override
  FutureResult<TransparencyItem?> call(String slug) =>
      _repository.getBySlug(slug);
}

@riverpod
GetDisclosureBySlug getDisclosureBySlugUseCase(Ref ref) =>
    GetDisclosureBySlug(ref.watch(transparencyRepositoryProvider));
