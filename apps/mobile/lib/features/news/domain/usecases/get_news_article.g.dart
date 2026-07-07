// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_news_article.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getNewsArticleUseCase)
const getNewsArticleUseCaseProvider = GetNewsArticleUseCaseProvider._();

final class GetNewsArticleUseCaseProvider
    extends $FunctionalProvider<GetNewsArticle, GetNewsArticle, GetNewsArticle>
    with $Provider<GetNewsArticle> {
  const GetNewsArticleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getNewsArticleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getNewsArticleUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetNewsArticle> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetNewsArticle create(Ref ref) {
    return getNewsArticleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetNewsArticle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetNewsArticle>(value),
    );
  }
}

String _$getNewsArticleUseCaseHash() =>
    r'29075a50a7a799d0fff2141aa71676061fb371ca';
