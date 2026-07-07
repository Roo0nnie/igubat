import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/base_repository.dart';
import '../../../../core/usecases/result.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

part 'auth_repository_impl.g.dart';

/// Fulfils the [AuthRepository] contract: delegates to the remote data source
/// and maps DTOs to domain entities, wrapping everything in `Either`.
class AuthRepositoryImpl with BaseRepository implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  FutureResult<Session?> signIn({
    required String email,
    required String password,
  }) => execute(() async {
    final model = await _remote.signIn(email: email, password: password);
    return model?.toEntity();
  });

  @override
  FutureResult<Unit> signUp({
    required String email,
    required String password,
    required String name,
    required String mobileNumber,
    required String barangay,
    required String address,
    required bool dpaConsent,
  }) => execute(() async {
    await _remote.signUp(
      email: email,
      password: password,
      name: name,
      mobileNumber: mobileNumber,
      barangay: barangay,
      address: address,
      dpaConsent: dpaConsent,
    );
    return unit;
  });

  @override
  FutureResult<Unit> sendVerificationOtp({required String email}) =>
      execute(() async {
        await _remote.sendVerificationOtp(email: email);
        return unit;
      });

  @override
  FutureResult<Session?> verifyEmailOtp({
    required String email,
    required String otp,
  }) => execute(() async {
    final model = await _remote.verifyEmailOtp(email: email, otp: otp);
    return model?.toEntity();
  });

  @override
  FutureResult<Unit> signOut() => execute(() async {
    await _remote.signOut();
    return unit;
  });

  @override
  FutureResult<Session?> getCurrentSession() => execute(() async {
    final model = await _remote.getSession();
    return model?.toEntity();
  });
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
