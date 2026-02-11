import 'package:flutter_test/flutter_test.dart';
import 'package:koralcore/domain/led/spectrum/spectrum_calculator.dart';
import 'package:koralcore/features/led/data/spectrum/spectrum_data_source_final.dart';

void main() {
  group('Spectrum Domain Logic (Canonical)', () {
    test('SpectrumDataSource should parse UV channel correctly', () {
      // Accessing the static getter triggers parsing
      final points = SpectrumDataSource.uv;
      expect(points, isNotEmpty);
      expect(points.first.waveLength, 380);

      // Verify a known value from the file (first point in UV)
      // { "wave": 380, "strength25": 0, "strength50": 0, "strength75": 5.970067477416278, "strength100": 16.435470000000002 }
      final first = points.first;
      expect(first.strength25, 0);
      expect(first.strength75, closeTo(5.97, 0.001));
      expect(first.strength100, closeTo(16.435, 0.001));
    });

    test('SpectrumCalculator should calculate full spectrum', () {
      final calculator = SpectrumCalculator();

      // Test all zeros
      final zeros = calculator.calculateSpectrum(
        uv: 0,
        purple: 0,
        blue: 0,
        royalBlue: 0,
        green: 0,
        red: 0,
        coldWhite: 0,
        moonLight: 0,
      );

      expect(zeros.length, 321); // 380 to 700 is 321 points
      expect(zeros.every((val) => val == 0.0), isTrue);

      // Test UV max
      final uvMax = calculator.calculateSpectrum(
        uv: 100,
        purple: 0,
        blue: 0,
        royalBlue: 0,
        green: 0,
        red: 0,
        coldWhite: 0,
        moonLight: 0,
      );

      expect(uvMax.length, 321);
      // UV has value at 380nm
      // 16.43547...
      expect(uvMax[0], closeTo(16.435, 0.001));

      // Test accumulation
      // UV at 380 is ~16.435
      // If we add another channel that has 0 at 380, it stays same.
      // If we add something that has value, it sums up.
      // Let's just check it's deterministic.
      final combined = calculator.calculateSpectrum(
        uv: 100,
        purple: 100,
        blue: 0,
        royalBlue: 0,
        green: 0,
        red: 0,
        coldWhite: 0,
        moonLight: 0,
      );

      // If purple has 0 at 380 (it does), then result is same as uvMax at 380
      // Checking Purple data from file: 380 is 0.
      expect(combined[0], closeTo(16.435, 0.001));
    });
  });
}
