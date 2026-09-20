/// App-wide magic-number and string constants.
///
/// Avoid sprinkling raw numbers / strings throughout the codebase.
/// Reference this file instead.
abstract final class AppConstants {
  // ── Layout ────────────────────────────────────────────────────────────────
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;
  static const double paddingXxl = 48.0;

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 48.0;

  // ── Animation ─────────────────────────────────────────────────────────────
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ── Pagination ────────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;

  // ── Network ───────────────────────────────────────────────────────────────
  static const int maxRetries = 3;
  static const int defaultTimeoutSeconds = 30;

  // ── Cache ─────────────────────────────────────────────────────────────────
  /// How long to keep API responses cached (in seconds).
  static const int defaultCacheTtlSeconds = 300; // 5 minutes
  static const int longCacheTtlSeconds = 3600; // 1 hour

  // ── Validation ────────────────────────────────────────────────────────────
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;
  static const int nameMinLength = 2;
  static const int nameMaxLength = 50;
  static const int otpLength = 6;
  static const int phoneMinLength = 7;
  static const int phoneMaxLength = 15;

  // ── Date / time ───────────────────────────────────────────────────────────
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  static const String timeFormat = 'hh:mm a';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";
  static Map<String, dynamic> dateAndTimeSetting = {
    'dateFormat': 'dd/MM/yyyy',
    'use24HourFormat': false,
  };

  // ── File / media ──────────────────────────────────────────────────────────
  static const int maxImageSizeMb = 5;
  static const int maxFileSizeMb = 25;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // ── Misc ──────────────────────────────────────────────────────────────────
  static const String appStoreUrl = 'https://apps.apple.com/app/id000000000';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.example.app';
  static const String privacyPolicyUrl = 'https://example.com/privacy-policy';
  static const String termsOfServiceUrl = 'https://example.com/terms-of-service';
  static const String supportEmail = 'support@example.com';

  // Path
  static const imageFolderPath = 'assets/images';
  static const iconFolderPath = 'assets/icons';

  // Name
  static const appName = 'App Name';

  // Google Server client id
  static const googleClientId =
      '587181574006-0okk2e2hafanm8p6st8vlmfuq5h9n050.apps.googleusercontent.com';
}
