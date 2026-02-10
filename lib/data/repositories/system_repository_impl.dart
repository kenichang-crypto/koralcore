
import '../../platform/contracts/system_repository.dart';

class SystemRepositoryImpl implements SystemRepository {
  @override
  Future<Map<String, dynamic>> readDeviceInfo(String deviceId) async {
    // Mock implementation
    return {
      'device_name': 'Mock Device',
      'product': 'LedController',
      'serial_number': '123456',
      'hw_version': '1.0',
    };
  }

  @override
  Future<String> readFirmwareVersion(String deviceId) async {
    return '1.0.0';
  }

  @override
  Future<Map<String, dynamic>> readCapability(String deviceId) async {
    return {
      'ledPower': true,
      'ledIntensity': true,
      'ledScheduleDaily': true,
    };
  }

  @override
  Future<void> syncTime(String deviceId, DateTime timestamp) async {
    // No-op
  }

  @override
  Future<void> reboot(String deviceId) async {
    // No-op
  }

  @override
  Future<void> reset(String deviceId) async {
    // No-op
  }
}
