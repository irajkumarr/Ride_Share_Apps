import 'package:flutter/material.dart';

class AppFontFamily {
  static const String fontFamily = 'Lexend';
}

class AppFontWeight {
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Aliases for common use cases
  static const FontWeight normal = regular;
  static const FontWeight w500 = medium;
  static const FontWeight w600 = semiBold;
  static const FontWeight w700 = bold;
}

class AppFontSize {
  // Main font sizes from Figma design
  static const double size7 = 7.0;
  static const double size9 = 9.0;
  static const double size10 = 10.0;
  static const double size11 = 11.0;
  static const double size12 = 12.0;
  static const double size13 = 14.0;
  static const double size14 = 14.0;
  static const double size15 = 15.0;
  static const double size16 = 16.0;
  static const double size18 = 18.0;

  // Semantic names for better code readability
  static const double tiny = size7;
  static const double extraSmall = size9;
  static const double small = size10;
  static const double smallPlus = size11;
  static const double caption = size12;
  static const double body = size14;
  static const double bodyLarge = size15;
  static const double title = size16;
  static const double heading = size18;
}
