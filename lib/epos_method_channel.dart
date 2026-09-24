import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'epos_platform_interface.dart';

/// An implementation of [EposPlatform] that uses method channels.
class MethodChannelEpos extends EposPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('epos');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> printTest() async {
    await methodChannel.invokeMethod<void>('printTest');
  }
}
