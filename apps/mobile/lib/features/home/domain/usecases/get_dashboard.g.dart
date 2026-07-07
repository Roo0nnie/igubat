// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_dashboard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getDashboardUseCase)
const getDashboardUseCaseProvider = GetDashboardUseCaseProvider._();

final class GetDashboardUseCaseProvider
    extends $FunctionalProvider<GetDashboard, GetDashboard, GetDashboard>
    with $Provider<GetDashboard> {
  const GetDashboardUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getDashboardUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getDashboardUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetDashboard> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetDashboard create(Ref ref) {
    return getDashboardUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetDashboard value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetDashboard>(value),
    );
  }
}

String _$getDashboardUseCaseHash() =>
    r'99b9c07170c42a03bb9ba0929585d2407644f487';
