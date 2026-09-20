import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AppGlobal {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static bool isEn = true;
  static bool isDashboardProfileNavRequested = false;
  static RemoteMessage? firebaseInitialMessage;
  static Uri? initialLinkUri;
}

/// Convenient accessor for the current root [BuildContext].
///
/// Returns `null` before the app is mounted. Check for `null` before
/// using this in background services or repositories.
BuildContext? get rootContext => AppGlobal.navigatorKey.currentContext;
