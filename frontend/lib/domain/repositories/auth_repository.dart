import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String email, required String password});

  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? role,
  });

  Future<void> requestPasswordReset({required String email});

  Future<void> verifyOtp({required String email, required String otp});

  Future<UserEntity> getProfile();

  Future<String> refreshAccessToken(String refreshToken);

  Future<void> logout();
}
