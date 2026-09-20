import 'analytics_parameter.dart';

/// A single analytics event — a name + typed parameters map.
///
/// Every event in the app is a concrete subclass.
/// Use [AnalyticsEvent.params] to get the map ready to send to Firebase.
abstract class AnalyticsEvent {
  const AnalyticsEvent();

  /// Firebase event name (snake_case, max 40 chars).
  String get name;

  /// Parameters attached to this event.
  /// Keys must use [AnalyticsParameter] constants.
  Map<String, Object> get params => const {};
}

// ════════════════════════════════════════════════════════════════
// SCREEN
// ════════════════════════════════════════════════════════════════

class ScreenViewEvent extends AnalyticsEvent {
  const ScreenViewEvent({
    required this.screenName,
    this.screenClass,
    this.previousScreen,
  });

  final String screenName;
  final String? screenClass;
  final String? previousScreen;

  @override
  String get name => 'screen_view';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.screenName: screenName,
    if (screenClass != null) AnalyticsParameter.screenClass: screenClass!,
    if (previousScreen != null) AnalyticsParameter.previousScreen: previousScreen!,
  };
}

// ════════════════════════════════════════════════════════════════
// AUTH
// ════════════════════════════════════════════════════════════════

class LoginEvent extends AnalyticsEvent {
  const LoginEvent({
    required this.method,
    this.success = true,
    this.failureReason,
  });

  final String method; // 'email' | 'google' | 'apple' | 'facebook'
  final bool success;
  final String? failureReason;

  @override
  String get name => 'login';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.loginMethod: method,
    AnalyticsParameter.success: success ? 1 : 0,
    if (!success && failureReason != null) AnalyticsParameter.failureReason: failureReason!,
  };
}

class SignUpEvent extends AnalyticsEvent {
  const SignUpEvent({required this.method, this.referrer});

  final String method; // 'email' | 'google' | 'apple'
  final String? referrer;

  @override
  String get name => 'sign_up';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.signUpMethod: method,
    if (referrer != null) AnalyticsParameter.source: referrer!,
  };
}

class LogoutEvent extends AnalyticsEvent {
  const LogoutEvent({this.reason});

  // 'user_initiated' | 'session_expired' | 'forced'
  final String? reason;

  @override
  String get name => 'logout';

  @override
  Map<String, Object> get params => {
    if (reason != null) AnalyticsParameter.action: reason!,
  };
}

class PasswordResetEvent extends AnalyticsEvent {
  const PasswordResetEvent({required this.success});

  final bool success;

  @override
  String get name => 'password_reset';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.success: success,
  };
}

// ════════════════════════════════════════════════════════════════
// UI INTERACTIONS
// ════════════════════════════════════════════════════════════════

class ButtonTappedEvent extends AnalyticsEvent {
  const ButtonTappedEvent({
    required this.buttonName,
    this.screenName,
    this.category,
  });

  final String buttonName;
  final String? screenName;
  final String? category;

  @override
  String get name => 'button_tapped';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.buttonName: buttonName,
    if (screenName != null) AnalyticsParameter.screenName: screenName!,
    if (category != null) AnalyticsParameter.itemCategory: category!,
  };
}

class SearchEvent extends AnalyticsEvent {
  const SearchEvent({required this.query, this.resultCount});

  final String query;
  final int? resultCount;

  @override
  String get name => 'search';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.searchTerm: query,
    if (resultCount != null) AnalyticsParameter.searchResultCount: resultCount!,
  };
}

class ShareEvent extends AnalyticsEvent {
  const ShareEvent({
    required this.method,
    required this.contentType,
    this.itemId,
  });

  final String method; // 'whatsapp' | 'copy_link' | 'email' etc.
  final String contentType; // 'article' | 'product' | 'profile' etc.
  final String? itemId;

  @override
  String get name => 'share';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.shareMethod: method,
    AnalyticsParameter.contentType: contentType,
    if (itemId != null) AnalyticsParameter.itemId: itemId!,
  };
}

// ════════════════════════════════════════════════════════════════
// E-COMMERCE
// ════════════════════════════════════════════════════════════════

