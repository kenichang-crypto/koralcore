import 'ble_transport_models.dart';

/// Simple in-memory observer that records BLE transport events for later
/// inspection within debug tooling or developer consoles.
class BleTransportLogBuffer implements BleTransportObserver {
  final List<BleTransportLogEntry> _events = <BleTransportLogEntry>[];
  final void Function(BleTransportLogEntry entry)? _onEventCallback;

  BleTransportLogBuffer({void Function(BleTransportLogEntry entry)? onEvent})
    : _onEventCallback = onEvent;

  @override
  void onEvent(BleTransportLogEntry entry) {
    _events.add(entry);
    _onEventCallback?.call(entry);
  }

  /// Returns a snapshot copy of the collected events.
  List<BleTransportLogEntry> snapshot() {
    return List<BleTransportLogEntry>.unmodifiable(_events);
  }

  /// Clears the buffered events while keeping the observer active.
  void clear() {
    _events.clear();
  }
}

/// Renders a single transport log entry into a concise, human-readable line.
String formatBleTransportLogEntry(BleTransportLogEntry entry) {
  final String opcodeHex =
      '0x${entry.opcode.toRadixString(16).padLeft(2, '0')}';
  final String result = entry.result?.name ?? 'pending';
  final DateTime sendTimestamp = entry.sendTimestamp ?? entry.timestamp;
  return '[${entry.type.name}] device=${entry.deviceId} opcode=$opcodeHex '
      'len=${entry.payloadLength} attempt=${entry.attempt} result=$result '
      'queued=${entry.enqueueTimestamp.toIso8601String()} '
      'sent=${sendTimestamp.toIso8601String()} message=${entry.message}';
}
