import 'package:flutter/foundation.dart';

import '../../../../app/common/app_error.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../app/device/update_device_name_usecase.dart';
import '../../../../app/device/update_device_sink_usecase.dart';
import '../../../../data/ble/ble_adapter.dart';
import '../../../../data/ble/dosing/dosing_command_builder.dart';
import '../../../../platform/contracts/device_repository.dart';
import '../../../../platform/contracts/sink_repository.dart';

/// DropSettingController - Dosing 設備設定控制器
///
/// PARITY: 100% reef-b-app DropSettingViewModel
/// android/ReefB_Android/.../drop_setting/DropSettingViewModel.kt
///
/// 功能:
/// - 編輯設備名稱
/// - 選擇水槽位置
/// - 設定延遲時間 (15秒-5分鐘)
/// - BLE 命令: setDelayTime
class DropSettingController extends ChangeNotifier {
  final String deviceId;
  final AppSession session;
  final UpdateDeviceNameUseCase updateDeviceNameUseCase;
  final UpdateDeviceSinkUseCase updateDeviceSinkUseCase;
  final DeviceRepository deviceRepository;
  final SinkRepository sinkRepository;
  final BleAdapter bleAdapter;
  final DosingCommandBuilder commandBuilder;

  // State variables
  String _deviceName = '';
  String? _sinkId;
  String? _sinkName;
  int _delayTimeSeconds = 15; // Default 15 seconds
  bool _isLoading = false;
  bool _isSaving = false;
  AppErrorCode? _lastErrorCode;

  DropSettingController({
    required this.deviceId,
    required this.session,
    required this.updateDeviceNameUseCase,
    required this.updateDeviceSinkUseCase,
    required this.deviceRepository,
    required this.sinkRepository,
    required this.bleAdapter,
    required this.commandBuilder,
  });

  // Getters
  String get deviceName => _deviceName;
  String? get sinkId => _sinkId;
  String? get sinkName => _sinkName;
  int get delayTimeSeconds => _delayTimeSeconds;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  AppErrorCode? get lastErrorCode => _lastErrorCode;
  bool get isConnected => session.isBleConnected;