class ViewItemEvent extends AnalyticsEvent {
  const ViewItemEvent({
    required this.itemId,
    required this.itemName,
    required this.currency,
    required this.price,
    this.category,
  });

  final String itemId;
  final String itemName;
  final String currency;
  final double price;
  final String? category;

  @override
  String get name => 'view_item';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.currency: currency,
    AnalyticsParameter.value: price,
    AnalyticsParameter.items: [
      {
        AnalyticsParameter.itemId: itemId,
        AnalyticsParameter.itemName: itemName,
        AnalyticsParameter.price: price,
        if (category != null) AnalyticsParameter.itemCategory: category!,
      },
    ],
  };
}

class AddToCartEvent extends AnalyticsEvent {
  const AddToCartEvent({
    required this.itemId,
    required this.itemName,
    required this.currency,
    required this.price,
    this.quantity = 1,
    this.category,
  });

  final String itemId;
  final String itemName;
  final String currency;
  final double price;
  final int quantity;
  final String? category;

  @override
  String get name => 'add_to_cart';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.currency: currency,
    AnalyticsParameter.value: price * quantity,
    AnalyticsParameter.items: [
      {
        AnalyticsParameter.itemId: itemId,
        AnalyticsParameter.itemName: itemName,
        AnalyticsParameter.price: price,
        AnalyticsParameter.quantity: quantity,
        if (category != null) AnalyticsParameter.itemCategory: category!,
      },
    ],
  };
}

class RemoveFromCartEvent extends AnalyticsEvent {
  const RemoveFromCartEvent({
    required this.itemId,
    required this.itemName,
    required this.currency,
    required this.price,
    this.quantity = 1,
  });

  final String itemId;
  final String itemName;
  final String currency;
  final double price;
  final int quantity;

  @override
  String get name => 'remove_from_cart';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.currency: currency,
    AnalyticsParameter.value: price * quantity,
    AnalyticsParameter.items: [
      {
        AnalyticsParameter.itemId: itemId,
        AnalyticsParameter.itemName: itemName,
        AnalyticsParameter.price: price,
        AnalyticsParameter.quantity: quantity,
      },
    ],
  };
}

class BeginCheckoutEvent extends AnalyticsEvent {
  const BeginCheckoutEvent({
    required this.currency,
    required this.value,
    this.coupon,
    this.items = const [],
  });

  final String currency;
  final double value;
  final String? coupon;
  final List<Map<String, Object>> items;

  @override
  String get name => 'begin_checkout';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.currency: currency,
    AnalyticsParameter.value: value,
    if (coupon != null) AnalyticsParameter.coupon: coupon!,
    if (items.isNotEmpty) AnalyticsParameter.items: items,
  };
}

class PurchaseEvent extends AnalyticsEvent {
  const PurchaseEvent({
    required this.transactionId,
    required this.currency,
    required this.value,
    this.coupon,
    this.discount,
    this.items = const [],
  });

  final String transactionId;
  final String currency;
  final double value;
  final String? coupon;
  final double? discount;
  final List<Map<String, Object>> items;

  @override
  String get name => 'purchase';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.transactionId: transactionId,
    AnalyticsParameter.currency: currency,
    AnalyticsParameter.value: value,
    if (coupon != null) AnalyticsParameter.coupon: coupon!,
    if (discount != null) AnalyticsParameter.discount: discount!,
    if (items.isNotEmpty) AnalyticsParameter.items: items,
  };
}

class RefundEvent extends AnalyticsEvent {
  const RefundEvent({
    required this.transactionId,
    required this.currency,
    required this.value,
  });

  final String transactionId;
  final String currency;
  final double value;

  @override
  String get name => 'refund';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.transactionId: transactionId,
    AnalyticsParameter.currency: currency,
    AnalyticsParameter.value: value,
  };
}

// ════════════════════════════════════════════════════════════════
// SUBSCRIPTION
// ════════════════════════════════════════════════════════════════

class SubscriptionStartedEvent extends AnalyticsEvent {
  const SubscriptionStartedEvent({
    required this.planName,
    required this.billingCycle,
    required this.value,
    required this.currency,
    this.trialDays,
  });

  final String planName;
  final String billingCycle; // 'monthly' | 'annual'
  final double value;
  final String currency;
  final int? trialDays;

