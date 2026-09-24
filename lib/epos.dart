import 'epos_platform_interface.dart';

class Epos {
  Future<String?> getPlatformVersion() {
    return EposPlatform.instance.getPlatformVersion();
  }
}
