import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'session.freezed.dart';

/// The session token + metadata, decoupled from Better Auth's two response
/// shapes (sign-in `{token,user}` vs get-session `{session,user}`).
@freezed
abstract class SessionToken with _$SessionToken {
  const factory SessionToken({
    required String value,
    String? id,
    String? userId,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SessionToken;
}

/// An authenticated session: a [SessionToken] paired with its [User].
@freezed
abstract class Session with _$Session {
  const factory Session({
    required SessionToken token,
    required User user,
  }) = _Session;
}
