library;

import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../application/common/app_error.dart';
import '../../application/common/app_error_code.dart';
import '../../domain/led_lighting/led_record.dart';
import '../../domain/led_lighting/led_record_state.dart';
import '../../domain/led_lighting/led_state.dart';
import '../../domain/led_lighting/scene_catalog.dart';
import '../../infrastructure/ble/ble_adapter.dart';
import '../../infrastructure/ble/ble_notify_bus.dart';
import '../../infrastructure/ble/led/led_command_builder.dart';
import '../../infrastructure/ble/platform_channels/ble_notify_packet.dart';
import '../../infrastructure/ble/transport/ble_transport_models.dart';
import '../../platform/contracts/led_record_repository.dart';
import '../../platform/contracts/led_repository.dart';

/// BLE-backed LED repository that bridges both [LedRepository] and
/// [LedRecordRepository]. This implementation intentionally keeps the API
/// surface identical to the existing use cases so controllers do not need to
/// change while we migrate the data source to BLE.
class BleLedRepositoryImpl extends LedRepository
    implements LedRecordRepository {
  // Opcodes mirror reef-b-app; keep aligned with Android CommandManager.
  static const int _opcodeSyncStart = 0x21; // START / RETURN / END sequence
  static const int _opcodeReturnRecord = 0x23;
  static const int _opcodeReturnPresetScene = 0x24;
  static const int _opcodeReturnCustomScene = 0x25;
  static const int _opcodeReturnSchedule = 0x26;
  static const int _opcodeUsePresetScene = 0x28;
  static const int _opcodeUseCustomScene = 0x29;
  static const int _opcodePreviewAck = 0x2A;
  static const int _opcodeMutationAck = 0x2F; // delete/clear/set/start acks
  static const int _opcodeClearRecordsAck = 0x30;
  static const int _opcodeChannelLevels = 0x33;
  static const int _opcodeSyncEnd = 0xFF;
  BleLedRepositoryImpl({
    required BleAdapter bleAdapter,
    LedCommandBuilder? commandBuilder,
    Stream<BleNotifyPacket>? notifyStream,
    Stream<BleConnectionState>? connectionStream,
    BleWriteOptions? writeOptions,
  }) : _bleAdapter = bleAdapter,
       _commandBuilder = commandBuilder ?? const LedCommandBuilder(),
       _writeOptions = writeOptions ?? const BleWriteOptions() {
    _notifySubscription = (notifyStream ?? BleNotifyBus.instance.stream).listen(
      _handlePacket,
      onError: _handleNotifyError,
    );
    _connectionSubscription = (connectionStream ?? bleAdapter.connectionState)
        .listen(_handleConnectionState);
  }

  final BleAdapter _bleAdapter;
  final LedCommandBuilder _commandBuilder;
  final BleWriteOptions _writeOptions;
  final Map<String, _DeviceSession> _sessions = <String, _DeviceSession>{};
  StreamSubscription<BleNotifyPacket>? _notifySubscription;
  StreamSubscription<BleConnectionState>? _connectionSubscription;

  // ---------------------------------------------------------------------------
  // LedRepository
  // ---------------------------------------------------------------------------
  @override
  Stream<LedState> observeLedState(String deviceId) {
    final _DeviceSession session = _ensureSession(deviceId);
    session.ensureProcessing(_processQueue);
    return session.ledStateStream;
  }

  @override
  Future<LedState?> getLedState(String deviceId) async {
    final _DeviceSession session = _ensureSession(deviceId);
    return session.cache.snapshotState();
  }

  @override
  Future<LedState> updateStatus({
    required String deviceId,
    required LedStatus status,
  }) async {
    final _DeviceSession session = _ensureSession(deviceId);
    session.cache.status = status;
    _emitLedState(session);
    return session.cache.snapshotState();
  }

  @override
  Future<LedState> applyScene({
    required String deviceId,
    required String sceneId,
  }) async {
    final _DeviceSession session = _ensureSession(deviceId);
    final _SceneApplicationContext context = _resolveSceneContext(
      session.cache,
      sceneId,
    );
    session.cache.status = LedStatus.applying;
    session.cache.pendingSceneId = context.sceneId;
    session.cache.pendingPresetSceneCode = context.presetCode;
    session.cache.pendingCustomSceneChannels = context.channelLevels;
    final Uint8List command = context.isPreset
        ? _commandBuilder.usePresetScene(context.presetCode!)
        : _commandBuilder.useCustomScene(context.channelLevels!);
    await _sendCommand(deviceId, command);
    return session.cache.snapshotState();
  }

  @override
  Future<LedState> applySchedule({
    required String deviceId,
    required String scheduleId,
  }) async {
    final _DeviceSession session = _ensureSession(deviceId);
    session.cache.status = LedStatus.applying;
    _emitLedState(session);
    // TODO: Encode schedule payload once schedule builder parity is ready.
    await _sendCommand(deviceId, _commandBuilder.syncInformation());
    session.cache.pendingScheduleId = scheduleId;
    return session.cache.snapshotState();
  }

  @override
  Future<LedState> resetToDefault(String deviceId) async {
    final _DeviceSession session = _ensureSession(deviceId);
    session.cache.status = LedStatus.syncing;
    _emitLedState(session);
    await _sendCommand(deviceId, _commandBuilder.resetLed());
    session.cache.invalidate();
    _requestSync(session);
    return session.cache.snapshotState();
  }

  @override
  Future<LedState> setChannelLevels({
    required String deviceId,
    required Map<String, int> channelLevels,
  }) async {
    final _DeviceSession session = _ensureSession(deviceId);
    session.cache.channelLevels = Map<String, int>.from(channelLevels);
    session.cache.status = LedStatus.applying;
    _emitLedState(session);
    await _sendCommand(deviceId, _commandBuilder.dimming(channelLevels));
    return session.cache.snapshotState();
  }

  // ---------------------------------------------------------------------------
  // LedRecordRepository
  // ---------------------------------------------------------------------------
  @override
  Stream<LedRecordState> observeState(String deviceId) {
    final _DeviceSession session = _ensureSession(deviceId);
    session.ensureProcessing(_processQueue);
    return session.recordStateStream;
  }

  @override
  Future<LedRecordState> getState(String deviceId) async {
    final _DeviceSession session = _ensureSession(deviceId);
    return session.cache.snapshotRecords();
  }

  @override
  Future<LedRecordState> refresh(String deviceId) async {
    final _DeviceSession session = _ensureSession(deviceId);
    _requestSync(session);
    return session.cache.snapshotRecords();
  }

  @override
  Future<LedRecordState> deleteRecord({
    required String deviceId,
    required String recordId,
  }) async {
    final _DeviceSession session = _ensureSession(deviceId);
    session.cache.recordStatus = LedRecordStatus.applying;
    _emitRecordState(session);
    final LedRecord? target = session.cache.findRecord(recordId);
    if (target == null) {
      throw StateError('Record "$recordId" not found for $deviceId.');
    }
    session.cache.pendingRecordId = recordId;
    final Future<void> mutationFuture =
        session.beginRecordMutation(_deleteRecordErrorMessage);
    try {
      await _sendCommand(
        deviceId,
        _commandBuilder.deleteRecord(
          hour: target.hour,
          minute: target.minute,
        ),
      );
    } catch (error) {
      session.failRecordMutation();
      rethrow;
    }
    await mutationFuture;
    return session.cache.snapshotRecords();
  }

  @override
  Future<LedRecordState> clearRecords(String deviceId) async {
    final _DeviceSession session = _ensureSession(deviceId);
    session.cache.recordStatus = LedRecordStatus.applying;
    session.cache.pendingClearRecords = true;
    _emitRecordState(session);
    final Future<void> mutationFuture =
        session.beginRecordMutation(_clearRecordsErrorMessage);
    try {
      await _sendCommand(deviceId, _commandBuilder.clearRecords());
    } catch (error) {
      session.failRecordMutation();
      rethrow;
    }
    await mutationFuture;
    return session.cache.snapshotRecords();
  }

  @override
  Future<LedRecordState> startPreview({
    required String deviceId,
    String? recordId,
  }) async {
    final _DeviceSession session = _ensureSession(deviceId);
    session.cache.previewingRecordId = recordId;
    session.cache.recordStatus = LedRecordStatus.previewing;
    _emitRecordState(session);
    await _sendCommand(deviceId, _commandBuilder.preview(start: true));
    return session.cache.snapshotRecords();
  }

  @override
  Future<LedRecordState> stopPreview(String deviceId) async {
    final _DeviceSession session = _ensureSession(deviceId);
    session.cache.recordStatus = LedRecordStatus.idle;
    session.cache.previewingRecordId = null;
    _emitRecordState(session);
    await _sendCommand(deviceId, _commandBuilder.preview(start: false));
    return session.cache.snapshotRecords();
  }

  // ---------------------------------------------------------------------------
  // Internal orchestration
  // ---------------------------------------------------------------------------
  _DeviceSession _ensureSession(String deviceId) {
    return _sessions.putIfAbsent(deviceId, () {
      final _DeviceSession session = _DeviceSession(deviceId: deviceId);
      session.ensureProcessing(_processQueue);
      _requestSync(session);
      return session;
    });
  }

  void _handlePacket(BleNotifyPacket packet) {
    final _DeviceSession session = _ensureSession(packet.deviceId);
    session.enqueue(packet);
  }

  void _handleNotifyError(Object error, StackTrace stackTrace) {
    // TODO: Surface BLE errors via cache + state emit.
  }

  void _handleConnectionState(BleConnectionState state) {
    final String? deviceId = state.deviceId;
    if (deviceId == null || deviceId.isEmpty) {
      return;
    }
    final _DeviceSession session = _ensureSession(deviceId);
    if (state.isDisconnected) {
      session.cache.invalidate();
      session.syncInFlight = false;
      session.activeSync = null;
      _emitLedState(session);
      _emitRecordState(session);
      return;
    }
    if (state.isConnected) {
      // Guard against overlapping syncs by resetting activeSync.
      session.activeSync = null;
      session.syncInFlight = false;
      _requestSync(session);
    }
  }

  void _requestSync(_DeviceSession session) {
    if (session.syncInFlight) {
      return;
    }
    if (!session.cache.beginSync()) {
      session.syncInFlight = false;
      return;
    }
    session.syncInFlight = true;
    session.activeSync = null;
    _sendCommand(session.deviceId, _commandBuilder.syncInformation());
  }

  Future<void> _processQueue(_DeviceSession session) async {
    await for (final BleNotifyPacket packet in session.queue) {
      _handleDevicePacket(session, packet);
    }
  }

  void _handleDevicePacket(_DeviceSession session, BleNotifyPacket packet) {
    final Uint8List data = packet.payload;
    if (data.isEmpty) {
      return;
    }
    if (!session.cache.isValid && !session.cache.isSyncing) {
      session.syncInFlight = false;
      return;
    }
    final int opcode = data[0] & 0xFF;
    session.activeSync ??= _SyncSession(deviceId: session.deviceId);

    switch (opcode) {
      case _opcodeSyncStart:
        session.activeSync!.begin();
        session.cache.status = LedStatus.syncing;
        session.cache.recordStatus = LedRecordStatus.idle;
        session.cache.handleSyncStart();
        break;
      case _opcodeReturnPresetScene:
        _handleSceneReturn(session, data, isCustom: false);
        break;
      case _opcodeReturnCustomScene:
        _handleSceneReturn(session, data, isCustom: true);
        break;
      case _opcodeReturnRecord:
        _handleRecordReturn(session, data);
        break;
      case _opcodeReturnSchedule:
        _handleScheduleReturn(session, data);
        break;
      case _opcodeUsePresetScene:
        _handlePresetSceneAck(session, data);
        break;
      case _opcodeUseCustomScene:
        _handleCustomSceneAck(session, data);
        break;
      case _opcodePreviewAck:
        _handlePreviewAck(session, data);
        break;
      case _opcodeMutationAck:
        _handleDeleteRecordAck(session, data);
        break;
      case _opcodeClearRecordsAck:
        _handleClearRecordsAck(session, data);
        break;
      case _opcodeChannelLevels:
        _handleChannelLevels(session, data);
        break;
      case _opcodeSyncEnd:
        _finalizeSync(session);
        break;
  }


  void _handleSceneReturn(
    _DeviceSession session,
    Uint8List data, {
    required bool isCustom,
  }) {
    final LedStateScene? scene = _parseSceneReturn(
      session,
      data,
      isCustom: isCustom,
    );
    if (scene == null) {
      return;
    }
    final _SyncSession? sync = session.activeSync;
    if (sync != null) {
      sync.upsertScene(scene);
    } else {
      session.cache.saveScene(scene);
    }
    if (isCustom) {
      session.cache.setMode(LedMode.customScene);
      session.cache.customSceneChannels = scene.channelLevels;
    } else if (scene.presetCode != null) {
      session.cache.setMode(LedMode.presetScene);
      session.cache.presetSceneCode = scene.presetCode;
    }
  }

  LedStateScene? _parseSceneReturn(
    _DeviceSession session,
    Uint8List data, {
    required bool isCustom,
  }) {
    if (isCustom) {
      if (data.length != 12) {
        return null;
      }
      final Map<String, int> channels =
          _decodeChannelPayload(data.sublist(2, 11));
      final LedStateScene? existing =
          session.cache.findSceneByChannels(channels);
      if (existing != null) {
        return existing.copyWith(channelLevels: channels);
      }
      return LedStateScene(
        sceneId: _deriveCustomSceneId(channels),
        name: _defaultCustomSceneName,
        channelLevels: channels,
        iconKey: _customSceneIconKey,
      );
    }
    if (data.length != 4) {
      return null;
    }
    final int code = data[2] & 0xFF;
    final LedStateScene? catalogScene = SceneCatalog.findByCode(code);
    if (catalogScene != null) {
      return catalogScene;
    }
    return LedStateScene(
      sceneId: _derivePresetSceneId(code),
      name: _presetSceneName(code),
      channelLevels: const <String, int>{},
      presetCode: code,
    );
  }
  void _handleRecordReturn(_DeviceSession session, Uint8List data) {
    final LedRecord? record = _parseRecordReturn(data);
    if (record == null) {
      return;
    }
    final _SyncSession? sync = session.activeSync;
    if (sync != null) {
      sync.upsertRecord(record);
    } else {
      session.cache.saveRecord(record);
      _rebuildSchedulesFromRecords(session.cache);
      _emitRecordState(session);
    }
    if (session.cache.mode == LedMode.none) {
      session.cache.setMode(LedMode.record);
    }
  }

  void _handleScheduleReturn(_DeviceSession session, Uint8List data) {
    final LedStateSchedule? schedule = _parseScheduleReturn(data);
    if (schedule != null) {
      session.activeSync?.schedules.add(schedule);
    }
  }

  LedStateSchedule? _parseScheduleReturn(Uint8List data) {
    // TODO: Map schedule payload fields per reef-b-app (see Android LedSyncInformationCommand schedule parsing).
    // Expected fields: scheduleId/code, enabled flag, window start/end minutes, recurrence label, channel levels.
    // Return null until mapping is aligned with reef-b-app.
    if (data.length < 2) {
      return null;
    }
    // Capture raw bytes for debugging parity; do not fabricate schedule.
    final String rawId = data
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    // TODO: Replace with real parsing once reef-b-app mapping is confirmed.
    return LedStateSchedule(
      scheduleId: rawId,
      enabled: false,
      window: const LedScheduleWindow(
        startMinutesFromMidnight: 0,
        endMinutesFromMidnight: 0,
        recurrenceLabel: 'TODO',
      ),
      channelLevels: const <String, int>{},
    );
  }

  LedRecord? _parseRecordReturn(Uint8List data) {
    if (data.length != 14) {
      return null;
    }
    final int hour = data[2] & 0xFF;
    final int minute = data[3] & 0xFF;
    if (hour >= 24 || minute >= 60) {
      return null;
    }
    final int minutesFromMidnight = hour * 60 + minute;
    final Map<String, int> channels =
        _decodeChannelPayload(data.sublist(4, 13));
    return LedRecord(
      id: _recordIdForMinutes(minutesFromMidnight),
      minutesFromMidnight: minutesFromMidnight,
      channelLevels: channels,
    );
  }

  void _handlePreviewAck(_DeviceSession session, Uint8List data) {
    if (data.length != 4) {
      return;
    }
    final int state = data[2] & 0xFF;
    switch (state) {
      case 0x00:
        session.cache.recordStatus = LedRecordStatus.error;
        session.cache.previewingRecordId = null;
        break;
      case 0x01:
        session.cache.recordStatus = LedRecordStatus.previewing;
        break;
      case 0x02:
        session.cache.recordStatus = LedRecordStatus.idle;
        session.cache.previewingRecordId = null;
        break;
    }
    _emitRecordState(session);
  }

  void _handleDeleteRecordAck(_DeviceSession session, Uint8List data) {
    if (data.length != 4) {
      return;
    }
    final int result = data[2] & 0xFF;
    if (result == 0x01) {
      final String? recordId = session.cache.pendingRecordId;
      if (recordId != null) {
        session.cache.removeRecord(recordId);
        if (session.cache.previewingRecordId == recordId) {
          session.cache.previewingRecordId = null;
        }
        session.cache.pendingRecordId = null;
      }
      session.cache.recordStatus = LedRecordStatus.idle;
      _rebuildSchedulesFromRecords(session.cache);
      session.resolveRecordMutationSuccess();
    } else {
      session.cache.recordStatus = LedRecordStatus.error;
      session.resolveRecordMutationFailure();
    }
    _emitRecordState(session);
  }

  void _handleClearRecordsAck(_DeviceSession session, Uint8List data) {
    if (data.length != 4) {
      return;
    }
    final int result = data[2] & 0xFF;
    if (result == 0x01) {
      session.cache.clearRecords();
      session.cache.recordStatus = LedRecordStatus.idle;
      session.cache.previewingRecordId = null;
      _rebuildSchedulesFromRecords(session.cache);
      session.resolveRecordMutationSuccess();
    } else {
      session.cache.recordStatus = LedRecordStatus.error;
      session.resolveRecordMutationFailure();
    }
    session.cache.pendingClearRecords = false;
    _emitRecordState(session);
  }

  void _handleChannelLevels(_DeviceSession session, Uint8List data) {
    // TODO: Parse channel levels payload per reef-b-app.
    // Do not emit immediately; buffer and apply on END to mirror Android.
    session.activeSync?.pendingChannels = const <String, int>{};
  }

  void _handlePresetSceneAck(_DeviceSession session, Uint8List data) {
    if (data.length != 4) {
      return;
    }
    final bool success = (data[2] & 0xFF) == 0x01;
    session.cache.status = success ? LedStatus.idle : LedStatus.error;
    if (success) {
      final int? presetCode = session.cache.pendingPresetSceneCode;
      session.cache.setMode(LedMode.presetScene);
      session.cache.presetSceneCode = presetCode;
      final String? preferredId = session.cache.pendingSceneId;
      final LedStateScene? scene = presetCode == null
          ? null
          : session.cache.findSceneByPreset(presetCode) ??
              SceneCatalog.findByCode(presetCode);
      if (scene != null) {
        session.cache.activeSceneId = scene.sceneId;
        session.cache.saveScene(scene);
        if (scene.channelLevels.isNotEmpty) {
          session.cache.applyChannels(scene.channelLevels);
        }
      } else if (presetCode != null) {
        session.cache.activeSceneId =
            preferredId ?? _derivePresetSceneId(presetCode);
      }
      session.cache.activeScheduleId = null;
    }
    session.cache.pendingSceneId = null;
    session.cache.pendingPresetSceneCode = null;
    session.cache.pendingCustomSceneChannels = null;
    _emitLedState(session);
  }

  void _handleCustomSceneAck(_DeviceSession session, Uint8List data) {
    if (data.length != 4) {
      return;
    }
    final bool success = (data[2] & 0xFF) == 0x01;
    session.cache.status = success ? LedStatus.idle : LedStatus.error;
    if (success) {
      final Map<String, int>? channels =
          session.cache.pendingCustomSceneChannels;
      if (channels != null) {
        final String sceneId =
            session.cache.pendingSceneId ?? _deriveCustomSceneId(channels);
        final LedStateScene? existing = session.cache.findScene(sceneId);
        final LedStateScene scene =
            existing?.copyWith(channelLevels: channels) ??
            LedStateScene(
              sceneId: sceneId,
              name: _defaultCustomSceneName,
              channelLevels: channels,
              iconKey: existing?.iconKey ?? _customSceneIconKey,
            );
        session.cache.setMode(LedMode.customScene);
        session.cache.customSceneChannels = channels;
        session.cache.activeSceneId = scene.sceneId;
        session.cache.activeScheduleId = null;
        session.cache.saveScene(scene);
        session.cache.applyChannels(channels);
      }
    }
    session.cache.pendingSceneId = null;
    session.cache.pendingPresetSceneCode = null;
    session.cache.pendingCustomSceneChannels = null;
    _emitLedState(session);
  }

  void _reconcileSceneStateFromSync(_DeviceSession session) {
    switch (session.cache.mode) {
      case LedMode.presetScene:
        final int? presetCode = session.cache.presetSceneCode;
        if (presetCode != null) {
          final LedStateScene? scene = session.cache.findSceneByPreset(
            presetCode,
          ) ?? SceneCatalog.findByCode(presetCode);
          session.cache.activeSceneId =
              scene?.sceneId ?? _derivePresetSceneId(presetCode);
          session.cache.activeScheduleId = null;
          if (scene != null && scene.channelLevels.isNotEmpty) {
            session.cache.applyChannels(scene.channelLevels);
          }
        }
        break;
      case LedMode.customScene:
        final Map<String, int>? channels = session.cache.customSceneChannels;
        if (channels != null) {
          final LedStateScene? existing = session.cache.findSceneByChannels(
            channels,
          );
          final LedStateScene scene =
              existing?.copyWith(channelLevels: channels) ??
              LedStateScene(
                sceneId: _deriveCustomSceneId(channels),
                name: _defaultCustomSceneName,
                channelLevels: channels,
              );
          session.cache.saveScene(scene);
          session.cache.activeSceneId = scene.sceneId;
          session.cache.activeScheduleId = null;
          session.cache.applyChannels(channels);
        }
        break;
      case LedMode.record:
      case LedMode.none:
        break;
    }
  }

  void _finalizeSync(_DeviceSession session) {
    final _SyncSession? sync = session.activeSync;
    if (sync == null) {
      return;
    }
    if (sync.scenes.isNotEmpty) {
      session.cache.scenes = List<LedStateScene>.unmodifiable(sync.scenes);
    }
    final List<LedStateSchedule> scheduleSource = sync.schedules.isNotEmpty
        ? sync.schedules
        : _deriveSchedulesFromRecords(sync.records);
    if (scheduleSource.isNotEmpty) {
      session.cache.schedules = List<LedStateSchedule>.unmodifiable(
        scheduleSource,
      );
      if (session.cache.pendingScheduleId != null) {
        final String pendingId = session.cache.pendingScheduleId!;
        final bool exists = scheduleSource.any(
          (s) => s.scheduleId == pendingId,
        );
        if (exists) {
          session.cache.activeScheduleId = pendingId;
          session.cache.activeSceneId = null;
        }
      }
    }
    if (sync.records.isNotEmpty) {
      sync.records.sort(
        (LedRecord a, LedRecord b) =>
            a.minutesFromMidnight.compareTo(b.minutesFromMidnight),
      );
      session.cache.records = List<LedRecord>.unmodifiable(sync.records);
      session.cache.recordStatus = LedRecordStatus.idle;
      session.cache.pendingRecordId = null;
      session.cache.pendingClearRecords = false;
      session.cache.previewingRecordId = null;
    }
    _reconcileSceneStateFromSync(session);
    session.cache.finishSync();
    session.syncInFlight = false;
    if (sync.pendingChannels != null) {
      session.cache.applyChannels(sync.pendingChannels!);
    }
    session.activeSync = null;
    _emitLedState(session);
    _emitRecordState(session);
  }

  void _finalizeMutation(_DeviceSession session) {
    // TODO: Align with reef-b-app acks (delete/clear/record changes).
    session.syncInFlight = false;
    _emitLedState(session);
    _emitRecordState(session);
  }

  Future<void> _sendCommand(String deviceId, Uint8List payload) {
    return _bleAdapter.writeBytes(
      deviceId: deviceId,
      data: payload,
      options: _writeOptions,
    );
  }

  void _emitLedState(_DeviceSession session) {
    session.ledStateController.add(session.cache.snapshotState());
  }

  void _emitRecordState(_DeviceSession session) {
    session.recordStateController.add(session.cache.snapshotRecords());
  }
}

class _DeviceSession {
  _DeviceSession({required this.deviceId})
    : cache = _LedInformationCache(deviceId: deviceId),
      ledStateController = StreamController<LedState>.broadcast(),
      recordStateController = StreamController<LedRecordState>.broadcast(),
      _queue = StreamController<BleNotifyPacket>(sync: true) {
    ledStateController.onListen = () {
      ledStateController.add(cache.snapshotState());
    };
    recordStateController.onListen = () {
      recordStateController.add(cache.snapshotRecords());
    };
  }

  final String deviceId;
  final _LedInformationCache cache;
  final StreamController<LedState> ledStateController;
  final StreamController<LedRecordState> recordStateController;
  final StreamController<BleNotifyPacket> _queue;
  _SyncSession? activeSync;
  Future<void>? _processing;
  bool syncInFlight = false;
  _RecordMutationTracker? _recordMutation;

  Stream<BleNotifyPacket> get queue => _queue.stream;
  Stream<LedState> get ledStateStream => ledStateController.stream;
  Stream<LedRecordState> get recordStateStream => recordStateController.stream;
  StreamController<LedState> get ledStateSink => ledStateController;
  StreamController<LedRecordState> get recordStateSink => recordStateController;

  void enqueue(BleNotifyPacket packet) {
    _queue.add(packet);
  }

  void ensureProcessing(Future<void> Function(_DeviceSession) runner) {
    _processing ??= runner(this);
  }

  Future<void> beginRecordMutation(String description) {
    final _RecordMutationTracker tracker = _RecordMutationTracker(description);
    _recordMutation?.completeError(AppErrorCode.transportError);
    _recordMutation = tracker;
    return tracker.future;
  }

  void resolveRecordMutationSuccess() {
    _recordMutation?.complete();
    _recordMutation = null;
  }

  void resolveRecordMutationFailure([AppErrorCode code = AppErrorCode.transportError]) {
    _recordMutation?.completeError(code);
    _recordMutation = null;
  }

  void failRecordMutation() {
    resolveRecordMutationFailure(AppErrorCode.transportError);
  }
}

class _LedInformationCache {
  _LedInformationCache({required this.deviceId})
    : status = LedStatus.idle,
      mode = LedMode.none,
      channelLevels = <String, int>{},
      scenes = const <LedStateScene>[],
      schedules = const <LedStateSchedule>[],
      records = const <LedRecord>[],
      recordStatus = LedRecordStatus.idle,
      pendingClearRecords = false,
      lastUpdated = DateTime.now();

  final String deviceId;
  LedStatus status;
  LedMode mode;
  bool isValid = false;
  bool isSyncing = false;
  String? activeSceneId;
  String? activeScheduleId;
  Map<String, int> channelLevels;
  List<LedStateScene> scenes;
  List<LedStateSchedule> schedules;
  List<LedRecord> records;
  LedRecordStatus recordStatus;
  String? previewingRecordId;
  String? pendingSceneId;
  String? pendingScheduleId;
  String? pendingRecordId;
  int? presetSceneCode;
  Map<String, int>? customSceneChannels;
  int? pendingPresetSceneCode;
  Map<String, int>? pendingCustomSceneChannels;
  bool pendingClearRecords;
  DateTime lastUpdated;

  LedState snapshotState() {
    return LedState(
      deviceId: deviceId,
      status: status,
      mode: mode,
      activeSceneId: activeSceneId,
      activeScheduleId: activeScheduleId,
      channelLevels: channelLevels,
      scenes: scenes,
      schedules: schedules,
    );
  }

  LedRecordState snapshotRecords() {
    final List<LedRecord> decorated = records
        .map(
          (record) => record.copyWith(
            isPreviewing: previewingRecordId == record.id,
          ),
        )
        .toList(growable: false);
    return LedRecordState(
      deviceId: deviceId,
      status: recordStatus,
      previewingRecordId: previewingRecordId,
      records: decorated,
    );
  }

  bool beginSync() {
    if (isSyncing) {
      return false;
    }
    isSyncing = true;
    status = LedStatus.syncing;
    return true;
  }

  void finishSync() {
    isSyncing = false;
    isValid = true;
    status = LedStatus.idle;
    lastUpdated = DateTime.now();
    pendingSceneId = null;
    pendingScheduleId = null;
    pendingPresetSceneCode = null;
    pendingCustomSceneChannels = null;
    pendingRecordId = null;
    pendingClearRecords = false;
    if (recordStatus != LedRecordStatus.previewing) {
      recordStatus = LedRecordStatus.idle;
    }
  }

  void handleSyncStart() {
    setMode(LedMode.none);
    presetSceneCode = null;
    customSceneChannels = null;
    activeSceneId = null;
    activeScheduleId = null;
    pendingRecordId = null;
    pendingClearRecords = false;
    previewingRecordId = null;
    recordStatus = LedRecordStatus.applying;
  }

  void setMode(LedMode newMode) {
    mode = newMode;
    if (newMode != LedMode.record) {
      activeScheduleId = null;
    }
    if (newMode != LedMode.presetScene) {
      presetSceneCode = null;
    }
    if (newMode != LedMode.customScene) {
      customSceneChannels = null;
    }
  }

  void applyChannels(Map<String, int> channels) {
    channelLevels = Map<String, int>.unmodifiable(_clampChannels(channels));
  }

  LedStateScene? findScene(String sceneId) {
    for (final LedStateScene scene in scenes) {
      if (scene.sceneId == sceneId) {
        return scene;
      }
    }
    return null;
  }

  LedStateScene? findSceneByPreset(int presetCode) {
    for (final LedStateScene scene in scenes) {
      if (scene.presetCode == presetCode) {
        return scene;
      }
    }
    return null;
  }

  LedStateScene? findSceneByChannels(Map<String, int> channels) {
    for (final LedStateScene scene in scenes) {
      if (_channelsMatch(scene.channelLevels, channels)) {
        return scene;
      }
    }
    return null;
  }

  void saveScene(LedStateScene scene) {
    final List<LedStateScene> next = List<LedStateScene>.from(scenes);
    final int index = next.indexWhere(
      (LedStateScene item) => item.sceneId == scene.sceneId,
    );
    if (index >= 0) {
      next[index] = scene;
    } else {
      next.add(scene);
    }
    scenes = List<LedStateScene>.unmodifiable(next);
  }

  LedRecord? findRecord(String recordId) {
    for (final LedRecord record in records) {
      if (record.id == recordId) {
        return record;
      }
    }
    return null;
  }

  void saveRecord(LedRecord record) {
    final List<LedRecord> next = List<LedRecord>.from(records);
    final int index = next.indexWhere((item) => item.id == record.id);
    if (index >= 0) {
      next[index] = record;
    } else {
      next.add(record);
    }
    _sortRecords(next);
    records = List<LedRecord>.unmodifiable(next);
  }

  void removeRecord(String recordId) {
    final List<LedRecord> next = List<LedRecord>.from(records)
      ..removeWhere((record) => record.id == recordId);
    records = List<LedRecord>.unmodifiable(next);
  }

  void clearRecords() {
    records = const <LedRecord>[];
  }

  void _sortRecords(List<LedRecord> list) {
    list.sort(
      (LedRecord a, LedRecord b) =>
          a.minutesFromMidnight.compareTo(b.minutesFromMidnight),
    );
  }

  Map<String, int> _clampChannels(Map<String, int> channels) {
    return <String, int>{
      for (final MapEntry<String, int> entry in channels.entries)
        entry.key: entry.value.clamp(0, 100),
    };
  }

  void invalidate() {
    isValid = false;
    status = LedStatus.error;
  }
}

class _SyncSession {
  _SyncSession({required this.deviceId});

  final String deviceId;
  final List<LedStateScene> scenes = <LedStateScene>[];
  final List<LedStateSchedule> schedules = <LedStateSchedule>[];
  final List<LedRecord> records = <LedRecord>[];
  Map<String, int>? pendingChannels;

  void begin() {
    scenes.clear();
    schedules.clear();
    records.clear();
    pendingChannels = null;
  }

  void upsertScene(LedStateScene scene) {
    final int index = scenes.indexWhere(
      (LedStateScene existing) => existing.sceneId == scene.sceneId,
    );
    if (index >= 0) {
      scenes[index] = scene;
    } else {
      scenes.add(scene);
    }
  }

  void upsertRecord(LedRecord record) {
    final int index = records.indexWhere(
      (LedRecord existing) => existing.id == record.id,
    );
    if (index >= 0) {
      records[index] = record;
    } else {
      records.add(record);
    }
  }

}


class _RecordMutationTracker {
  _RecordMutationTracker(this.description);

  final String description;
  final Completer<void> _completer = Completer<void>();

  Future<void> get future => _completer.future;

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  void completeError(AppErrorCode code) {
    if (!_completer.isCompleted) {
      _completer.completeError(
        AppError(code: code, message: description),
      );
    }
  }
}

List<LedStateSchedule> _deriveSchedulesFromRecords(List<LedRecord> records) {
  if (records.isEmpty) {
    return const <LedStateSchedule>[];
  }
  final List<LedRecord> ordered = List<LedRecord>.from(records)
    ..sort(
      (LedRecord a, LedRecord b) =>
          a.minutesFromMidnight.compareTo(b.minutesFromMidnight),
    );
  final int count = ordered.length;
  if (count == 1) {
    final LedRecord single = ordered.first;
    return <LedStateSchedule>[
      _scheduleFromRecord(
        record: single,
        endMinutes: single.minutesFromMidnight,
      ),
    ];
  }
  final List<LedStateSchedule> schedules = <LedStateSchedule>[];
  for (int i = 0; i < count; i++) {
    final LedRecord current = ordered[i];
    final LedRecord next = ordered[(i + 1) % count];
    schedules.add(
      _scheduleFromRecord(
        record: current,
        endMinutes: next.minutesFromMidnight,
      ),
    );
  }
  return schedules;
}

LedStateSchedule _scheduleFromRecord({
  required LedRecord record,
  required int endMinutes,
}) {
  final LedScheduleWindow window = LedScheduleWindow(
    startMinutesFromMidnight: record.minutesFromMidnight,
    endMinutesFromMidnight: endMinutes,
    recurrenceLabel: _derivedScheduleRecurrence,
  );
  return LedStateSchedule(
    scheduleId: record.id,
    enabled: true,
    window: window,
    channelLevels: record.channelLevels,
  );
}

@visibleForTesting
List<LedStateSchedule> deriveSchedulesFromRecordsForTest(
  List<LedRecord> records,
) =>
    _deriveSchedulesFromRecords(records);

@visibleForTesting
LedStateSchedule scheduleFromRecordForTest({
  required LedRecord record,
  required int endMinutes,
}) =>
    _scheduleFromRecord(record: record, endMinutes: endMinutes);

void _rebuildSchedulesFromRecords(_LedInformationCache cache) {
  final List<LedStateSchedule> derived =
      _deriveSchedulesFromRecords(cache.records);
  cache.schedules = List<LedStateSchedule>.unmodifiable(derived);
  if (cache.activeScheduleId != null &&
      derived.every((schedule) => schedule.scheduleId != cache.activeScheduleId)) {
    cache.activeScheduleId = null;
  }
}

class _SceneApplicationContext {
  const _SceneApplicationContext({
    required this.sceneId,
    this.presetCode,
    this.channelLevels,
  }) : assert(presetCode != null || channelLevels != null);

  final String sceneId;
  final int? presetCode;
  final Map<String, int>? channelLevels;

  bool get isPreset => presetCode != null;
}

const String _defaultCustomSceneName = 'Custom Scene';
const String _customSceneIconKey = 'ic_custom';

_SceneApplicationContext _resolveSceneContext(
  _LedInformationCache cache,
  String sceneId,
) {
  final LedStateScene? scene =
      cache.findScene(sceneId) ?? SceneCatalog.findById(sceneId);
  if (scene == null) {
    throw StateError(
      'Scene "$sceneId" is not available for ${cache.deviceId}.',
    );
  }
  if (scene.presetCode != null) {
    return _SceneApplicationContext(
      sceneId: scene.sceneId,
      presetCode: scene.presetCode,
    );
  }
  if (scene.channelLevels.isEmpty) {
    throw StateError('Custom scene "$sceneId" does not define channel levels.');
  }
  return _SceneApplicationContext(
    sceneId: scene.sceneId,
    channelLevels: Map<String, int>.from(scene.channelLevels),
  );
}

Map<String, int> _decodeChannelPayload(List<int> bytes) {
  final Map<String, int> channels = <String, int>{};
  final int count = bytes.length.clamp(0, ledChannelOrder.length);
  for (int i = 0; i < count; i++) {
    channels[ledChannelOrder[i]] = bytes[i] & 0xFF;
  }
  return channels;
}

String _recordIdForMinutes(int minutes) {
  return 'record-${minutes.toString().padLeft(4, '0')}';
}

const String _derivedScheduleRecurrence = 'daily';
const String _deleteRecordErrorMessage = 'Failed to delete LED record.';
const String _clearRecordsErrorMessage = 'Failed to clear LED records.';

String _derivePresetSceneId(int code) =>
    'preset_${code.toString().padLeft(2, '0')}';

String _deriveCustomSceneId(Map<String, int> channels) {
  return 'custom_${_orderedChannelLevels(channels).join('-')}';
}

String _presetSceneName(int code) =>
    'Preset Scene ${code.toString().padLeft(2, '0')}';

List<int> _orderedChannelLevels(Map<String, int> channels) {
  return <int>[
    for (final String key in ledChannelOrder) _channelIntensity(channels, key),
  ];
}

int _channelIntensity(Map<String, int> channels, String key) {
  int? value = channels[key];
  if (value == null && key == 'moonLight') {
    value = channels['moon'];
  }
  return (value ?? 0).clamp(0, 100);
}

bool _channelsMatch(Map<String, int> a, Map<String, int> b) {
  final List<int> orderedA = _orderedChannelLevels(a);
  final List<int> orderedB = _orderedChannelLevels(b);
  if (orderedA.length != orderedB.length) {
    return false;
  }
  for (int i = 0; i < orderedA.length; i++) {
    if (orderedA[i] != orderedB[i]) {
      return false;
    }
  }
  return true;
}
