
  static List<SpectrumWavePoint> get uv => _parse(UV);
  static List<SpectrumWavePoint> get purple => _parse(Purple);
  static List<SpectrumWavePoint> get blue => _parse(Blue);
  static List<SpectrumWavePoint> get royalBlue => _parse(RoyalBlue);
  static List<SpectrumWavePoint> get green => _parse(Green);
  static List<SpectrumWavePoint> get red => _parse(Red);
  static List<SpectrumWavePoint> get coldWhite => _parse(ColdWhite);
  static List<SpectrumWavePoint> get moonLight => _parse(MoonLight);

  static List<SpectrumWavePoint> _parse(String jsonStr) {
    final Map<String, dynamic> json = jsonDecode(jsonStr);
    return SpectrumDataConfig.fromJson(json).list;
  }
}
