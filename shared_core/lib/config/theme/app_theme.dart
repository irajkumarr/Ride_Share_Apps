import 'package:flutter/material.dart';
import 'widget_themes/appbar_theme.dart';
import 'widget_themes/bottom_sheet_theme.dart';
import 'widget_themes/checkbox_theme.dart';
import 'widget_themes/chip_theme.dart';
import 'widget_themes/elevated_button_theme.dart';
import 'widget_themes/outlined_button_theme.dart';
import 'widget_themes/text_field_theme.dart';
import 'widget_themes/text_theme.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/font.dart';

import 'theme_extensions/app_colors_extension.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColor.secondary,
      brightness: Brightness.light,
      error: AppColor.red,
    ),
    fontFamily: AppFontFamily.fontFamily,
    disabledColor: AppColor.gray,
    brightness: Brightness.light,
    primaryColor: AppColor.secondary,
    textTheme: AppTextTheme.lightTextTheme,
    chipTheme: AppChipTheme.lightChipTheme,
    scaffoldBackgroundColor: AppColor.background,
    appBarTheme: AppAppBarTheme.lightAppBarTheme,
    checkboxTheme: AppCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: AppBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: AppTextFormFieldTheme.lightInputDecorationTheme,
    extensions: [
      const AppColorsExtension(
        primary: AppColor.primary,
        secondary: AppColor.secondary,
        success: AppColor.green,
        warning: AppColor.yellow,
        error: AppColor.red,
        info: AppColor.cornflowerBlue,
        cardBackground: AppColor.white,
      ),
    ],
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColor.secondary,
      brightness: Brightness.dark,
      error: AppColor.red,
    ),
    fontFamily: AppFontFamily.fontFamily,
    disabledColor: AppColor.gray,
    brightness: Brightness.dark,
    primaryColor: AppColor.secondary,
    textTheme: AppTextTheme.darkTextTheme,
    chipTheme: AppChipTheme.darkChipTheme,
    scaffoldBackgroundColor: AppColor.black,
    appBarTheme: AppAppBarTheme.darkAppBarTheme,
    checkboxTheme: AppCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: AppBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: AppTextFormFieldTheme.darkInputDecorationTheme,
    extensions: [
      const AppColorsExtension(
        primary: AppColor.primary,
        secondary: AppColor.secondary,
        success: AppColor.green,
        warning: AppColor.yellow,
        error: AppColor.red,
        info: AppColor.cornflowerBlue,
        cardBackground: AppColor.charcoal,
      ),
    ],
  );
}
