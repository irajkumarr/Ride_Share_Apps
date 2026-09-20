import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/utils/colors.dart';

class AppAppBarTheme {
  AppAppBarTheme._();

  static final lightAppBarTheme = const AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: AppColor.black,
      size: AppConstants.iconSizeMd,
    ),
    actionsIconTheme: IconThemeData(
      color: AppColor.black,
      size: AppConstants.iconSizeMd,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AppColor.black,
    ),
  );
  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: AppColor.black,
      size: AppConstants.iconSizeMd,
    ),
    actionsIconTheme: IconThemeData(
      color: AppColor.white,
      size: AppConstants.iconSizeMd,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AppColor.white,
    ),
  );
}
