// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mark_notification_read.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(markNotificationReadUseCase)
const markNotificationReadUseCaseProvider =
    MarkNotificationReadUseCaseProvider._();

final class MarkNotificationReadUseCaseProvider
    extends
        $FunctionalProvider<
          MarkNotificationRead,
          MarkNotificationRead,
          MarkNotificationRead
        >
    with $Provider<MarkNotificationRead> {
  const MarkNotificationReadUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'markNotificationReadUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$markNotificationReadUseCaseHash();

  @$internal
  @override
  $ProviderElement<MarkNotificationRead> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarkNotificationRead create(Ref ref) {
    return markNotificationReadUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarkNotificationRead value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarkNotificationRead>(value),
    );
  }
}

String _$markNotificationReadUseCaseHash() =>
    r'ffdd381f45635aa2a3758ea81023ac83be4a0507';
