import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'analytics_event.dart';

/// Central analytics service — thin, typed wrapper around [FirebaseAnalytics].
///
/// Setup in main.dart:
/// ```dart
/// await Firebase.initializeApp();
/// AnalyticsService.instance.setEnabled(!kDebugMode);
/// ```
///
/// Track anywhere:
/// ```dart
/// AnalyticsService.instance.track(const LoginEvent(method: 'google'));
/// ```
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ─── Configuration ─────────────────────────────────────────

  /// Disable analytics entirely (e.g. in debug or when user opts out).
  Future<void> setEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
    debugPrint('[Analytics] Collection enabled: $enabled');
  }

  // ─── User Identity ──────────────────────────────────────────

  /// Call after login / sign-up to attach a user to all future events.
  Future<void> setUser({
    required String userId,
    String? email,
    String? name,
    String? plan,
  }) async {
    await _analytics.setUserId(id: userId);
    if (plan != null) {
      await _analytics.setUserProperty(name: 'plan', value: plan);
    }
    if (name != null) {
      await _analytics.setUserProperty(name: 'name', value: name);
    }
    debugPrint('[Analytics] User set: $userId');
  }

  /// Call on logout to clear user identity.
  Future<void> clearUser() async {
    await _analytics.setUserId(id: null);
    debugPrint('[Analytics] User cleared');
  }

  // ─── Event Tracking ─────────────────────────────────────────

  /// Track any [AnalyticsEvent].
  ///
  /// ```dart
  /// AnalyticsService.instance.track(
  ///   const PurchaseEvent(
  ///     transactionId: 'order_123',
  ///     currency: 'USD',
  ///     value: 49.99,
  ///   ),
  /// );
  /// ```
  Future<void> track(AnalyticsEvent event) async {
    try {
      await _analytics.logEvent(
        name: event.name,
        parameters: event.params.isEmpty ? null : event.params,
      );
      debugPrint('[Analytics] ✓ ${event.name} ${event.params}');
    } catch (e) {
      debugPrint('[Analytics] ✗ Failed to track ${event.name}: $e');
    }
  }

  // ─── Screen Tracking ────────────────────────────────────────

  /// Manually log a screen view (use [AnalyticsObserver] for automatic tracking).
  Future<void> trackScreen(String screenName, {String? screenClass}) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      debugPrint('[Analytics] 📱 Screen: $screenName');
    } catch (e) {
      debugPrint('[Analytics] ✗ Failed to track screen $screenName: $e');
    }
  }

  // ─── Firebase Analytics Observer accessor ──────────────────

  /// Pass to [MaterialApp.navigatorObservers] via [AnalyticsObserver].
  FirebaseAnalytics get firebaseAnalytics => _analytics;
}
