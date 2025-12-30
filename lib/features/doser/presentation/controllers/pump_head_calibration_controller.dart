import 'package:flutter/foundation.dart';

import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/usecases/doser/read_calibration_history.dart';
import '../models/pump_head_calibration_record.dart';

class PumpHeadCalibrationController extends ChangeNotifier {
  final String headId;
  final AppSession session;
  final ReadCalibrationHistoryUseCase readCalibrationHistoryUseCase;

  List<PumpHeadCalibrationRecord> _records = const [];
  bool _isLoading = true;
  AppErrorCode? _lastErrorCode;

  PumpHeadCalibrationController({
    required this.headId,
    required this.session,
    required this.readCalibrationHistoryUseCase,
  });

  List<PumpHeadCalibrationRecord> get records => _records;
  bool get isLoading => _isLoading;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  Future<void> refresh() async {
    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _records = const [];
      _isLoading = false;
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final List<ReadCalibrationRecordSnapshot> snapshots =
          await readCalibrationHistoryUseCase.execute(
            deviceId: deviceId,
            headId: headId,
          );
      _records = snapshots.map(_mapSnapshot).toList(growable: false)
        ..sort((a, b) => b.performedAt.compareTo(a.performedAt));
      _clearErrorFlag();
    } on AppError catch (error) {
      _records = const [];
      _setError(error.code);
    } catch (_) {
      _records = const [];
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_lastErrorCode == null) return;
    _lastErrorCode = null;
    notifyListeners();
  }

  PumpHeadCalibrationRecord _mapSnapshot(
    ReadCalibrationRecordSnapshot snapshot,
  ) {
    return PumpHeadCalibrationRecord(
      id: snapshot.id,
      speedProfile: snapshot.speedProfile,
      flowRateMlPerMin: snapshot.flowRateMlPerMin,
      performedAt: snapshot.performedAt,
      note: snapshot.note,
    );
  }

  void _clearErrorFlag() {
    if (_lastErrorCode == null) return;
    _lastErrorCode = null;
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }
}
