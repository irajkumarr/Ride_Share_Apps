

// ─────────────────────────────────────────────────────────────────────────────
// String extensions
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_core/config/theme/theme_extensions/app_colors_extension.dart';
import 'package:shared_core/core/utils/toast_overlay.dart';

extension StringX on String {
  /// `"hello world"` → `"Hello World"`
  String get toTitleCase =>
      split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  /// `"hello"` → `"Hello"`
  String get capitalised => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Returns `true` if the string is a valid email address.
  bool get isValidEmail => RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+'
    r'@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  ).hasMatch(this);

  /// Check if string is a valid phone number
  bool get isPhone {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(this);
  }

  /// Returns `true` if the string is a valid URL.
  bool get isValidUrl => Uri.tryParse(this)?.hasAbsolutePath ?? false;

  /// Returns `true` if the string contains only digits.
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);

  /// Returns `true` if the string is null or blank.
  bool get isBlank => trim().isEmpty;

  /// Shortens long strings: `"Hello World"` → `"Hello W…"` (max 8).
  String truncate(int maxLength, {String ellipsis = '…'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';

  /// Remove all whitespace: `"hello world"` → `"helloworld"`.
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Convert to slug (lowercase with hyphens)
  String toSlug() {
    return toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'[\s-]+'), '-')
        .trim();
  }

  /// Masks a string, showing only the last [visible] characters:
  /// `"1234567890".mask()` → `"••••••7890"`.
  String mask({int visible = 4, String char = '•'}) {
    if (length <= visible) return this;
    return char * (length - visible) + substring(length - visible);
  }

  // UI Helpers
  /// Converts hex string to Color object
  /// Supports: #RRGGBB, RRGGBB, #AARRGGBB, AARRGGBB
  dynamic toColor() {
    // Note: dynamic return to avoid importing Material in this logic-only file
    // The user can cast it to Color or we can import material here
    var hexColor = replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    if (hexColor.length == 8) {
      return int.parse('0x$hexColor');
    }
    return null;
  }
}

extension NullableStringX on String? {
  /// Returns `true` if the value is null or blank.
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// Returns `this` or [fallback] if null/blank.
  String orDefault([String fallback = '']) => isNullOrBlank ? fallback : this!;
}

// ─────────────────────────────────────────────────────────────────────────────
// DateTime extensions
// ─────────────────────────────────────────────────────────────────────────────

extension DateTimeX on DateTime {
  /// `"14 Mar 2025"`
  String get toDisplayDate => DateFormat('dd MMM yyyy').format(this);

  /// `"14 Mar 2025, 02:30 PM"`
  String get toDisplayDateTime => DateFormat('dd MMM yyyy, hh:mm a').format(this);

  /// `"02:30 PM"`
  String get toDisplayTime => DateFormat('hh:mm a').format(this);

  /// ISO 8601 date string: `"2025-03-14"`
  String get toApiDate => DateFormat('yyyy-MM-dd').format(this);

  /// ISO 8601 UTC: `"2025-03-14T14:30:00Z"`
  String get toApiDateTime => DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(toUtc());

  /// Whether this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  String get toIso8601DateOnly {
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  /// Whether this date was yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek) && isBefore(endOfWeek);
  }

  /// Relative label: "Today", "Yesterday", or [toDisplayDate].
  String get toRelativeLabel {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (isTomorrow) return 'Tomorrow';
    if (isThisWeek) return 'This Week';
    return toDisplayDate;
  }

  /// Get time ago string (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Start of the day (00:00:00).
  DateTime get startOfDay => DateTime(year, month, day);

  /// End of the day (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}

extension NullableDateTimeX on DateTime? {
  String get toDisplayDateOrEmpty => this?.toDisplayDate ?? '';
  String get toDisplayDateTimeOrEmpty => this?.toDisplayDateTime ?? '';
}

// ─────────────────────────────────────────────────────────────────────────────
// BuildContext extensions
// ─────────────────────────────────────────────────────────────────────────────

extension BuildContextX on BuildContext {
  // ── Theme shortcuts ──────────────────────────────────────────────────────

  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Custom theme colors extension
  AppColorsExtension get appColors => theme.extension<AppColorsExtension>()!;

