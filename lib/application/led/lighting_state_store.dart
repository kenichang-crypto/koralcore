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
