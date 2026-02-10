import 'spectrum_wave_point.dart';

class SpectrumDataConfig {
  final List<SpectrumWavePoint> list;

  const SpectrumDataConfig({required this.list});

  factory SpectrumDataConfig.fromJson(Map<String, dynamic> json) {
    return SpectrumDataConfig(
      list: (json['list'] as List<dynamic>)
          .map((e) => SpectrumWavePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