  /// Initialize - Load device data
  ///
  /// PARITY: DropSettingViewModel.setNowDeviceId() (Line 52-77)
  Future<void> initialize() async {
    _isLoading = true;
    _lastErrorCode = null;
    notifyListeners();

    try {
      // Load device data
      final deviceData = await deviceRepository.getDevice(deviceId);
      if (deviceData == null) {
        throw const AppError(
          code: AppErrorCode.invalidParam,
          message: 'Device not found',
        );
      }

      // Set device name
      _deviceName = (deviceData['name'] as String?) ?? '';

      // Set sink ID and name
      _sinkId = deviceData['sinkId'] as String?;
      if (_sinkId != null) {
        final sinks = sinkRepository.getCurrentSinks();
        final sink = sinks.where((s) => s.id == _sinkId).firstOrNull;
        _sinkName = sink?.name;
      } else {
        _sinkName = null;
      }

      // Set delay time
      _delayTimeSeconds = (deviceData['delayTime'] as int?) ?? 15;
    } on AppError catch (error) {
      _lastErrorCode = error.code;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update device name
  ///
  /// PARITY: DropSettingViewModel.setName() (Line 79-81)
  void updateName(String name) {
    _deviceName = name;
    notifyListeners();
  }

  /// Update sink selection
  ///
  /// PARITY: DropSettingViewModel.setSelectSinkId() (Line 83-86)
  Future<void> updateSinkId(String? newSinkId) async {
    _sinkId = newSinkId;

    // Load sink name
    if (_sinkId != null) {
      final sinks = sinkRepository.getCurrentSinks();
      final sink = sinks.where((s) => s.id == _sinkId).firstOrNull;
      _sinkName = sink?.name;
    } else {
      _sinkName = null;
    }

    notifyListeners();
  }

  /// Update delay time
  ///
  /// PARITY: DropSettingViewModel.setSelectDelayTime() (Line 92-95)
  void updateDelayTime(int seconds) {
    _delayTimeSeconds = seconds;
    notifyListeners();
  }

  /// Save settings
  ///
  /// PARITY: DropSettingViewModel.editDevice() + setDelayTime() (Line 106-180)
  ///
  /// Flow:
  /// 1. Validate name (not empty)
  /// 2. Update device name (DB)
  /// 3. Update sink position (DB, check capacity)
  /// 4. Send BLE command for delay time (if connected)
  /// 5. Update delay time in DB
  Future<bool> save() async {
    _isSaving = true;
    _lastErrorCode = null;
    notifyListeners();

    try {
      // 1. Validate name
      final trimmedName = _deviceName.trim();
      if (trimmedName.isEmpty) {
        _lastErrorCode = AppErrorCode.invalidParam;
        _isSaving = false;
        notifyListeners();
        return false;
      }

      // 2. Update device name
      await updateDeviceNameUseCase.execute(
        deviceId: deviceId,
        name: trimmedName,
      );

      // 3. Update sink position
      // Get current device data
      final deviceData = await deviceRepository.getDevice(deviceId);
      if (deviceData == null) {
        throw const AppError(
          code: AppErrorCode.invalidParam,
          message: 'Device not found',
        );
      }

      final currentSinkId = deviceData['sinkId'] as String?;
      final deviceType = deviceData['type'] as String?;

      // Update sink if changed
      if (_sinkId != currentSinkId) {
        await updateDeviceSinkUseCase.execute(
          deviceId: deviceId,
          newSinkId: _sinkId,
          currentSinkId: currentSinkId,
          deviceType: deviceType,
        );
      }

      // 4 & 5. Update delay time
      await _updateDelayTime();

      return true;
    } on AppError catch (error) {
      _lastErrorCode = error.code;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Update delay time (DB + BLE)
  ///
  /// PARITY: DropSettingViewModel.setDelayTime() (Line 173-180)
  /// PARITY: DropSettingViewModel.bleSetDelayTime() (Line 183-186)
  Future<void> _updateDelayTime() async {
    // Update DB first
    final deviceData = await deviceRepository.getDevice(deviceId);
    if (deviceData != null) {
      deviceData['delayTime'] = _delayTimeSeconds;
      await deviceRepository.addSavedDevice(deviceData);
    }

    // Send BLE command if connected
    if (isConnected && session.activeDeviceId == deviceId) {
      final command = commandBuilder.setDelayTime(_delayTimeSeconds);
      await bleAdapter.writeBytes(deviceId: deviceId, data: command);
      // Note: ACK handling will be done by BLE layer
      // In Android, it's handled by onReadData() callback (Line 255-265)
      // For now, we assume success (DB is already updated)
    }
  }

  /// Get formatted delay time string
  ///
  /// PARITY: DropSettingActivity.setObserver() delayTimeLiveData (Line 158-184)
  String getDelayTimeText() {
    switch (_delayTimeSeconds) {
      case 15:
        return '15 秒'; // TODO(l10n): Use l10n._15sec
      case 30:
        return '30 秒'; // TODO(l10n): Use l10n._30sec
      case 60:
        return '1 分'; // TODO(l10n): Use l10n._1min
      case 120:
        return '2 分'; // TODO(l10n): Use l10n._2min
      case 180:
        return '3 分'; // TODO(l10n): Use l10n._3min
      case 240:
        return '4 分'; // TODO(l10n): Use l10n._4min
      case 300:
        return '5 分'; // TODO(l10n): Use l10n._5min
      default:
        return '$_delayTimeSeconds 秒';
    }
  }

  /// Get available delay time options
  static List<int> getDelayTimeOptions() {
    return [15, 30, 60, 120, 180, 240, 300];
  }
}
