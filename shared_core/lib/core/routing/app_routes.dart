import 'package:flutter/material.dart';

final shellNavigatorKey = GlobalKey<NavigatorState>();

/// Centralized route path constants for GoRouter.
///
/// Use these variables instead of raw strings throughout the app.
/// Example: `context.go(AppRoutes.onboarding)` instead of `context.go('/')`.
/// Named route path constants – single source of truth for all route paths.
abstract final class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  // Nested / parameterised
  static const String userDetail = '/users/:id';

  // Deep link routes
  static const String product = '/product/:id';
  static const String order = '/order';
  static const String deepLinkHome = '/deep-link-home';
}
