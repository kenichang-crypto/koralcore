import 'package:flutter/foundation.dart';

import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/led_lighting/led_record.dart';
import '../../../../platform/contracts/led_record_repository.dart';

/// Controller for LED record time setting page.
///
/// PARITY: Mirrors reef-b-app's LedRecordTimeSettingViewModel.
class LedRecordTimeSettingController extends ChangeNotifier {
  final AppSession session;
  final LedRecordRepository ledRecordRepository;
  final LedRecord? initialRecord;

  LedRecordTimeSettingController({
    required this.session,
    required this.ledRecordRepository,
    this.initialRecord,
  }) {
    // Initialize from initialRecord if provided
    if (initialRecord != null) {
      _timeHour = initialRecord!.hour;
      _timeMinute = initialRecord!.minute;
      _isEditMode = true;

      // Set channel levels from initial record
      _channelLevels = Map<String, int>.from(initialRecord!.channelLevels);
    }
  }

  // State
  bool _isLoading = false;
  bool _inDimmingMode = false;
  bool _isEditMode = false;
  int _timeHour = 5;
  int _timeMinute = 0;
  Map<String, int> _channelLevels = {
    'coldWhite': 0,
    'royalBlue': 0,
    'blue': 0,
    'red': 0,
    'green': 0,
    'purple': 0,
    'uv': 0,
    'warmWhite': 0,
    'moonlight': 0,
  };
  AppErrorCode? _lastErrorCode;

  // Getters
  bool get isLoading => _isLoading;
  bool get inDimmingMode => _inDimmingMode;
  bool get isEditMode => _isEditMode;
  int get timeHour => _timeHour;
  int get timeMinute => _timeMinute;
  Map<String, int> get channelLevels => Map.unmodifiable(_channelLevels);
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  // UI setters
  void setTime(int hour, int minute) {
    _timeHour = hour;
    _timeMinute = minute;
    notifyListeners();
  }

  void setChannelLevel(String channelId, int value) {
    _channelLevels[channelId] = value.clamp(0, 100);
    notifyListeners();

    // If in dimming mode, send dimming command
    if (_inDimmingMode) {
      _sendDimmingCommand();
    }
  }

  int getChannelLevel(String channelId) {
    return _channelLevels[channelId] ?? 0;
  }

  /// Enter dimming mode for preview.
  Future<void> enterDimmingMode() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Send BLE command to enter dimming mode (0x2E)
      // For now, simulate
      await Future.delayed(const Duration(milliseconds: 300));
      _inDimmingMode = true;
      _clearError();
    } catch (e) {
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Exit dimming mode.
  Future<void> exitDimmingMode() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Send BLE command to exit dimming mode (0x2F)
      // For now, simulate
      await Future.delayed(const Duration(milliseconds: 300));
      _inDimmingMode = false;
      _clearError();
    } catch (e) {
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send dimming command for preview.
  void _sendDimmingCommand() {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      return;
    }

    // TODO: Send BLE dimming command (0x30) with current channel levels
    // This should be sent asynchronously without blocking
  }

  /// Save record.
  ///
  /// Returns the saved record if successful, null otherwise.
  /// Callbacks are called for validation errors.
  Future<LedRecord?> saveRecord({
    required void Function() onTimeError,
    required void Function() onTimeExists,
  }) async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return null;
    }

    // Validate time
    final int minutesFromMidnight = _timeHour * 60 + _timeMinute;
    if (minutesFromMidnight < 0 || minutesFromMidnight >= 1440) {
      onTimeError();
      return null;
    }

    // TODO: Check if time already exists (if not in edit mode)
    // This requires checking existing records

    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Send BLE SET_RECORD command (0x27)
      // For now, simulate
      await Future.delayed(const Duration(milliseconds: 500));

      // Create record
      final LedRecord record = LedRecord(
        id: 'record-${DateTime.now().millisecondsSinceEpoch}',
        minutesFromMidnight: minutesFromMidnight,
        channelLevels: Map<String, int>.from(_channelLevels),
      );

      _clearError();
      return record;
    } catch (e) {
      _setError(AppErrorCode.unknownError);
      return null;
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

