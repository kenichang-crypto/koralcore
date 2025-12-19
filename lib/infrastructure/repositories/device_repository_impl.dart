library;

import 'dart:async';
import 'dart:math';

import '../../application/common/app_error.dart';
import '../../application/common/app_error_code.dart';
import '../../platform/contracts/device_repository.dart';

/// In-memory repository that simulates the platform device list.
class DeviceRepositoryImpl extends DeviceRepository {
  final List<_DeviceRecord> _records = [
    _DeviceRecord(
      id: 'reef-dose-4k',
      name: 'Reef Dose 4',
      rssi: -52,
      state: 'disconnected',
      provisioned: true,
    ),
    _DeviceRecord(
      id: 'reef-led-x',
      name: 'Reef LED X',
      rssi: -61,
      state: 'disconnected',
      provisioned: true,
    ),
    _DeviceRecord(
      id: 'reef-lab',
      name: 'Reef Lab',
      rssi: -70,
      state: 'disconnected',
      provisioned: false,
    ),
  ];

  final StreamController<List<Map<String, dynamic>>> _controller;
  final Random _random = Random();

  String? _currentDeviceId;

  DeviceRepositoryImpl()
    : _controller = StreamController<List<Map<String, dynamic>>>.broadcast() {
    _controller.onListen = _emit;
    _emit();
  }

  @override
  Future<List<Map<String, dynamic>>> scanDevices({Duration? timeout}) async {
    await Future<void>.delayed(timeout ?? const Duration(seconds: 2));
    for (var i = 0; i < _records.length; i++) {
      _records[i] = _records[i].withRandomizedRssi(_random);
    }
    _emit();
    return _snapshot();
  }

  @override
  Future<void> addDevice(
    String deviceId, {
    Map<String, dynamic>? metadata,
  }) async {
    final existingIndex = _records.indexWhere(
      (record) => record.id == deviceId,
    );
    if (existingIndex != -1) {
      return;
    }

    _records.add(
      _DeviceRecord(
        id: deviceId,
        name: metadata?['name']?.toString() ?? 'Device ${_records.length + 1}',
        rssi: metadata?['rssi'] is num
            ? (metadata?['rssi'] as num).round()
            : -65,
        state: 'disconnected',
        provisioned: metadata?['provisioned'] == true,
      ),
    );
    _emit();
  }

  @override
  Future<void> connect(String deviceId) async {
    final index = _indexOf(deviceId);
    final record = _records[index];
    if (record.state == 'connecting') {
      throw const AppError(
        code: AppErrorCode.deviceBusy,
        message: 'Device already connecting',
      );
    }

    if (_currentDeviceId != null && _currentDeviceId != deviceId) {
      final previousIndex = _indexOf(_currentDeviceId!);
      _records[previousIndex] = _records[previousIndex].copyWith(
        state: 'disconnected',
      );
    }

    _records[index] = record.copyWith(state: 'connected');
    _currentDeviceId = deviceId;
    _emit();
  }

  @override
  Future<void> disconnect(String deviceId) async {
    final index = _indexOf(deviceId);
    _records[index] = _records[index].copyWith(state: 'disconnected');
    if (_currentDeviceId == deviceId) {
      _currentDeviceId = null;
    }
    _emit();
  }

  @override
  Future<void> removeDevice(String deviceId) async {
    _records.removeWhere((record) => record.id == deviceId);
    if (_currentDeviceId == deviceId) {
      _currentDeviceId = null;
    }
    _emit();
  }

  @override
  Future<void> setCurrentDevice(String deviceId) async {
    _currentDeviceId = deviceId;
  }

  @override
  Future<String?> getCurrentDevice() async => _currentDeviceId;

  @override
  Future<void> updateDeviceState(String deviceId, String state) async {
    final index = _indexOf(deviceId);
    _records[index] = _records[index].copyWith(state: state);
    _emit();
  }

  @override
  Stream<List<Map<String, dynamic>>> observeDevices() => _controller.stream;

  @override
  Future<Map<String, dynamic>?> getDevice(String deviceId) async {
    final index = _indexOf(deviceId, allowMissing: true);
    if (index == -1) {
      return null;
    }
    return _records[index].toMap();
  }

  @override
  Future<String?> getDeviceState(String deviceId) async {
    final index = _indexOf(deviceId, allowMissing: true);
    if (index == -1) {
      return null;
    }
    return _records[index].state;
  }

  void _emit() {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(_snapshot());
  }

  List<Map<String, dynamic>> _snapshot() {
    return _records.map((record) => record.toMap()).toList(growable: false);
  }

  int _indexOf(String deviceId, {bool allowMissing = false}) {
    final index = _records.indexWhere((record) => record.id == deviceId);
    if (index == -1 && !allowMissing) {
      throw AppError(
        code: AppErrorCode.invalidParam,
        message: 'Unknown device id $deviceId',
      );
    }
    return index;
  }
}

class _DeviceRecord {
  final String id;
  final String name;
  final int rssi;
  final String state;
  final bool provisioned;

  const _DeviceRecord({
    required this.id,
    required this.name,
    required this.rssi,
    required this.state,
    required this.provisioned,
  });

  _DeviceRecord copyWith({
    String? id,
    String? name,
    int? rssi,
    String? state,
    bool? provisioned,
  }) {
    return _DeviceRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      state: state ?? this.state,
      provisioned: provisioned ?? this.provisioned,
    );
  }

  _DeviceRecord withRandomizedRssi(Random random) {
    final delta = random.nextInt(10) - 5;
    final int next = (rssi + delta).clamp(-90, -40).toInt();
    return copyWith(rssi: next);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rssi': rssi,
      'state': state,
      'provisioned': provisioned,
    };
  }
}
