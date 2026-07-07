// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_verification_otp.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sendVerificationOtpUseCase)
const sendVerificationOtpUseCaseProvider =
    SendVerificationOtpUseCaseProvider._();

final class SendVerificationOtpUseCaseProvider
    extends
        $FunctionalProvider<
          SendVerificationOtp,
          SendVerificationOtp,
          SendVerificationOtp
        >
    with $Provider<SendVerificationOtp> {
  const SendVerificationOtpUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendVerificationOtpUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendVerificationOtpUseCaseHash();

  @$internal
  @override
  $ProviderElement<SendVerificationOtp> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SendVerificationOtp create(Ref ref) {
    return sendVerificationOtpUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SendVerificationOtp value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SendVerificationOtp>(value),
    );
  }
}

String _$sendVerificationOtpUseCaseHash() =>
    r'630b845b5dfa69e437e424d35c69e4e3be0a235e';
