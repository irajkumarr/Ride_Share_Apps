// ── Router observer ───────────────────────────────────────────────────────────

// ignore_for_file: strict_raw_type

import 'package:flutter/material.dart';
import 'package:shared_core/core/utils/app_logger.dart';

// / Logs navigation events for analytics / debugging.
class AppRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    final name = route.settings.name;

    if (name == null) return;

    AppLogger.info('Router → push: $name');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    final name = route.settings.name;
    if (name == null) return;

    AppLogger.info('Router → pop: $name');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    final name = newRoute?.settings.name;
    if (name == null) return;

    AppLogger.info('Router → replace: $name');
  }
}
