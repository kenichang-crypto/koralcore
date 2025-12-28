typedef SinkId = String;

enum SinkType { defaultSink, custom }

class Sink {
  final SinkId id;
  final String name;
  final SinkType type;
  final List<String> deviceIds;

  const Sink({
    required this.id,
    required this.name,
    required this.type,
    required this.deviceIds,
  });

  factory Sink.defaultSink(List<String> deviceIds) {
    return Sink(
      id: 'default-sink',
      name: 'My Reef',
      type: SinkType.defaultSink,
      deviceIds: List.unmodifiable(deviceIds),
    );
  }

  /// Creates a copy with updated fields.
  Sink copyWith({
    SinkId? id,
    String? name,
    SinkType? type,
    List<String>? deviceIds,
  }) {
    return Sink(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      deviceIds: deviceIds ?? this.deviceIds,
    );
  }
}
