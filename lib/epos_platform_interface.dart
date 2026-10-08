import 'package:epos/src/epos_device.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'epos_method_channel.dart';

abstract class EposPlatform extends PlatformInterface {
  /// Constructs a EposPlatform.
  EposPlatform() : super(token: _token);

  static final Object _token = Object();

  static EposPlatform _instance = MethodChannelEpos();

  /// The default instance of [EposPlatform] to use.
  ///
  /// Defaults to [MethodChannelEpos].
  static EposPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EposPlatform] when
  /// they register themselves.
  static set instance(EposPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<EposDevice> get discoveryStream {
    throw UnimplementedError('discoveryStream has not been implemented.');
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> startDiscovery() {
    throw UnimplementedError('startDiscovery() has not been implemented.');
  }

  Future<void> stopDiscovery() {
    throw UnimplementedError('stopDiscovery() has not been implemented.');
  }

  Future<void> connect(String target) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<void> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  Future<void> printText(String text) {
    throw UnimplementedError('printText() has not been implemented.');
  }

  Future<void> sendPrintJob(List<Map<String, dynamic>> commands) {
    throw UnimplementedError('sendPrintJob() has not been implemented.');
  }
}
