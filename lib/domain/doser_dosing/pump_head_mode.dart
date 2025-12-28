library;

import 'pump_head_record_type.dart';
import 'pump_head_record_detail.dart';

/// Pump head mode representing the current schedule state.
///
/// PARITY: Mirrors reef-b-app Android's DropHeadMode data class.
///
/// This represents the **current state** of a pump head as returned from
/// BLE sync operations, not a schedule definition to be set.
class PumpHeadMode {
  /// Schedule type
  final PumpHeadRecordType mode;

  /// Execution days of week (Monday through Sunday)
  /// Used for weekly schedules (24h weekly, custom weekly)
  final List<bool>? runDay;

  /// Time string for date ranges or single timed doses
  /// Format examples:
  /// - Single: "2025-01-15 14:30"
  /// - Range: "2025-01-15 ~ 2025-01-20"
  final String? timeString;

  /// Today's scheduled drop volume (ml)
  final double recordDrop;

  /// Today's non-scheduled drop volume (ml)
  final double? otherDrop;

  /// Total daily drop volume (ml)
  /// Used for 24h and single schedules
  final int? totalDrop;

  /// Pump rotating speed: 1=low, 2=medium, 3=high
  final int rotatingSpeed;

  /// Custom schedule details
  /// Only populated when mode is PumpHeadRecordType.custom
  final List<PumpHeadRecordDetail> recordDetail;

  const PumpHeadMode({
    this.mode = PumpHeadRecordType.none,
    this.runDay,
    this.timeString,
    this.recordDrop = 0.0,
    this.otherDrop,
    this.totalDrop,
    this.rotatingSpeed = 2,
    List<PumpHeadRecordDetail>? recordDetail,
  }) : assert(rotatingSpeed >= 1 && rotatingSpeed <= 3,
          'rotatingSpeed must be 1-3'),
       recordDetail = recordDetail ?? const [];

  PumpHeadMode copyWith({
    PumpHeadRecordType? mode,
    List<bool>? runDay,
    String? timeString,
    double? recordDrop,
    double? otherDrop,
    int? totalDrop,
    int? rotatingSpeed,
    List<PumpHeadRecordDetail>? recordDetail,
  }) {
    return PumpHeadMode(
      mode: mode ?? this.mode,
      runDay: runDay ?? this.runDay,
      timeString: timeString ?? this.timeString,
      recordDrop: recordDrop ?? this.recordDrop,
      otherDrop: otherDrop ?? this.otherDrop,
      totalDrop: totalDrop ?? this.totalDrop,
      rotatingSpeed: rotatingSpeed ?? this.rotatingSpeed,
      recordDetail: recordDetail ?? this.recordDetail,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PumpHeadMode &&
        other.mode == mode &&
        _listEquals(other.runDay, runDay) &&
        other.timeString == timeString &&
        other.recordDrop == recordDrop &&
        other.otherDrop == otherDrop &&
        other.totalDrop == totalDrop &&
        other.rotatingSpeed == rotatingSpeed &&
        _listEquals(other.recordDetail, recordDetail);
  }

  @override
  int get hashCode => Object.hash(
        mode,
        runDay,
        timeString,
        recordDrop,
        otherDrop,
        totalDrop,
        rotatingSpeed,
        recordDetail,
      );

  @override
  String toString() =>
      'PumpHeadMode(mode: $mode, runDay: $runDay, timeString: $timeString, '
      'recordDrop: $recordDrop, otherDrop: $otherDrop, totalDrop: $totalDrop, '
      'rotatingSpeed: $rotatingSpeed, recordDetail: $recordDetail)';

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

