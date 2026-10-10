import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'epos_platform_interface.dart';
import 'src/epos_device.dart';

/// An implementation of [EposPlatform] that uses method channels.
class MethodChannelEpos extends EposPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  static const MethodChannel methodChannel = MethodChannel('epos/methods');

  static const EventChannel discoveryChannel = EventChannel('epos/discovery');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Stream<EposDevice> get discoveryStream {
    return discoveryChannel.receiveBroadcastStream().map((event) {
      final map = Map<String, dynamic>.from(event);
      return EposDevice.fromMap(map);
    });
  }

  @override
  Future<void> startDiscovery() async {
    await methodChannel.invokeMethod<void>('startDiscovery');
  }

  @override
  Future<void> stopDiscovery() async {
    await methodChannel.invokeMethod<void>('stopDiscovery');
  }

  @override
  Future<void> connect(String target) async {
    await methodChannel.invokeMethod<void>('connect', {'target': target});
  }

  @override
  Future<void> disconnect() async {
    await methodChannel.invokeMethod<void>('disconnect');
  }

  @override
  Future<void> sendPrintJob(List<Map<String, dynamic>> commands) async {
    await methodChannel.invokeMethod<void>('sendPrintJob', {
      'commands': commands,
    });
  }
}
