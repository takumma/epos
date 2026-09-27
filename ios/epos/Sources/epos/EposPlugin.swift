import Flutter
import UIKit
import libepos2

public class EposPlugin: NSObject, FlutterPlugin {
    
    private var printer: Epos2Printer?
    
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
      
        guard let printer = Epos2Printer(
            printerSeries: EPOS2_TM_T88.rawValue,
            lang: EPOS2_MODEL_ANK.rawValue
      ) else {
          result (FlutterError(code: "PRINTER_INIT_FAILED", message: "Failed to initialize Epos2Printer", details: nil ))
          return
      }
        
      
      self.printer = printer
      
      var sdkResult = printer.addTextAlign(EPOS2_ALIGN_CENTER.rawValue)

      guard sdkResult == EPOS2_SUCCESS.rawValue else {
          result(
              FlutterError(
                  code: "ADD_TEXT_ALIGN_FAILED",
                  message: "Failed to set text alignment",
                  details: sdkResult
              )
          )
          return
      }

      sdkResult = printer.addText("Hello World")

      guard sdkResult == EPOS2_SUCCESS.rawValue else {
          result(
              FlutterError(
                  code: "ADD_TEXT_FAILED",
                  message: "Failed to add text",
                  details: sdkResult
              )
          )
          return
      }
      
      
    result(nil)
  }
}
