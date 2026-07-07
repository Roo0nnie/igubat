// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_otp.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(verifyEmailOtpUseCase)
const verifyEmailOtpUseCaseProvider = VerifyEmailOtpUseCaseProvider._();

final class VerifyEmailOtpUseCaseProvider
    extends $FunctionalProvider<VerifyEmailOtp, VerifyEmailOtp, VerifyEmailOtp>
    with $Provider<VerifyEmailOtp> {
  const VerifyEmailOtpUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifyEmailOtpUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verifyEmailOtpUseCaseHash();

  @$internal
  @override
  $ProviderElement<VerifyEmailOtp> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VerifyEmailOtp create(Ref ref) {
    return verifyEmailOtpUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifyEmailOtp value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifyEmailOtp>(value),
    );
  }
}

String _$verifyEmailOtpUseCaseHash() =>
    r'a2f9f3f7767384d66860cd338ded35278bfabe87';
