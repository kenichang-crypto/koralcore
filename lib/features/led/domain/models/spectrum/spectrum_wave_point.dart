class SpectrumWavePoint {
  final int waveLength;
  final double strength25;
  final double strength50;
  final double strength75;
  final double strength100;

  const SpectrumWavePoint({
    required this.waveLength,
    required this.strength25,
    required this.strength50,
    required this.strength75,
    required this.strength100,
  });

  factory SpectrumWavePoint.fromJson(Map<String, dynamic> json) {
    return SpectrumWavePoint(
      waveLength: json['wave'] as int,
      strength25: (json['strength25'] as num).toDouble(),
      strength50: (json['strength50'] as num).toDouble(),
      strength75: (json['strength75'] as num).toDouble(),
      strength100: (json['strength100'] as num).toDouble(),
    );
  }
}
