import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "koralcore/ble_transport"
  private var transportChannel: FlutterMethodChannel?
  private let bleHost = BleHost()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: channelName,
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        self?.handle(call: call, result: result)
      }
      transportChannel = channel
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handle(call: FlutterMethodCall, result: FlutterResult) {
    switch call.method {
    case "write":
      handleWrite(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleWrite(call: FlutterMethodCall, result: FlutterResult) {
    guard let arguments = call.arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Arguments missing", details: nil))
      return
    }

    guard let payloadData = arguments["payload"] as? FlutterStandardTypedData else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "payload is required", details: nil))
      return
    }

    let deviceId = arguments["deviceId"] as? String
    let mode = arguments["mode"] as? String ?? "withResponse"

    switch bleHost.sendCommand(deviceId: deviceId, payload: payloadData.data, mode: mode) {
    case .success(let payload):
      result(successMap(payload: payload))
    case .notReady(let reason):
      result(failureMap(reason: reason))
    case .failure(let reason):
      result(failureMap(reason: reason))
    }
  }

  private func successMap(payload: Data?) -> [String: Any] {
    var response: [String: Any] = ["status": "ack"]
    if let payload = payload {
      response["payload"] = FlutterStandardTypedData(bytes: payload)
    }
    return response
  }

  private func failureMap(reason: String) -> [String: Any] {
    return [
      "status": "failure",
      "errorCode": "unknown",
      "message": reason,
    ]
  }
}
