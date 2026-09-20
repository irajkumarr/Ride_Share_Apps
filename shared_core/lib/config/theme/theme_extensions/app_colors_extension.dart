import 'package:flutter/material.dart';

/// Custom theme extension to manage brand-specific colors that are not part
/// of the standard Material [ColorScheme].
///
/// This allows accessing colors via `Theme.of(context).extension<AppColorsExtension>()`.
///
/// Usage: context.appColors.cardBackground
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.cardBackground,
  });

  final Color primary;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color cardBackground;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? primary,
    Color? secondary,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? cardBackground,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      cardBackground: cardBackground ?? this.cardBackground,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }

    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
    );
  }
}
