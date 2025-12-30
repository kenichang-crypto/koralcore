import 'package:flutter/foundation.dart';

import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/usecases/led/init_led_record_usecase.dart';
import '../../../../platform/contracts/led_record_repository.dart';

/// Controller for LED record setting page.
///
/// PARITY: Mirrors reef-b-app's LedRecordSettingViewModel.
class LedRecordSettingController extends ChangeNotifier {
  final AppSession session;
  final LedRecordRepository ledRecordRepository;
  final InitLedRecordUseCase initLedRecordUseCase;

  LedRecordSettingController({
    required this.session,
    required this.ledRecordRepository,
    required this.initLedRecordUseCase,
  });

  // State
  bool _isLoading = false;
  int _initStrength = 50; // Default: 50%
  int _sunriseHour = 6;
  int _sunriseMinute = 0;
  int _sunsetHour = 18;
  int _sunsetMinute = 0;
  int _slowStart = 30; // Default: 30 minutes
  int _moonlight = 0; // Default: 0%
  AppErrorCode? _lastErrorCode;

  // Getters
  bool get isLoading => _isLoading;
  int get initStrength => _initStrength;
  int get sunriseHour => _sunriseHour;
  int get sunriseMinute => _sunriseMinute;
  int get sunsetHour => _sunsetHour;
  int get sunsetMinute => _sunsetMinute;
  int get slowStart => _slowStart;
  int get moonlight => _moonlight;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  // UI setters
  void setInitStrength(int value) {
    _initStrength = value.clamp(0, 100);
    notifyListeners();
  }

  void setSunrise(int hour, int minute) {
    _sunriseHour = hour;
    _sunriseMinute = minute;
    notifyListeners();
  }

  void setSunset(int hour, int minute) {
    _sunsetHour = hour;
    _sunsetMinute = minute;
    notifyListeners();
  }

  void setSlowStart(int minutes) {
    _slowStart = minutes.clamp(0, 1440);
    notifyListeners();
  }

  void setMoonlight(int value) {
    _moonlight = value.clamp(0, 100);
    notifyListeners();
  }

  /// Save LED record settings.
  ///
  /// Returns true if successful, false otherwise.
  /// onTimeError is called if sunrise > sunset.
  Future<bool> saveLedRecord({
    required void Function() onTimeError,
  }) async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return false;
    }

    // Convert to minutes from midnight
    final int sunriseMinutes = _sunriseHour * 60 + _sunriseMinute;
    final int sunsetMinutes = _sunsetHour * 60 + _sunsetMinute;

    // Validate: sunrise must be before sunset
    if (sunriseMinutes >= sunsetMinutes) {
      onTimeError();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // PARITY: reef-b-app's initLedRecord() sends 5 SET_RECORD commands
      // and then starts record mode if current mode is not CUSTOM_SCENE or PRESET_SCENE
      await initLedRecordUseCase.execute(
        deviceId: deviceId,
        initStrength: _initStrength,
        sunriseHour: _sunriseHour,
        sunriseMinute: _sunriseMinute,
        sunsetHour: _sunsetHour,
        sunsetMinute: _sunsetMinute,
        slowStart: _slowStart,
        moonlight: _moonlight,
      );

      _clearError();
      return true;
    } catch (e) {
      _setError(AppErrorCode.unknownError);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  void _clearError() {
    _lastErrorCode = null;
  }
}

