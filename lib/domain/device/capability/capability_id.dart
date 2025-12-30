/// CapabilityId 是「平台層」識別能力的方式
///
/// 重點：
/// - 與 device / firmware / BLE 無關
/// - 一旦定義就不能改語意
/// - UI、UseCase、Log 都只認這個 ID
enum CapabilityId {
  /// LED 開關能力
  ledPower,

  /// LED 亮度 / 光譜調整
  ledIntensity,

  /// LED 每日排程能力 (ID: led.schedule.daily)
  ledScheduleDaily,

  /// LED 自訂排程能力 (ID: led.schedule.custom)
  ledScheduleCustom,

  /// LED 情境/場景排程能力 (ID: led.schedule.scene)
  ledScheduleScene,

  /// 定量滴液（doser）
  dosing,

  /// Doser 支援小數毫升
  doserDecimalMl,

  /// Doser 支援 oneshot 排程（koralDose 4K）
  doserOneshotSchedule,

  /// 排程能力（泛用）
  scheduling,
}
