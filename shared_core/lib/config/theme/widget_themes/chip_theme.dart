import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';

class AppChipTheme {
  AppChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: AppColor.gray.withValues(alpha: 0.4),
    labelStyle: const TextStyle(color: AppColor.black),
    selectedColor: AppColor.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: AppColor.white,
  );

  static ChipThemeData darkChipTheme = const ChipThemeData(
    disabledColor: AppColor.grayG,
    labelStyle: TextStyle(color: AppColor.white),
    selectedColor: AppColor.primary,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: AppColor.white,
  );
}
