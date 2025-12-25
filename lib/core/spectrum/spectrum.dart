// Ported from Android Spectrum.kt
// Data structure for spectrum calculation (no UI)

class SpectrumItem {
  final int wave;
  final double strength25;
  final double strength50;
  final double strength75;
  final double strength100;

  SpectrumItem({
    required this.wave,
    required this.strength25,
    required this.strength50,
    required this.strength75,
    required this.strength100,
  });

  factory SpectrumItem.fromJson(Map<String, dynamic> json) {
    return SpectrumItem(
      wave: json['wave'] as int,
      strength25: (json['strength25'] as num).toDouble(),
      strength50: (json['strength50'] as num).toDouble(),
      strength75: (json['strength75'] as num).toDouble(),
      strength100: (json['strength100'] as num).toDouble(),
    );
  }
}

class Spectrum {
  final List<SpectrumItem> list;
  Spectrum({required this.list});

  factory Spectrum.fromJson(Map<String, dynamic> json) {
    final items = (json['list'] as List)
        .map((e) => SpectrumItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return Spectrum(list: items);
  }
}
