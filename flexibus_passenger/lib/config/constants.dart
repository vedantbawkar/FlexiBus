// App-wide constants
// lib/config/constants.dart

class AppConstants {
  // App Info
  static const String appName = 'FlexiBus';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themePreferenceKey = 'theme_preference';

  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.example.com';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Padding & Sizes
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double borderRadiusS = 4.0;
  static const double borderRadiusM = 8.0;
  static const double borderRadiusL = 16.0;
  static const double borderRadiusXL = 24.0;

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Please check your internet connection.';
  static const String errorInvalidCredentials = 'Invalid email or password.';

  // Success Messages
  static const String successLogin = 'Successfully logged in!';
  static const String successDataSaved = 'Data saved successfully!';


  // Date Formats
  static const String dateFormatFull = 'MMMM dd, yyyy';
  static const String dateFormatShort = 'MMM dd';
  static const String timeFormat = 'HH:mm';

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxRemarkLength = 200;

  // File Types
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocTypes = ['pdf', 'doc', 'docx'];
  static const List<String> allowedSpreadsheetTypes = ['xls', 'xlsx', 'csv'];

  // Maximum Sizes
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocSize = 10 * 1024 * 1024; // 10MB
  static const int maxBatchSize =
      100; // Maximum number of records to process at once
}
