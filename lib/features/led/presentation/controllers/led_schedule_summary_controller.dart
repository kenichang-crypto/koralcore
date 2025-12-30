import 'package:flutter/material.dart';

import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/usecases/led/read_led_schedule_summary_usecase.dart';
import '../../../../domain/led_lighting/led_schedule_overview.dart';

class LedScheduleSummaryController extends ChangeNotifier {
  final AppSession session;
  final ReadLedScheduleSummaryUseCase readLedScheduleSummaryUseCase;

  LedScheduleOverview? _summary;
  bool _isLoading = true;
  AppErrorCode? _lastErrorCode;

  LedScheduleSummaryController({
    required this.session,
    required this.readLedScheduleSummaryUseCase,
  });

  LedScheduleOverview? get summary => _summary;
  bool get isLoading => _isLoading;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _summary = null;
      _isLoading = false;
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return;
    }

    try {
      _summary = await readLedScheduleSummaryUseCase.execute(
        deviceId: deviceId,
      );
      _clearError();
    } on AppError catch (error) {
      _summary = null;
      _setError(error.code);
    } catch (_) {
      _summary = null;
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
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

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  void _clearError() {
    if (_lastErrorCode == null) {
      return;
    }
    _lastErrorCode = null;
  }
}
