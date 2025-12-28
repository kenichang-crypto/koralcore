library;

import 'dart:async';
import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../../application/common/app_error.dart';
import '../../application/common/app_error_code.dart';
import '../../domain/sink/sink.dart';
import '../../infrastructure/database/database_helper.dart';
import '../../platform/contracts/device_repository.dart';
import '../../platform/contracts/sink_repository.dart';

/// SQLite-backed repository for device management.
/// Handles device persistence and state management.
class DeviceRepositoryImpl extends DeviceRepository {
  final SinkRepository? _sinkRepository;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<_DeviceRecord> _savedRecords = <_DeviceRecord>[];
  final List<_DeviceRecord> _discoveredRecords = <_DeviceRecord>[];
  final StreamController<List<Map<String, dynamic>>> _savedController;
  final StreamController<List<Map<String, dynamic>>> _discoveredController;
  final Random _random = Random();

  String? _currentDeviceId;
  bool _initialized = false;

  DeviceRepositoryImpl({SinkRepository? sinkRepository})
    : _sinkRepository = sinkRepository,
      _savedController =
          StreamController<List<Map<String, dynamic>>>.broadcast(),
      _discoveredController =
          StreamController<List<Map<String, dynamic>>>.broadcast() {
    _savedController.onListen = _emitSaved;
    _discoveredController.onListen = _emitDiscovered;
    _initialize();
  }

  Future<void> _initialize() async {
    if (_initialized) {
      return;
    }
    await _loadDevicesFromDatabase();
    _initialized = true;
    _emitSaved();
    _emitDiscovered();
  }

