class Environment {
  const Environment._();

  static String get apiBaseUrl {
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

  static bool get isProduction {
    const buildMode = String.fromEnvironment('BUILD_MODE', defaultValue: 'development');
    return buildMode == 'production';
  }

  static bool get isDevelopment {
    const buildMode = String.fromEnvironment('BUILD_MODE', defaultValue: 'development');
    return buildMode == 'development';
  }
}
