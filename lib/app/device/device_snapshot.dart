enum DeviceConnectionState { connected, connecting, disconnected }

/// Lightweight DTO returned by device use cases for presentation layers.
/// PARITY: Matches reef-b-app's Device entity fields.

class DeviceSnapshot {
  final String id;
  final String name;
  final String? type; // 'LED' or 'DROP'
  final int? rssi;
  final DeviceConnectionState state;
  final bool provisioned;
  final bool isMaster;
  final bool favorite; // PARITY: reef-b-app Device.favorite
  final String? sinkId; // PARITY: reef-b-app Device.sinkId
  final String? group; // PARITY: reef-b-app Device.group ('A', 'B', 'C', 'D', 'E')

  const DeviceSnapshot({
    required this.id,
    required this.name,
    required this.state,
    this.type,
    this.rssi,
    this.provisioned = false,
    this.isMaster = false,
    this.favorite = false,
    this.sinkId,
    this.group,
  });

  bool get isConnected => state == DeviceConnectionState.connected;
  bool get isConnecting => state == DeviceConnectionState.connecting;

  factory DeviceSnapshot.fromMap(Map<String, dynamic> raw) {
    final String stateValue = (raw['state'] ?? 'disconnected').toString();
    return DeviceSnapshot(
      id: raw['id']?.toString() ?? '',
      name: raw['name']?.toString() ?? 'Unknown',
      type: raw['type']?.toString(),
      rssi: raw['rssi'] is num ? (raw['rssi'] as num).round() : null,
      state: _fromState(stateValue),
      provisioned: raw['provisioned'] == true,
      isMaster: raw['isMaster'] == true,
      favorite: raw['favorite'] == true || raw['isFavorite'] == true,
      sinkId: raw['sinkId']?.toString() ?? raw['sink_id']?.toString(),
      group: raw['group']?.toString() ?? raw['device_group']?.toString(),
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
    String? type,
    int? rssi,
    DeviceConnectionState? state,
    bool? provisioned,
    bool? isMaster,
    bool? favorite,
    String? sinkId,
    String? group,
  }) {
    return DeviceSnapshot(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      rssi: rssi ?? this.rssi,
      state: state ?? this.state,
      provisioned: provisioned ?? this.provisioned,
      isMaster: isMaster ?? this.isMaster,
      favorite: favorite ?? this.favorite,
      sinkId: sinkId ?? this.sinkId,
      group: group ?? this.group,
    );
  }
}