  @override
  String get name => 'subscription_started';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.planName: planName,
    AnalyticsParameter.billingCycle: billingCycle,
    AnalyticsParameter.value: value,
    AnalyticsParameter.currency: currency,
    if (trialDays != null) AnalyticsParameter.trialDays: trialDays!,
  };
}

class SubscriptionCancelledEvent extends AnalyticsEvent {
  const SubscriptionCancelledEvent({
    required this.planName,
    this.reason,
  });

  final String planName;
  final String? reason;

  @override
  String get name => 'subscription_cancelled';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.planName: planName,
    if (reason != null) AnalyticsParameter.cancellationReason: reason!,
  };
}

class SubscriptionRenewedEvent extends AnalyticsEvent {
  const SubscriptionRenewedEvent({
    required this.planName,
    required this.value,
    required this.currency,
  });

  final String planName;
  final double value;
  final String currency;

  @override
  String get name => 'subscription_renewed';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.planName: planName,
    AnalyticsParameter.value: value,
    AnalyticsParameter.currency: currency,
  };
}

class SubscriptionUpgradedEvent extends AnalyticsEvent {
  const SubscriptionUpgradedEvent({
    required this.fromPlan,
    required this.toPlan,
    required this.value,
    required this.currency,
  });

  final String fromPlan;
  final String toPlan;
  final double value;
  final String currency;

  @override
  String get name => 'subscription_upgraded';

  @override
  Map<String, Object> get params => {
    'from_plan': fromPlan,
    'to_plan': toPlan,
    AnalyticsParameter.value: value,
    AnalyticsParameter.currency: currency,
  };
}

// ════════════════════════════════════════════════════════════════
// CONTENT
// ════════════════════════════════════════════════════════════════

class SelectContentEvent extends AnalyticsEvent {
  const SelectContentEvent({
    required this.contentType,
    required this.itemId,
  });

  final String contentType;
  final String itemId;

  @override
  String get name => 'select_content';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.contentType: contentType,
    AnalyticsParameter.itemId: itemId,
  };
}

class ContentViewedEvent extends AnalyticsEvent {
  const ContentViewedEvent({
    required this.contentId,
    required this.contentType,
    this.title,
    this.category,
    this.author,
  });

  final String contentId;
  final String contentType;
  final String? title;
  final String? category;
  final String? author;

  @override
  String get name => 'content_viewed';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.contentId: contentId,
    AnalyticsParameter.contentType: contentType,
    if (title != null) AnalyticsParameter.contentTitle: title!,
    if (category != null) AnalyticsParameter.contentCategory: category!,
    if (author != null) AnalyticsParameter.contentAuthor: author!,
  };
}

class ContentCompletedEvent extends AnalyticsEvent {
  const ContentCompletedEvent({
    required this.contentId,
    required this.contentType,
    this.percentageScrolled,
  });

  final String contentId;
  final String contentType;
  final int? percentageScrolled; // 0-100

  @override
  String get name => 'content_completed';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.contentId: contentId,
    AnalyticsParameter.contentType: contentType,
    if (percentageScrolled != null) AnalyticsParameter.percentageScrolled: percentageScrolled!,
  };
}

// ════════════════════════════════════════════════════════════════
// ONBOARDING
// ════════════════════════════════════════════════════════════════

class OnboardingStepViewedEvent extends AnalyticsEvent {
  const OnboardingStepViewedEvent({
    required this.stepName,
    required this.stepNumber,
    required this.totalSteps,
  });

  final String stepName;
  final int stepNumber;
  final int totalSteps;

  @override
  String get name => 'onboarding_step_viewed';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.stepName: stepName,
    AnalyticsParameter.stepNumber: stepNumber,
    AnalyticsParameter.totalSteps: totalSteps,
  };
}

class OnboardingStepCompletedEvent extends AnalyticsEvent {
  const OnboardingStepCompletedEvent({
    required this.stepName,
    required this.stepNumber,
    required this.totalSteps,
    this.isSkipped = false,
  });

  final String stepName;
  final int stepNumber;
  final int totalSteps;
  final bool isSkipped;

