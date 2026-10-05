import 'epos_platform_interface.dart';
import 'src/epos_device.dart';

export 'src/epos_device.dart';

class Epos {
  Stream<EposDevice> get discoveryStream {
    return EposPlatform.instance.discoveryStream;
  }

  Future<String?> getPlatformVersion() {
    return EposPlatform.instance.getPlatformVersion();
  }

  Future<void> startDiscovery() async {
    await EposPlatform.instance.startDiscovery();
  }

  Future<void> stopDiscovery() async {
    await EposPlatform.instance.stopDiscovery();
  }

  Future<void> connect(String target) async {
    await EposPlatform.instance.connect(target);
  }

  Future<void> disconnect() async {
    await EposPlatform.instance.disconnect();
  }

  Future<void> printText(String text) async {
    await EposPlatform.instance.printText(text);
  }
}
