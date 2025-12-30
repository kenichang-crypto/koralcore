library;

import '../../led_lighting/led_state.dart';
import '../../../platform/contracts/led_record_repository.dart';
import '../../../platform/contracts/led_repository.dart';
import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';

/// Use case for initializing LED record with multiple SET_RECORD commands.
///
/// PARITY: Mirrors reef-b-app's LedRecordSettingViewModel.initLedRecord().
/// Sends 5 SET_RECORD commands:
/// 1. Midnight (0:00): all channels 0, moonlight
/// 2. Sunrise start: all channels 0, moonlight
/// 3. Sunrise end: all channels initStrength, moonlight 0
/// 4. Sunset start: all channels initStrength, moonlight 0
/// 5. Sunset end: all channels 0, moonlight
class InitLedRecordUseCase {
  const InitLedRecordUseCase({
    required this.ledRecordRepository,
    required this.ledRepository,
  });

  final LedRecordRepository ledRecordRepository;
  final LedRepository ledRepository;

  Future<void> execute({
    required String deviceId,
    required int initStrength,
    required int sunriseHour,
    required int sunriseMinute,
    required int sunsetHour,
    required int sunsetMinute,
    required int slowStart,
    required int moonlight,
  }) async {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'Init record requires an active device.',
      );
    }

    // Calculate time points
    final int sunriseStart = sunriseHour * 60 + sunriseMinute;
    final int sunriseEnd = sunriseStart + slowStart;
    final int sunsetStart = sunsetHour * 60 + sunsetMinute - slowStart;
    final int sunsetEnd = sunsetHour * 60 + sunsetMinute;

    // Create channel levels map for initStrength (all channels)
    final Map<String, int> initStrengthChannels = {
      'coldWhite': initStrength,
      'royalBlue': initStrength,
      'blue': initStrength,
      'red': initStrength,
      'green': initStrength,
      'purple': initStrength,
      'uv': initStrength,
      'warmWhite': initStrength,
      'moonLight': 0,
    };

    // Create channel levels map for all 0 with moonlight
    final Map<String, int> zeroChannelsWithMoonlight = {
      'coldWhite': 0,
      'royalBlue': 0,
      'blue': 0,
      'red': 0,
      'green': 0,
      'purple': 0,
      'uv': 0,
      'warmWhite': 0,
      'moonLight': moonlight,
    };

    // Send 5 SET_RECORD commands sequentially
    // 1. Midnight (0:00)
    await ledRecordRepository.setRecord(
      deviceId: deviceId,
      hour: 0,
      minute: 0,
      channelLevels: zeroChannelsWithMoonlight,
    );

    // 2. Sunrise start
    await ledRecordRepository.setRecord(
      deviceId: deviceId,
      hour: sunriseStart ~/ 60,
      minute: sunriseStart % 60,
      channelLevels: zeroChannelsWithMoonlight,
    );

    // 3. Sunrise end
    await ledRecordRepository.setRecord(
      deviceId: deviceId,
      hour: sunriseEnd ~/ 60,
      minute: sunriseEnd % 60,
      channelLevels: initStrengthChannels,
    );

    // 4. Sunset start
    await ledRecordRepository.setRecord(
      deviceId: deviceId,
      hour: sunsetStart ~/ 60,
      minute: sunsetStart % 60,
      channelLevels: initStrengthChannels,
    );

    // 5. Sunset end
    await ledRecordRepository.setRecord(
      deviceId: deviceId,
      hour: sunsetEnd ~/ 60,
      minute: sunsetEnd % 60,
      channelLevels: zeroChannelsWithMoonlight,
    );

    // Check current mode and start record if needed
    final LedState? state = await ledRepository.getLedState(deviceId);
    if (state != null) {
      // PARITY: reef-b-app checks if mode is not CUSTOM_SCENE or PRESET_SCENE
      if (state.mode != LedMode.customScene &&
          state.mode != LedMode.presetScene) {
        await ledRepository.startRecord(deviceId);
      }
    }
  }
}

