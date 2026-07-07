// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads and edits the citizen's `/me/profile`. Falls back to the session user
/// when the dedicated profile endpoint is unavailable.

@ProviderFor(ProfileController)
const profileControllerProvider = ProfileControllerProvider._();

/// Loads and edits the citizen's `/me/profile`. Falls back to the session user
/// when the dedicated profile endpoint is unavailable.
final class ProfileControllerProvider
    extends $AsyncNotifierProvider<ProfileController, User> {
  /// Loads and edits the citizen's `/me/profile`. Falls back to the session user
  /// when the dedicated profile endpoint is unavailable.
  const ProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @$internal
  @override
  ProfileController create() => ProfileController();
}

String _$profileControllerHash() => r'8646de4657601ff7f7190d54cefcd110eb29ec08';

/// Loads and edits the citizen's `/me/profile`. Falls back to the session user
/// when the dedicated profile endpoint is unavailable.

abstract class _$ProfileController extends $AsyncNotifier<User> {
  FutureOr<User> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<User>, User>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<User>, User>,
              AsyncValue<User>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
