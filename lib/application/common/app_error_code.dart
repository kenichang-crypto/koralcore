/// Canonical set of application-level error codes exposed to callers.
enum AppErrorCode {
  deviceBusy,
  noActiveDevice,
  noDeviceSelected,
  notSupported,
  invalidParam,
  transportError,
  unknownError,
  sinkFull, // Sink is full (used for both DROP device limit and LED group limit)
  connectLimit, // Maximum 1 device can be connected simultaneously (PARITY: reef-b-app)
  ledMasterCannotDelete, // LED master device cannot be deleted when group has other devices (PARITY: reef-b-app)
}
