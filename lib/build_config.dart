enum Flavor { stag, prod }

class BuildConfig {
  final Flavor flavor;
  final String appName;

  const BuildConfig({required this.flavor, required this.appName});

  static late BuildConfig _instance;
  static BuildConfig get instance => _instance;

  static void init({required Flavor flavor, required String appName}) {
    _instance = BuildConfig(flavor: flavor, appName: appName);
  }

  static bool get isProd => instance.flavor == Flavor.prod;
  static bool get isStag => instance.flavor == Flavor.stag;
}
