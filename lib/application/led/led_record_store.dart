library;

import 'dart:async';

import '../../domain/led_lighting/led_record.dart';
import '../../domain/led_lighting/led_record_state.dart';

class LedRecordMemoryStore {
  LedRecordMemoryStore({
    Map<String, List<LedRecord>>? seedRecordsOverride,
    Map<String, Duration>? latencyOverrides,
  }) : _seedRecordsOverride = seedRecordsOverride ?? const {},
       _latencyOverrides = latencyOverrides ?? const {};

  final Map<String, List<LedRecord>> _seedRecordsOverride;
  final Map<String, Duration> _latencyOverrides;
  final Map<String, _LedRecordDeviceState> _devices = {};

  Stream<LedRecordState> observe(String deviceId) =>
      _ensureDevice(deviceId).stream;

  LedRecordState snapshot(String deviceId) => _ensureDevice(deviceId).state;

  Future<LedRecordState> refresh(String deviceId) async {
    final _LedRecordDeviceState device = _ensureDevice(deviceId);
    device.emit(
      device.state.copyWith(
        status: LedRecordStatus.applying,
        previewingRecordId: null,
      ),
    );
    await Future<void>.delayed(device.latency);
    final LedRecordState refreshed = LedRecordState(
      deviceId: deviceId,
      status: LedRecordStatus.idle,
      previewingRecordId: null,
      records: _seedRecords(deviceId),
    );
    device.emit(refreshed);
    return refreshed;
  }

  Future<LedRecordState> deleteRecord(String deviceId, String recordId) async {
    final _LedRecordDeviceState device = _ensureDevice(deviceId);
    if (!device.containsRecord(recordId)) {
      return device.state;
    }

    device.emit(
      device.state.copyWith(
        status: LedRecordStatus.applying,
        previewingRecordId: device.state.previewingRecordId,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 180));

    final List<LedRecord> updated = device.state.records
        .where((record) => record.id != recordId)
        .map((record) => record.copyWith())
        .toList(growable: false);

    final LedRecordState next = device.state.copyWith(
      status: LedRecordStatus.idle,
      previewingRecordId: device.state.previewingRecordId == recordId
          ? null
          : device.state.previewingRecordId,
      records: updated,
    );
    device.emit(next);
    return next;
  }

