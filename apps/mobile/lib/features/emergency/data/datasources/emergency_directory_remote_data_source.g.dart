// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_directory_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(emergencyDirectoryRemoteDataSource)
const emergencyDirectoryRemoteDataSourceProvider =
    EmergencyDirectoryRemoteDataSourceProvider._();

final class EmergencyDirectoryRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          EmergencyDirectoryRemoteDataSource,
          EmergencyDirectoryRemoteDataSource,
          EmergencyDirectoryRemoteDataSource
        >
    with $Provider<EmergencyDirectoryRemoteDataSource> {
  const EmergencyDirectoryRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emergencyDirectoryRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$emergencyDirectoryRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<EmergencyDirectoryRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmergencyDirectoryRemoteDataSource create(Ref ref) {
    return emergencyDirectoryRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmergencyDirectoryRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmergencyDirectoryRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$emergencyDirectoryRemoteDataSourceHash() =>
    r'6fcd202344b6b9a034a6f7a76027d3c6da9b9c8f';
