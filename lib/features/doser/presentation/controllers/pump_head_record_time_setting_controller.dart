import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/doser_dosing/pump_head_record_detail.dart';

/// Controller for pump head record time setting page.
///
/// PARITY: Mirrors reef-b-app's DropHeadRecordTimeSettingViewModel.
class PumpHeadRecordTimeSettingController extends ChangeNotifier {
  final String headId;
  final AppSession session;
  final List<PumpHeadRecordDetail> existingDetails;
  final PumpHeadRecordDetail? initialDetail;

  PumpHeadRecordTimeSettingController({
    required this.headId,
    required this.session,
    required this.existingDetails,
    this.initialDetail,
  }) {
    // Initialize from initialDetail if provided
    if (initialDetail != null) {
      final timeParts = initialDetail!.timeString?.split(' ~ ');
      if (timeParts != null && timeParts.length == 2) {
        final startParts = timeParts[0].split(':');
        final endParts = timeParts[1].split(':');
        if (startParts.length == 2 && endParts.length == 2) {
          final startHour = int.tryParse(startParts[0]) ?? 8;
          final startMinute = int.tryParse(startParts[1]) ?? 0;
          final endHour = int.tryParse(endParts[0]) ?? 10;
          final endMinute = int.tryParse(endParts[1]) ?? 0;
          _startTime = TimeOfDay(hour: startHour, minute: startMinute);
          _endTime = TimeOfDay(hour: endHour, minute: endMinute);
        }
      }
      _dropTimes = initialDetail!.dropTime;
      _dropVolume = initialDetail!.totalDrop;
      _rotatingSpeed = initialDetail!.rotatingSpeed;
    } else {
      // Default values
      _startTime = const TimeOfDay(hour: 8, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 0);
      _dropTimes = 3;
    }
  }

  // State
  final bool _isLoading = false;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int _dropTimes = 3;
  int? _dropVolume;
  int _rotatingSpeed = 2; // Default: medium
  AppErrorCode? _lastErrorCode;

  // Getters
  bool get isLoading => _isLoading;
  TimeOfDay? get startTime => _startTime;
  TimeOfDay? get endTime => _endTime;
  int get dropTimes => _dropTimes;
  int? get dropVolume => _dropVolume;
  int get rotatingSpeed => _rotatingSpeed;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  /// Check if device supports decimal dose (0.4ml minimum).
  /// TODO: Get device context from AppContext.currentDeviceSession to check capabilities.
  bool get isDecimalDose {
    // For now, default to false (1.0ml minimum) until device context is available.
    return false;
  }

  /// Get minimum dose based on device capability.
  double get minDose => isDecimalDose ? 0.4 : 1.0;

  /// Get valid drop times range based on time window.
  List<int> get dropTimesRange {
    if (_startTime == null || _endTime == null) {
      return List.generate(120, (i) => i + 1); // Default: 1-120
    }

    int startHour = _startTime!.hour;
    int endHour = _endTime!.hour;
    if (endHour == 0) {
      endHour = 24;
    }

    int duration;
    if (endHour > startHour) {
      duration = endHour - startHour;
    } else {
      // Cross-day not allowed, but handle gracefully
      duration = 1;
    }

    // Maximum 5 drops per hour
    final int maxDrops = duration * 5;
    return List.generate(maxDrops, (i) => i + 1);
  }

  // UI setters
  void setStartTime(TimeOfDay time) {
    _startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    _endTime = time;
    if (time.hour == 0 && time.minute == 0) {
      // Treat 00:00 as 24:00
      _endTime = const TimeOfDay(hour: 24, minute: 0);
    }
    notifyListeners();
  }

  void setDropTimes(int times) {
    _dropTimes = times;
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

  /// Check if time slot already exists.
  bool _isTimeExists() {
    if (_startTime == null || _endTime == null) {
      return false;
    }

    // Create time string for comparison
    final String newTimeString =
        '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')} ~ ${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';

    // Check against existing details (excluding initialDetail if editing)
    for (final detail in existingDetails) {
      if (detail == initialDetail) {
        continue; // Skip the one being edited
      }
      if (detail.timeString == newTimeString) {
        return true;
      }

      // Check for overlap
      final existingParts = detail.timeString?.split(' ~ ');
      if (existingParts != null && existingParts.length == 2) {
        final existingStartParts = existingParts[0].split(':');
        final existingEndParts = existingParts[1].split(':');
        if (existingStartParts.length == 2 && existingEndParts.length == 2) {
          final existingStartHour = int.tryParse(existingStartParts[0]) ?? 0;
          final existingEndHour = int.tryParse(existingEndParts[0]) ?? 0;
          final newStartHour = _startTime!.hour;
          int newEndHour = _endTime!.hour;
          if (newEndHour == 0) {
            newEndHour = 24;
          }

          // Check for overlap
          if (newStartHour < existingEndHour &&
              newEndHour > existingStartHour) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Save time slot detail.
  ///
  /// Returns the detail if successful, null otherwise.
  PumpHeadRecordDetail? save({
    required void Function() onDropVolumeTooLittle,
    required void Function() onDropVolumeTooMuch,
    required void Function() onTimeExists,
  }) {
    // Check for cross-day (not allowed)
    if (_startTime == null || _endTime == null) {
      return null;
    }

    int endHour = _endTime!.hour;
    if (endHour == 0) {
      endHour = 24;
    }

    if (endHour <= _startTime!.hour) {
      // Cross-day not allowed, silently ignore
      return null;
    }

    // Check minimum dose per drop
    if (_dropVolume == null) {
      return null;
    }

    final double eachDose = _dropVolume! / _dropTimes;
    if (eachDose < minDose) {
      onDropVolumeTooLittle();
      return null;
    }

    // Check maximum (500ml)
    if (_dropVolume! > 500) {
      onDropVolumeTooMuch();
      return null;
    }

    // Check if time slot already exists
    if (_isTimeExists()) {
      onTimeExists();
      return null;
    }

    // Create detail
    final String timeString =
        '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')} ~ ${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';

    return PumpHeadRecordDetail(
      timeString: timeString,
      dropTime: _dropTimes,
      totalDrop: _dropVolume!,
      rotatingSpeed: _rotatingSpeed,
    );
  }
}
