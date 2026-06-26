// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_events.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(listEventsUseCase)
const listEventsUseCaseProvider = ListEventsUseCaseProvider._();

final class ListEventsUseCaseProvider
    extends $FunctionalProvider<ListEvents, ListEvents, ListEvents>
    with $Provider<ListEvents> {
  const ListEventsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listEventsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listEventsUseCaseHash();

  @$internal
  @override
  $ProviderElement<ListEvents> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ListEvents create(Ref ref) {
    return listEventsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListEvents value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListEvents>(value),
    );
  }
}

String _$listEventsUseCaseHash() => r'5ae196b5eb1da209333deadbb41c8472c9dd1a0f';
