// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_disclosure_by_slug.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getDisclosureBySlugUseCase)
const getDisclosureBySlugUseCaseProvider =
    GetDisclosureBySlugUseCaseProvider._();

final class GetDisclosureBySlugUseCaseProvider
    extends
        $FunctionalProvider<
          GetDisclosureBySlug,
          GetDisclosureBySlug,
          GetDisclosureBySlug
        >
    with $Provider<GetDisclosureBySlug> {
  const GetDisclosureBySlugUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getDisclosureBySlugUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getDisclosureBySlugUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetDisclosureBySlug> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetDisclosureBySlug create(Ref ref) {
    return getDisclosureBySlugUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetDisclosureBySlug value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetDisclosureBySlug>(value),
    );
  }
}

String _$getDisclosureBySlugUseCaseHash() =>
    r'4670e1e8f46e66410276ba90132efc4c4ca265f6';
