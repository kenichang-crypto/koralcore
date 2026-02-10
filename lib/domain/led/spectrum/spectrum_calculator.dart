// Ported from Android SpectrumUtil.kt
// Spectrum calculation logic (no UI, no chart)

import '../../../features/led/data/spectrum/spectrum_data_source_final.dart';
import '../../../features/led/domain/models/spectrum/spectrum_wave_point.dart';
import 'spectrum.dart';

class SpectrumCalculator {
  final List<SpectrumItem> uvDatas;
  final List<SpectrumItem> purpleDatas;
  final List<SpectrumItem> blueDatas;
  final List<SpectrumItem> royalBlueDatas;
  final List<SpectrumItem> greenDatas;
  final List<SpectrumItem> redDatas;
  final List<SpectrumItem> coldWhiteDatas;
  final List<SpectrumItem> moonLightDatas;

  SpectrumCalculator()
    : uvDatas = _mapToItems(SpectrumDataSource.uv),
      purpleDatas = _mapToItems(SpectrumDataSource.purple),
      blueDatas = _mapToItems(SpectrumDataSource.blue),
      royalBlueDatas = _mapToItems(SpectrumDataSource.royalBlue),
      greenDatas = _mapToItems(SpectrumDataSource.green),
      redDatas = _mapToItems(SpectrumDataSource.red),
      coldWhiteDatas = _mapToItems(SpectrumDataSource.coldWhite),
      moonLightDatas = _mapToItems(SpectrumDataSource.moonLight);

  static List<SpectrumItem> _mapToItems(List<SpectrumWavePoint> source) {
    return source
        .map(
          (e) => SpectrumItem(
            wave: e.waveLength,
            strength25: e.strength25,
            strength50: e.strength50,
            strength75: e.strength75,
            strength100: e.strength100,
          ),
        )
        .toList();
  }

  /// Returns a list of spectrum intensity (length 320, 380~699) for given channel values (0~100)
  List<double> calculateSpectrum({
    required int uv,
    required int purple,
    required int blue,
    required int royalBlue,
    required int green,
    required int red,
    required int coldWhite,
    required int moonLight,
  }) {
    final uvArr = _getChartValues(uvDatas, uv);
    final purpleArr = _getChartValues(purpleDatas, purple);
    final blueArr = _getChartValues(blueDatas, blue);
    final royalBlueArr = _getChartValues(royalBlueDatas, royalBlue);
    final greenArr = _getChartValues(greenDatas, green);
    final redArr = _getChartValues(redDatas, red);
    final coldWhiteArr = _getChartValues(coldWhiteDatas, coldWhite);
    final moonLightArr = _getChartValues(moonLightDatas, moonLight);

    final result = <double>[];
    for (var i = 0; i < uvArr.length; i++) {
      double value = 0;
      value += uvArr[i];
      value += purpleArr[i];
      value += blueArr[i];
      value += royalBlueArr[i];
      value += greenArr[i];
      value += redArr[i];
      value += coldWhiteArr[i];
      value += moonLightArr[i];
      result.add(value);
    }
    return result;
  }

  List<double> _getChartValues(List<SpectrumItem> datas, int strength) {
    return datas.map((spectrum) {
      if (strength == 0) return 0.0;
      if (strength > 0 && strength < 25) {
        return _getInterpolation(0, 0.0, 25, spectrum.strength25, strength);
      }
      if (strength == 25) return spectrum.strength25;
      if (strength > 25 && strength < 50) {
        return _getInterpolation(
          25,
          spectrum.strength25,
          50,
          spectrum.strength50,
          strength,
        );
      }
      if (strength == 50) return spectrum.strength50;
      if (strength > 50 && strength < 75) {
        return _getInterpolation(
          50,
          spectrum.strength50,
          75,
          spectrum.strength75,
          strength,
        );
      }
      if (strength == 75) return spectrum.strength75;
      if (strength > 75 && strength < 100) {
        return _getInterpolation(
          75,
          spectrum.strength75,
          100,
          spectrum.strength100,
          strength,
        );
      }
      if (strength == 100) return spectrum.strength100;
      return 0.0;
    }).toList();
  }

  double _getInterpolation(int x1, double y1, int x3, double y3, int x2) {
    return y1 + (x2 - x1) / (x3 - x1) * (y3 - y1);
  }
}
