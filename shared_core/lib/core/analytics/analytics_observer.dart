import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'analytics_service.dart';

/// Drop into [MaterialApp.navigatorObservers] to auto-track every screen.
///
/// ```dart
/// MaterialApp(
///   navigatorObservers: [AnalyticsObserver()],
/// )
/// ```
///
/// For named routes the screen name is taken from [RouteSettings.name].
/// For unnamed routes you can override [screenNameExtractor].
class AnalyticsObserver extends RouteObserver<ModalRoute<dynamic>> {
  AnalyticsObserver({this.screenNameExtractor});

  /// Optional: customise how the screen name is extracted from a route.
  /// Return null to fall back to the default behaviour.
  final String? Function(RouteSettings settings)? screenNameExtractor;

  // The FirebaseAnalyticsObserver handles the actual Firebase call.
  // We keep our own layer so we can add custom logic / logging on top.
  late final FirebaseAnalyticsObserver _firebaseObserver = FirebaseAnalyticsObserver(
    analytics: AnalyticsService.instance.firebaseAnalytics,
    nameExtractor: _extractName,
  );

  String? _previousScreen;

  // String? _extractName(RouteSettings settings) {
  //   // 1. Custom extractor (if provided)
  //   final custom = screenNameExtractor?.call(settings);
  //   if (custom != null) return custom;

  //   // 2. Named route
  //   if (settings.name != null && settings.name!.isNotEmpty) {
  //     return settings.name;
  //   }

  //   return null;
  // }

  String? _extractName(RouteSettings settings) {
    final custom = screenNameExtractor?.call(settings);
    if (custom != null) return custom;

    // go_router fallback
    if (settings.name != null && settings.name!.isNotEmpty) {
      return settings.name;
    }

    // Fallback for go_router (important)
    return settings.arguments?.toString() ?? settings.toString();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _firebaseObserver.didPush(route, previousRoute);
    _logScreen(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _firebaseObserver.didPop(route, previousRoute);
    if (previousRoute != null) _logScreen(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _firebaseObserver.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _logScreen(newRoute);
  }

  // void _logScreen(Route<dynamic> route) {
  //   if (route is! ModalRoute) return;

  //   final name = _extractName(route.settings);
  //   if (name == null || name == _previousScreen) return;

  //   AnalyticsService.instance.trackScreen(
  //     name,
  //     screenClass: route.runtimeType.toString(),
  //   );

  //   _previousScreen = name;
  // }
  void _logScreen(Route<dynamic> route) {
    if (route is! ModalRoute) return;

    final name = _extractName(route.settings);

    // 👇 Add this guard
    if (name == null || name.isEmpty || name == _previousScreen) return;

    AnalyticsService.instance.trackScreen(
      name,
      screenClass: route.runtimeType.toString(),
    );

    _previousScreen = name;
  }
}
