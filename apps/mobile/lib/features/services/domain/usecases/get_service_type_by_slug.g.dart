// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_service_type_by_slug.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getServiceTypeBySlugUseCase)
const getServiceTypeBySlugUseCaseProvider =
    GetServiceTypeBySlugUseCaseProvider._();

final class GetServiceTypeBySlugUseCaseProvider
    extends
        $FunctionalProvider<
          GetServiceTypeBySlug,
          GetServiceTypeBySlug,
          GetServiceTypeBySlug
        >
    with $Provider<GetServiceTypeBySlug> {
  const GetServiceTypeBySlugUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getServiceTypeBySlugUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getServiceTypeBySlugUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetServiceTypeBySlug> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetServiceTypeBySlug create(Ref ref) {
    return getServiceTypeBySlugUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetServiceTypeBySlug value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetServiceTypeBySlug>(value),
    );
  }
}

String _$getServiceTypeBySlugUseCaseHash() =>
    r'faf98b859a5be32daedaa64ac6eb64708e962521';