  // ── MediaQuery shortcuts ─────────────────────────────────────────────────

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Safe-area insets for the current view.
  EdgeInsets get safeArea => MediaQuery.paddingOf(this);

  // ── Responsive breakpoints ────────────────────────────────────────────────

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;

  // ── Platform ─────────────────────────────────────────────────────────────
  bool get isIOS => theme.platform == TargetPlatform.iOS;
  bool get isAndroid => theme.platform == TargetPlatform.android;

  // Widgets

  void toast(
    String message, {
    ToastType type = ToastType.normal,
    Duration? toastDuration,
    ToastGravity? toastGravity,
  }) {
    try {
      FToast fToast = FToast()
        ..init(this)
        ..removeCustomToast()
        ..removeQueuedCustomToasts();
      Duration duration = toastDuration.isNull
          ? (type == ToastType.normal || type == ToastType.success)
                ? const Duration(seconds: 3)
                : const Duration(seconds: 10)
          : const Duration(seconds: 10);

      Color foregroundColor = Colors.black;
      Color backgroundColor = Colors.white;
      IconData iconData = Icons.info;

      switch (type) {
        case ToastType.success:
          foregroundColor = Colors.green;
          backgroundColor = Colors.green.shade50;
          iconData = Icons.check_circle;
        case ToastType.failure:
          foregroundColor = Colors.red;
          backgroundColor = Colors.red.shade50;
          iconData = Icons.dangerous;
        case ToastType.warning:
          foregroundColor = Colors.orange;
          backgroundColor = Colors.orange.shade50;
          iconData = Icons.warning;
        case ToastType.normal:
          foregroundColor = Colors.indigo;
          backgroundColor = Colors.indigo.shade50;
          iconData = Icons.info;
      }

      fToast.showToast(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: 1.0,
              style: BorderStyle.solid,
              color: foregroundColor.withValues(alpha: 0.5),
            ),
            /*boxShadow: const [
              BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 2, offset: Offset(0, 2)),
              BoxShadow(color: Colors.black26, spreadRadius: 1, blurRadius: 2, offset: Offset(0, -2)),
            ],*/
          ),
          child: IntrinsicWidth(
            child: Row(
              children: [
                Icon(iconData, color: foregroundColor),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 24,
                    style: textTheme.titleMedium?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.bold,
                      //shadows: [const Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        toastDuration: duration,
        //gravity: MediaQuery.viewInsetsOf(this).bottom > 0 ? ToastGravity.CENTER : ToastGravity.BOTTOM,
        gravity: toastGravity ?? ToastGravity.BOTTOM,
        isDismissible: true,
      );
    } catch (e) {
      log('Error showing toast: $e');
    }
  }

  void snack(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      clipBehavior: Clip.antiAlias,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    ScaffoldMessenger.of(this)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // ── SnackBar helpers ─────────────────────────────────────────────────────

  /// Show a standard informational snackbar.
  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Show an error snackbar with red background.
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(this).colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show a success snackbar.
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<T?> showAppBottomSheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool useSafeArea = true,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      builder: builder,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
    );
  }

  Future<T?> showAppDialog<T>({required WidgetBuilder builder}) {
    return showDialog<T>(
      context: this,
      builder: builder,
    );
  }

  // ── Focus ─────────────────────────────────────────────────────────────────

  /// Hides the keyboard by removing focus from the current focus node.
  void hideKeyboard() => FocusScope.of(this).unfocus();

