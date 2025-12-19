enum DeviceConnectionState { connected, connecting, disconnected }

/// Lightweight DTO returned by device use cases for presentation layers.
class DeviceSnapshot {
  final String id;
  final String name;
  final int? rssi;
  final DeviceConnectionState state;
  final bool provisioned;

  const DeviceSnapshot({
    required this.id,
    required this.name,
    required this.state,
    this.rssi,
    this.provisioned = false,
  });

  bool get isConnected => state == DeviceConnectionState.connected;
  bool get isConnecting => state == DeviceConnectionState.connecting;

  factory DeviceSnapshot.fromMap(Map<String, dynamic> raw) {
    final String stateValue = (raw['state'] ?? 'disconnected').toString();
    return DeviceSnapshot(
      id: raw['id']?.toString() ?? '',
      name: raw['name']?.toString() ?? 'Unknown',
      rssi: raw['rssi'] is num ? (raw['rssi'] as num).round() : null,
      state: _fromState(stateValue),
      provisioned: raw['provisioned'] == true,
    );
  }

  static DeviceConnectionState _fromState(String value) {
    switch (value) {
      case 'connected':
        return DeviceConnectionState.connected;
      case 'connecting':
        return DeviceConnectionState.connecting;
      default:
        return DeviceConnectionState.disconnected;
    }
  }

  DeviceSnapshot copyWith({
    String? id,
    String? name,
    int? rssi,
    DeviceConnectionState? state,
    bool? provisioned,
  }) {
    return DeviceSnapshot(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      state: state ?? this.state,
      provisioned: provisioned ?? this.provisioned,
    );
  }
}
