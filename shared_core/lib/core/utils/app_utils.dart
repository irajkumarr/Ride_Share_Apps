import 'dart:io';

import 'package:intl/intl.dart';

import 'app_constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DateUtils
// ─────────────────────────────────────────────────────────────────────────────

/// Date and time formatting helpers.
abstract final class AppDateUtils {
  /// Parses an ISO 8601 string to [DateTime] safely.
  /// Returns `null` if [value] is null or malformed.
  static DateTime? tryParse(String? value) {
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Formats [date] using [pattern] (intl pattern string).
  static String format(DateTime date, String pattern) => DateFormat(pattern).format(date);

  /// `"14 Mar 2025"`
  static String toDisplayDate(DateTime date) => DateFormat(AppConstants.dateFormat).format(date);

  /// `"14 Mar 2025, 02:30 PM"`
  static String toDisplayDateTime(DateTime date) =>
      DateFormat(AppConstants.dateTimeFormat).format(date);

  /// `"2025-03-14"`
  static String toApiDate(DateTime date) => DateFormat(AppConstants.apiDateFormat).format(date);

  /// Relative time label: "Just now", "5 mins ago", "2 days ago", etc.
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    }
    final years = (diff.inDays / 365).floor();
    return '$years year${years == 1 ? '' : 's'} ago';
  }

  /// Whether [date] falls within today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NumberUtils
// ─────────────────────────────────────────────────────────────────────────────

/// Number formatting helpers.
abstract final class NumberUtils {
  /// `1234567` → `"1,234,567"`
  static String withCommas(num value) => NumberFormat('#,###').format(value);

  /// `1234.5` → `"$1,234.50"` (default USD)
  static String toCurrency(
    num value, {
    String symbol = '\$',
    String locale = 'en_US',
    int decimalDigits = 2,
  }) => NumberFormat.currency(
    locale: locale,
    symbol: symbol,
    decimalDigits: decimalDigits,
  ).format(value);

  /// `0.75` → `"75%"`
  static String toPercent(double value, {int decimalDigits = 0}) =>
      NumberFormat.percentPattern().format(value).replaceAll('.', '');

  /// `1500000` → `"1.5M"`, `12300` → `"12.3K"`
  static String compact(num value) => NumberFormat.compact().format(value);

  /// Safe division that returns [fallback] when [divisor] is zero.
  static double safeDivide(
    num dividend,
    num divisor, {
    double fallback = 0.0,
  }) => divisor == 0 ? fallback : dividend / divisor;
}

// ─────────────────────────────────────────────────────────────────────────────
// FileUtils
// ─────────────────────────────────────────────────────────────────────────────

/// File and MIME type helpers.
abstract final class FileUtils {
  /// Returns the file extension in lower case (without the leading dot).
  /// `"photo.JPEG"` → `"jpeg"`
  static String extension(String filePath) => filePath.split('.').last.toLowerCase();

  /// Returns `true` if [filePath] has an image extension.
  static bool isImage(String filePath) =>
      AppConstants.allowedImageTypes.contains(extension(filePath));

  /// Returns a human-readable file size string.
  /// `1048576` → `"1.0 MB"`
  static String readableSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }

  /// Returns `true` if [file] is within the allowed size limit.
  static bool isWithinSizeLimit(File file, {int maxMb = 5}) {
    final bytes = file.lengthSync();
    return bytes <= maxMb * 1024 * 1024;
  }

  /// Infers a basic MIME type from the file extension.
  static String mimeType(String filePath) {
    return switch (extension(filePath)) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'pdf' => 'application/pdf',
      'mp4' => 'video/mp4',
      'mp3' => 'audio/mpeg',
      'json' => 'application/json',
      'csv' => 'text/csv',
      _ => 'application/octet-stream',
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StringUtils
// ─────────────────────────────────────────────────────────────────────────────

/// Miscellaneous string utilities.
abstract final class StringUtils {
  /// Generates initials from a full name.
  /// `"John Doe"` → `"JD"` | `"Alice"` → `"A"`
  static String initials(String name, {int maxChars = 2}) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(maxChars).map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();
  }

  /// Removes diacritics / accent characters for search normalisation.
  /// `"café"` → `"cafe"`
  static String removeDiacritics(String text) {
    const withDiacritics =
        'àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ'
        'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞŸ';
    const withoutDiacritics =
        'aaaaaaaceeeeiiiidnooooooouuuuyby'
        'AAAAAAAACEEEEIIIIDNOOOOOOOUUUUYBy';

    return text.splitMapJoin(
      '',
      onNonMatch: (char) {
        final idx = withDiacritics.indexOf(char);
        return idx >= 0 ? withoutDiacritics[idx] : char;
      },
    );
  }

  /// Masks an email: `"john.doe@example.com"` → `"j•••.d••@example.com"`
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    final masked = name.length <= 2
        ? name
        : '${name[0]}${'•' * (name.length - 2)}${name[name.length - 1]}';
    return '$masked@$domain';
  }
}
