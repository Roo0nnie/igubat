// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_report.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(createReportUseCase)
const createReportUseCaseProvider = CreateReportUseCaseProvider._();

final class CreateReportUseCaseProvider
    extends $FunctionalProvider<CreateReport, CreateReport, CreateReport>
    with $Provider<CreateReport> {
  const CreateReportUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createReportUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createReportUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateReport> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateReport create(Ref ref) {
    return createReportUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateReport value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateReport>(value),
    );
  }
}

String _$createReportUseCaseHash() =>
    r'c8992a822ecd768eba41c5dc01b9f2aa704d9c1c';
