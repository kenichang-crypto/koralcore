library;

import 'dart:async';
import 'dart:math';

import '../../application/common/app_error.dart';
import '../../application/common/app_error_code.dart';
import '../../platform/contracts/device_repository.dart';

/// In-memory repository that simulates the platform device list with saved/discovered sets.
class DeviceRepositoryImpl extends DeviceRepository {
  final List<_DeviceRecord> _savedRecords = [
    const _DeviceRecord(
      id: 'reef-dose-4k',
      name: 'Reef Dose 4',
      rssi: -52,
      state: 'disconnected',
      provisioned: true,
      isMaster: false,
    ),
    const _DeviceRecord(
      id: 'reef-led-x',
      name: 'Reef LED X',
      rssi: -61,
      state: 'disconnected',
      provisioned: true,
      isMaster: true,
    ),
    const _DeviceRecord(
      id: 'reef-lab',
      name: 'Reef Lab',
      rssi: -70,
      state: 'disconnected',
      provisioned: false,
      isMaster: false,
    ),
  ];

  final List<_DeviceRecord> _discoveredRecords = [];

  final StreamController<List<Map<String, dynamic>>> _savedController;
  final StreamController<List<Map<String, dynamic>>> _discoveredController;
  final Random _random = Random();

  String? _currentDeviceId;

  DeviceRepositoryImpl()
    : _savedController =
          StreamController<List<Map<String, dynamic>>>.broadcast(),
      _discoveredController =
          StreamController<List<Map<String, dynamic>>>.broadcast() {
    _savedController.onListen = _emitSaved;
    _discoveredController.onListen = _emitDiscovered;
    _emitSaved();
    _emitDiscovered();
  }

  @override
  Future<List<Map<String, dynamic>>> scanDevices({Duration? timeout}) async {
    await Future<void>.delayed(timeout ?? const Duration(seconds: 2));
    _randomizeRssi(_savedRecords);
    if (_discoveredRecords.isEmpty) {
      _discoveredRecords.addAll(_generateDiscovered());
    } else {
      _randomizeRssi(_discoveredRecords);
    }
    _emitSaved();
    _emitDiscovered();
    return _discoveredRecords
        .map((record) => record.toMap())
        .toList(growable: false);
  }

  @override
  Future<List<Map<String, dynamic>>> listSavedDevices() async {
    return _savedSnapshot();
  }

  @override
  Stream<List<Map<String, dynamic>>> observeSavedDevices() =>
      _savedController.stream;

  @override
  Future<void> addSavedDevice(Map<String, dynamic> device) async {
    final String id = device['id']?.toString() ?? '';
    if (id.isEmpty) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Device id must not be empty',
      );
    }
    final int index = _indexOf(id, allowMissing: true);
    final _DeviceRecord record = _DeviceRecord(
      id: id,
      name: device['name']?.toString() ?? 'Device ${_savedRecords.length + 1}',
      rssi: device['rssi'] is num ? (device['rssi'] as num).round() : -65,
      state: device['state']?.toString() ?? 'disconnected',
      provisioned: device['provisioned'] == true,
      isMaster: device['isMaster'] == true,
    );
    if (index == -1) {
      _savedRecords.add(record);
    } else {
      _savedRecords[index] = record;
    }
    _emitSaved();
  }

  @override
  Future<void> removeSavedDevice(String deviceId) async {
    _savedRecords.removeWhere((record) => record.id == deviceId);
    if (_currentDeviceId == deviceId) {
      _currentDeviceId = null;
    }
    _emitSaved();
  }

  @override
  Future<void> addDevice(
    String deviceId, {
    Map<String, dynamic>? metadata,
  }) async {
    await addSavedDevice({'id': deviceId, ...?metadata});
  }

  @override
  Future<void> connect(String deviceId) async {
    final index = _indexOf(deviceId);
    final record = _savedRecords[index];
    if (record.state == 'connecting') {
      throw const AppError(
        code: AppErrorCode.deviceBusy,
        message: 'Device already connecting',
      );
    }

    if (_currentDeviceId != null && _currentDeviceId != deviceId) {
      final previousIndex = _indexOf(_currentDeviceId!, allowMissing: true);
      if (previousIndex != -1) {
        _savedRecords[previousIndex] = _savedRecords[previousIndex].copyWith(
          state: 'disconnected',
        );
      }
    }

    _savedRecords[index] = record.copyWith(state: 'connected');
    _currentDeviceId = deviceId;
    _emitSaved();
  }

  @override
  Future<void> disconnect(String deviceId) async {
    final index = _indexOf(deviceId);
    _savedRecords[index] = _savedRecords[index].copyWith(state: 'disconnected');
    if (_currentDeviceId == deviceId) {
      _currentDeviceId = null;
    }
    _emitSaved();
  }

  @override
  Future<void> removeDevice(String deviceId) async {
    await removeSavedDevice(deviceId);
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
    _savedRecords[index] = _savedRecords[index].copyWith(state: state);
    _emitSaved();
  }

  @override
  Stream<List<Map<String, dynamic>>> observeDevices() =>
      _savedController.stream;

  @override
  Future<Map<String, dynamic>?> getDevice(String deviceId) async {
    final index = _indexOf(deviceId, allowMissing: true);
    if (index == -1) {
      return null;
    }
    return _savedRecords[index].toMap();
  }

  @override
  Future<String?> getDeviceState(String deviceId) async {
    final index = _indexOf(deviceId, allowMissing: true);
    if (index == -1) {
      return null;
    }
    return _savedRecords[index].state;
  }

  void _emitSaved() {
    if (!_savedController.isClosed) {
      _savedController.add(_savedSnapshot());
    }
  }

  void _emitDiscovered() {
    if (!_discoveredController.isClosed) {
      _discoveredController.add(
        _discoveredRecords
            .map((record) => record.toMap())
            .toList(growable: false),
      );
    }
  }

  List<Map<String, dynamic>> _savedSnapshot() {
    return _savedRecords
        .map((record) => record.toMap())
        .toList(growable: false);
  }

  List<_DeviceRecord> _generateDiscovered() {
    final List<_DeviceRecord> generated = List<_DeviceRecord>.from(
      _savedRecords,
    );
    generated.add(
      _DeviceRecord(
        id: 'reef-temp-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Reef Probe',
        rssi: -68,
        state: 'disconnected',
        provisioned: false,
        isMaster: false,
      ),
    );
    return generated;
  }

  void _randomizeRssi(List<_DeviceRecord> records) {
    for (var i = 0; i < records.length; i++) {
      records[i] = records[i].withRandomizedRssi(_random);
    }
  }

  int _indexOf(String deviceId, {bool allowMissing = false}) {
    final index = _savedRecords.indexWhere((record) => record.id == deviceId);
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
  final bool isMaster;

  const _DeviceRecord({
    required this.id,
    required this.name,
    required this.rssi,
    required this.state,
    required this.provisioned,
    required this.isMaster,
  });

  _DeviceRecord copyWith({
    String? id,
    String? name,
    int? rssi,
    String? state,
    bool? provisioned,
    bool? isMaster,
  }) {
    return _DeviceRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      state: state ?? this.state,
      provisioned: provisioned ?? this.provisioned,
      isMaster: isMaster ?? this.isMaster,
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
      'isMaster': isMaster,
    };
  }
}
