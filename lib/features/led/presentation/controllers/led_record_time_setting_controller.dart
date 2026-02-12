import 'package:flutter/foundation.dart';

import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/led_lighting/led_record.dart';
import '../../../../domain/led_lighting/led_record_state.dart';
import '../../../../platform/contracts/led_record_repository.dart';

/// Controller for LED record time setting page.
///
/// PARITY: Mirrors reef-b-app's LedRecordTimeSettingViewModel.
class LedRecordTimeSettingController extends ChangeNotifier {
  final AppSession session;
  final LedRecordRepository ledRecordRepository;
  final LedRecord? initialRecord;
  final int? initialHour;
  final int? initialMinute;

  LedRecordTimeSettingController({
    required this.session,
    required this.ledRecordRepository,
    this.initialRecord,
    this.initialHour,
    this.initialMinute,
  }) {
    // Initialize from initialRecord if provided
    if (initialRecord != null) {
      _timeHour = initialRecord!.hour;
      _timeMinute = initialRecord!.minute;
      _isEditMode = true;

      // Set channel levels from initial record
      _channelLevels = Map<String, int>.from(initialRecord!.channelLevels);
    } else if (initialHour != null && initialMinute != null) {
      // Initialize from initialHour/Minute if provided
      _timeHour = initialHour!;
      _timeMinute = initialMinute!;
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
  String get timeLabel =>
      '${_timeHour.toString().padLeft(2, '0')} : ${_timeMinute.toString().padLeft(2, '0')}';
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

    // Validate time range
    final int selectTime = _timeHour * 60 + _timeMinute;
    if (selectTime < 0 || selectTime >= 1440) {
      onTimeError();
      return null;
    }

    // Fetch existing records and validate (PARITY: reef-b-app canAddRecord)
    final LedRecordState state =
        await ledRecordRepository.getState(deviceId);
    final records = List<LedRecord>.from(state.records)
      ..sort((a, b) => a.minutesFromMidnight.compareTo(b.minutesFromMidnight));

    // In edit mode, exclude the record being edited for validation
    final recordsForValidation = _isEditMode && initialRecord != null
        ? records.where((r) => r.id != initialRecord!.id).toList()
        : records;

    for (var i = 0; i < recordsForValidation.length; i++) {
      final nowRecordTime = recordsForValidation[i].minutesFromMidnight;
      final nextRecordTime = i == recordsForValidation.length - 1
          ? 1440
          : recordsForValidation[i + 1].minutesFromMidnight;

      if (selectTime == nowRecordTime) {
        if (_isEditMode) {
          // In edit mode, same time as another record - still invalid
          onTimeExists();
          return null;
        }
        // Could be our own record in edit - but we excluded it, so this is another
        onTimeExists();
        return null;
      }

      if (selectTime > nowRecordTime && selectTime < nextRecordTime) {
        if (selectTime < nowRecordTime + 10 || selectTime > nextRecordTime - 10) {
          onTimeError();
          return null;
        }
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      await ledRecordRepository.setRecord(
        deviceId: deviceId,
        hour: _timeHour,
        minute: _timeMinute,
        channelLevels: Map<String, int>.from(_channelLevels),
      );

      _clearError();
      return LedRecord(
        id: 'record-$selectTime',
        minutesFromMidnight: selectTime,
        channelLevels: Map.unmodifiable(_channelLevels),
      );
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

