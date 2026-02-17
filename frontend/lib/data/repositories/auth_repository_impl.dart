import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../sources/auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteSource);

  final AuthRemoteSource _remoteSource;

  @override
  Future<UserEntity> login(
      {required String email, required String password}) async {
    final user = await _remoteSource.login(email: email, password: password);
    return user;
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? role,
  }) async {
    final user = await _remoteSource.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      role: role,
    );
    return user;
  }

  @override
  Future<void> requestPasswordReset({required String email}) =>
      _remoteSource.requestPasswordReset(email: email);

  @override
  Future<void> verifyOtp({required String email, required String otp}) =>
      _remoteSource.verifyOtp(email: email, otp: otp);

  @override
  Future<UserEntity> getProfile() async {
    final user = await _remoteSource.getProfile();
    return user;
  }

  @override
  Future<String> refreshAccessToken(String refreshToken) =>
      _remoteSource.refreshAccessToken(refreshToken);

  @override
  Future<void> logout() => _remoteSource.logout();
}
