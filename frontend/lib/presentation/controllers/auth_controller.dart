import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../providers/app_providers.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final useCases = ref.read(authUseCasesProvider);
  return AuthController(useCases)..restoreSession();
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._useCases) : super(AuthState.initial());

  final AuthUseCases _useCases;
  final _controller = StreamController<AuthState>.broadcast();
  // Use shared storage instance for consistency
  final _secureStorage = SecureStorage.instance;

  Stream<AuthState> get authStateStream => _controller.stream;

  Future<void> restoreSession() async {
    // Set status to restoring to prevent router from redirecting during restoration
    state = state.copyWith(status: AuthStatus.restoring);
    _controller.add(state);

    try {
      // First check if access token exists in storage
      String? token;
      try {
        if (kIsWeb) {
          print('[Auth] restoreSession: Attempting to read access token from storage...');
        }
        token = await _secureStorage.read(AppConstants.tokenKey);
        // Debug: Log token existence (don't log the actual token for security)
        if (kIsWeb) {
          print('[Auth] restoreSession: Access token read result - exists: ${token != null && token.isNotEmpty}, length: ${token?.length ?? 0}');
          // Also check if we can read all keys to verify storage is working
          try {
            final allKeys = await _secureStorage.readAll();
            print('[Auth] restoreSession: Storage has ${allKeys.length} keys: ${allKeys.keys.toList()}');
          } catch (e) {
            print('[Auth] restoreSession: Could not read all keys: $e');
          }
        }
      } catch (e) {
        // Storage read error - assume no token
        token = null;
        if (kIsWeb) {
          print('[Auth] restoreSession: Error reading access token: $e');
          print('[Auth] restoreSession: Error type: ${e.runtimeType}');
        }
      }
      
      // If no access token exists, try to use refresh token
      if (token == null || token.isEmpty) {
        if (kIsWeb) {
          print('[Auth] restoreSession: No access token found, checking for refresh token...');
        }
        try {
          final refreshToken = await _secureStorage.read(AppConstants.refreshTokenKey);
          if (refreshToken != null && refreshToken.isNotEmpty) {
            if (kIsWeb) {
              print('[Auth] restoreSession: Refresh token found, attempting to refresh access token...');
            }
            try {
              // Use refresh token to get new access token
              final newAccessToken = await _useCases.refreshAccessToken(refreshToken);
              if (kIsWeb) {
                print('[Auth] restoreSession: Successfully refreshed access token');
              }
              token = newAccessToken;
            } catch (refreshError) {
              if (kIsWeb) {
                print('[Auth] restoreSession: Failed to refresh token: $refreshError');
              }
              // Refresh failed - clear tokens and log out
              await _secureStorage.delete(AppConstants.tokenKey);
              await _secureStorage.delete(AppConstants.refreshTokenKey);
              state = AuthState.initial();
              _controller.add(state);
              return;
            }
          } else {
            if (kIsWeb) {
              print('[Auth] restoreSession: No refresh token found, staying logged out');
            }
            state = AuthState.initial();
            _controller.add(state);
            return;
          }
        } catch (e) {
          if (kIsWeb) {
            print('[Auth] restoreSession: Error reading refresh token: $e');
          }
          state = AuthState.initial();
          _controller.add(state);
          return;
        }
      }
      
      // If still no token, stay logged out
      if (token == null || token.isEmpty) {
        if (kIsWeb) {
          print('[Auth] restoreSession: No token available, staying logged out');
        }
        state = AuthState.initial();
        _controller.add(state);
        return;
      }

      // Token exists, try to restore session by fetching profile
      if (kIsWeb) {
        print('[Auth] Token found, fetching profile...');
      }
      try {
        final user = await _useCases.getProfile();
        if (kIsWeb) {
          print('[Auth] Profile fetched successfully, user: ${user.email}');
        }
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        _controller.add(state);
      } catch (profileError) {
        // If getProfile fails, check if it's an auth error
        if (profileError is AppException) {
          if (kIsWeb) {
            print('[Auth] getProfile error: ${profileError.code} - ${profileError.message}');
          }
          if (profileError.code == 401 || profileError.code == 403) {
            // Token is invalid, clear it and log out
            if (kIsWeb) {
              print('[Auth] Token invalid (${profileError.code}), logging out');
            }
            try {
              await _secureStorage.delete(AppConstants.tokenKey);
            } catch (_) {
              // Ignore errors clearing token
            }
            state = AuthState.initial();
            _controller.add(state);
          } else {
            // Network or other error - token exists, so keep user logged in
            // Re-throw to be caught by outer catch block
            if (kIsWeb) {
              print('[Auth] Non-auth error (${profileError.code}), keeping token');
            }
            rethrow;
          }
        } else {
          if (kIsWeb) {
            print('[Auth] Unexpected error in getProfile: $profileError');
          }
          rethrow;
        }
      }
    } on AppException catch (error) {
      // Only clear state if it's an authentication error (401/403)
      // This means the token is invalid or expired
      if (error.code == 401 || error.code == 403) {
        // Clear invalid token
        try {
          await _secureStorage.delete(AppConstants.tokenKey);
        } catch (_) {
          // Ignore errors clearing token
        }
        state = AuthState.initial();
        _controller.add(state);
      } else {
        // For other errors (network, server errors), check if token still exists
        // If token exists, keep user logged in - might be temporary network issue
        try {
          final token = await _secureStorage.read(AppConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            // Token exists but API call failed - keep user logged in
            // Use existing user if available, otherwise stay in restoring state
            // This prevents logout on temporary network issues
            if (state.user != null) {
              // Keep existing user data
              state = state.copyWith(status: AuthStatus.authenticated);
            } else {
              // No user data, but token exists - stay in restoring to prevent redirect
              // Router will wait, and user can retry
              state = state.copyWith(status: AuthStatus.restoring);
            }
            _controller.add(state);
          } else {
            // No token, stay logged out
            state = AuthState.initial();
            _controller.add(state);
          }
        } catch (_) {
          // Can't check token, assume logged out
          state = AuthState.initial();
          _controller.add(state);
        }
      }
    } catch (e) {
      // For any other exceptions, check if token exists
      try {
        final token = await _secureStorage.read(AppConstants.tokenKey);
        if (token == null || token.isEmpty) {
          // No token, stay logged out
          state = AuthState.initial();
          _controller.add(state);
        } else {
          // Token exists but error occurred - keep user logged in if we have user data
          if (state.user != null) {
            state = state.copyWith(status: AuthStatus.authenticated);
          } else {
            // Stay in restoring to prevent redirect
            state = state.copyWith(status: AuthStatus.restoring);
          }
          _controller.add(state);
        }
      } catch (_) {
        // Can't check token, assume not logged in
        state = AuthState.initial();
        _controller.add(state);
      }
    }
  }

  Future<void> login(String email, String password) async {
    if (kIsWeb) {
      print('[Auth] login: Starting login for $email');
    }
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    _controller.add(state);
    try {
      final user = await _useCases.login(email, password);
      
      // Verify token was saved - wait a bit for storage to complete
      if (kIsWeb) {
        // Give storage time to complete the write operation
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Check token immediately after login
        String? token;
        try {
          token = await _secureStorage.read(AppConstants.tokenKey);
          print('[Auth] login: Token saved check - exists: ${token != null && token.isNotEmpty}, length: ${token?.length ?? 0}');
          
          // Also check all keys in storage
          try {
            final allKeys = await _secureStorage.readAll();
            print('[Auth] login: Storage has ${allKeys.length} keys: ${allKeys.keys.toList()}');
            if (allKeys.containsKey(AppConstants.tokenKey)) {
              print('[Auth] login: Token key found in storage keys list');
            } else {
              print('[Auth] login: WARNING - Token key NOT found in storage keys list!');
            }
          } catch (e) {
            print('[Auth] login: Could not read all keys: $e');
          }
        } catch (e) {
          print('[Auth] login: Error reading token after save: $e');
        }
      }
      
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      _controller.add(state);
      if (kIsWeb) {
        print('[Auth] login: Login successful, state updated to authenticated');
        print('[Auth] login: User: ${user.email}, Roles: ${user.roles.map((r) => r.type.name).join(", ")}');
      }
    } on AppException catch (error) {
      if (kIsWeb) {
        print('[Auth] login: Login error: ${error.code} - ${error.message}');
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: error.message,
      );
      _controller.add(state);
    } catch (e) {
      // Catch any other exceptions (network errors, JSON parsing, etc.)
      if (kIsWeb) {
        print('[Auth] login: Unexpected error: $e');
        print('[Auth] login: Error type: ${e.runtimeType}');
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Login failed: ${e.toString()}',
      );
      _controller.add(state);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    _controller.add(state);
    try {
      final user = await _useCases.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      _controller.add(state);
    } on AppException catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: error.message,
      );
      _controller.add(state);
    }
  }

  Future<void> requestPasswordReset(String email) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    _controller.add(state);
    try {
      await _useCases.requestPasswordReset(email);
      state = state.copyWith(status: AuthStatus.resetRequested);
      _controller.add(state);
    } on AppException catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: error.message,
      );
      _controller.add(state);
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    _controller.add(state);
    try {
      await _useCases.verifyOtp(email, otp);
      state = state.copyWith(status: AuthStatus.otpVerified);
      _controller.add(state);
    } on AppException catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: error.message,
      );
      _controller.add(state);
    }
  }

  Future<void> logout() async {
    await _useCases.logout();
    state = AuthState.initial();
    _controller.add(state);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

enum AuthStatus {
  initial,
  loading,
  restoring, // New status for session restoration
  authenticated,
  resetRequested,
  otpVerified,
  error,
}

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isRestoring => status == AuthStatus.restoring;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
