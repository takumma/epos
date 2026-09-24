import 'epos_platform_interface.dart';

class Epos {
  Future<String?> getPlatformVersion() {
    return EposPlatform.instance.getPlatformVersion();
  }

  Future<void> printTest() {
    return EposPlatform.instance.printTest();
  }
}
