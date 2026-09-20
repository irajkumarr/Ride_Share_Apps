import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/ui_utils.dart';

/* -- Light & Dark Elevated Button Themes -- */
class AppElevatedButtonTheme {
  AppElevatedButtonTheme._(); //To avoid creating instances

  /* -- Light Theme -- */
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColor.white,
      backgroundColor: AppColor.secondary,
      disabledForegroundColor: AppColor.gray,
      disabledBackgroundColor: AppColor.lightGray,
      side: const BorderSide(color: AppColor.secondary),
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSm),
      textStyle: const TextStyle(
        fontSize: 16,
        color: AppColor.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
      ),
    ),
  );

  /* -- Dark Theme -- */
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColor.white,
      backgroundColor: AppColor.secondary,
      disabledForegroundColor: AppColor.gray,
      disabledBackgroundColor: AppColor.gray,
      side: const BorderSide(color: AppColor.secondary),
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSm),
      textStyle: const TextStyle(
        fontSize: 16,
        color: AppColor.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf8),
      ),
    ),
  );
}
