// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_notifications.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getNotificationsUseCase)
const getNotificationsUseCaseProvider = GetNotificationsUseCaseProvider._();

final class GetNotificationsUseCaseProvider
    extends
        $FunctionalProvider<
          GetNotifications,
          GetNotifications,
          GetNotifications
        >
    with $Provider<GetNotifications> {
  const GetNotificationsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getNotificationsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getNotificationsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetNotifications> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetNotifications create(Ref ref) {
    return getNotificationsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetNotifications value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetNotifications>(value),
    );
  }
}

String _$getNotificationsUseCaseHash() =>
    r'0ed0c25d424514b24e9a4d303555497ab28f8920';
