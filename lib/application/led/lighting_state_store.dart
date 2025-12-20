library;

class LightingStateSnapshot {
  final List<LightingChannelSnapshot> channels;
  final DateTime updatedAt;

  LightingStateSnapshot({
    required List<LightingChannelSnapshot> channels,
    required this.updatedAt,
  }) : channels = List<LightingChannelSnapshot>.unmodifiable(
         channels.map((channel) => channel.copyWith()),
       );

  LightingStateSnapshot clone() =>
      LightingStateSnapshot(channels: channels, updatedAt: updatedAt);
}

class LightingChannelSnapshot {
  final String id;
  final String label;
  final int percentage;

  const LightingChannelSnapshot({
    required this.id,
    required this.label,
    required this.percentage,
  });

  LightingChannelSnapshot copyWith({String? label, int? percentage}) {
    return LightingChannelSnapshot(
      id: id,
      label: label ?? this.label,
      percentage: percentage ?? this.percentage,
    );
  }
}

class LightingStateMemoryStore {
  LightingStateMemoryStore()
    : _state = {
        'default': LightingStateSnapshot(
          channels: _seedChannels,
          updatedAt: DateTime.now(),
        ),
      };

  final Map<String, LightingStateSnapshot> _state;

  LightingStateSnapshot read({required String deviceId}) {
    final String key = deviceId.isEmpty ? 'default' : deviceId;
    final LightingStateSnapshot? existing = _state[key];
    if (existing != null) {
      return existing.clone();
    }

    final LightingStateSnapshot template = _state['default']!;
    final LightingStateSnapshot seeded = LightingStateSnapshot(
      channels: template.channels,
      updatedAt: DateTime.now(),
    );
    _state[key] = seeded;
    return seeded.clone();
  }

  LightingStateSnapshot write({
    required String deviceId,
    required List<LightingChannelSnapshot> channels,
  }) {
    final String key = deviceId.isEmpty ? 'default' : deviceId;
    final LightingStateSnapshot snapshot = LightingStateSnapshot(
      channels: channels,
      updatedAt: DateTime.now(),
    );
    _state[key] = snapshot;
    return snapshot.clone();
  }

  static List<LightingChannelSnapshot> get _seedChannels => const [
    LightingChannelSnapshot(id: 'white', label: 'Cool white', percentage: 65),
    LightingChannelSnapshot(id: 'blue', label: 'Royal blue', percentage: 80),
  ];
}
