library;

import 'dart:async';

import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';

/// ReadCalibrationHistoryUseCase
///
/// PARITY: Corresponds to reef-b-app's calibration history reading:
/// - DropHeadMainViewModel.getAdjustHistory() -> dropInformation.getHistory(headId)
/// - DropHeadAdjustListActivity displays adjust history from DropInformation
/// - History is populated via BLE callbacks: dropGetAdjustHistorySize, dropGetAdjustHistoryState
/// - DropInformation.initAdjustHistory() initializes history before reading
/// - iOS: PumpHeadViewModel.inquireCalibrationHistory() -> getDropCalibrationHistoryCommand()
class ReadCalibrationRecordSnapshot {
  final String id;
  final String speedProfile;
  final double flowRateMlPerMin;
  final DateTime performedAt;
  final String? note;

  const ReadCalibrationRecordSnapshot({
    required this.id,
    required this.speedProfile,
    required this.flowRateMlPerMin,
    required this.performedAt,
    this.note,
  });
}

class ReadCalibrationHistoryUseCase {
  const ReadCalibrationHistoryUseCase();

  Future<List<ReadCalibrationRecordSnapshot>> execute({
    required String deviceId,
    required String headId,
  }) async {
    final String normalizedHeadId = headId.toUpperCase();
    final List<_CalibrationSeed>? seeds = _calibrationSeeds[normalizedHeadId];
    if (seeds == null) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Unknown pump head identifier.',
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 180));
    final DateTime now = DateTime.now();

    return seeds
        .map(
          (seed) => ReadCalibrationRecordSnapshot(
            id: '${normalizedHeadId}_${seed.id}',
            speedProfile: seed.speedProfile,
            flowRateMlPerMin: seed.flowRateMlPerMin,
            performedAt: now.subtract(seed.age),
            note: seed.note,
          ),
        )
        .toList(growable: false);
  }
}

class _CalibrationSeed {
  final String id;
  final String speedProfile;
  final double flowRateMlPerMin;
  final Duration age;
  final String? note;

  const _CalibrationSeed({
    required this.id,
    required this.speedProfile,
    required this.flowRateMlPerMin,
    required this.age,
    this.note,
  });
}

const Map<String, List<_CalibrationSeed>> _calibrationSeeds =
    <String, List<_CalibrationSeed>>{
      'A': <_CalibrationSeed>[
        _CalibrationSeed(
          id: 'high',
          speedProfile: 'High',
          flowRateMlPerMin: 32.4,
          age: Duration(days: 2, hours: 4),
          note: 'Post-maintenance check',
        ),
        _CalibrationSeed(
          id: 'medium',
          speedProfile: 'Medium',
          flowRateMlPerMin: 28.1,
          age: Duration(days: 7, hours: 6),
        ),
        _CalibrationSeed(
          id: 'low',
          speedProfile: 'Low',
          flowRateMlPerMin: 22.7,
          age: Duration(days: 14, hours: 1),
          note: 'Initial setup',
        ),
      ],
      'B': <_CalibrationSeed>[
        _CalibrationSeed(
          id: 'medium',
          speedProfile: 'Medium',
          flowRateMlPerMin: 29.3,
          age: Duration(days: 3, hours: 2),
        ),
        _CalibrationSeed(
          id: 'low',
          speedProfile: 'Low',
          flowRateMlPerMin: 21.9,
          age: Duration(days: 10),
        ),
      ],
      'C': <_CalibrationSeed>[
        _CalibrationSeed(
          id: 'single',
          speedProfile: 'Custom',
          flowRateMlPerMin: 24.0,
          age: Duration(days: 1, hours: 8),
          note: 'Salt mix change',
        ),
      ],
      'D': <_CalibrationSeed>[
        _CalibrationSeed(
          id: 'high',
          speedProfile: 'High',
          flowRateMlPerMin: 31.0,
          age: Duration(days: 5, hours: 1),
        ),
        _CalibrationSeed(
          id: 'medium',
          speedProfile: 'Medium',
          flowRateMlPerMin: 26.4,
          age: Duration(days: 9, hours: 4),
          note: 'Valve replacement',
        ),
      ],
    };
