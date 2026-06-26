// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$User {

 String get id; String get name; String get email; String? get image; bool get emailVerified; UserRole get role; UserStatus? get status; String? get mobileNumber; String? get barangay; String? get address; bool get dpaConsent; int? get departmentId; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get lastLoginAt;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.image, image) || other.image == image)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.address, address) || other.address == address)&&(identical(other.dpaConsent, dpaConsent) || other.dpaConsent == dpaConsent)&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,email,image,emailVerified,role,status,mobileNumber,barangay,address,dpaConsent,departmentId,createdAt,updatedAt,lastLoginAt);

@override
String toString() {
  return 'User(id: $id, name: $name, email: $email, image: $image, emailVerified: $emailVerified, role: $role, status: $status, mobileNumber: $mobileNumber, barangay: $barangay, address: $address, dpaConsent: $dpaConsent, departmentId: $departmentId, createdAt: $createdAt, updatedAt: $updatedAt, lastLoginAt: $lastLoginAt)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String? image, bool emailVerified, UserRole role, UserStatus? status, String? mobileNumber, String? barangay, String? address, bool dpaConsent, int? departmentId, DateTime? createdAt, DateTime? updatedAt, DateTime? lastLoginAt
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? image = freezed,Object? emailVerified = null,Object? role = null,Object? status = freezed,Object? mobileNumber = freezed,Object? barangay = freezed,Object? address = freezed,Object? dpaConsent = null,Object? departmentId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastLoginAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus?,mobileNumber: freezed == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,dpaConsent: null == dpaConsent ? _self.dpaConsent : dpaConsent // ignore: cast_nullable_to_non_nullable
as bool,departmentId: freezed == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String? image,  bool emailVerified,  UserRole role,  UserStatus? status,  String? mobileNumber,  String? barangay,  String? address,  bool dpaConsent,  int? departmentId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? lastLoginAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.image,_that.emailVerified,_that.role,_that.status,_that.mobileNumber,_that.barangay,_that.address,_that.dpaConsent,_that.departmentId,_that.createdAt,_that.updatedAt,_that.lastLoginAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String? image,  bool emailVerified,  UserRole role,  UserStatus? status,  String? mobileNumber,  String? barangay,  String? address,  bool dpaConsent,  int? departmentId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? lastLoginAt)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.name,_that.email,_that.image,_that.emailVerified,_that.role,_that.status,_that.mobileNumber,_that.barangay,_that.address,_that.dpaConsent,_that.departmentId,_that.createdAt,_that.updatedAt,_that.lastLoginAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String? image,  bool emailVerified,  UserRole role,  UserStatus? status,  String? mobileNumber,  String? barangay,  String? address,  bool dpaConsent,  int? departmentId,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? lastLoginAt)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.image,_that.emailVerified,_that.role,_that.status,_that.mobileNumber,_that.barangay,_that.address,_that.dpaConsent,_that.departmentId,_that.createdAt,_that.updatedAt,_that.lastLoginAt);case _:
  return null;

}
}

}

/// @nodoc


class _User implements User {
  const _User({required this.id, required this.name, required this.email, this.image, this.emailVerified = false, this.role = UserRole.registeredCitizen, this.status, this.mobileNumber, this.barangay, this.address, this.dpaConsent = false, this.departmentId, this.createdAt, this.updatedAt, this.lastLoginAt});
  

@override final  String id;
@override final  String name;
@override final  String email;
@override final  String? image;
@override@JsonKey() final  bool emailVerified;
@override@JsonKey() final  UserRole role;
@override final  UserStatus? status;
@override final  String? mobileNumber;
@override final  String? barangay;
@override final  String? address;
@override@JsonKey() final  bool dpaConsent;
@override final  int? departmentId;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? lastLoginAt;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.image, image) || other.image == image)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.address, address) || other.address == address)&&(identical(other.dpaConsent, dpaConsent) || other.dpaConsent == dpaConsent)&&(identical(other.departmentId, departmentId) || other.departmentId == departmentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,email,image,emailVerified,role,status,mobileNumber,barangay,address,dpaConsent,departmentId,createdAt,updatedAt,lastLoginAt);

@override
String toString() {
  return 'User(id: $id, name: $name, email: $email, image: $image, emailVerified: $emailVerified, role: $role, status: $status, mobileNumber: $mobileNumber, barangay: $barangay, address: $address, dpaConsent: $dpaConsent, departmentId: $departmentId, createdAt: $createdAt, updatedAt: $updatedAt, lastLoginAt: $lastLoginAt)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String? image, bool emailVerified, UserRole role, UserStatus? status, String? mobileNumber, String? barangay, String? address, bool dpaConsent, int? departmentId, DateTime? createdAt, DateTime? updatedAt, DateTime? lastLoginAt
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? image = freezed,Object? emailVerified = null,Object? role = null,Object? status = freezed,Object? mobileNumber = freezed,Object? barangay = freezed,Object? address = freezed,Object? dpaConsent = null,Object? departmentId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? lastLoginAt = freezed,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UserStatus?,mobileNumber: freezed == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,dpaConsent: null == dpaConsent ? _self.dpaConsent : dpaConsent // ignore: cast_nullable_to_non_nullable
as bool,departmentId: freezed == departmentId ? _self.departmentId : departmentId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
