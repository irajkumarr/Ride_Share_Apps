import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../routing/app_routes.dart';
import '../../utils/app_logger.dart';

/// Deep link data class to hold parsed deep link information
class DeepLinkData {
  final String path;
  final Map<String, String> queryParams;
  final Map<String, dynamic> payload;

  DeepLinkData({
    required this.path,
    this.queryParams = const {},
    this.payload = const {},
  });
}

/// Service to handle deep links (Universal Links / App Links and Custom URL Schemes)
///
/// This service handles:
/// - Deep links from Firebase Dynamic Links
/// - Deep links from notifications
/// - Custom URL scheme links (appscheme://)
/// - Universal links (https://example.com/)
///
/// Usage:
/// ```dart
/// // Initialize in main.dart after Firebase initialization
/// await DeepLinkService.instance.init();
///
/// // Listen to deep links
/// DeepLinkService.instance.deepLinkStream.listen((link) {
///   print('Deep link received: ${link.path}');
/// });
/// ```
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final _deepLinkController = StreamController<DeepLinkData>.broadcast();
  Stream<DeepLinkData> get deepLinkStream => _deepLinkController.stream;

  static const String _scheme = 'appscheme';
  static const String _host = 'example';

  /// Initialize deep link handling
  /// Call this after Firebase.initializeApp() in main.dart
  Future<void> init() async {
    AppLogger.info('DeepLinkService: Initializing...');

    // Handle initial link from FCM (if app was launched via deep link)
    await _handleInitialLink();

    // Listen for FCM notification taps that contain deep link data
    _listenToNotificationDeepLinks();

    AppLogger.info('DeepLinkService: Initialized successfully');
  }

  /// Handle the initial deep link when app is launched
  Future<void> _handleInitialLink() async {
    try {
      // Check if app was launched via deep link
      final initialLink = await FirebaseMessaging.instance.getInitialMessage();
      if (initialLink != null) {
        _handleNotificationPayload(initialLink.data);
      }
    } catch (e) {
      AppLogger.error('DeepLinkService: Error handling initial link', error: e);
    }
  }

  /// Listen to notification taps for deep link navigation
  void _listenToNotificationDeepLinks() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationPayload(message.data);
    });
  }

  /// Handle notification payload and extract deep link
  void _handleNotificationPayload(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    final id = data['id'] as String?;

    if (route != null) {
      final deepLink = DeepLinkData(
        path: route,
        queryParams: id != null ? {'id': id} : {},
        payload: data,
      );

      _deepLinkController.add(deepLink);
      AppLogger.info('DeepLinkService: Notification deep link: $route');
    }
  }

  /// Navigate to the appropriate screen based on deep link
  ///
  /// Example deep links:
  /// - /home - Home screen
  /// - /profile - Profile screen
  /// - /product/123 - Product detail with ID
  /// - /orders?id=456 - Orders with query param
  void navigateToDeepLink(BuildContext context, DeepLinkData deepLink) {
    final path = deepLink.path;
    final queryParams = deepLink.queryParams;

    AppLogger.info('DeepLinkService: Navigating to: $path');

    switch (path) {
      case 'home':
        context.go(AppRoutes.home);
        break;
      case 'profile':
        context.go(AppRoutes.profile);
        break;
      case 'settings':
        context.go(AppRoutes.settings);
        break;
      case 'notifications':
        context.go(AppRoutes.notifications);
        break;
      case 'product':
        final productId = queryParams['id'];
        if (productId != null) {
          context.go('/product/$productId');
          // context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.home);
        }
        break;
      case 'order':
        final orderId = queryParams['id'];
        if (orderId != null) {
          // context.go('/order/$orderId');
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.home);
        }
        break;
      default:
        // Unknown route, go to home
        context.go(AppRoutes.home);
    }
  }

  /// Create a deep link URL for sharing
  ///
  /// Usage:
  /// ```dart
  /// final url = DeepLinkService.instance.createDeepLink(
  ///   route: 'product',
  ///   params: {'id': '123'},
  /// );
  /// print(url); // https://example.com/product/123 or appscheme://example/product/123
  /// ```
  String createDeepLink({
    required String route,
    Map<String, String>? params,
    bool useUniversalLink = true,
  }) {
    final buffer = StringBuffer();

    if (useUniversalLink) {
      buffer.write('https://example.com/$route');
    } else {
      buffer.write('$_scheme://$_host/$route');
    }

    if (params != null && params.isNotEmpty) {
      final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      buffer.write('?$queryString');
    }

    return buffer.toString();
  }

  /// Parse a deep link URL into DeepLinkData
  ///
  /// Usage:
  /// ```dart
  /// final data = DeepLinkService.instance.parseDeepLink(
  ///   'https://example.com/product/123?id=456',
  /// );
  /// print(data.path); // /product/123
  /// print(data.queryParams); // {id: 456}
  /// ```
  DeepLinkData parseDeepLink(Uri uri) {
    final pathSegments = uri.pathSegments;
    final path = pathSegments.isNotEmpty ? '/${pathSegments.join('/')}' : '/';

    final queryParams = <String, String>{};
    uri.queryParameters.forEach((key, value) {
      queryParams[key] = value;
    });

    return DeepLinkData(
      path: path,
      queryParams: queryParams,
      payload: {},
    );
  }

  /// Handle incoming deep link from app lifecycle or external source
  ///
  /// Usage:
  /// ```dart
  /// // In WidgetsBindingObserver didChangeAppLifecycleState
  /// if (state == AppLifecycleState.resumed) {
  ///   // Check for new deep links
  /// }
  /// ```
  void handleDeepLink(Uri? uri) {
    if (uri == null) return;

    final deepLink = parseDeepLink(uri);
    _deepLinkController.add(deepLink);
    AppLogger.info('DeepLinkService: Received deep link: ${uri.toString()}');
  }

  /// Clean up resources
  void dispose() {
    _deepLinkController.close();
  }
}

/// Extension to easily access deep link navigation
extension DeepLinkNavigation on BuildContext {
  /// Navigate using deep link string
  ///
  /// Usage:
  /// ```dart
  /// context.navigateWithDeepLink('https://example.com/product/123');
  /// context.navigateWithDeepLink('appscheme://example/product/123');
  /// ```
  void navigateWithDeepLink(String deepLinkString) {
    try {
      final uri = Uri.parse(deepLinkString);
      final data = DeepLinkService.instance.parseDeepLink(uri);
      DeepLinkService.instance.navigateToDeepLink(this, data);
    } catch (e) {
      AppLogger.error('DeepLinkNavigation: Error parsing deep link', error: e);
      go(AppRoutes.home);
    }
  }
}
