// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_my_reports.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getMyReportsUseCase)
const getMyReportsUseCaseProvider = GetMyReportsUseCaseProvider._();

final class GetMyReportsUseCaseProvider
    extends $FunctionalProvider<GetMyReports, GetMyReports, GetMyReports>
    with $Provider<GetMyReports> {
  const GetMyReportsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMyReportsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMyReportsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMyReports> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetMyReports create(Ref ref) {
    return getMyReportsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMyReports value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMyReports>(value),
    );
  }
}

String _$getMyReportsUseCaseHash() =>
    r'503b769cd3ec2e8b08b708094fcd961dfe450f63';
