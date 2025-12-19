library;

import '../../platform/contracts/led_port.dart';

/// Placeholder implementation until LED schedule reads are wired to the
/// platform plugins.
class LightingRepositoryImpl implements LedPort {
  const LightingRepositoryImpl();

  @override
  Future<LedScheduleOverview?> readScheduleOverview({
    required String deviceId,
  }) async {
    return null;
  }
}

// Additional methods or classes can be added below as needed.
