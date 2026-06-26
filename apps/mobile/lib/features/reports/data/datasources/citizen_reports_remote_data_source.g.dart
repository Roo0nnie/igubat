// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citizen_reports_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(citizenReportsRemoteDataSource)
const citizenReportsRemoteDataSourceProvider =
    CitizenReportsRemoteDataSourceProvider._();

final class CitizenReportsRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          CitizenReportsRemoteDataSource,
          CitizenReportsRemoteDataSource,
          CitizenReportsRemoteDataSource
        >
    with $Provider<CitizenReportsRemoteDataSource> {
  const CitizenReportsRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'citizenReportsRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$citizenReportsRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<CitizenReportsRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CitizenReportsRemoteDataSource create(Ref ref) {
    return citizenReportsRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CitizenReportsRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CitizenReportsRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$citizenReportsRemoteDataSourceHash() =>
    r'0c7ff48544ac1e49ae9caea1a589e060a8f33e21';
