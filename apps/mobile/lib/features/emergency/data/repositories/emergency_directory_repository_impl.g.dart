// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_directory_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(emergencyDirectoryRepository)
const emergencyDirectoryRepositoryProvider =
    EmergencyDirectoryRepositoryProvider._();

final class EmergencyDirectoryRepositoryProvider
    extends
        $FunctionalProvider<
          EmergencyDirectoryRepository,
          EmergencyDirectoryRepository,
          EmergencyDirectoryRepository
        >
    with $Provider<EmergencyDirectoryRepository> {
  const EmergencyDirectoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emergencyDirectoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emergencyDirectoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<EmergencyDirectoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EmergencyDirectoryRepository create(Ref ref) {
    return emergencyDirectoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmergencyDirectoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmergencyDirectoryRepository>(value),
    );
  }
}

String _$emergencyDirectoryRepositoryHash() =>
    r'a338a112d5ab0e82a0de51b9bea5954b018b10bd';
