import '../lib/features/led/domain/models/spectrum/spectrum_wave_point.dart';
import '../lib/features/led/domain/services/spectrum_calculator.dart';
import '../lib/features/led/data/spectrum/spectrum_data_source_final.dart';

void main() {
  print('Verifying Spectrum Logic...');
  
  // Verify Model
  final point = SpectrumWavePoint(
    waveLength: 450,
    strength25: 10,
    strength50: 20,
    strength75: 30,
    strength100: 40,
  );
  if (point.waveLength != 450) throw 'Model failed';
  
  // Verify Calculator
  if (SpectrumCalculator.calculateIntensity(point, 0) != 0.0) throw 'Calc 0 failed';
  if (SpectrumCalculator.calculateIntensity(point, 25) != 10.0) throw 'Calc 25 failed';
  if (SpectrumCalculator.calculateIntensity(point, 12.5) != 5.0) throw 'Calc 12.5 failed';
  
  // Verify Data Source
  try {
    final uv = SpectrumDataSource.uv;
    print('UV points count: ${uv.length}');
    if (uv.isEmpty) throw 'UV empty';
    if (uv.first.waveLength != 380) throw 'UV start wave failed';
    
    // Check values
    // { "wave": 380, "strength25": 0, "strength50": 0, "strength75": 5.97... }
    if (uv.first.strength75 < 5.9 || uv.first.strength75 > 6.0) throw 'UV value mismatch';
    
  } catch (e) {
    print('Data Source Failed: $e');
    rethrow;
  }
  
  print('Verification PASSED');
}
