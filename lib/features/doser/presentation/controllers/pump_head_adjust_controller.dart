import 'dart:async';

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../data/ble/ble_adapter.dart';
import '../../../../data/ble/dosing/dosing_command_builder.dart';

/// PumpHeadAdjustController
///
/// PARITY: Mirrors reef-b-app's DropHeadAdjustViewModel.
/// Manages the state and logic for pump head calibration/adjustment.
class PumpHeadAdjustController extends ChangeNotifier {
  final String headId;
  final AppSession session;
  final BleAdapter bleAdapter;
  final DosingCommandBuilder commandBuilder = const DosingCommandBuilder();

  int _selectedSpeed = 1; // Default: Low speed
  bool _isLoading = false;
  bool _isCalibrating = false;
  bool _isCalibrationComplete = false;
  AppErrorCode? _lastErrorCode;
  final TextEditingController volumeController = TextEditingController();

  // Countdown timer state
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  PumpHeadAdjustController({
    required this.headId,
    required this.session,
    required this.bleAdapter,
  });

  int get selectedSpeed => _selectedSpeed;
  bool get isLoading => _isLoading;
  bool get isCalibrating => _isCalibrating;
  bool get isCalibrationComplete => _isCalibrationComplete;
  AppErrorCode? get lastErrorCode => _lastErrorCode;
  int get remainingSeconds => _remainingSeconds;

  void setSpeed(int speed) {
    if (speed < 1 || speed > 3) return;
    _selectedSpeed = speed;
    notifyListeners();
  }

  /// Start calibration process.
  ///
  /// PARITY: Mirrors reef-b-app's DropHeadAdjustViewModel.clickBtnNext().
  /// Sends BLE command 0x75 (startAdjust) to start the calibration.
  Future<void> startCalibration(BuildContext context) async {
    if (!session.isBleConnected) {
      _setError(AppErrorCode.noActiveDevice);
      return;
    }

    final deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      return;
    }

    _isLoading = true;
    _isCalibrating = true;
    _lastErrorCode = null;
    notifyListeners();

    try {
      // PARITY: BLE command 0x75 - startAdjust
      // Format: [0x75, 0x02, headNo, speed, checksum]
      final pumpId = _headIdToPumpId(headId);
      final command = commandBuilder.startAdjust(
        headNo: pumpId,
        speed: _selectedSpeed,
      );
      await bleAdapter.writeBytes(
        deviceId: deviceId,
        data: command,
      );

      // Calibration started successfully
      // Start countdown timer
      _startCountdown();
    } on AppError catch (error) {
      _setError(error.code);
      _isCalibrating = false;
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dosingStartAdjustFailed),
          ),
        );
      }
    } catch (error) {
      _setError(AppErrorCode.unknownError);
      _isCalibrating = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start countdown timer for calibration.
  ///
  /// PARITY: DROP_ADJUST_TIME = 21 seconds (21000 ms)
  void _startCountdown() {
    // PARITY: DROP_ADJUST_TIME = 21 seconds (21000 ms)
    const int totalSeconds = 21;
    _remainingSeconds = totalSeconds;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _onCountdownComplete();
      }
    });
    notifyListeners();
  }

  /// Called when countdown timer completes.
  ///
  /// PARITY: Mirrors reef-b-app's DropHeadAdjustActivity.startTimer() onFinish().
  /// Shows the volume input field and "Complete Calibration" button.
  void _onCountdownComplete() {
    _isCalibrating = false;
    _isCalibrationComplete = true;
    notifyListeners();
  }

  /// Complete calibration by submitting the actual drop volume.
  ///
  /// PARITY: Mirrors reef-b-app's DropHeadAdjustViewModel.clickBtnComplete().
  /// Sends BLE command 0x76 (adjustResult) with the measured volume.
  Future<void> completeCalibration(BuildContext context) async {
    if (!session.isBleConnected) {
      _setError(AppErrorCode.noActiveDevice);
      return;
    }

    final deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      return;
    }

    // Validate volume input
    final volumeText = volumeController.text.trim();
    if (volumeText.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dosingAdjustVolumeEmpty),
        ),
      );
      return;
    }

    final double? volume = double.tryParse(volumeText);
    if (volume == null || volume < 0.1 || volume > 500.9) {
      _setError(AppErrorCode.invalidParam);
      return;
    }

    _isLoading = true;
    _lastErrorCode = null;
    notifyListeners();

    try {
      // PARITY: BLE command 0x76 - adjustResult
      // Format: [0x76, 0x04, headNo, speed, volume_H, volume_L, checksum]
      // Volume is pre-scaled (ml × 10)
      final pumpId = _headIdToPumpId(headId);
      final int volumeScaled = (volume * 10).round();
      final command = commandBuilder.adjustResult(
        headNo: pumpId,
        speed: _selectedSpeed,
        volume: volumeScaled,
      );
      await bleAdapter.writeBytes(
        deviceId: deviceId,
        data: command,
      );

      // Calibration completed successfully
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dosingAdjustSuccessful),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } on AppError catch (error) {
      _setError(error.code);
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dosingAdjustFailed),
          ),
        );
      }
    } catch (error) {
      _setError(AppErrorCode.unknownError);
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dosingAdjustFailed),
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
    notifyListeners();
  }

  void clearError() {
    _lastErrorCode = null;
    notifyListeners();
  }

  /// Convert headId (e.g., 'A', 'B', 'C', 'D') to pumpId (1, 2, 3, 4).
  int _headIdToPumpId(String headId) {
    final String normalized = headId.trim().toUpperCase();
    if (normalized.isEmpty) {
      return 1;
    }
    final int candidate = normalized.codeUnitAt(0) - 64; // 'A' = 65, so A -> 1
    if (candidate < 1 || candidate > 4) {
      return 1;
    }
    return candidate;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    volumeController.dispose();
    super.dispose();
  }
}

