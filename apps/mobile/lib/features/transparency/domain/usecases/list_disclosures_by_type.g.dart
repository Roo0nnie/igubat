// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_disclosures_by_type.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(listDisclosuresByTypeUseCase)
const listDisclosuresByTypeUseCaseProvider =
    ListDisclosuresByTypeUseCaseProvider._();

final class ListDisclosuresByTypeUseCaseProvider
    extends
        $FunctionalProvider<
          ListDisclosuresByType,
          ListDisclosuresByType,
          ListDisclosuresByType
        >
    with $Provider<ListDisclosuresByType> {
  const ListDisclosuresByTypeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listDisclosuresByTypeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listDisclosuresByTypeUseCaseHash();

  @$internal
  @override
  $ProviderElement<ListDisclosuresByType> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListDisclosuresByType create(Ref ref) {
    return listDisclosuresByTypeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListDisclosuresByType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListDisclosuresByType>(value),
    );
  }
}

String _$listDisclosuresByTypeUseCaseHash() =>
    r'5759748ac7ba3b1ff0cc5e063000ccea34f69ecf';
