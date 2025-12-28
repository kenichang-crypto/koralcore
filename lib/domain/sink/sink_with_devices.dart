library;

import 'sink.dart';

/// Represents a Sink with its associated devices.
/// 
/// PARITY: Matches reef-b-app's SinkWithDevices.kt
/// 
/// Note: In koralcore, devices are represented as Map<String, dynamic>
/// since there's no dedicated Device domain model. This matches the
/// DeviceRepository interface which returns Map<String, dynamic>.
class SinkWithDevices {
  final Sink sink;
  final List<Map<String, dynamic>> devices;

  const SinkWithDevices({
    required this.sink,
    required this.devices,
  });

  /// Creates a copy with updated fields.
  SinkWithDevices copyWith({
    Sink? sink,
    List<Map<String, dynamic>>? devices,
  }) {
    return SinkWithDevices(
      sink: sink ?? this.sink,
      devices: devices ?? this.devices,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SinkWithDevices &&
          other.sink == sink &&
          _listEquals(other.devices, devices);

  @override
  int get hashCode => Object.hash(sink, devices);

  @override
  String toString() =>
      'SinkWithDevices(sink: $sink, devices: ${devices.length} devices)';

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

