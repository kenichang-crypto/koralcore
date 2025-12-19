import 'package:flutter/foundation.dart';

import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../application/doser/read_dosing_schedule_summary_usecase.dart';
import '../../../../application/doser/read_today_total.dart';
import '../../../../application/doser/single_dose_immediate_usecase.dart';
import '../../../../application/doser/single_dose_timed_usecase.dart';
import '../../../../domain/doser_dosing/pump_speed.dart';
import '../../../../domain/doser_dosing/today_dose_summary.dart';
import '../../../../domain/doser_dosing/single_dose_immediate.dart';
import '../../../../domain/doser_dosing/single_dose_timed.dart';
import '../../../../domain/doser_schedule/dosing_schedule_summary.dart';
import '../models/pump_head_summary.dart';

class PumpHeadDetailController extends ChangeNotifier {
  static const double _defaultManualDoseMl = 1.0;
  static const double _defaultTimedDoseMl = 0.5;
  static const Duration _defaultTimedLeadDuration = Duration(minutes: 5);

  final String headId;
  final AppSession session;
  final ReadTodayTotalUseCase readTodayTotalUseCase;
  final ReadDosingScheduleSummaryUseCase readDosingScheduleSummaryUseCase;
  final SingleDoseImmediateUseCase singleDoseImmediateUseCase;
  final SingleDoseTimedUseCase singleDoseTimedUseCase;

  PumpHeadSummary _summary;
  bool _isLoading = true;
  bool _isTodayDoseLoading = true;
  bool _isScheduleSummaryLoading = true;
  bool _isManualDoseInFlight = false;
  bool _isTimedDoseInFlight = false;
  AppErrorCode? _lastErrorCode;
  TodayDoseSummary? _todayDoseSummary;
  DosingScheduleSummary? _scheduleSummary;

  PumpHeadDetailController({
    required this.headId,
    required this.session,
    required this.readTodayTotalUseCase,
    required this.readDosingScheduleSummaryUseCase,
    required this.singleDoseImmediateUseCase,
    required this.singleDoseTimedUseCase,
  }) : _summary = PumpHeadSummary.demo(headId);

  PumpHeadSummary get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isTodayDoseLoading => _isTodayDoseLoading;
  bool get isScheduleSummaryLoading => _isScheduleSummaryLoading;
  bool get isManualDoseInFlight => _isManualDoseInFlight;
  bool get isTimedDoseInFlight => _isTimedDoseInFlight;
  TodayDoseSummary? get todayDoseSummary => _todayDoseSummary;
  DosingScheduleSummary? get dosingScheduleSummary => _scheduleSummary;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  bool get canDisplayData => session.isBleConnected && !isLoading;

  Future<void> refresh() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _summary = PumpHeadSummary.demo(headId);
      _isLoading = false;
      _isTodayDoseLoading = false;
      _isScheduleSummaryLoading = false;
      _todayDoseSummary = null;
      _scheduleSummary = null;
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return;
    }

    _isLoading = true;
    _isTodayDoseLoading = true;
    _isScheduleSummaryLoading = true;
    notifyListeners();

    AppErrorCode? failure;

    await Future.wait(<Future<void>>[
      _loadTodayTotals(deviceId).catchError((Object error) {
        failure ??= _mapErrorCode(error);
      }),
      _loadScheduleSummary(deviceId).catchError((Object error) {
        failure ??= _mapErrorCode(error);
      }),
    ], eagerError: false);

    if (failure == null) {
      _clearErrorFlag();
    } else {
      _setError(failure!);
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    if (_lastErrorCode == null) return;
    _lastErrorCode = null;
    notifyListeners();
  }

  Future<bool> sendManualDose() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return false;
    }

    if (_isManualDoseInFlight) {
      return false;
    }

    _isManualDoseInFlight = true;
    notifyListeners();

    try {
      final SingleDoseImmediate dose = SingleDoseImmediate(
        pumpId: _pumpIdFromHeadId(headId),
        doseMl: _defaultManualDoseMl,
        speed: PumpSpeed.medium,
      );

      await singleDoseImmediateUseCase.execute(deviceId: deviceId, dose: dose);

      await refresh();
      return true;
    } on AppError catch (error) {
      _setError(error.code);
      notifyListeners();
      return false;
    } catch (_) {
      _setError(AppErrorCode.unknownError);
      notifyListeners();
      return false;
    } finally {
      _isManualDoseInFlight = false;
      notifyListeners();
    }
  }

  Future<bool> scheduleTimedDose() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return false;
    }

    if (_isTimedDoseInFlight) {
      return false;
    }

    _isTimedDoseInFlight = true;
    notifyListeners();

    try {
      final SingleDoseTimed dose = SingleDoseTimed(
        pumpId: _pumpIdFromHeadId(headId),
        doseMl: _defaultTimedDoseMl,
        speed: PumpSpeed.low,
        executeAt: DateTime.now().add(_defaultTimedLeadDuration),
      );

      await singleDoseTimedUseCase.execute(deviceId: deviceId, dose: dose);

      return true;
    } on AppError catch (error) {
      _setError(error.code);
      notifyListeners();
      return false;
    } catch (_) {
      _setError(AppErrorCode.unknownError);
      notifyListeners();
      return false;
    } finally {
      _isTimedDoseInFlight = false;
      notifyListeners();
    }
  }

  void _clearErrorFlag() {
    if (_lastErrorCode == null) return;
    _lastErrorCode = null;
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  AppErrorCode _mapErrorCode(Object error) {
    if (error is AppError) {
      return error.code;
    }
    return AppErrorCode.unknownError;
  }

  Future<void> _loadTodayTotals(String deviceId) async {
    try {
      final TodayDoseSummary? summary = await readTodayTotalUseCase.execute(
        deviceId: deviceId,
        headId: headId,
      );
      _todayDoseSummary = summary;
      if (summary != null) {
        _summary = _summary.copyWith(todayDispensedMl: summary.totalMl);
      }
    } finally {
      _isTodayDoseLoading = false;
    }
  }

  Future<void> _loadScheduleSummary(String deviceId) async {
    try {
      _scheduleSummary = await readDosingScheduleSummaryUseCase.execute(
        deviceId: deviceId,
        headId: headId,
      );
    } finally {
      _isScheduleSummaryLoading = false;
    }
  }

  int _pumpIdFromHeadId(String value) {
    final String normalized = value.trim().toUpperCase();
    if (normalized.isEmpty) {
      return 1;
    }
    final int candidate = normalized.codeUnitAt(0) - 64;
    if (candidate < 1) {
      return 1;
    }
    return candidate;
  }
}
