class AppConfig {
  // API Configuration
  // Railway production URL
  static String get apiBaseUrl {
    return 'https://hrms-backend-production-501b.up.railway.app';
    // Use computer's IP address for Android device to connect locally
    // return 'http://192.168.0.110:8000';
  }

  // App Info
  static const String appName = 'HRMS';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String orgDataKey = 'org_data';
  static const String menusDataKey = 'menus_data';
  static const String permissionsDataKey = 'permissions_data';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