  Future<void> _loadDevicesFromDatabase() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('devices');
    _savedRecords.clear();
    _savedRecords.addAll(maps.map((map) => _DeviceRecord.fromMap(map)).toList());
  }

  Future<void> _saveDeviceToDatabase(_DeviceRecord record) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      'devices',
      {
        'id': record.id,
        'name': record.name,
        'rssi': record.rssi,
        'state': record.state,
        'provisioned': record.provisioned ? 1 : 0,
        'is_master': record.isMaster ? 1 : 0,
        'is_favorite': record.isFavorite ? 1 : 0,
        'mac_address': record.macAddress,
        'sink_id': record.sinkId,
        'type': record.type,
        'device_group': record.group,
        'delay_time': record.delayTime,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _deleteDeviceFromDatabase(String deviceId) async {
    final db = await _dbHelper.database;
    await db.delete('devices', where: 'id = ?', whereArgs: [deviceId]);
  }

  Future<void> _updateDeviceInDatabase(_DeviceRecord record) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      'devices',
      {
        'name': record.name,
        'rssi': record.rssi,
        'state': record.state,
        'provisioned': record.provisioned ? 1 : 0,
        'is_master': record.isMaster ? 1 : 0,
        'is_favorite': record.isFavorite ? 1 : 0,
        'mac_address': record.macAddress,
        'sink_id': record.sinkId,
        'type': record.type,
        'device_group': record.group,
        'delay_time': record.delayTime,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> scanDevices({Duration? timeout}) async {
    await Future<void>.delayed(timeout ?? const Duration(seconds: 2));
    _discoveredRecords
      ..clear()
      ..addAll(_generateDiscovered());
    
    // PARITY: Filter devices by name (matches reef-b-app's scanResult filtering)
    // Only include devices with names matching "koralDOSE", "coralDOSE", "koralLED", "coralLED"
    _discoveredRecords.removeWhere((record) {
      return !_matchesDeviceNameFilter(record.name);
    });
    
    _emitDiscovered();
    return _discoveredRecords
        .map((record) => record.toMap())
        .toList(growable: false);
  }

  /// Check if device name matches the filter criteria.
  /// 
  /// PARITY: Matches reef-b-app's BluetoothViewModel.scanResult() logic:
  /// - Returns false if name is null or empty
  /// - Returns true if name contains "koralDOSE", "coralDOSE", "koralLED", or "coralLED" (case-insensitive)
  bool _matchesDeviceNameFilter(String? deviceName) {
    if (deviceName == null || deviceName.isEmpty) {
      return false;
    }

    final lowerName = deviceName.toLowerCase();
    return lowerName.contains('koraldose') ||
        lowerName.contains('coraldose') ||
        lowerName.contains('koralled') ||
        lowerName.contains('coralled');
  }

  @override
  Future<List<Map<String, dynamic>>> listSavedDevices() async {
    await _initialize();
    return _savedSnapshot();
  }

  @override
  Stream<List<Map<String, dynamic>>> observeSavedDevices() =>
      _savedController.stream;

  @override
  Future<void> addSavedDevice(Map<String, dynamic> device) async {
    await _initialize();
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
      isFavorite: device['favorite'] == true || device['isFavorite'] == true,
      macAddress: device['macAddress']?.toString(),
      sinkId: device['sinkId']?.toString(),
      type: device['type']?.toString(),
      group: device['group']?.toString(),
      delayTime: device['delayTime'] is num ? (device['delayTime'] as num).round() : null,
    );
    if (index == -1) {
      _savedRecords.add(record);
      await _saveDeviceToDatabase(record);
    } else {
      _savedRecords[index] = record;
      await _updateDeviceInDatabase(record);
    }
    _emitSaved();
  }

  @override
  Future<void> removeSavedDevice(String deviceId) async {
    await _initialize();
    final int index = _indexOf(deviceId, allowMissing: true);
    if (index == -1) {
      return;
    }

    final _DeviceRecord record = _savedRecords[index];
    if (record.isMaster) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Cannot remove a master device from the registry.',
      );
    }

    _savedRecords.removeAt(index);
    await _deleteDeviceFromDatabase(deviceId);
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
    await _initialize();
    final int index = _indexOf(deviceId);
    final _DeviceRecord record = _savedRecords[index];
    if (record.state == 'connecting') {
      throw const AppError(
        code: AppErrorCode.deviceBusy,
        message: 'Device already connecting',
      );
    }

    final updated = record.copyWith(state: 'connected');
    _savedRecords[index] = updated;
    await _updateDeviceInDatabase(updated);
    _currentDeviceId = deviceId;
    _emitSaved();
  }

  @override
  Future<void> disconnect(String deviceId) async {
    await _initialize();
    final int index = _indexOf(deviceId);
    final updated = _savedRecords[index].copyWith(state: 'disconnected');
    _savedRecords[index] = updated;
    await _updateDeviceInDatabase(updated);
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
    await _initialize();
    final int index = _indexOf(deviceId);
    final updated = _savedRecords[index].copyWith(state: state);
    _savedRecords[index] = updated;
    await _updateDeviceInDatabase(updated);
    _emitSaved();
  }

  @override
  Stream<List<Map<String, dynamic>>> observeDevices() =>
      _discoveredController.stream;

  @override
  Future<Map<String, dynamic>?> getDevice(String deviceId) async {
    await _initialize();
    final int index = _indexOf(deviceId, allowMissing: true);
    if (index == -1) {
      return null;
    }
    return _savedRecords[index].toMap();
  }

  @override
  Future<String?> getDeviceState(String deviceId) async {
    await _initialize();
    final int index = _indexOf(deviceId, allowMissing: true);
    if (index == -1) {
      return null;
    }
    return _savedRecords[index].state;
  }

  @override
  Future<void> updateDeviceName(String deviceId, String name) async {
    await _initialize();
    if (name.trim().isEmpty) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Device name must not be empty',
      );
    }
    final int index = _indexOf(deviceId);
    final updated = _savedRecords[index].copyWith(name: name.trim());
    _savedRecords[index] = updated;
    await _updateDeviceInDatabase(updated);
    _emitSaved();
  }

  @override
  Future<void> toggleFavoriteDevice(String deviceId) async {
    await _initialize();
    final int index = _indexOf(deviceId);
    final _DeviceRecord record = _savedRecords[index];
    final updated = record.copyWith(isFavorite: !record.isFavorite);
    _savedRecords[index] = updated;
    await _updateDeviceInDatabase(updated);
    _emitSaved();
  }

  @override
  Future<bool> isDeviceFavorite(String deviceId) async {
    await _initialize();
    final int index = _indexOf(deviceId, allowMissing: true);
    if (index == -1) {
      return false;
    }
    return _savedRecords[index].isFavorite;
  }

  void _emitSaved() {
    if (!_savedController.isClosed) {
      _savedController.add(_savedSnapshot());
    }
    _syncDefaultSink();
  }

  void _emitDiscovered() {
    if (_discoveredController.isClosed) {
      return;
    }
    _discoveredController.add(
      _discoveredRecords
          .map((record) => record.toMap())
          .toList(growable: false),
    );
  }

  List<Map<String, dynamic>> _savedSnapshot() {
    return _savedRecords
        .map((record) => record.toMap())
        .toList(growable: false);
  }

  List<_DeviceRecord> _generateDiscovered() {
    final List<_DeviceRecord> generated = <_DeviceRecord>[];
    for (int i = 0; i < 3; i++) {
      generated.add(
        _DeviceRecord(
          id: 'reef-discovered-${DateTime.now().millisecondsSinceEpoch + i}',
          name: 'Nearby Device ${_random.nextInt(90) + 10}',
          rssi: (-45 - _random.nextInt(35)),
          state: 'disconnected',
          provisioned: false,
          isMaster: false,
        ).withRandomizedRssi(_random),
      );
    }
    return generated;
  }

  void _syncDefaultSink() {
    final SinkRepository? repository = _sinkRepository;
    if (repository == null) {
      return;
    }
    repository.upsertSink(
      Sink.defaultSink(
        _savedRecords.map((record) => record.id).toList(growable: false),
      ),
    );
  }

  int _indexOf(String deviceId, {bool allowMissing = false}) {
    final int index = _savedRecords.indexWhere(
      (record) => record.id == deviceId,
    );
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
  final bool isFavorite;
  final String? macAddress;
  final String? sinkId;
  final String? type; // 'LED' or 'DROP'
  final String? group; // 'A', 'B', 'C', 'D', 'E'
  final int? delayTime; // Delay time in seconds

  const _DeviceRecord({
    required this.id,
    required this.name,
    required this.rssi,
    required this.state,
    required this.provisioned,
    required this.isMaster,
    this.isFavorite = false,
    this.macAddress,
    this.sinkId,
    this.type,
    this.group,
    this.delayTime,
  });

  factory _DeviceRecord.fromMap(Map<String, dynamic> map) {
    return _DeviceRecord(
      id: map['id'] as String,
      name: map['name'] as String,
      rssi: map['rssi'] as int? ?? -65,
      state: map['state'] as String? ?? 'disconnected',
      provisioned: (map['provisioned'] as int? ?? 0) != 0,
      isMaster: (map['is_master'] as int? ?? 0) != 0,
      isFavorite: (map['is_favorite'] as int? ?? 0) != 0,
      macAddress: map['mac_address'] as String?,
      sinkId: map['sink_id'] as String?,
      type: map['type'] as String?,
      group: map['device_group'] as String?,
      delayTime: map['delay_time'] as int?,
    );
  }

  _DeviceRecord copyWith({
    String? id,
    String? name,
    int? rssi,
    String? state,
    bool? provisioned,
    bool? isMaster,
    bool? isFavorite,
    String? macAddress,
    String? sinkId,
    String? type,
    String? group,
    int? delayTime,
  }) {
    return _DeviceRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      state: state ?? this.state,
      provisioned: provisioned ?? this.provisioned,
      isMaster: isMaster ?? this.isMaster,
      isFavorite: isFavorite ?? this.isFavorite,
      macAddress: macAddress ?? this.macAddress,
      sinkId: sinkId ?? this.sinkId,
      type: type ?? this.type,
      group: group ?? this.group,
      delayTime: delayTime ?? this.delayTime,
    );
  }

  _DeviceRecord withRandomizedRssi(Random random) {
    final int delta = random.nextInt(10) - 5;
    final int next = (rssi + delta).clamp(-90, -40).toInt();
    return copyWith(rssi: next);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rssi': rssi,
      'favorite': isFavorite,
      'state': state,
      'provisioned': provisioned,
      'isMaster': isMaster,
      'macAddress': macAddress,
      'sinkId': sinkId,
      'type': type,
      'group': group,
      'delayTime': delayTime,
    };
  }
}
