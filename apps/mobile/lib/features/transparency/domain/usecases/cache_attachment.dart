import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/transparency_repository_impl.dart';
import '../entities/transparency_attachment.dart';
import '../repositories/transparency_repository.dart';

part 'cache_attachment.g.dart';

class CacheAttachment extends UseCase<Uri, TransparencyAttachment> {
  CacheAttachment(this._repository);

  final TransparencyRepository _repository;

  @override
  FutureResult<Uri> call(TransparencyAttachment attachment) =>
      _repository.cacheAttachment(attachment);
}

@riverpod
CacheAttachment cacheAttachmentUseCase(Ref ref) =>
    CacheAttachment(ref.watch(transparencyRepositoryProvider));
