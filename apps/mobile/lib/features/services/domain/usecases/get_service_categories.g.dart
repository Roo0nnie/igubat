// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_service_categories.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getServiceCategoriesUseCase)
const getServiceCategoriesUseCaseProvider =
    GetServiceCategoriesUseCaseProvider._();

final class GetServiceCategoriesUseCaseProvider
    extends
        $FunctionalProvider<
          GetServiceCategories,
          GetServiceCategories,
          GetServiceCategories
        >
    with $Provider<GetServiceCategories> {
  const GetServiceCategoriesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getServiceCategoriesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getServiceCategoriesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetServiceCategories> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetServiceCategories create(Ref ref) {
    return getServiceCategoriesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetServiceCategories value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetServiceCategories>(value),
    );
  }
}

String _$getServiceCategoriesUseCaseHash() =>
    r'cfbc804175bdaa06a98aa1e0b8a844a302b0cf33';
