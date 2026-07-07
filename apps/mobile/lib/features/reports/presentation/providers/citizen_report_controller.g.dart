// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citizen_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives submission of a new citizen report (`POST /me/reports`).
///
/// [build] holds no state (the form owns its inputs); [submit] performs the
/// create and, on success, invalidates [myReportsProvider] so any list screen
/// refreshes. The method is named `submit` (not `update`/`refresh`, which are
/// reserved on AsyncNotifier).

@ProviderFor(CitizenReportController)
const citizenReportControllerProvider = CitizenReportControllerProvider._();

/// Drives submission of a new citizen report (`POST /me/reports`).
///
/// [build] holds no state (the form owns its inputs); [submit] performs the
/// create and, on success, invalidates [myReportsProvider] so any list screen
/// refreshes. The method is named `submit` (not `update`/`refresh`, which are
/// reserved on AsyncNotifier).
final class CitizenReportControllerProvider
    extends $AsyncNotifierProvider<CitizenReportController, void> {
  /// Drives submission of a new citizen report (`POST /me/reports`).
  ///
  /// [build] holds no state (the form owns its inputs); [submit] performs the
  /// create and, on success, invalidates [myReportsProvider] so any list screen
  /// refreshes. The method is named `submit` (not `update`/`refresh`, which are
  /// reserved on AsyncNotifier).
  const CitizenReportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'citizenReportControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$citizenReportControllerHash();

  @$internal
  @override
  CitizenReportController create() => CitizenReportController();
}

String _$citizenReportControllerHash() =>
    r'641bd51fa1f170d86bcdf4e36b0463c6c15c1b02';

/// Drives submission of a new citizen report (`POST /me/reports`).
///
/// [build] holds no state (the form owns its inputs); [submit] performs the
/// create and, on success, invalidates [myReportsProvider] so any list screen
/// refreshes. The method is named `submit` (not `update`/`refresh`, which are
/// reserved on AsyncNotifier).

abstract class _$CitizenReportController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
