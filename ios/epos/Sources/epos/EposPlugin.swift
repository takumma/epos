import Flutter
import UIKit
import libepos2

public class EposPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "epos", binaryMessenger: registrar.messenger())
    let instance = EposPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "printTest":
      printTest(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func printTest(result: @escaping FlutterResult) {
    result(nil)
  }
}
