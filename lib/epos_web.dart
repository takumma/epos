// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'epos_platform_interface.dart';
import 'src/epos_device.dart';

/// A web implementation of the EposPlatform of the Epos plugin.
class EposWeb extends EposPlatform {
  /// Constructs a EposWeb
  EposWeb();

  static void registerWith(Registrar registrar) {
    EposPlatform.instance = EposWeb();
  }

  @override
  Stream<EposDevice> get discoveryStream {
    // Web implementation for discoveryStream
    throw UnimplementedError(
      'discoveryStream has not been implemented for web.',
    );
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }

  @override
  Future<void> startDiscovery() async {
    // Web implementation for startDiscovery
  }

  @override
  Future<void> stopDiscovery() async {
    // Web implementation for stopDiscovery
  }

  @override
  Future<void> connect(String target) async {
    // Web implementation for connect
  }

  @override
  Future<void> disconnect() async {
    // Web implementation for disconnect
  }

  @override
  Future<void> printText(String text) async {
    // Web implementation for printText
  }

  @override
  Future<void> sendPrintJob(List<Map<String, dynamic>> commands) async {
    // Web implementation for sendPrintJob
  }
}
