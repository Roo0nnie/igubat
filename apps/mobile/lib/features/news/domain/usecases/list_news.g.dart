// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_news.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(listNewsUseCase)
const listNewsUseCaseProvider = ListNewsUseCaseProvider._();

final class ListNewsUseCaseProvider
    extends $FunctionalProvider<ListNews, ListNews, ListNews>
    with $Provider<ListNews> {
  const ListNewsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listNewsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listNewsUseCaseHash();

  @$internal
  @override
  $ProviderElement<ListNews> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ListNews create(Ref ref) {
    return listNewsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListNews value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListNews>(value),
    );
  }
}

String _$listNewsUseCaseHash() => r'8368b8cd78e1c29d2c8b0b6f6ba5aa489af3363e';
