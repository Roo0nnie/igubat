// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mark_all_notifications_read.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(markAllNotificationsReadUseCase)
const markAllNotificationsReadUseCaseProvider =
    MarkAllNotificationsReadUseCaseProvider._();

final class MarkAllNotificationsReadUseCaseProvider
    extends
        $FunctionalProvider<
          MarkAllNotificationsRead,
          MarkAllNotificationsRead,
          MarkAllNotificationsRead
        >
    with $Provider<MarkAllNotificationsRead> {
  const MarkAllNotificationsReadUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'markAllNotificationsReadUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$markAllNotificationsReadUseCaseHash();

  @$internal
  @override
  $ProviderElement<MarkAllNotificationsRead> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarkAllNotificationsRead create(Ref ref) {
    return markAllNotificationsReadUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarkAllNotificationsRead value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarkAllNotificationsRead>(value),
    );
  }
}

String _$markAllNotificationsReadUseCaseHash() =>
    r'0f0f5e73a8e4bba87cc931752769f1c1a0971971';
