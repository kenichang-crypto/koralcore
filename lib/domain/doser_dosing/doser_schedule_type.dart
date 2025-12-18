/// DoserScheduleType
///
/// Domain-level enumeration for pump schedules defined in docs:
/// - `docs/reef_b_app_behavior.md`
/// - `docs/ble_protocol_v1_11.md`
///
/// Manual / single commands (BLE 15 / 16) are represented by
/// `SingleDoseImmediate` / `SingleDoseTimed` models and are **not** part of
/// this enum. This enum exclusively models scheduled dosing (BLE 24h/custom,
/// and 32–34 oneshot sequence).
enum DoserScheduleType {
  /// 24-hour evenly distributed dosing
  /// TODO(BLE-24H): Map to BLE "24h schedule" command once builder exists.
  h24,

  /// Custom schedule with interval distribution
  /// TODO(BLE-CUSTOM): Map to BLE custom schedule command once defined.
  custom,

  /// One-shot schedule (4K only). Corresponds to BLE commands 32-34.
  /// TODO(BLE-32-34): Map to BLE oneshot builder for command chain 32–34.
  oneshotSchedule,
}
