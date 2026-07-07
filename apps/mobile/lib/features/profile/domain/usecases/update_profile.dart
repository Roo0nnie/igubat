import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../repositories/profile_repository.dart';

part 'update_profile.g.dart';

/// Mutable profile fields the citizen can edit (`UpdateProfileSchema`).
class UpdateProfileParams {
  const UpdateProfileParams({
    this.name,
    this.mobileNumber,
    this.barangay,
    this.address,
    this.image,
  });

  final String? name;
  final String? mobileNumber;
  final String? barangay;
  final String? address;
  final String? image;

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (mobileNumber != null) 'mobileNumber': mobileNumber,
    if (barangay != null) 'barangay': barangay,
    if (address != null) 'address': address,
    if (image != null) 'image': image,
  };
}

class UpdateProfile extends UseCase<User, UpdateProfileParams> {
  UpdateProfile(this._repository);

  final ProfileRepository _repository;

  @override
  FutureResult<User> call(UpdateProfileParams params) =>
      _repository.updateProfile(params);
}

@riverpod
UpdateProfile updateProfileUseCase(Ref ref) =>
    UpdateProfile(ref.watch(profileRepositoryProvider));
