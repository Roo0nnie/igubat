import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// Citizen/staff role (backend `users.role`). Mobile users are
/// [UserRole.registeredCitizen]; staff roles exist for completeness.
enum UserRole {
  registeredCitizen,
  frontlineOfficer,
  departmentSupervisor,
  contentEditor,
  emergencyOperator,
  ictAdmin,
  superAdmin,
  unknown;

  static UserRole fromApi(String? value) => switch (value) {
    'registered_citizen' => UserRole.registeredCitizen,
    'frontline_officer' => UserRole.frontlineOfficer,
    'department_supervisor' => UserRole.departmentSupervisor,
    'content_editor' => UserRole.contentEditor,
    'emergency_operator' => UserRole.emergencyOperator,
    'ict_admin' => UserRole.ictAdmin,
    'super_admin' => UserRole.superAdmin,
    _ => UserRole.unknown,
  };

  bool get isCitizen => this == UserRole.registeredCitizen;
}

/// Account status (backend `users.status`).
enum UserStatus {
  active,
  locked,
  deactivated,
  unknown;

  static UserStatus fromApi(String? value) => switch (value) {
    'active' => UserStatus.active,
    'locked' => UserStatus.locked,
    'deactivated' => UserStatus.deactivated,
    _ => UserStatus.unknown,
  };
}

/// Domain entity for an authenticated citizen.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    String? image,
    @Default(false) bool emailVerified,
    @Default(UserRole.registeredCitizen) UserRole role,
    UserStatus? status,
    String? mobileNumber,
    String? barangay,
    String? address,
    @Default(false) bool dpaConsent,
    int? departmentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) = _User;
}
