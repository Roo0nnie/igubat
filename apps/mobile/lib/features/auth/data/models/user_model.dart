import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// DTO for the Better Auth `user` object (and `/me/profile`). Maps to the
/// [User] domain entity via [toEntity].
@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String name,
    required String email,
    String? image,
    @Default(false) bool emailVerified,
    String? role,
    String? status,
    String? mobileNumber,
    String? barangay,
    String? address,
    @Default(false) bool dpaConsent,
    int? departmentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  User toEntity() => User(
    id: id,
    name: name,
    email: email,
    image: image,
    emailVerified: emailVerified,
    role: UserRole.fromApi(role),
    status: status == null ? null : UserStatus.fromApi(status),
    mobileNumber: mobileNumber,
    barangay: barangay,
    address: address,
    dpaConsent: dpaConsent,
    departmentId: departmentId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    lastLoginAt: lastLoginAt,
  );
}
