import 'package:flutter/foundation.dart';

import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../application/doser/update_pump_head_settings.dart';

class PumpHeadSettingsController extends ChangeNotifier {
  final String headId;
  final AppSession session;
  final UpdatePumpHeadSettingsUseCase updateUseCase;

  bool _isSaving = false;
  AppErrorCode? _lastErrorCode;

  PumpHeadSettingsController({
    required this.headId,
    required this.session,
    required this.updateUseCase,
  });

  bool get isSaving => _isSaving;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  Future<bool> save({required String name, required int delaySeconds}) async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _lastErrorCode = AppErrorCode.noActiveDevice;
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _lastErrorCode = null;
    notifyListeners();

    try {
      await updateUseCase.execute(
        deviceId: deviceId,
        headId: headId,
        name: name,
        delaySeconds: delaySeconds,
      );
      return true;
    } on AppError catch (error) {
      _lastErrorCode = error.code;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
