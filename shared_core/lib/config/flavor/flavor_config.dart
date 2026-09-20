enum AppFlavor { dev, prod }

class AppConfig {
  static AppFlavor _flavor = AppFlavor.dev;

  static AppFlavor get flavor => _flavor;

  static void setFlavor(AppFlavor flavor) {
    _flavor = flavor;
  }

  static bool get isDev => _flavor == AppFlavor.dev;
  static bool get isProd => _flavor == AppFlavor.prod;
  static String get flavorName => _flavor == AppFlavor.dev ? 'Development' : 'Production';
}
