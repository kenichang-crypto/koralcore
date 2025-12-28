import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../application/doser/apply_schedule_usecase.dart';
import '../../../../domain/doser_dosing/pump_head.dart';
import '../../../../domain/doser_dosing/pump_head_mode.dart';
import '../../../../domain/doser_dosing/pump_head_record_detail.dart';
import '../../../../domain/doser_dosing/pump_head_record_type.dart';
import '../../../../platform/contracts/pump_head_repository.dart';

/// Controller for pump head record setting page.
///
/// PARITY: Mirrors reef-b-app's DropHeadRecordSettingViewModel.
class PumpHeadRecordSettingController extends ChangeNotifier {
  final String headId;
  final AppSession session;
  final PumpHeadRepository pumpHeadRepository;
  final ApplyScheduleUseCase applyScheduleUseCase;

  PumpHeadRecordSettingController({
    required this.headId,
    required this.session,
    required this.pumpHeadRepository,
    required this.applyScheduleUseCase,
  });

  // State
  bool _isLoading = false;
  PumpHead? _pumpHead;
  PumpHeadMode? _currentMode;
  PumpHeadRecordType _selectedRecordType = PumpHeadRecordType.none;
  int? _dropVolume;
  int _rotatingSpeed = 2; // Default: medium
  int? _selectRunTime; // 0:立即執行, 1:一週固定天數, 2:時間範圍, 3:時間點
  final List<bool> _weekDays = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ]; // Sun-Sat
  DateTimeRange? _dateRange;
  String? _timeString; // For single timed dose
  List<PumpHeadRecordDetail> _recordDetails = [];
  AppErrorCode? _lastErrorCode;

  // Getters
  bool get isLoading => _isLoading;
  PumpHead? get pumpHead => _pumpHead;
  PumpHeadMode? get currentMode => _currentMode;
  PumpHeadRecordType get selectedRecordType => _selectedRecordType;
  int? get dropVolume => _dropVolume;
  int get rotatingSpeed => _rotatingSpeed;
  int? get selectRunTime => _selectRunTime;
  List<bool> get weekDays => List.unmodifiable(_weekDays);
  DateTimeRange? get dateRange => _dateRange;
  String? get timeString => _timeString;
  List<PumpHeadRecordDetail> get recordDetails =>
      List.unmodifiable(_recordDetails);
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  /// Check if device supports decimal dose (0.4ml minimum).
  /// TODO: Get device context from AppContext.currentDeviceSession to check capabilities.
  bool get isDecimalDose {
    // For now, default to false (1.0ml minimum) until device context is available.
    return false;
  }

  /// Get minimum dose based on device capability.
  double get minDose => isDecimalDose ? 0.4 : 1.0;

  /// Initialize controller and load current state.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? deviceId = session.activeDeviceId;
      if (deviceId == null) {
        _setError(AppErrorCode.noActiveDevice);
        return;
      }

      // Load pump head
      final PumpHead? head = await pumpHeadRepository.getPumpHead(deviceId, headId);
      _pumpHead = head;

      // TODO: Load current mode from BLE state
      // This should come from DosingState.getMode(headId)
      // For now, we'll use empty mode

      _clearError();
    } catch (e) {
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UI setters
  void setSelectedRecordType(PumpHeadRecordType type) {
    _selectedRecordType = type;
    notifyListeners();
  }

  void setDropVolume(int? volume) {
    _dropVolume = volume;
    notifyListeners();
  }

  void setRotatingSpeed(int speed) {
    _rotatingSpeed = speed.clamp(1, 3);
    notifyListeners();
  }

  void setSelectRunTime(int? time) {
    _selectRunTime = time;
    notifyListeners();
  }

  void setWeekDay(int index, bool value) {
    if (index >= 0 && index < 7) {
      _weekDays[index] = value;
      notifyListeners();
    }
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    notifyListeners();
  }

  void setTimeString(String? time) {
    _timeString = time;
    notifyListeners();
  }

  void addRecordDetail(PumpHeadRecordDetail detail) {
    // Check for cross-day (e.g., 22:00 ~ 01:00)
    final timeParts = detail.timeString?.split(' ~ ');
    if (timeParts != null && timeParts.length == 2) {
      final startParts = timeParts[0].split(':');
      final endParts = timeParts[1].split(':');
      if (startParts.length == 2 && endParts.length == 2) {
        final startHour = int.tryParse(startParts[0]) ?? 0;
        final endHour = int.tryParse(endParts[0]) ?? 0;
        if (endHour <= startHour) {
          // Cross-day not allowed, ignore
          return;
        }
      }
    }

    final List<PumpHeadRecordDetail> updated = List.from(_recordDetails);
    updated.add(detail);

    // Sort by start time
    updated.sort((a, b) {
      final aStart = a.timeString?.split(' ~ ').first ?? '00:00';
      final bStart = b.timeString?.split(' ~ ').first ?? '00:00';
      return aStart.compareTo(bStart);
    });

    _recordDetails = updated;
    notifyListeners();
  }

  void deleteRecordDetail(PumpHeadRecordDetail detail) {
    _recordDetails.remove(detail);
    notifyListeners();
  }

  /// Save schedule settings.
  ///
  /// Returns error callbacks for validation failures.
  Future<bool> saveSchedule({
    required void Function() onDropVolumeEmpty,
    required void Function() onRunTimeEmpty,
    required void Function() onDropVolumeTooLittle,
    required void Function() onDropOutOfTodayBound,
    required void Function() onDropVolumeTooMuch,
    required void Function() onDetailsEmpty,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? deviceId = session.activeDeviceId;
      if (deviceId == null) {
        _setError(AppErrorCode.noActiveDevice);
        return false;
      }

      switch (_selectedRecordType) {
        case PumpHeadRecordType.none:
          // Clear schedule
          // TODO: Implement clear schedule command
          await Future.delayed(const Duration(milliseconds: 500));
          _clearError();
          return true;

        case PumpHeadRecordType.h24:
          if (_dropVolume == null) {
            onDropVolumeEmpty();
            return false;
          }

          // Check minimum per-hour dose
          final double perHour = _dropVolume! / 24.0;
          if (perHour < minDose) {
            onDropVolumeTooLittle();
            return false;
          }

          // Check daily minimum (24ml)
          if (_dropVolume! < 24) {
            onDropVolumeTooLittle();
            return false;
          }

          // Check maximum (500ml)
          if (_dropVolume! > 500) {
            onDropVolumeTooMuch();
            return false;
          }

          if (_selectRunTime == null) {
            onRunTimeEmpty();
            return false;
          }

          // TODO: Apply 24h schedule via ApplyScheduleUseCase
          await Future.delayed(const Duration(milliseconds: 500));
          _clearError();
          return true;

        case PumpHeadRecordType.single:
          if (_dropVolume == null) {
            onDropVolumeEmpty();
            return false;
          }

          // Check max drop limit
          if (_pumpHead?.maxDrop != null &&
              _dropVolume! > _pumpHead!.maxDrop!) {
            onDropOutOfTodayBound();
            return false;
          }

          if (_selectRunTime == null) {
            onRunTimeEmpty();
            return false;
          }

          // TODO: Apply single dose schedule via ApplyScheduleUseCase
          await Future.delayed(const Duration(milliseconds: 500));
          _clearError();
          return true;

        case PumpHeadRecordType.custom:
          if (_recordDetails.isEmpty) {
            onDetailsEmpty();
            return false;
          }

          final int recordTotalDropVolume = _recordDetails.fold(
            0,
            (sum, detail) => sum + detail.totalDrop,
          );

          // Check max drop limit
          if (_pumpHead?.maxDrop != null &&
              recordTotalDropVolume > _pumpHead!.maxDrop!) {
            onDropOutOfTodayBound();
            return false;
          }

          // Check minimum (1ml)
          if (recordTotalDropVolume < 1) {
            onDropVolumeTooLittle();
            return false;
          }

          // Check maximum (500ml)
          if (recordTotalDropVolume > 500) {
            onDropVolumeTooMuch();
            return false;
          }

          // Check each detail for minimum dose
          for (final detail in _recordDetails) {
            final double eachDose = detail.totalDrop / detail.dropTime;
            if (eachDose < minDose) {
              onDropVolumeTooLittle();
              return false;
            }
          }

          if (_selectRunTime == null) {
            onRunTimeEmpty();
            return false;
          }

          // TODO: Apply custom schedule via ApplyScheduleUseCase
          await Future.delayed(const Duration(milliseconds: 500));
          _clearError();
          return true;
      }
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
