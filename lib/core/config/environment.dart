/// Environment configuration for the app
/// 
/// Usage:
/// ```dart
/// // Set environment at app startup
/// AppConfig.setEnvironment(Environment.prod);
/// 
/// // Access config values
/// print(AppConfig.baseUrl);
/// ```

enum Environment { dev, staging, prod }

class AppConfig {
  static Environment _env = Environment.dev;
  
  /// Set the current environment
  static void setEnvironment(Environment env) {
    _env = env;
  }
  
  /// Get the current environment
  static Environment get environment => _env;
  
  /// Base URL for the API
  static String get baseUrl {
    switch (_env) {
      case Environment.dev:
        return 'https://svr10.biz-dimension.com:9093';
      case Environment.staging:
        return 'https://staging.biz-dimension.com:9093';
      case Environment.prod:
        return 'https://svr10.biz-dimension.com:9093';
    }
  }
  
  /// Default host (can be overridden by user settings)
  static String get defaultHost {
    switch (_env) {
      case Environment.dev:
        return 'svr10.biz-dimension.com';
      case Environment.staging:
        return 'staging.biz-dimension.com';
      case Environment.prod:
        return 'svr10.biz-dimension.com';
    }
  }
  
  /// Default port
  static String get defaultPort => '9093';
  
  /// Whether to disable SSL (only in dev)
  static bool get shouldDisableSSL => _env == Environment.dev;
  
  /// API endpoints
  static String get authEndpoint => '/api/auth';
  static String get sapEndpoint => '/api/sapIntegration';
  static String get attachmentsEndpoint => '/api/sapIntegration/Attachments2';
  static String get notificationsEndpoint => '/api/notifications/sendToWeb';
}
