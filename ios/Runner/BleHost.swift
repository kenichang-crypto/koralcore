import Foundation
import os.log

/// Platform-side BLE host skeleton. Bluetooth integration will be added later.
final class BleHost {
  private let logger = OSLog(subsystem: "com.example.koralcore", category: "BleHost")

  func sendCommand(deviceId: String?, payload: Data, mode: String) -> BleCommandResult {
    os_log("sendCommand deviceId=%{public}@ mode=%{public}@ bytes=%{public}d",
           log: logger,
           type: .debug,
           deviceId ?? "<none>",
           mode,
           payload.count)
    return .notReady("Native BLE host not implemented yet.")
  }

  func onNotification(_ payload: Data) {
    os_log("onNotification bytes=%{public}d", log: logger, type: .debug, payload.count)
  }
}

enum BleCommandResult {
  case success(Data?)
  case notReady(String)
  case failure(String)
}
