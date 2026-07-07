import '../../../../core/usecases/result.dart';
import '../../../auth/domain/entities/user.dart';
import '../usecases/update_profile.dart';

/// Citizen profile contract (`/me/profile`). Returns the shared [User] entity.
abstract interface class ProfileRepository {
  FutureResult<User> getProfile();

  FutureResult<User> updateProfile(UpdateProfileParams params);
}
