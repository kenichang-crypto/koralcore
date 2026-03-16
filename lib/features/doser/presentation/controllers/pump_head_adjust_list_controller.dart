import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/common/app_session.dart';
import '../../../../domain/doser_dosing/pump_head_adjust_history.dart';
import '../../../../domain/doser_dosing/dosing_state.dart';
import '../../../../domain/usecases/doser/observe_dosing_state_usecase.dart';

class PumpHeadAdjustListController extends ChangeNotifier {
  PumpHeadAdjustListController({
    required String headId,
    required AppSession session,
    required ObserveDosingStateUseCase observeDosingStateUseCase,
  })  : _headId = headId,
        _session = session,
        _observeDosingStateUseCase = observeDosingStateUseCase {
    _listen();
  }

  final String _headId;
  final AppSession _session;
  final ObserveDosingStateUseCase _observeDosingStateUseCase;

  StreamSubscription<DosingState>? _subscription;
  List<PumpHeadAdjustHistory>? _history;
  bool _isLoading = true;
  Object? _error;

  List<PumpHeadAdjustHistory>? get history => _history;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  void _listen() {
    final String? deviceId = _session.activeDeviceId;
    if (deviceId == null || deviceId.isEmpty) {
      _error = 'No active device';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _subscription = _observeDosingStateUseCase
        .execute(deviceId: deviceId)
        .listen(_handleState, onError: _handleError);
  }

  void _handleState(DosingState state) {
    _history = state.getAdjustHistory(_headIndex(_headId));
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void _handleError(Object error, StackTrace stackTrace) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  int _headIndex(String headId) {
    if (headId.isEmpty) return 0;
    final String normalized = headId.trim().toUpperCase();
    if (normalized.isEmpty) return 0;
    final int code = normalized.codeUnitAt(0) - 65;
    if (code < 0) return 0;
    if (code > 3) return 3;
    return code;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
