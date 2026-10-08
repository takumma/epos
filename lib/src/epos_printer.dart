import '../epos_platform_interface.dart';
import 'epos_device.dart';
import 'epos_printer_job.dart';

class EposPrinter {
  EposPrinter({required this.device, EposPlatform? platform})
    : _platform = platform ?? EposPlatform.instance;

  final EposDevice device;
  final EposPlatform _platform;

  Future<void> printText(String text) async {
    await _platform.printText(text);
  }

  Future<void> disconnect() async {
    await _platform.disconnect();
  }

  Future<void> print(EposPrinterJob job) async {
    await _platform.sendPrintJob(job.commands);
  }

  EposPrinterJob createPrintJob() {
    return EposPrinterJob(platform: _platform);
  }
}
