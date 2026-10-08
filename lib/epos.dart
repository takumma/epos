import 'epos_platform_interface.dart';
import 'src/epos_device.dart';
import 'src/epos_printer.dart';

export 'src/epos_device.dart';
export 'src/epos_printer.dart';
export 'src/epos_printer_job.dart';

class Epos {
  Epos({EposPlatform? platform})
    : _platform = platform ?? EposPlatform.instance;

  final EposPlatform _platform;

  Stream<EposDevice> get discoveryStream {
    return _platform.discoveryStream;
  }

  Future<String?> getPlatformVersion() {
    return _platform.getPlatformVersion();
  }

  Future<void> startDiscovery() async {
    await _platform.startDiscovery();
  }

  Future<void> stopDiscovery() async {
    await _platform.stopDiscovery();
  }

  Future<EposPrinter> connect(EposDevice device) async {
    await _platform.connect(device.target);

    return EposPrinter(device: device, platform: _platform);
  }

  Future<void> disconnect() async {
    await _platform.disconnect();
  }
}
