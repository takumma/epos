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
        case "sendPrintJob":
            sendPrintJob(result: result, arguments: call.arguments)
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

    private func sendPrintJob(result: @escaping FlutterResult, arguments: Any?)
    {
        guard let args = arguments as? [String: Any],
            let commands = args["commands"] as? [[String: Any]]
        else {
            result(
                FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid arguments for sendPrintJob", details: nil)
            )
            return
        }

        guard printer != nil else {
            result(
                FlutterError(
                    code: "PRINTER_NOT_CONNECTED",
                    message: "Printer is not connected", details: nil))
            return
        }

        var status: Int32? = EPOS2_SUCCESS.rawValue
        for command in commands {
            if let type = command["type"] as? String {
                switch type {
                case "text":
                    if let text = command["text"] as? String {
                        if containsKorean(text) {
                            if let image = renderTextAsImage(text) {
                                status =
                                    printer?.add(
                                        image,
                                        x: 0,
                                        y: 0,
                                        width: Int(image.size.width),
                                        height: Int(image.size.height),
                                        color: EPOS2_COLOR_1.rawValue,
                                        mode: EPOS2_MODE_MONO.rawValue,
                                        halftone: EPOS2_HALFTONE_DITHER
                                            .rawValue,
                                        brightness: Double(EPOS2_PARAM_DEFAULT),
                                        compress: EPOS2_COMPRESS_AUTO.rawValue
                                    ) ?? EPOS2_ERR_PARAM.rawValue
                            }
                        } else {

                            status =
                                printer?.addText(text)
                                ?? EPOS2_ERR_PARAM.rawValue
                        }
                    }
                case "textLang":
                    if let lang = command["lang"] as? String {
                        status = printer?.addTextLang(Epos2Lang(lang).rawValue)
                    }
                case "align":
                    if let align = command["align"] as? String {
                        printer?.addTextAlign(Epos2Align(align).rawValue)
                    }
                case "style":
                    if let reverse = command["reverse"] as? Bool,
                       let ul = command["ul"] as? Bool,
                       let em = command["em"] as? Bool,
                       let color = command["color"] as? String {
                        status = printer?.addTextStyle(
                            reverse.eposBoolValue,
                            ul: ul.eposBoolValue,
                            em: em.eposBoolValue,
                            color: Epos2Color(color).rawValue
                        ) ?? EPOS2_ERR_PARAM.rawValue
                    }
                case "textSmooth":
                    if let smooth = command["smooth"] as? Bool {
                        status = printer?.addTextSmooth(smooth.eposBoolValue)
                            ?? EPOS2_ERR_PARAM.rawValue
                    }
                case "feed":
                    if let lines = command["lines"] as? Int {
                        status =
                            printer?.addFeedLine(lines)
                            ?? EPOS2_ERR_PARAM.rawValue
                    }
                case "cut":
                    status =
                        printer?.addCut(EPOS2_CUT_FEED.rawValue)
                        ?? EPOS2_ERR_PARAM.rawValue
                default:
                    break
                }
            }
            if status != EPOS2_SUCCESS.rawValue {
                result(
                    FlutterError(
                        code: "PRINT_FAILED",
                        message: "Failed to add command", details: status))
                return
            }
        }

        status =
            printer?.sendData(Int(EPOS2_PARAM_DEFAULT))
            ?? EPOS2_ERR_PARAM.rawValue
        if status != EPOS2_SUCCESS.rawValue {
            result(
                FlutterError(
                    code: "SEND_FAILED",
                    message: "Failed to send print job", details: status))
            return
        }

        result(nil)
    }

    private func containsKorean(_ text: String) -> Bool {
        return text.range(of: "\\p{Hangul}", options: .regularExpression) != nil
    }

    private func renderTextAsImage(
        _ text: String,
        fontSize: CGFloat = 24
    ) -> UIImage? {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]

        let textSize = (text as NSString).size(withAttributes: attributes)
        let size = CGSize(
            width: ceil(textSize.width) + 8, height: ceil(textSize.height) + 8)

        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        defer { UIGraphicsEndImageContext() }

        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        (text as NSString).draw(
            at: CGPoint(x: 4, y: 4), withAttributes: attributes)

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    private func createPrinter() -> Bool {
        if printer != nil {
            return true
        }
        printer = Epos2Printer.init(
            printerSeries: EPOS2_TM_T88.rawValue,
            lang: EPOS2_MODEL_JAPANESE.rawValue
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

extension Epos2Align {
    init(_ s: String) {
        switch s {
        case "left":
            self = EPOS2_ALIGN_LEFT
        case "center":
            self = EPOS2_ALIGN_CENTER
        case "right":
            self = EPOS2_ALIGN_RIGHT
        default:
            self = EPOS2_ALIGN_LEFT
        }
    }
}

extension Epos2Color {
    init(_ s: String) {
        switch s {
        case "color1":
            self = EPOS2_COLOR_1
        case "color2":
            self = EPOS2_COLOR_2
        case "color3":
            self = EPOS2_COLOR_3
        case "color4":
            self = EPOS2_COLOR_4
        default:
            self = EPOS2_COLOR_1
        }
    }
}

extension Epos2Lang {
    init(_ s: String) {
        switch s {
        case "enAwk":
            self = EPOS2_LANG_EN
        case "ja":
            self = EPOS2_LANG_JA
        case "zhCh":
            self = EPOS2_LANG_ZH_CN
        case "zhTw":
            self = EPOS2_LANG_ZH_TW
        case "ko":
            self = EPOS2_LANG_KO
        case "th":
            self = EPOS2_LANG_TH
        case "vi":
            self = EPOS2_LANG_VI
        case "multi":
            self = EPOS2_LANG_MULTI
        default:
            self = EPOS2_LANG_EN
        }
    }
}

extension Epos2Cut {
    init(_ s: String) {
        switch s {
        case "cutFeed":
            self = EPOS2_CUT_FEED
        case "cutNoFeed":
            self = EPOS2_CUT_NO_FEED
        case "cutReserve":
            self = EPOS2_CUT_RESERVE
        case "fullCutFeed":
            self = EPOS2_FULL_CUT_FEED
        case "fullCutNoFeed":
            self = EPOS2_FULL_CUT_NO_FEED
        case "fullCutReserve":
            self = EPOS2_FULL_CUT_RESERVE
        default:
            self = EPOS2_CUT_FEED
        }
    }
}

extension Bool {
    var eposBoolValue: Int32 {
        return self ? EPOS2_TRUE : EPOS2_FALSE
    }
}