  Future<LedRecordState> clearRecords(String deviceId) async {
    final _LedRecordDeviceState device = _ensureDevice(deviceId);
    if (device.state.records.isEmpty) {
      return device.state;
    }

    device.emit(
      device.state.copyWith(
        status: LedRecordStatus.applying,
        previewingRecordId: null,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final LedRecordState next = device.state.copyWith(
      status: LedRecordStatus.idle,
      previewingRecordId: null,
      records: const <LedRecord>[],
    );
    device.emit(next);
    return next;
  }

  Future<LedRecordState> startPreview(
    String deviceId, {
    String? recordId,
  }) async {
    final _LedRecordDeviceState device = _ensureDevice(deviceId);
    final String? resolvedRecordId =
        recordId ??
        (device.state.records.isEmpty ? null : device.state.records.first.id);

    final LedRecordState next = device.state.copyWith(
      status: LedRecordStatus.previewing,
      previewingRecordId: resolvedRecordId,
    );
    device.emit(next);
    return next;
  }

  Future<LedRecordState> stopPreview(String deviceId) async {
    final _LedRecordDeviceState device = _ensureDevice(deviceId);
    final LedRecordState next = device.state.copyWith(
      status: LedRecordStatus.idle,
      previewingRecordId: null,
    );
    device.emit(next);
    return next;
  }

  _LedRecordDeviceState _ensureDevice(String deviceId) {
    if (_devices.containsKey(deviceId)) {
      return _devices[deviceId]!;
    }

    final Duration latency =
        _latencyOverrides[deviceId] ??
        _seedCatalog[deviceId]?.latency ??
        _seedCatalog['default']!.latency;
    final List<LedRecord> seeds = _seedRecords(deviceId);

    final _LedRecordDeviceState deviceState = _LedRecordDeviceState(
      deviceId: deviceId,
      latency: latency,
      records: seeds,
    );
    _devices[deviceId] = deviceState;
    return deviceState;
  }

  List<LedRecord> _seedRecords(String deviceId) {
    final List<LedRecord>? override = _seedRecordsOverride[deviceId];
    if (override != null) {
      return override
          .map((record) => record.copyWith())
          .toList(growable: false);
    }

    final _RecordSeedBundle bundle =
        _seedCatalog[deviceId] ?? _seedCatalog['default']!;
    return bundle.records
        .map(
          (seed) => LedRecord(
            id: _recordId(seed.hour, seed.minute),
            minutesFromMidnight: _minutes(seed.hour, seed.minute),
            channelLevels: seed.channelLevels,
          ),
        )
        .toList(growable: false);
  }
}

class _LedRecordDeviceState {
  _LedRecordDeviceState({
    required this.deviceId,
    required List<LedRecord> records,
    required this.latency,
  }) : _controller = StreamController<LedRecordState>.broadcast(),
       state = LedRecordState(
         deviceId: deviceId,
         status: LedRecordStatus.idle,
         previewingRecordId: null,
         records: records,
       ) {
    _controller.add(state);
  }

  final String deviceId;
  final Duration latency;
  final StreamController<LedRecordState> _controller;
  LedRecordState state;

  Stream<LedRecordState> get stream => _controller.stream;

  void emit(LedRecordState next) {
    state = next;
    _controller.add(state);
  }

  bool containsRecord(String recordId) =>
      state.records.any((record) => record.id == recordId);
}

class _RecordSeedBundle {
  final Duration latency;
  final List<_RecordSeed> records;

  const _RecordSeedBundle({required this.latency, required this.records});
}

class _RecordSeed {
  final int hour;
  final int minute;
  final Map<String, int> channelLevels;

  const _RecordSeed({
    required this.hour,
    required this.minute,
    required this.channelLevels,
  });
}

int _minutes(int hour, int minute) => hour * 60 + minute;
String _recordId(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

Map<String, int> _levels({
  int coldWhite = 0,
  int royalBlue = 0,
  int blue = 0,
  int red = 0,
  int green = 0,
  int purple = 0,
  int uv = 0,
  int warmWhite = 0,
  int moonLight = 0,
}) {
  return <String, int>{
    'coldWhite': coldWhite,
    'royalBlue': royalBlue,
    'blue': blue,
    'red': red,
    'green': green,
    'purple': purple,
    'uv': uv,
    'warmWhite': warmWhite,
    'moonLight': moonLight,
  };
}

final Map<String, _RecordSeedBundle> _seedCatalog = <String, _RecordSeedBundle>{
  'default': _RecordSeedBundle(
    latency: const Duration(milliseconds: 160),
    records: <_RecordSeed>[
      _RecordSeed(hour: 0, minute: 0, channelLevels: _levels(moonLight: 10)),
      _RecordSeed(
        hour: 6,
        minute: 0,
        channelLevels: _levels(
          coldWhite: 15,
          royalBlue: 25,
          blue: 20,
          moonLight: 5,
        ),
      ),
      _RecordSeed(
        hour: 9,
        minute: 0,
        channelLevels: _levels(
          coldWhite: 45,
          royalBlue: 55,
          blue: 50,
          green: 15,
          red: 12,
        ),
      ),
      _RecordSeed(
        hour: 13,
        minute: 0,
        channelLevels: _levels(
          coldWhite: 75,
          royalBlue: 85,
          blue: 80,
          green: 30,
          red: 28,
          purple: 20,
          uv: 18,
          warmWhite: 40,
        ),
      ),
      _RecordSeed(
        hour: 18,
        minute: 30,
        channelLevels: _levels(
          coldWhite: 40,
          royalBlue: 50,
          blue: 45,
          green: 20,
          red: 18,
          moonLight: 8,
        ),
      ),
      _RecordSeed(
        hour: 21,
        minute: 30,
        channelLevels: _levels(
          coldWhite: 10,
          royalBlue: 20,
          blue: 18,
          moonLight: 12,
        ),
      ),
    ],
  ),
  'lagoon_x2': _RecordSeedBundle(
    latency: const Duration(milliseconds: 140),
    records: <_RecordSeed>[
      _RecordSeed(hour: 0, minute: 0, channelLevels: _levels(moonLight: 6)),
      _RecordSeed(
        hour: 7,
        minute: 15,
        channelLevels: _levels(coldWhite: 20, royalBlue: 35, blue: 30, red: 8),
      ),
      _RecordSeed(
        hour: 11,
        minute: 45,
        channelLevels: _levels(
          coldWhite: 65,
          royalBlue: 80,
          blue: 78,
          green: 22,
          red: 20,
          purple: 14,
          uv: 12,
          warmWhite: 35,
        ),
      ),
      _RecordSeed(
        hour: 16,
        minute: 30,
        channelLevels: _levels(
          coldWhite: 55,
          royalBlue: 70,
          blue: 68,
          green: 24,
          red: 18,
          moonLight: 4,
        ),
      ),
      _RecordSeed(
        hour: 20,
        minute: 0,
        channelLevels: _levels(
          coldWhite: 18,
          royalBlue: 32,
          blue: 28,
          moonLight: 10,
        ),
      ),
    ],
  ),
};