  // ── Routing shortcuts ────────────────────────────────────────────────────
  String get currentRoute {
    final router = GoRouter.of(this);
    final RouteMatch lastMatch = router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// num extensions
// ─────────────────────────────────────────────────────────────────────────────

extension NumX on num {
  /// Converts a number of bytes to a human-readable string.
  /// `1536.toFileSize()` → `"1.5 KB"`
  String toFileSize() {
    if (this < 1024) return '${this} B';
    if (this < 1048576) return '${(this / 1024).toStringAsFixed(1)} KB';
    if (this < 1073741824) {
      return '${(this / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(this / 1073741824).toStringAsFixed(1)} GB';
  }

  /// Format as currency
  String formatCurrency({String symbol = '\$', int decimals = 0}) {
    final format = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
    );
    return format.format(this);
  }

  /// Format with comma separator
  String formatWithComma() {
    final format = NumberFormat('#,###');
    return format.format(this);
  }

  /// Round to decimal places
  double roundTo(int places) {
    final mod = 10 * places;
    return (this * mod).round() / mod;
  }

  /// Get ordinal string (1st, 2nd, 3rd, etc.)
  String get ordinal {
    if (this >= 11 && this <= 13) return '${this}th';
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  /// Check if in range
  bool inRange(num start, num end) => this >= start && this <= end;

  /// Percentage calculation
  double percentageOf(num total) {
    if (total == 0) return 0;
    return (this / total) * 100;
  }

  // SizedBox generators
  Widget get kH => SizedBox(height: toDouble());
  Widget get kW => SizedBox(width: toDouble());

  // BorderRadius helpers
  BorderRadius get radius => BorderRadius.circular(toDouble());

  // Duration helpers
  Duration get ms => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());
}

/// Extension methods for Duration
///
/// Usage:
/// ```dart
/// Duration duration = Duration(hours: 2, minutes: 30);
/// print(duration.format()); // '2h 30m'
/// ```
extension DurationExtensions on Duration {
  /// Format duration as string
  String format() {
    if (inDays > 0) {
      return '${inDays}d ${inHours.remainder(24)}h';
    } else if (inHours > 0) {
      return '${inHours}h ${inMinutes.remainder(60)}m';
    } else if (inMinutes > 0) {
      return '${inMinutes}m ${inSeconds.remainder(60)}s';
    } else {
      return '${inSeconds}s';
    }
  }

  /// Format as HH:MM:SS
  String formatHHMMSS() {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

/// Extension methods for List
///
/// Usage:
/// ```dart
/// List items = [1, 2, 3, 4, 5];
/// items.shuffle(); // Random order
/// items.firstWhereOrNull((e) => e > 3); // 4
/// ```
extension ListExtensions<T> on List<T> {
  /// Get first element matching predicate or null
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Get element at index or null
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Group list by key
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keyFunction(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }
}

///=====================| Generic Extensions |=====================///

extension NullableWidget<T> on T? {
  Widget? nullOr(Widget Function(T) widgetBuilder) =>
      this == null ? null : widgetBuilder(this as T);

  bool get isNull => this == null;
}

extension IterableExtension<T> on Iterable<T> {
  // Safe accessors
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  // Iteration
  Iterable<E> mapIndexed<E>(E Function(int index, T item) f) {
    var i = 0;
    return map((e) => f(i++, e));
  }

  // Data manipulation
  Map<K, List<T>> groupBy<K>(K Function(T item) keySelector) {
    final groups = <K, List<T>>{};
    for (final item in this) {
      final key = keySelector(item);
      groups.putIfAbsent(key, () => []).add(item);
    }
    return groups;
  }

  Iterable<List<T>> chunk(int size) {
    if (size <= 0) return [toList()];
    final chunks = <List<T>>[];
    final list = toList();
    for (var i = 0; i < list.length; i += size) {
      chunks.add(
        list.sublist(i, i + size > list.length ? list.length : i + size),
      );
    }
    return chunks;
  }

  List<T> get distinct => toSet().toList();

  List<T> distinctBy(Object Function(T item) keySelector) {
    final seen = <Object>{};
    return where((item) => seen.add(keySelector(item))).toList();
  }
}

extension WidgetExtension on Widget {
  /// Wrap the widget with Padding
  Widget paddingAll(double value) => Padding(
    padding: EdgeInsets.all(value),
    child: this,
  );

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    ),
    child: this,
  );

  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    ),
    child: this,
  );

  /// Wrap the widget with Opacity
  Widget opacity(double value) => Opacity(opacity: value, child: this);

  /// Wrap the widget with Visibility
  Widget visible(bool visible, {Widget fallback = const SizedBox.shrink()}) =>
      visible ? this : fallback;

  /// Wrap the widget with Center
  Widget get center => Center(child: this);

  /// Wrap the widget with Expanded
  Widget get expanded => Expanded(child: this);

  /// Wrap the widget with FittedBox
  Widget get fitted => FittedBox(child: this);

  /// Wrap the widget with Hero
  Widget hero(Object tag) => Hero(tag: tag, child: this);

  /// Wrap the widget with InkWell
  Widget tooltip(String message) => Tooltip(message: message, child: this);
}
