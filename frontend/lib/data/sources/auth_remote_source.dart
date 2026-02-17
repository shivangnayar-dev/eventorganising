import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthRemoteSource {
  final _client = ApiClient.instance;

  Future<UserModel> login(
      {required String email, required String password}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data ?? const {};
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    if (accessToken != null && refreshToken != null) {
      await _client.saveTokens(accessToken, refreshToken);
    }
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? role,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
        if (role != null) 'role': role,
      },
    );
    final data = response.data ?? const {};
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    if (accessToken != null && refreshToken != null) {
      await _client.saveTokens(accessToken, refreshToken);
    }
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _client.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    await _client.post(
      '/auth/verify-otp',
      data: {'email': email, 'otp': otp},
    );
  }

  Future<UserModel> getProfile() async {
    final response = await _client.get<Map<String, dynamic>>('/auth/profile');
    return UserModel.fromJson(response.data ?? const {});
  }

  Future<String> refreshAccessToken(String refreshToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final data = response.data ?? const {};
    final accessToken = data['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Failed to refresh access token');
    }
    await _client.saveAccessToken(accessToken);
    return accessToken;
  }

  Future<void> logout() async {
    // Get refresh token before clearing
    final refreshToken = await SecureStorage.instance.read(
      AppConstants.refreshTokenKey,
    );
    
    // Call logout endpoint if we have a refresh token
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _client.post('/auth/logout', data: {'refreshToken': refreshToken});
      } catch (e) {
        // Ignore errors - clear tokens anyway
      }
    }
    
    // Clear tokens from storage
    await _client.clearTokens();
  }
}
