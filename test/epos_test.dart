import 'package:flutter_test/flutter_test.dart';
import 'package:epos/epos.dart';
import 'package:epos/epos_platform_interface.dart';
import 'package:epos/epos_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEposPlatform
    with MockPlatformInterfaceMixin
    implements EposPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final EposPlatform initialPlatform = EposPlatform.instance;

  test('$MethodChannelEpos is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEpos>());
  });

  test('getPlatformVersion', () async {
    Epos eposPlugin = Epos();
    MockEposPlatform fakePlatform = MockEposPlatform();
    EposPlatform.instance = fakePlatform;

    expect(await eposPlugin.getPlatformVersion(), '42');
  });
}
