import 'package:flutter/foundation.dart';

import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/usecases/doser/single_dose_immediate_usecase.dart';
import '../../../../domain/doser_dosing/pump_speed.dart';
import '../../../../domain/doser_dosing/single_dose_immediate.dart';

class ManualDosingController extends ChangeNotifier {
  final AppSession session;
  final SingleDoseImmediateUseCase singleDoseImmediateUseCase;

  bool _isSubmitting = false;
  AppErrorCode? _lastErrorCode;

  ManualDosingController({
    required this.session,
    required this.singleDoseImmediateUseCase,
  });

  bool get isSubmitting => _isSubmitting;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  Future<bool> submit({required String headId, required double doseMl}) async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _lastErrorCode = AppErrorCode.noActiveDevice;
      notifyListeners();
      return false;
    }
    // KC-A-FINAL: Gate on device ready state
    if (!session.isReady) {
      _lastErrorCode = AppErrorCode.deviceNotReady;
      notifyListeners();
      return false;
    }

    if (_isSubmitting) {
      return false;
    }

    _isSubmitting = true;
    _lastErrorCode = null;
    notifyListeners();

    try {
      final SingleDoseImmediate dose = SingleDoseImmediate(
        pumpId: _pumpIdFromHeadId(headId),
        doseMl: doseMl,
        speed: PumpSpeed.medium,
      );

      await singleDoseImmediateUseCase.execute(deviceId: deviceId, dose: dose);
      return true;
    } on AppError catch (error) {
      _lastErrorCode = error.code;
      return false;
    } catch (_) {
      _lastErrorCode = AppErrorCode.unknownError;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_lastErrorCode == null) {
      return;
    }
    _lastErrorCode = null;
    notifyListeners();
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
