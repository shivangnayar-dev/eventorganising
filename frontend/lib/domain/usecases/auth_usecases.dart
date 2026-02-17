import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class AuthUseCases {
  const AuthUseCases(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> login(String email, String password) =>
      _repository.login(email: email, password: password);

  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? role,
  }) =>
      _repository.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
      );

  Future<void> requestPasswordReset(String email) =>
      _repository.requestPasswordReset(email: email);

  Future<void> verifyOtp(String email, String otp) =>
      _repository.verifyOtp(email: email, otp: otp);

  Future<UserEntity> getProfile() => _repository.getProfile();

  Future<String> refreshAccessToken(String refreshToken) =>
      _repository.refreshAccessToken(refreshToken);

  Future<void> logout() => _repository.logout();
}
