/// All analytics parameter key constants used across events.
///
/// Using constants prevents typos and makes refactoring safe.
/// Firebase Analytics limits parameter names to 40 chars (snake_case).
class AnalyticsParameter {
  AnalyticsParameter._();

  // ─── Screen ────────────────────────────────────────────────
  static const String screenName = 'screen_name';
  static const String screenClass = 'screen_class';
  static const String previousScreen = 'previous_screen';

  // ─── User ──────────────────────────────────────────────────
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userPlan = 'user_plan';
  static const String userRole = 'user_role';
  static const String isLoggedIn = 'is_logged_in';

  // ─── Auth ──────────────────────────────────────────────────
  static const String loginMethod = 'login_method';
  static const String signUpMethod = 'sign_up_method';
  static const String success = 'success';
  static const String failureReason = 'failure_reason';

  // ─── Button / UI ───────────────────────────────────────────
  static const String buttonName = 'button_name';
  static const String itemName = 'item_name';
  static const String itemId = 'item_id';
  static const String itemCategory = 'item_category';
  static const String itemListName = 'item_list_name';
  static const String contentType = 'content_type';
  static const String label = 'label';
  static const String action = 'action';

  // ─── Search ────────────────────────────────────────────────
  static const String searchTerm = 'search_term';
  static const String searchResultCount = 'search_result_count';

  // ─── E-Commerce ────────────────────────────────────────────
  static const String transactionId = 'transaction_id';
  static const String currency = 'currency';
  static const String value = 'value';
  static const String price = 'price';
  static const String quantity = 'quantity';
  static const String discount = 'discount';
  static const String coupon = 'coupon';
  static const String paymentType = 'payment_type';
  static const String cartId = 'cart_id';
  static const String items = 'items';

  // ─── Content ───────────────────────────────────────────────
  static const String contentId = 'content_id';
  static const String contentTitle = 'content_title';
  static const String contentCategory = 'content_category';
  static const String contentAuthor = 'content_author';
  static const String contentFormat = 'content_format';
  static const String percentageScrolled = 'percentage_scrolled';

  // ─── Notification ──────────────────────────────────────────
  static const String notificationId = 'notification_id';
  static const String notificationType = 'notification_type';
  static const String campaignName = 'campaign_name';
  static const String campaignSource = 'campaign_source';

  // ─── Onboarding / Funnel ───────────────────────────────────
  static const String stepName = 'step_name';
  static const String stepNumber = 'step_number';
  static const String totalSteps = 'total_steps';
  static const String funnelName = 'funnel_name';
  static const String isSkipped = 'is_skipped';
  static const String isCompleted = 'is_completed';

  // ─── Subscription ──────────────────────────────────────────
  static const String planName = 'plan_name';
  static const String billingCycle = 'billing_cycle';
  static const String trialDays = 'trial_days';
  static const String cancellationReason = 'cancellation_reason';

  // ─── Error ─────────────────────────────────────────────────
  static const String errorCode = 'error_code';
  static const String errorMessage = 'error_message';
  static const String errorType = 'error_type';
  static const String isFatal = 'is_fatal';

  // ─── App / Session ─────────────────────────────────────────
  static const String appVersion = 'app_version';
  static const String buildNumber = 'build_number';
  static const String platform = 'platform';
  static const String source = 'source';
  static const String medium = 'medium';
  static const String isFirstOpen = 'is_first_open';
  static const String sessionDuration = 'session_duration_seconds';

  // ─── Feature / Settings ────────────────────────────────────
  static const String featureName = 'feature_name';
  static const String isEnabled = 'is_enabled';
  static const String settingName = 'setting_name';
  static const String settingValue = 'setting_value';
  static const String permissionType = 'permission_type';
  static const String isGranted = 'is_granted';

  // ─── Share ─────────────────────────────────────────────────
  static const String shareMethod = 'method';
}
