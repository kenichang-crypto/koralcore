/// LedScheduleType
///
/// Enumerates the supported LED scheduling modes handled in the domain layer.
enum LedScheduleType {
  /// Daily repeating schedule with shared channel values across the window.
  daily,

  /// Custom schedule with multiple time points or segments per day.
  custom,

  /// Scene-based schedule that references reusable LED scenes.
  scene,
}
