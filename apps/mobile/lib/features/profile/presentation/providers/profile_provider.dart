import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';

part 'profile_provider.g.dart';

/// Loads and edits the citizen's `/me/profile`. Falls back to the session user
/// when the dedicated profile endpoint is unavailable.
@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<User> build() async {
    final result =
        await ref.read(getProfileUseCaseProvider).call(const NoParams());
    return result.fold(
      (failure) {
        final sessionUser = ref.read(currentUserProvider);
        if (sessionUser != null) return sessionUser;
        throw failure;
      },
      (user) => user,
    );
  }

  /// Persists profile edits. Returns `true` on success and refreshes the
  /// session so session-derived screens reflect the change.
  Future<bool> saveProfile(UpdateProfileParams params) async {
    final result = await ref.read(updateProfileUseCaseProvider).call(params);
    return result.fold((_) => false, (user) {
      state = AsyncData(user);
      ref.invalidate(authStateProvider);
      return true;
    });
  }
}
