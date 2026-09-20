import '../../core/utils/app_constants.dart';

/// Reusable form field validators.
///
/// All validators return `null` on success or an error string on failure,
/// matching Flutter's [FormField.validator] signature.
///
/// Usage (TextFormField):
/// ```dart
/// validator: Validators.compose([
///   Validators.required(),
///   Validators.email(),
/// ]),
/// ```
abstract final class Validators {
  // ── Primitives ─────────────────────────────────────────────────────────────

  /// Field must not be null or blank.
  static String? Function(String?) required({String? message}) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message ?? 'This field is required';
      }
      return null;
    };
  }

  /// Value must be a valid email address.
  static String? Function(String?) email({String? message}) {
    return (value) {
      if (value == null || value.trim().isEmpty) return null; // use required()
      final regex = RegExp(
        r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+'
        r'@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
      );
      if (!regex.hasMatch(value.trim())) {
        return message ?? 'Enter a valid email address';
      }
      return null;
    };
  }

  /// Value must be a valid phone number (digits only, 7–15 chars).
  static String? Function(String?) phone({String? message}) {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length < AppConstants.phoneMinLength ||
          digits.length > AppConstants.phoneMaxLength) {
        return message ?? 'Enter a valid phone number';
      }
      return null;
    };
  }

  /// Minimum character length.
  static String? Function(String?) minLength(int min, {String? message}) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length < min) {
        return message ?? 'Must be at least $min characters';
      }
      return null;
    };
  }

  /// Maximum character length.
  static String? Function(String?) maxLength(int max, {String? message}) {
    return (value) {
      if (value == null) return null;
      if (value.length > max) {
        return message ?? 'Must not exceed $max characters';
      }
      return null;
    };
  }

  /// Password complexity: ≥8 chars, at least one uppercase, one digit,
  /// one special character.
  static String? Function(String?) password({String? message}) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length < AppConstants.passwordMinLength) {
        return message ??
            'Password must be at least '
                '${AppConstants.passwordMinLength} characters';
      }
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return message ?? 'Password must contain at least one uppercase letter';
      }
      if (!RegExp(r'\d').hasMatch(value)) {
        return message ?? 'Password must contain at least one number';
      }
      if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
        return message ?? 'Password must contain at least one special character';
      }
      return null;
    };
  }

  /// [confirm] must match [original].
  static String? Function(String?) match(
    String? Function() getOriginal, {
    String? message,
  }) {
    return (value) {
      if (value != getOriginal()) {
        return message ?? 'Values do not match';
      }
      return null;
    };
  }

  /// Value must be a valid URL.
  static String? Function(String?) url({String? message}) {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;
      final uri = Uri.tryParse(value.trim());
      if (uri == null || !uri.hasAbsolutePath || !uri.hasScheme) {
        return message ?? 'Enter a valid URL';
      }
      return null;
    };
  }

  /// Value must match a numeric pattern.
  static String? Function(String?) numeric({String? message}) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!RegExp(r'^\d+$').hasMatch(value)) {
        return message ?? 'Enter a valid number';
      }
      return null;
    };
  }

  /// Full name validator:
  /// - Only alphabets
  /// - At least 2 words
  /// - Each word ≥ 3 characters
  static String? Function(String?) fullName({String? message}) {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;

      final parts = value.trim().split(RegExp(r'\s+'));

      // ❌ Must be at least 2 parts
      if (parts.length < 2) {
        return message ?? 'Enter at least first and last name';
      }

      for (final part in parts) {
        // ❌ Each part must be at least 2 characters
        if (part.length < 3) {
          return message ?? 'Each name must be at least 3 characters';
        }

        // ❌ Only alphabets allowed
        if (!RegExp(r'^[a-zA-Z]+$').hasMatch(part)) {
          return message ?? 'Name must contain only alphabets';
        }
      }

      return null;
    };
  }

  // ── Composer ───────────────────────────────────────────────────────────────

  /// Chains multiple validators; returns the first error found.
  ///
  /// Example:
  /// ```dart
  /// validator: Validators.compose([
  ///   Validators.required(),
  ///   Validators.email(),
  /// ]),
  /// ```
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
