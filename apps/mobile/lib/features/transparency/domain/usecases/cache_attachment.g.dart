// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_attachment.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cacheAttachmentUseCase)
const cacheAttachmentUseCaseProvider = CacheAttachmentUseCaseProvider._();

final class CacheAttachmentUseCaseProvider
    extends
        $FunctionalProvider<CacheAttachment, CacheAttachment, CacheAttachment>
    with $Provider<CacheAttachment> {
  const CacheAttachmentUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheAttachmentUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheAttachmentUseCaseHash();

  @$internal
  @override
  $ProviderElement<CacheAttachment> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CacheAttachment create(Ref ref) {
    return cacheAttachmentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CacheAttachment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CacheAttachment>(value),
    );
  }
}

String _$cacheAttachmentUseCaseHash() =>
    r'a6c8a346e5a56117d341e1e29f659bfcc05c63fa';
