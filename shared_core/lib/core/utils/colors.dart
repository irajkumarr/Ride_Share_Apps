import 'dart:ui';

class AppColor {
  static const Color primary = Color(0xFFD6ED39);
  static const Color darkGreen = Color(0xFFBDD22A);
  // static const Color secondary = Color(0xFF7254F8);
  static const Color secondary = Color(0xFF1877F2);
  static const Color lightPurple = Color(0xFFF1EAFF);
  static const Color white = Color(0XFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGray = Color(0xFFF0F0F0);
  static const Color gray = Color(0xFF666666);
  static const Color red = Color(0xFFff3333);
  static const Color background = Color(0xFFF8F8F8);
  static const Color lightPrimaryColor = Color(0xffF2F1F6);
  static const Color lightGray = Color(0xFF757575);
  static const Color activeGreen = Color(0xFF36B37E);
  static const Color activeBackgroundGreen = Color(0xFFE5FFF4);
  static const Color borderGrey = Color(0xFFD4D4D4);
  static const Color yellow = Color(0xFFFFC107);
  static const Color green = Color(0xFF28A745);
  static const Color grayG = Color(0xFF758389);
  static const Color charcoal = Color(0xFF444444);
  static const Color warmGray = Color(0xFF827D7D);
  static const Color mediumPurple = Color(0xFF8A5DD9);
  static const Color cornflowerBlue = Color(0xFF4A90E2);
  static const Color slateGray = Color(0xFF728188);

  static Color primaryColor(double opacity) {
    try {
      return const Color(0xFFD6ED39).withValues(alpha: opacity);
    } catch (e) {
      return const Color(0xFFD6ED39).withValues(alpha: opacity);
    }
  }
}
