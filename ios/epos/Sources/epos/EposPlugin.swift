import Flutter
import UIKit
import libepos2

public class EposPlugin: NSObject, FlutterPlugin, Epos2PtrReceiveDelegate,
    Epos2DiscoveryDelegate
{

    private var discoverySink: FlutterEventSink?
    private var printer: Epos2Printer?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "epos/methods", binaryMessenger: registrar.messenger())
        let discoveryChannel = FlutterEventChannel(
            name: "epos/discovery", binaryMessenger: registrar.messenger())

        let instance = EposPlugin()

        registrar.addMethodCallDelegate(instance, channel: channel)
        discoveryChannel.setStreamHandler(instance)
    }

    public func handle(
        _ call: FlutterMethodCall, result: @escaping FlutterResult
    ) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "startDiscovery":
            startDiscovery(result: result)
        case "stopDiscovery":
            stopDiscovery(result: result)
        case "connect":
            connect(result: result, arguments: call.arguments)
        case "disconnect":
            disconnect(result: result)
        case "printText":
            printText(result: result, arguments: call.arguments)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startDiscovery(result: @escaping FlutterResult) {
        let filterOption = Epos2FilterOption()
        filterOption.deviceType = EPOS2_TYPE_PRINTER.rawValue

        let status = Epos2Discovery.start(filterOption, delegate: self)

        if status != EPOS2_SUCCESS.rawValue {
            result(
                FlutterError(
                    code: "DISCOVERY_FAILED",
                    message: "Failed to start discovery", details: nil))
        }
    }

    private func stopDiscovery(result: @escaping FlutterResult) {
        let status = Epos2Discovery.stop()
        if status != EPOS2_SUCCESS.rawValue {
            result(
                FlutterError(
                    code: "DISCOVERY_FAILED",
                    message: "Failed to stop discovery", details: nil))
        }
    }

    private func connect(result: @escaping FlutterResult, arguments: Any?) {
        guard let args = arguments as? [String: Any],
            let target = args["target"] as? String
        else {
            result(
                FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid arguments for connect", details: nil))
            return
        }

        guard createPrinter() else {
            result(
                FlutterError(
                    code: "PRINTER_CREATION_FAILED",
                    message: "Failed to create printer", details: nil))
            return
        }

        let status = printer!.connect(target, timeout: Int(EPOS2_PARAM_DEFAULT))

        if status != EPOS2_SUCCESS.rawValue {
            result(
                FlutterError(
                    code: "CONNECTION_FAILED",
                    message: "Failed to connect to printer", details: nil))
            return
        }

        result(nil)
    }

    private func disconnect(result: @escaping FlutterResult) {
        guard printer != nil else {
            result(nil)
            return
        }

        printer?.disconnect()
        printer?.clearCommandBuffer()
        printer?.setReceiveEventDelegate(nil)
        printer = nil

        result(nil)
    }

    private func printText(result: @escaping FlutterResult, arguments: Any?) {
        guard let args = arguments as? [String: Any],
            let text = args["text"] as? String
        else {
            result(
                FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid arguments for printText", details: nil))
            return
        }

        guard printer != nil else {
            result(
                FlutterError(
                    code: "PRINTER_NOT_CONNECTED",
                    message: "Printer is not connected", details: nil))
            return
        }

        var status = printer?.addTextAlign(EPOS2_ALIGN_LEFT.rawValue)
        print("addTextAlign: \(status)")
        if status != EPOS2_SUCCESS.rawValue {
            result(
                FlutterError(
                    code: "PRINT_FAILED",
                    message: "Failed to set text alignment", details: status))
            return
        }

        status = printer?.addText("==============================\n")
        status = printer?.addText("Hello World!\n")
        status = printer?.addText("==============================\n")
        
        print("addText: \(status)")
        if status != EPOS2_SUCCESS.rawValue {
            result(
                FlutterError(
                    code: "PRINT_FAILED",
                    message: "Failed to add text", details: status))
            return
        }
        
        status = printer?.sendData(Int(EPOS2_PARAM_DEFAULT))
        print("sendData: \(status)")

        if status != EPOS2_SUCCESS.rawValue {
            result(
                FlutterError(
                    code: "ADD_TEXT_FAILED",
                    message: "Failed to add text", details: status))
            return
        }

        result(nil)
    }

    private func createPrinter() -> Bool {
        if printer != nil {
            return true
        }
        printer = Epos2Printer.init(
            printerSeries: EPOS2_TM_T88.rawValue,
            lang: EPOS2_MODEL_ANK.rawValue
        )

        printer?.setReceiveEventDelegate(self)

        return printer != nil
    }

    public func onPtrReceive(
        _ printerObj: Epos2Printer!,
        code: Int32,
        status: Epos2PrinterStatusInfo!,
        printJobId: String!
    ) {
        print("===== onPtrReceive =====")
            print("code: \(code)")
            print("printJobId: \(printJobId ?? "")")

            if let status = status {
                print("online: \(status.online)")
                print("connection: \(status.connection)")
                print("paper: \(status.paper)")
                print("coverOpen: \(status.coverOpen)")
                print("paperFeed: \(status.paperFeed)")
                print("errorStatus: \(status.errorStatus)")
                print("autoRecoverError: \(status.autoRecoverError)")
                print("unrecoverError: \(status.unrecoverError)")
            }

            print("========================")
    }

    public func onDiscovery(_ deviceInfo: Epos2DeviceInfo!) {
        guard let deviceInfo else {
            return
        }
        let device: [String: Any] = [
            "deviceName": deviceInfo.deviceName ?? "",
            "target": deviceInfo.target ?? "",
        ]

        discoverySink?(device)
    }
}

extension EposPlugin: FlutterStreamHandler {
    public func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        discoverySink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        discoverySink = nil
        return nil
    }
}
