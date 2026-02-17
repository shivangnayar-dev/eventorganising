class AppConstants {
  const AppConstants._();

  // API Base URL - Can be overridden via environment variable or build config
  static String get baseUrl {
    // Check for environment variable first (set during build)
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Check for build mode
    const buildMode = String.fromEnvironment('BUILD_MODE', defaultValue: 'development');
    
    // Default based on build mode
    switch (buildMode) {
      case 'production':
        return 'http://72.61.232.15/api'; // Production API URL (HTTP)
      case 'staging':
        return 'https://staging-api.yourdomain.com'; // Update with your staging API URL
      default:
        return 'http://localhost:3000'; // Development default
    }
  }

  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const int defaultPageSize = 20;
}
