import 'package:flutter/material.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/font.dart';
import '../../../core/utils/ui_utils.dart';

class AppTextFormFieldTheme {
  AppTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: AppColor.gray,
    suffixIconColor: AppColor.gray,
    // constraints: const BoxConstraints.expand(height: TSizes.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(
      fontSize: AppFontSize.size14,
      color: AppColor.black,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: AppFontSize.size12,
      color: AppColor.gray,
    ),
    errorStyle: const TextStyle().copyWith(
      fontStyle: FontStyle.normal,
      fontSize: AppFontSize.size11,
    ),
    floatingLabelStyle: const TextStyle().copyWith(
      color: AppColor.black.withValues(alpha: 0.8),
    ),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
      borderSide: BorderSide(
        width: 1,
        color: AppColor.gray.withValues(alpha: 0.5),
      ),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
      borderSide: BorderSide(
        width: 1,
        color: AppColor.gray.withValues(alpha: 0.5),
      ),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
      borderSide: const BorderSide(width: 1.5, color: AppColor.secondary),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
      borderSide: const BorderSide(width: 1, color: AppColor.red),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
      borderSide: const BorderSide(width: 1, color: AppColor.red),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: AppColor.gray,
    suffixIconColor: AppColor.gray,
    // constraints: const BoxConstraints.expand(height: TSizes.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(
      fontSize: AppFontSize.size14,
      color: AppColor.white,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: AppFontSize.size12,
      color: AppColor.white,
    ),
    floatingLabelStyle: const TextStyle().copyWith(
      color: AppColor.white.withValues(alpha: 0.8),
    ),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
      borderSide: const BorderSide(width: 1, color: AppColor.gray),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
      borderSide: const BorderSide(width: 1, color: AppColor.gray),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
      borderSide: const BorderSide(width: 1, color: AppColor.white),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
      borderSide: const BorderSide(width: 1, color: AppColor.red),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf5),
      borderSide: const BorderSide(width: 1, color: AppColor.red),
    ),
  );
}
