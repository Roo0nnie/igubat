// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_event.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getEventUseCase)
const getEventUseCaseProvider = GetEventUseCaseProvider._();

final class GetEventUseCaseProvider
    extends $FunctionalProvider<GetEvent, GetEvent, GetEvent>
    with $Provider<GetEvent> {
  const GetEventUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getEventUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getEventUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetEvent> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetEvent create(Ref ref) {
    return getEventUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetEvent value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetEvent>(value),
    );
  }
}

String _$getEventUseCaseHash() => r'49fd1df373b85af8a1dc0ac673b706e3516316da';
