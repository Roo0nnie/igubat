// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationPreferences {

 bool get news; bool get serviceRequests; bool get issueReports; bool get emergencyBroadcasts; bool get transparency; bool get pushEnabled; bool get emailEnabled;
/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<NotificationPreferences> get copyWith => _$NotificationPreferencesCopyWithImpl<NotificationPreferences>(this as NotificationPreferences, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferences&&(identical(other.news, news) || other.news == news)&&(identical(other.serviceRequests, serviceRequests) || other.serviceRequests == serviceRequests)&&(identical(other.issueReports, issueReports) || other.issueReports == issueReports)&&(identical(other.emergencyBroadcasts, emergencyBroadcasts) || other.emergencyBroadcasts == emergencyBroadcasts)&&(identical(other.transparency, transparency) || other.transparency == transparency)&&(identical(other.pushEnabled, pushEnabled) || other.pushEnabled == pushEnabled)&&(identical(other.emailEnabled, emailEnabled) || other.emailEnabled == emailEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,news,serviceRequests,issueReports,emergencyBroadcasts,transparency,pushEnabled,emailEnabled);

@override
String toString() {
  return 'NotificationPreferences(news: $news, serviceRequests: $serviceRequests, issueReports: $issueReports, emergencyBroadcasts: $emergencyBroadcasts, transparency: $transparency, pushEnabled: $pushEnabled, emailEnabled: $emailEnabled)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferencesCopyWith<$Res>  {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value, $Res Function(NotificationPreferences) _then) = _$NotificationPreferencesCopyWithImpl;
@useResult
$Res call({
 bool news, bool serviceRequests, bool issueReports, bool emergencyBroadcasts, bool transparency, bool pushEnabled, bool emailEnabled
});




}
/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final NotificationPreferences _self;
  final $Res Function(NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? news = null,Object? serviceRequests = null,Object? issueReports = null,Object? emergencyBroadcasts = null,Object? transparency = null,Object? pushEnabled = null,Object? emailEnabled = null,}) {
  return _then(_self.copyWith(
news: null == news ? _self.news : news // ignore: cast_nullable_to_non_nullable
as bool,serviceRequests: null == serviceRequests ? _self.serviceRequests : serviceRequests // ignore: cast_nullable_to_non_nullable
as bool,issueReports: null == issueReports ? _self.issueReports : issueReports // ignore: cast_nullable_to_non_nullable
as bool,emergencyBroadcasts: null == emergencyBroadcasts ? _self.emergencyBroadcasts : emergencyBroadcasts // ignore: cast_nullable_to_non_nullable
as bool,transparency: null == transparency ? _self.transparency : transparency // ignore: cast_nullable_to_non_nullable
as bool,pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPreferences].
extension NotificationPreferencesPatterns on NotificationPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreferences value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool news,  bool serviceRequests,  bool issueReports,  bool emergencyBroadcasts,  bool transparency,  bool pushEnabled,  bool emailEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.news,_that.serviceRequests,_that.issueReports,_that.emergencyBroadcasts,_that.transparency,_that.pushEnabled,_that.emailEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool news,  bool serviceRequests,  bool issueReports,  bool emergencyBroadcasts,  bool transparency,  bool pushEnabled,  bool emailEnabled)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences():
return $default(_that.news,_that.serviceRequests,_that.issueReports,_that.emergencyBroadcasts,_that.transparency,_that.pushEnabled,_that.emailEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool news,  bool serviceRequests,  bool issueReports,  bool emergencyBroadcasts,  bool transparency,  bool pushEnabled,  bool emailEnabled)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.news,_that.serviceRequests,_that.issueReports,_that.emergencyBroadcasts,_that.transparency,_that.pushEnabled,_that.emailEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationPreferences extends NotificationPreferences {
  const _NotificationPreferences({this.news = true, this.serviceRequests = true, this.issueReports = true, this.emergencyBroadcasts = true, this.transparency = true, this.pushEnabled = true, this.emailEnabled = true}): super._();
  

@override@JsonKey() final  bool news;
@override@JsonKey() final  bool serviceRequests;
@override@JsonKey() final  bool issueReports;
@override@JsonKey() final  bool emergencyBroadcasts;
@override@JsonKey() final  bool transparency;
@override@JsonKey() final  bool pushEnabled;
@override@JsonKey() final  bool emailEnabled;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferencesCopyWith<_NotificationPreferences> get copyWith => __$NotificationPreferencesCopyWithImpl<_NotificationPreferences>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferences&&(identical(other.news, news) || other.news == news)&&(identical(other.serviceRequests, serviceRequests) || other.serviceRequests == serviceRequests)&&(identical(other.issueReports, issueReports) || other.issueReports == issueReports)&&(identical(other.emergencyBroadcasts, emergencyBroadcasts) || other.emergencyBroadcasts == emergencyBroadcasts)&&(identical(other.transparency, transparency) || other.transparency == transparency)&&(identical(other.pushEnabled, pushEnabled) || other.pushEnabled == pushEnabled)&&(identical(other.emailEnabled, emailEnabled) || other.emailEnabled == emailEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,news,serviceRequests,issueReports,emergencyBroadcasts,transparency,pushEnabled,emailEnabled);

@override
String toString() {
  return 'NotificationPreferences(news: $news, serviceRequests: $serviceRequests, issueReports: $issueReports, emergencyBroadcasts: $emergencyBroadcasts, transparency: $transparency, pushEnabled: $pushEnabled, emailEnabled: $emailEnabled)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferencesCopyWith<$Res> implements $NotificationPreferencesCopyWith<$Res> {
  factory _$NotificationPreferencesCopyWith(_NotificationPreferences value, $Res Function(_NotificationPreferences) _then) = __$NotificationPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool news, bool serviceRequests, bool issueReports, bool emergencyBroadcasts, bool transparency, bool pushEnabled, bool emailEnabled
});




}
/// @nodoc
class __$NotificationPreferencesCopyWithImpl<$Res>
    implements _$NotificationPreferencesCopyWith<$Res> {
  __$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final _NotificationPreferences _self;
  final $Res Function(_NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? news = null,Object? serviceRequests = null,Object? issueReports = null,Object? emergencyBroadcasts = null,Object? transparency = null,Object? pushEnabled = null,Object? emailEnabled = null,}) {
  return _then(_NotificationPreferences(
news: null == news ? _self.news : news // ignore: cast_nullable_to_non_nullable
as bool,serviceRequests: null == serviceRequests ? _self.serviceRequests : serviceRequests // ignore: cast_nullable_to_non_nullable
as bool,issueReports: null == issueReports ? _self.issueReports : issueReports // ignore: cast_nullable_to_non_nullable
as bool,emergencyBroadcasts: null == emergencyBroadcasts ? _self.emergencyBroadcasts : emergencyBroadcasts // ignore: cast_nullable_to_non_nullable
as bool,transparency: null == transparency ? _self.transparency : transparency // ignore: cast_nullable_to_non_nullable
as bool,pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
