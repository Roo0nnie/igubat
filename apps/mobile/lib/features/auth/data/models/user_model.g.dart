// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  image: json['image'] as String?,
  emailVerified: json['emailVerified'] as bool? ?? false,
  role: json['role'] as String?,
  status: json['status'] as String?,
  mobileNumber: json['mobileNumber'] as String?,
  barangay: json['barangay'] as String?,
  address: json['address'] as String?,
  dpaConsent: json['dpaConsent'] as bool? ?? false,
  departmentId: (json['departmentId'] as num?)?.toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'image': instance.image,
      'emailVerified': instance.emailVerified,
      'role': instance.role,
      'status': instance.status,
      'mobileNumber': instance.mobileNumber,
      'barangay': instance.barangay,
      'address': instance.address,
      'dpaConsent': instance.dpaConsent,
      'departmentId': instance.departmentId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
    };
