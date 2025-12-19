library;

import '../../domain/led_lighting/led_schedule_overview.dart';

export '../../domain/led_lighting/led_schedule_overview.dart';

/// Platform abstraction for LED schedule reads.
abstract class LedPort {
  /// Reads the currently active LED schedule overview for the device.
  Future<LedScheduleOverview?> readScheduleOverview({required String deviceId});
}
