// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citizen_reports_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(citizenReportsRepository)
const citizenReportsRepositoryProvider = CitizenReportsRepositoryProvider._();

final class CitizenReportsRepositoryProvider
    extends
        $FunctionalProvider<
          CitizenReportsRepository,
          CitizenReportsRepository,
          CitizenReportsRepository
        >
    with $Provider<CitizenReportsRepository> {
  const CitizenReportsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'citizenReportsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$citizenReportsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CitizenReportsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CitizenReportsRepository create(Ref ref) {
    return citizenReportsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CitizenReportsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CitizenReportsRepository>(value),
    );
  }
}

String _$citizenReportsRepositoryHash() =>
    r'eec9892b0b5321bc92133dfe868c5bf50318d430';
