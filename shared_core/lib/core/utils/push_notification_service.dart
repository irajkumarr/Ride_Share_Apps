import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../storage/local_storage_service.dart';
import 'app_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level handler required by Firebase for background messages.
/// Must be a top-level (non-class) function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('FCM background message: ${message.messageId}');
  // NOTE: Firebase.initializeApp() must have been called before this runs.
  // It is called automatically by the Firebase plugin for background isolates.
}

/// Manages Firebase Cloud Messaging (FCM) and local notifications.
///
/// Responsibilities:
/// - Requesting / checking notification permissions.
/// - Fetching and persisting the FCM device token.
/// - Listening to foreground, background, and terminated-state messages.
/// - Displaying local notifications for foreground messages.
///
/// Register in [configureDependencies] and call [init] during app bootstrap.
class PushNotificationService {
  PushNotificationService(this._messaging, this._localStorage);

  final FirebaseMessaging _messaging;
  final LocalStorageService _localStorage;

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Stream controllers so the rest of the app can react to messages.
  final _messageController = StreamController<RemoteMessage>.broadcast();
  final _tokenController = StreamController<String>.broadcast();

  /// Emits every foreground FCM message.
  Stream<RemoteMessage> get messageStream => _messageController.stream;

  /// Emits whenever the FCM token is refreshed.
  Stream<String> get tokenStream => _tokenController.stream;

  /// Initialise the service.  Call once after [Firebase.initializeApp].
  Future<void> init() async {
    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission (iOS + Android 13+)
    await _requestPermission();

    // Local notifications setup
    await _initLocalNotifications();

    // Fetch current token
    await _fetchAndSaveToken();

    // Token refresh listener
    _messaging.onTokenRefresh.listen((token) {
      AppLogger.info('FCM token refreshed');
      _localStorage.setString(LocalStorageKeys.fcmToken, value: token);
      _tokenController.add(token);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App opened via notification (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // App launched via notification (terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    AppLogger.info('PushNotificationService initialised');
  }

  // ── Permission ────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    AppLogger.info('FCM permission: ${settings.authorizationStatus.name}');
  }

  Future<bool> get hasPermission async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // ── Token ─────────────────────────────────────────────────────────────────

  Future<void> _fetchAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _localStorage.setString(LocalStorageKeys.fcmToken, value: token);
        _tokenController.add(token);
        AppLogger.info('FCM token: $token');
      }
    } catch (e) {
      AppLogger.error('Failed to get FCM token', error: e);
    }
  }

  /// Returns the saved FCM token, or fetches a fresh one if absent.
  Future<String?> getToken() async {
    return _localStorage.getString(LocalStorageKeys.fcmToken) ?? _messaging.getToken();
  }

  /// Deletes the current FCM token (call on logout).
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    await _localStorage.remove(LocalStorageKeys.fcmToken);
    AppLogger.info('FCM token deleted');
  }

  // ── Local notifications ────────────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important push notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          channel,
        );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data.toString(),
    );
  }

  // ── Message handlers ──────────────────────────────────────────────────────

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.info('FCM foreground: ${message.messageId}');
    _messageController.add(message);
    await _showLocalNotification(message);
  }

  void _handleNotificationTap(RemoteMessage message) {
    AppLogger.info('FCM notification tapped: ${message.messageId}');
    // Handle deep-link navigation from notification payload
    // Use DeepLinkService to navigate based on the route in the payload
    final route = message.data['route'] as String?;
    final id = message.data['id'] as String?;

    if (route != null) {
      // final deepLink = DeepLinkData(
      //   path: route,
      //   queryParams: id != null ? {'id': id} : {},
      //   payload: message.data,
      // );
      // debugPrint(deepLink.toString());
      _messageController.add(message);
      // Note: Actual navigation should be handled in your router or main app
      // DeepLinkService.instance.navigateToDeepLink(context, deepLink);
      AppLogger.info('FCM: Will navigate to $route');
    } else {
      _messageController.add(message);
    }
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    AppLogger.info('Local notification tapped: ${response.payload}');
    // TODO: Handle deep-link navigation from payload
  }

  // ── Subscription management ───────────────────────────────────────────────

  /// Subscribe to a topic (e.g. broadcast announcements).
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    AppLogger.info('FCM: subscribed to topic $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    AppLogger.info('FCM: unsubscribed from topic $topic');
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  void dispose() {
    _messageController.close();
    _tokenController.close();
  }
}
