// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(signInUseCase)
const signInUseCaseProvider = SignInUseCaseProvider._();

final class SignInUseCaseProvider
    extends $FunctionalProvider<SignIn, SignIn, SignIn>
    with $Provider<SignIn> {
  const SignInUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignIn> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignIn create(Ref ref) {
    return signInUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignIn value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignIn>(value),
    );
  }
}

String _$signInUseCaseHash() => r'f886f4410e36074f6efd2b29ffa00cc821ab263f';