  @override
  String get name => 'onboarding_step_completed';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.stepName: stepName,
    AnalyticsParameter.stepNumber: stepNumber,
    AnalyticsParameter.totalSteps: totalSteps,
    AnalyticsParameter.isSkipped: isSkipped,
  };
}

class OnboardingCompletedEvent extends AnalyticsEvent {
  const OnboardingCompletedEvent({this.isSkipped = false});

  final bool isSkipped;

  @override
  String get name => 'onboarding_completed';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.isSkipped: isSkipped,
  };
}

// ════════════════════════════════════════════════════════════════
// NOTIFICATIONS
// ════════════════════════════════════════════════════════════════

class NotificationReceivedEvent extends AnalyticsEvent {
  const NotificationReceivedEvent({
    required this.notificationType,
    this.campaignName,
    this.notificationId,
  });

  final String notificationType;
  final String? campaignName;
  final String? notificationId;

  @override
  String get name => 'notification_received';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.notificationType: notificationType,
    if (campaignName != null) AnalyticsParameter.campaignName: campaignName!,
    if (notificationId != null) AnalyticsParameter.notificationId: notificationId!,
  };
}

class NotificationTappedEvent extends AnalyticsEvent {
  const NotificationTappedEvent({
    required this.notificationType,
    this.campaignName,
    this.notificationId,
  });

  final String notificationType;
  final String? campaignName;
  final String? notificationId;

  @override
  String get name => 'notification_tapped';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.notificationType: notificationType,
    if (campaignName != null) AnalyticsParameter.campaignName: campaignName!,
    if (notificationId != null) AnalyticsParameter.notificationId: notificationId!,
  };
}

class NotificationPermissionEvent extends AnalyticsEvent {
  const NotificationPermissionEvent({required this.isGranted});

  final bool isGranted;

  @override
  String get name => 'notification_permission';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.isGranted: isGranted,
  };
}

// ════════════════════════════════════════════════════════════════
// APP / FEATURE
// ════════════════════════════════════════════════════════════════

class AppOpenedEvent extends AnalyticsEvent {
  const AppOpenedEvent({this.source, this.isFirstOpen = false});

  // 'push_notification' | 'deep_link' | 'widget' | 'direct'
  final String? source;
  final bool isFirstOpen;

  @override
  String get name => 'app_opened';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.isFirstOpen: isFirstOpen,
    if (source != null) AnalyticsParameter.source: source!,
  };
}

class FeatureUsedEvent extends AnalyticsEvent {
  const FeatureUsedEvent({required this.featureName, this.action});

  final String featureName;
  final String? action;

  @override
  String get name => 'feature_used';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.featureName: featureName,
    if (action != null) AnalyticsParameter.action: action!,
  };
}

class SettingChangedEvent extends AnalyticsEvent {
  const SettingChangedEvent({
    required this.settingName,
    required this.newValue,
  });

  final String settingName;
  final String newValue;

  @override
  String get name => 'setting_changed';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.settingName: settingName,
    AnalyticsParameter.settingValue: newValue,
  };
}

class PermissionRequestedEvent extends AnalyticsEvent {
  const PermissionRequestedEvent({
    required this.permissionType,
    required this.isGranted,
  });

  // 'camera' | 'location' | 'notifications' | 'contacts' etc.
  final String permissionType;
  final bool isGranted;

  @override
  String get name => 'permission_requested';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.permissionType: permissionType,
    AnalyticsParameter.isGranted: isGranted,
  };
}

class ErrorEvent extends AnalyticsEvent {
  const ErrorEvent({
    required this.errorCode,
    required this.errorMessage,
    this.errorType,
    this.screenName,
    this.isFatal = false,
  });

  final String errorCode;
  final String errorMessage;
  final String? errorType;
  final String? screenName;
  final bool isFatal;

  @override
  String get name => 'app_error';

  @override
  Map<String, Object> get params => {
    AnalyticsParameter.errorCode: errorCode,
    AnalyticsParameter.errorMessage: errorMessage,
    if (errorType != null) AnalyticsParameter.errorType: errorType!,
    if (screenName != null) AnalyticsParameter.screenName: screenName!,
    AnalyticsParameter.isFatal: isFatal,
  };
}
