import 'package:flutter/material.dart';

import '../../../../application/common/app_error.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../application/led/read_lighting_state.dart';
import '../../../../application/led/set_channel_intensity.dart';

class LedControlController extends ChangeNotifier {
  final AppSession session;
  final ReadLightingStateUseCase readLightingStateUseCase;
  final SetChannelIntensityUseCase setChannelIntensityUseCase;

  List<LedChannelEditState> _channels = const [];
  List<LedChannelEditState> _initialChannels = const [];
  DateTime? _lastUpdated;
  bool _isLoading = true;
  bool _isApplying = false;
  AppErrorCode? _lastErrorCode;

  LedControlController({
    required this.session,
    required this.readLightingStateUseCase,
    required this.setChannelIntensityUseCase,
  });

  List<LedChannelEditState> get channels => _channels;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isLoading => _isLoading;
  bool get isApplying => _isApplying;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  bool get hasChanges {
    if (_channels.length != _initialChannels.length) {
      return true;
    }
    for (int i = 0; i < _channels.length; i++) {
      if (_channels[i].value != _initialChannels[i].value) {
        return true;
      }
    }
    return false;
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setEmptyState();
      _setError(AppErrorCode.noActiveDevice);
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final LightingStateSnapshot snapshot = await readLightingStateUseCase
          .execute(deviceId: deviceId);
      _applySnapshot(snapshot);
      _clearError();
    } on AppError catch (error) {
      _setEmptyState();
      _setError(error.code);
    } catch (_) {
      _setEmptyState();
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateChannel(String channelId, double value) {
    final int normalized = value.round().clamp(0, 100);
    final int index = _channels.indexWhere(
      (channel) => channel.id == channelId,
    );
    if (index == -1 || _channels[index].value == normalized) {
      return;
    }

    final List<LedChannelEditState> next = List<LedChannelEditState>.from(
      _channels,
      growable: false,
    );
    next[index] = next[index].copyWith(value: normalized);
    _channels = next;
    notifyListeners();
  }

  void resetEdits() {
    _channels = _initialChannels
        .map((channel) => channel.copyWith())
        .toList(growable: false);
    notifyListeners();
  }

  Future<bool> applyChanges() async {
    if (!hasChanges) {
      return true;
    }

    final String? deviceId = session.activeDeviceId;
    if (deviceId == null) {
      _setError(AppErrorCode.noActiveDevice);
      notifyListeners();
      return false;
    }

    _isApplying = true;
    notifyListeners();

    try {
      final LightingStateSnapshot snapshot = await setChannelIntensityUseCase
          .execute(
            deviceId: deviceId,
            channels: _channels
                .map(
                  (channel) => ChannelIntensityChange(
                    channelId: channel.id,
                    percentage: channel.value,
                  ),
                )
                .toList(growable: false),
          );
      _applySnapshot(snapshot);
      _clearError();
      return true;
    } on AppError catch (error) {
      _setError(error.code);
      return false;
    } catch (_) {
      _setError(AppErrorCode.unknownError);
      return false;
    } finally {
      _isApplying = false;
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

  void _applySnapshot(LightingStateSnapshot snapshot) {
    _channels = snapshot.channels
        .map(
          (channel) => LedChannelEditState(
            id: channel.id,
            label: channel.label,
            value: channel.percentage,
          ),
        )
        .toList(growable: false);
    _initialChannels = _channels
        .map((channel) => channel.copyWith())
        .toList(growable: false);
    _lastUpdated = snapshot.updatedAt;
  }

  void _setEmptyState() {
    _channels = const [];
    _initialChannels = const [];
    _lastUpdated = null;
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

class LedChannelEditState {
  final String id;
  final String label;
  final int value;

  const LedChannelEditState({
    required this.id,
    required this.label,
    required this.value,
  });

  LedChannelEditState copyWith({String? label, int? value}) {
    return LedChannelEditState(
      id: id,
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }
}
