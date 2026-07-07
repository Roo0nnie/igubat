// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_current_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getCurrentSessionUseCase)
const getCurrentSessionUseCaseProvider = GetCurrentSessionUseCaseProvider._();

final class GetCurrentSessionUseCaseProvider
    extends
        $FunctionalProvider<
          GetCurrentSession,
          GetCurrentSession,
          GetCurrentSession
        >
    with $Provider<GetCurrentSession> {
  const GetCurrentSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCurrentSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCurrentSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCurrentSession> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCurrentSession create(Ref ref) {
    return getCurrentSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentSession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentSession>(value),
    );
  }
}

String _$getCurrentSessionUseCaseHash() =>
    r'd05366f31490a7f29a41e23f0031fea06099338d';
