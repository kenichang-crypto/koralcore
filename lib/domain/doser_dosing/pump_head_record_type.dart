library;

/// Pump head record type.
///
/// PARITY: Mirrors reef-b-app Android's DropRecordType enum.
enum PumpHeadRecordType {
  /// No schedule
  none,

  /// 24-hour evenly distributed dosing
  h24,

  /// Single timed dose
  single,

  /// Custom schedule
  custom,
}

