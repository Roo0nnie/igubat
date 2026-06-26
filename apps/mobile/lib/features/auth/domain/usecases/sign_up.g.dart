// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(signUpUseCase)
const signUpUseCaseProvider = SignUpUseCaseProvider._();

final class SignUpUseCaseProvider
    extends $FunctionalProvider<SignUp, SignUp, SignUp>
    with $Provider<SignUp> {
  const SignUpUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignUp> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignUp create(Ref ref) {
    return signUpUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignUp value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignUp>(value),
    );
  }
}

String _$signUpUseCaseHash() => r'2dd0625d879cabd020041bf9d058eb8a95b2d55f';
