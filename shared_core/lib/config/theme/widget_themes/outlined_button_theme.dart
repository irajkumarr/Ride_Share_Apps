import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/ui_utils.dart';

/* -- Light & Dark Outlined Button Themes -- */
class AppOutlinedButtonTheme {
  AppOutlinedButtonTheme._(); //To avoid creating instances

  /* -- Light Theme -- */
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColor.black,
      side: const BorderSide(color: AppColor.primary),
      textStyle: const TextStyle(
        fontSize: 16,
        color: AppColor.black,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.paddingSm,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
      ),
    ),
  );

  /* -- Dark Theme -- */
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColor.white,
      side: const BorderSide(color: AppColor.secondary),
      textStyle: const TextStyle(
        fontSize: 16,
        color: AppColor.white,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.paddingSm,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
      ),
    ),
  );
}
