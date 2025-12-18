library;

/// Describes the BLE action being captured by the recorder.
enum BleRecordType {
  /// Outgoing write command to a characteristic.
  write,

  /// Incoming notification from the peripheral.
  notify,

  /// Application-triggered read.
  read,

  /// Transport or protocol level error surfaced by BLE stack.
  error,
}
