library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../device/device_snapshot.dart';
import 'app_context.dart';

/// Reactive view of global session state (connection, guards, etc.).
class AppSession extends ChangeNotifier {
  final AppContext context;
  StreamSubscription<List<DeviceSnapshot>>? _subscription;

  String? _activeDeviceId;
  String? _activeDeviceName;

  AppSession({required this.context}) {
    _subscription = context.scanDevicesUseCase.observe().listen(_onDevices);
  }

  bool get isBleConnected => _activeDeviceId != null;
  String? get activeDeviceId => _activeDeviceId;
  String? get activeDeviceName => _activeDeviceName;

  void _onDevices(List<DeviceSnapshot> devices) {
    DeviceSnapshot? connected;
    for (final device in devices) {
      if (device.isConnected) {
        connected = device;
        break;
      }
    }

    final String? nextId = connected?.id;
    final String? nextName = connected?.name;

    if (_activeDeviceId == nextId && _activeDeviceName == nextName) {
      return;
    }

    _activeDeviceId = nextId;
    _activeDeviceName = nextName;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
