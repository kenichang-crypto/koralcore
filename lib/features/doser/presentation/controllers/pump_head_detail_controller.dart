import 'package:flutter/widgets.dart';

import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/usecases/doser/read_dosing_schedule_summary_usecase.dart';
import '../../../../domain/usecases/doser/read_today_total.dart';
import '../../../../domain/usecases/doser/single_dose_immediate_usecase.dart';
import '../../../../domain/usecases/doser/single_dose_timed_usecase.dart';
import '../../../../domain/doser_dosing/pump_speed.dart';
import '../../../../domain/doser_dosing/today_dose_summary.dart';
import '../../../../domain/doser_dosing/single_dose_immediate.dart';
import '../../../../domain/doser_dosing/single_dose_timed.dart';
import '../../../../domain/doser_dosing/pump_head.dart';
import '../../../../domain/doser_dosing/dosing_schedule_summary.dart';
import '../models/pump_head_summary.dart';

class PumpHeadDetailController extends ChangeNotifier
    with WidgetsBindingObserver {
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
  bool _isScheduleSummaryLoading = true;
  bool _isManualDoseInFlight = false;
  bool _isTimedDoseInFlight = false;
  AppErrorCode? _lastErrorCode;
  TodayDoseReadState _todayDoseState = const TodayDoseReadState.idle();
  DosingScheduleSummary? _scheduleSummary;
  Future<void>? _refreshInProgress;
  String? _refreshDeviceId;
  String? _activeDeviceId;
  bool _isDisposed = false;

  PumpHeadDetailController({
    required this.headId,
    required this.session,
    required this.readTodayTotalUseCase,
    required this.readDosingScheduleSummaryUseCase,
    required this.singleDoseImmediateUseCase,
    required this.singleDoseTimedUseCase,
  }) : _summary = PumpHeadSummary.demo(headId) {
    WidgetsBinding.instance.addObserver(this);
    session.addListener(_handleSessionChanged);
  }

  PumpHeadSummary get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isTodayDoseLoading => _todayDoseState.isLoading;
  bool get isScheduleSummaryLoading => _isScheduleSummaryLoading;
  bool get isManualDoseInFlight => _isManualDoseInFlight;
  bool get isTimedDoseInFlight => _isTimedDoseInFlight;
  TodayDoseSummary? get todayDoseSummary => _todayDoseState.summary;
  DosingScheduleSummary? get dosingScheduleSummary => _scheduleSummary;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  bool get canDisplayData => session.isBleConnected && !isLoading;

  Future<void> refresh() {
    final String? deviceId = session.activeDeviceId;
    if (_refreshInProgress != null && _refreshDeviceId == deviceId) {
      return _refreshInProgress!;
    }

    final Future<void> refreshTask = _performRefresh(deviceId);
    _refreshDeviceId = deviceId;
    _refreshInProgress = refreshTask.whenComplete(() {
      if (identical(_refreshInProgress, refreshTask)) {
        _refreshInProgress = null;
        _refreshDeviceId = null;
      }
    });

    return _refreshInProgress!;
  }

  Future<void> _performRefresh(String? deviceId) async {
    if (deviceId == null) {
      _handleNoActiveDevice();
      return;
    }

    final bool deviceChanged = _activeDeviceId != deviceId;
    _activeDeviceId = deviceId;

    _isLoading = true;
    _isScheduleSummaryLoading = true;
    _todayDoseState = TodayDoseReadState.loading(
      previousSummary: deviceChanged ? null : _todayDoseState.summary,
    );
    if (deviceChanged) {
      _summary = _summary.copyWith(todayDispensedMl: 0);
      _scheduleSummary = null;
    }
    _notifyListenersIfActive();

    final List<AppErrorCode?> results = await Future.wait<AppErrorCode?>(
      <Future<AppErrorCode?>>[
        _loadTodayTotals(deviceId),
        _loadScheduleSummary(deviceId),
      ],
      eagerError: false,
    );

    if (!_shouldApplyResult(deviceId)) {
      return;
    }

    AppErrorCode? failure;
    for (final AppErrorCode? code in results) {
      failure ??= code;
    }

    if (failure == null) {
      _clearErrorFlag();
    } else {
      _setError(failure);
    }

    _isLoading = false;
    _notifyListenersIfActive();
  }

  void _handleNoActiveDevice() {
    _activeDeviceId = null;
    _summary = PumpHeadSummary.demo(headId);
    _isLoading = false;
    _isScheduleSummaryLoading = false;
    _todayDoseState = const TodayDoseReadState.idle();
    _scheduleSummary = null;
    _setError(AppErrorCode.noActiveDevice);
    _notifyListenersIfActive();
  }

  bool _shouldApplyResult(String deviceId) {
    return !_isDisposed && _activeDeviceId == deviceId;
  }

  void _notifyListenersIfActive() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    session.removeListener(_handleSessionChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh();
    }
  }

  void _handleSessionChanged() {
    final bool isConnected = session.isBleConnected;
    final bool deviceChanged = _activeDeviceId != session.activeDeviceId;

    if (deviceChanged) {
      refresh();
      return;
    }

    if (!isConnected) {
      _handleNoActiveDevice();
      return;
    }

    _applySessionPumpHead();
  }

  void clearError() {
    if (_lastErrorCode == null) return;
    _lastErrorCode = null;
    _notifyListenersIfActive();
  }

  Future<bool> sendManualDose() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      _notifyListenersIfActive();
      return false;
    }
    // KC-A-FINAL: Gate on device ready state
    if (!session.isReady) {
      _setError(AppErrorCode.deviceNotReady);
      _notifyListenersIfActive();
      return false;
    }

    if (_isManualDoseInFlight) {
      return false;
    }

    _isManualDoseInFlight = true;
    _notifyListenersIfActive();

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
      _notifyListenersIfActive();
      return false;
    } catch (_) {
      _setError(AppErrorCode.unknownError);
      _notifyListenersIfActive();
      return false;
    } finally {
      _isManualDoseInFlight = false;
      _notifyListenersIfActive();
    }
  }

  Future<bool> scheduleTimedDose() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      _notifyListenersIfActive();
      return false;
    }
    // KC-A-FINAL: Gate on device ready state
    if (!session.isReady) {
      _setError(AppErrorCode.deviceNotReady);
      _notifyListenersIfActive();
      return false;
    }

    if (_isTimedDoseInFlight) {
      return false;
    }

    _isTimedDoseInFlight = true;
    _notifyListenersIfActive();

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
      _notifyListenersIfActive();
      return false;
    } catch (_) {
      _setError(AppErrorCode.unknownError);
      _notifyListenersIfActive();
      return false;
    } finally {
      _isTimedDoseInFlight = false;
      _notifyListenersIfActive();
    }
  }

  void _clearErrorFlag() {
    if (_lastErrorCode == null) return;
    _lastErrorCode = null;
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  Future<AppErrorCode?> _loadTodayTotals(String deviceId) async {
    try {
      final TodayDoseSummary? summary = await readTodayTotalUseCase.execute(
        deviceId: deviceId,
        headId: headId,
      );
      if (!_shouldApplyResult(deviceId)) {
        return null;
      }
      if (summary == null) {
        _todayDoseState = const TodayDoseReadState.empty();
        return null;
      }
      _todayDoseState = TodayDoseReadState.success(summary);
      return null;
    } on AppError catch (error) {
      if (_shouldApplyResult(deviceId)) {
        _todayDoseState = TodayDoseReadState.failure(
          error.code,
          previousSummary: _todayDoseState.summary,
        );
      }
      return error.code;
    } catch (_) {
      if (_shouldApplyResult(deviceId)) {
        _todayDoseState = TodayDoseReadState.failure(
          AppErrorCode.unknownError,
          previousSummary: _todayDoseState.summary,
        );
      }
      return AppErrorCode.unknownError;
    }
  }

  Future<AppErrorCode?> _loadScheduleSummary(String deviceId) async {
    try {
      final DosingScheduleSummary? summary =
          await readDosingScheduleSummaryUseCase.execute(
            deviceId: deviceId,
            headId: headId,
          );
      if (_shouldApplyResult(deviceId)) {
        _scheduleSummary = summary;
      }
      return null;
    } on AppError catch (error) {
      if (_shouldApplyResult(deviceId)) {
        _scheduleSummary = null;
      }
      return error.code;
    } catch (_) {
      if (_shouldApplyResult(deviceId)) {
        _scheduleSummary = null;
      }
      return AppErrorCode.unknownError;
    } finally {
      if (_shouldApplyResult(deviceId)) {
        _isScheduleSummaryLoading = false;
      }
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

  void _applySessionPumpHead({bool notify = true}) {
    final PumpHead? head = _sessionPumpHead();
    if (head == null) {
      return;
    }
    final PumpHeadSummary next = PumpHeadSummary.fromPumpHead(head);
    if (_pumpHeadSummariesEqual(_summary, next)) {
      return;
    }
    _summary = next;
    if (notify) {
      _notifyListenersIfActive();
    }
  }

  PumpHead? _sessionPumpHead() {
    final String target = headId.toUpperCase();
    for (final PumpHead head in session.pumpHeads) {
      if (head.headId.toUpperCase() == target) {
        return head;
      }
    }
    return null;
  }

  bool _pumpHeadSummariesEqual(PumpHeadSummary a, PumpHeadSummary b) {
    return a.headId == b.headId &&
        a.additiveName == b.additiveName &&
        a.dailyTargetMl == b.dailyTargetMl &&
        a.todayDispensedMl == b.todayDispensedMl &&
        a.flowRateMlPerMin == b.flowRateMlPerMin &&
        a.lastDoseAt == b.lastDoseAt &&
        a.statusKey == b.statusKey;
  }
}

class TodayDoseReadState {
  final bool isLoading;
  final TodayDoseSummary? summary;
  final AppErrorCode? errorCode;

  const TodayDoseReadState._({
    required this.isLoading,
    this.summary,
    this.errorCode,
  });

  const TodayDoseReadState.idle()
    : this._(isLoading: false, summary: null, errorCode: null);

  TodayDoseReadState.loading({TodayDoseSummary? previousSummary})
    : this._(isLoading: true, summary: previousSummary, errorCode: null);

  const TodayDoseReadState.empty()
    : this._(isLoading: false, summary: null, errorCode: null);

  TodayDoseReadState.success(TodayDoseSummary summary)
    : this._(isLoading: false, summary: summary, errorCode: null);

  TodayDoseReadState.failure(
    AppErrorCode code, {
    TodayDoseSummary? previousSummary,
  }) : this._(isLoading: false, summary: previousSummary, errorCode: code);
}
