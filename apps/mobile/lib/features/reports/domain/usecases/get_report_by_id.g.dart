// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_report_by_id.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getReportByIdUseCase)
const getReportByIdUseCaseProvider = GetReportByIdUseCaseProvider._();

final class GetReportByIdUseCaseProvider
    extends $FunctionalProvider<GetReportById, GetReportById, GetReportById>
    with $Provider<GetReportById> {
  const GetReportByIdUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getReportByIdUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getReportByIdUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetReportById> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetReportById create(Ref ref) {
    return getReportByIdUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetReportById value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetReportById>(value),
    );
  }
}

String _$getReportByIdUseCaseHash() =>
    r'cc6338686a2908e32cb7e0a0ce67854ba926f7c6';
