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
  static const int _opcodeTimeCorrection = 0x20;
  static const int _opcodeSyncStart = 0x21; // START / RETURN / END sequence
  static const int _opcodeReturnRecord = 0x23;
  static const int _opcodeReturnPresetScene = 0x24;
  static const int _opcodeReturnCustomScene = 0x25;
  static const int _opcodeReturnSchedule = 0x26;
  static const int _opcodeSetRecord = 0x27;
  static const int _opcodeUsePresetScene = 0x28;
  static const int _opcodeUseCustomScene = 0x29;
  static const int _opcodePreviewAck = 0x2A;
  static const int _opcodeStartRecord = 0x2B;
  static const int _opcodeReset = 0x2E;
  static const int _opcodeMutationAck = 0x2F; // delete/clear/set/start acks
  static const int _opcodeClearRecordsAck = 0x30;
  static const int _opcodeEnterDimmingMode = 0x32;
  static const int _opcodeChannelLevels = 0x33;
  static const int _opcodeExitDimmingMode = 0x34;
  // PARITY: reef-b-app uses 0x21 + data[2]==0x02 for sync END, not 0xFF.
  // Removed _opcodeSyncEnd = 0xFF;
  BleLedRepositoryImpl({
    required BleAdapter bleAdapter,
    LedCommandBuilder? commandBuilder,
    Stream<BleNotifyPacket>? notifyStream,
    Stream<BleConnectionState>? connectionStream,
    BleWriteOptions? writeOptions,
  }) : _bleAdapter = bleAdapter,
       _commandBuilder = commandBuilder ?? const LedCommandBuilder(),
       _writeOptions = writeOptions ??
           const BleWriteOptions(
             // PARITY: reef-b-app uses WRITE_TYPE_NO_RESPONSE
             mode: BleWriteMode.withoutResponse,
           ) {
    _notifySubscription = (notifyStream ?? BleNotifyBus.instance.stream).listen(
      _handlePacket,
      onError: _handleNotifyError,
    );
    if (connectionStream != null) {
      _connectionSubscription = connectionStream.listen(_handleConnectionState);
    }
  }

  final BleAdapter _bleAdapter;
  final LedCommandBuilder _commandBuilder;
  final BleWriteOptions _writeOptions;
  final Map<String, _DeviceSession> _sessions = <String, _DeviceSession>{};
  // ignore: unused_field
  StreamSubscription<BleNotifyPacket>? _notifySubscription;
  // ignore: unused_field
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
    emitLedState(session);
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
    await sendCommand(deviceId, command);
    return session.cache.snapshotState();
  }

  @override
  Future<LedState> applySchedule({
    required String deviceId,
    required String scheduleId,
  }) async {
    final _DeviceSession session = _ensureSession(deviceId);
    final _ScheduleApplicationContext context =
        _resolveScheduleApplicationContext(session.cache, scheduleId);
    session.cache.status = LedStatus.applying;
    session.cache.pendingScheduleId = scheduleId;
    emitLedState(session);
    final Uint8List command = _commandBuilder.applySchedule(
      scheduleCode: context.scheduleCode,
      enabled: context.enabled,
      startHour: context.startHour,
      startMinute: context.startMinute,
      endHour: context.endHour,
      endMinute: context.endMinute,
      recurrenceMask: context.recurrenceMask,
      channels: context.orderedChannels,
    );
    await sendCommand(deviceId, command);
    return session.cache.snapshotState();
  }

  @override
  Future<LedState> resetToDefault(String deviceId) async {
    final _DeviceSession session = _ensureSession(deviceId);
    session.cache.status = LedStatus.applying;
    emitLedState(session);
    await sendCommand(deviceId, _commandBuilder.resetLed());
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
    emitLedState(session);
    await sendCommand(deviceId, _commandBuilder.dimming(channelLevels));
    return session.cache.snapshotState();
  }

  @override
  Future<LedState> startRecord(String deviceId) async {
    final _DeviceSession session = _ensureSession(deviceId);
    session.cache.status = LedStatus.applying;
    emitLedState(session);
    await sendCommand(deviceId, _commandBuilder.startRecordPlayback());
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
  Future<LedRecordState> setRecord({
    required String deviceId,
    required int hour,
    required int minute,
    required Map<String, int> channelLevels,
  }) async {
    final _DeviceSession session = _ensureSession(deviceId);
    session.cache.recordStatus = LedRecordStatus.applying;
    emitRecordState(session);
    
    // Convert channel levels to ordered list
    final List<int> orderedChannels = <int>[
      channelLevels['coldWhite'] ?? 0,
      channelLevels['royalBlue'] ?? 0,
      channelLevels['blue'] ?? 0,
      channelLevels['red'] ?? 0,
      channelLevels['green'] ?? 0,
      channelLevels['purple'] ?? 0,
      channelLevels['uv'] ?? 0,
      channelLevels['warmWhite'] ?? 0,
      channelLevels['moonLight'] ?? channelLevels['moon'] ?? 0,
    ];
    
    // Store pending record data for ACK handling
    final int minutesFromMidnight = hour * 60 + minute;
    session.cache.pendingRecordData = _PendingRecordData(
      minutesFromMidnight: minutesFromMidnight,
      channelLevels: Map<String, int>.from(channelLevels),
    );
    
    final Future<void> mutationFuture =
        session.beginRecordMutation(_setRecordErrorMessage);
    try {
      await sendCommand(
        deviceId,
        _commandBuilder.setRecord(
          hour: hour,
          minute: minute,
          channels: orderedChannels,
        ),
      );
    } catch (error) {
      session.failRecordMutation();
      session.cache.pendingRecordData = null;
      rethrow;
    }
    await mutationFuture;
    return session.cache.snapshotRecords();
  }

  @override
  Future<LedRecordState> deleteRecord({
    required String deviceId,
    required String recordId,
  }) async {
    final _DeviceSession session = _ensureSession(deviceId);
    session.cache.recordStatus = LedRecordStatus.applying;
    emitRecordState(session);
    final LedRecord? target = session.cache.findRecord(recordId);
    if (target == null) {
      throw StateError('Record "$recordId" not found for $deviceId.');
    }
    session.cache.pendingRecordId = recordId;
    final Future<void> mutationFuture =
        session.beginRecordMutation(_deleteRecordErrorMessage);
    try {
      await sendCommand(
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
    emitRecordState(session);
    final Future<void> mutationFuture =
        session.beginRecordMutation(_clearRecordsErrorMessage);
    try {
      await sendCommand(deviceId, _commandBuilder.clearRecords());
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
    emitRecordState(session);
    await sendCommand(deviceId, _commandBuilder.preview(start: true));
    return session.cache.snapshotRecords();
  }

  @override
  Future<LedRecordState> stopPreview(String deviceId) async {
    final _DeviceSession session = _ensureSession(deviceId);
    session.cache.recordStatus = LedRecordStatus.idle;
    session.cache.previewingRecordId = null;
    emitRecordState(session);
    await sendCommand(deviceId, _commandBuilder.preview(start: false));
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
    // PARITY: Surface BLE errors via cache + state emit.
    // When BLE notification stream errors, mark all sessions as error state
    for (final _DeviceSession session in _sessions.values) {
      session.cache.status = LedStatus.error;
      session.cache.recordStatus = LedRecordStatus.error;
      emitLedState(session);
      emitRecordState(session);
    }
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
      emitLedState(session);
      emitRecordState(session);
      return;
    }
    if (state.isConnected) {
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
    sendCommand(session.deviceId, _commandBuilder.syncInformation());
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
    // PARITY: Removed _SyncSession. reef-b-app updates state immediately, no buffering.

    switch (opcode) {
      case _opcodeSyncStart:
        // PARITY: reef-b-app uses 0x21 with data[2] to indicate sync status:
        // 0x01 = START, 0x02 = END, 0x00 = FAILED
        if (data.length < 3) {
          return; // Invalid payload
        }
        final int status = data[2] & 0xFF;
        switch (status) {
          case 0x01: // Sync START
            // PARITY: reef-b-app clears information on START, no sync session needed.
            session.cache.status = LedStatus.applying;
            session.cache.recordStatus = LedRecordStatus.idle;
            session.cache.handleSyncStart();
            break;
          case 0x02: // Sync END
            // PARITY: reef-b-app only notifies END, no state merging.
            finalizeSync(session);
            break;
          case 0x00: // Sync FAILED
            session.cache.finishSync();
            session.syncInFlight = false;
            break;
          default:
            // Unknown status, ignore
            break;
        }
        break;
      case _opcodeReturnPresetScene:
        handleSceneReturn(session, data, isCustom: false);
        break;
      case _opcodeReturnCustomScene:
        handleSceneReturn(session, data, isCustom: true);
        break;
      case _opcodeReturnRecord:
        handleRecordReturn(session, data);
        break;
      case _opcodeReturnSchedule:
        handleScheduleReturn(session, data);
        break;
      case _opcodeUsePresetScene:
        handlePresetSceneAck(session, data);
        break;
      case _opcodeUseCustomScene:
        handleCustomSceneAck(session, data);
        break;
      case _opcodePreviewAck:
        handlePreviewAck(session, data);
        break;
      case _opcodeMutationAck:
        handleMutationAck(session, data);
        break;
      case _opcodeClearRecordsAck:
        handleClearRecordsAck(session, data);
        break;
      case _opcodeChannelLevels:
        handleChannelLevels(session, data);
        break;
      case _opcodeTimeCorrection:
        handleTimeCorrectionAck(session, data);
        break;
      case _opcodeSetRecord:
        handleSetRecordAck(session, data);
        break;
      case _opcodeStartRecord:
        handleStartRecordAck(session, data);
        break;
      case _opcodeReset:
        handleResetAck(session, data);
        break;
      case _opcodeEnterDimmingMode:
        handleEnterDimmingModeAck(session, data);
        break;
      case _opcodeExitDimmingMode:
        handleExitDimmingModeAck(session, data);
        break;
      // PARITY: Removed 0xFF sync end case. reef-b-app uses 0x21 + data[2]==0x02 instead.
    }
  }

  void handleSceneReturn(
    _DeviceSession session,
    Uint8List data, {
    required bool isCustom,
  }) {
    final LedStateScene? scene = parseSceneReturn(
      session,
      data,
      isCustom: isCustom,
    );
    if (scene == null) {
      return;
    }
    // PARITY: reef-b-app updates state immediately, no buffering.
    session.cache.saveScene(scene);
    if (isCustom) {
      session.cache.setMode(LedMode.customScene);
      session.cache.customSceneChannels = scene.channelLevels;
    } else if (scene.presetCode != null) {
      session.cache.setMode(LedMode.presetScene);
      session.cache.presetSceneCode = scene.presetCode;
    }
    // PARITY: reef-b-app only notifies UI at sync END, not during sync.
    if (!session.cache.isSyncing) {
      emitLedState(session);
    }
  }

  LedStateScene? parseSceneReturn(
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
  void handleRecordReturn(_DeviceSession session, Uint8List data) {
    final LedRecord? record = parseRecordReturn(data);
    if (record == null) {
      return;
    }
    // PARITY: reef-b-app updates state immediately, no buffering.
    session.cache.saveRecord(record);
    // PARITY: reef-b-app does not derive schedules from records.
    // Removed _rebuildSchedulesFromRecords() call.
    if (session.cache.mode == LedMode.none) {
      session.cache.setMode(LedMode.record);
    }
    // PARITY: reef-b-app only notifies UI at sync END, not during sync.
    if (!session.cache.isSyncing) {
      emitRecordState(session);
    }
  }

  void handleScheduleReturn(_DeviceSession session, Uint8List data) {
    // PARITY: Opcode 0x26 (RETURN_SCHEDULE) is NOT implemented in reef-b-app.
    // _parseScheduleReturn returns null, so this handler does nothing.
    // ignore: unused_local_variable
    final LedStateSchedule? schedule = parseScheduleReturn(data);
    // No-op: schedule is always null per parity with reef-b-app
  }

  LedStateSchedule? parseScheduleReturn(Uint8List data) {
    // PARITY: reef-b-app does NOT implement opcode 0x26 (RETURN_SCHEDULE).
    // Verified: CommandManager.kt has no handler for CMD_LED_RETURN_SCHEDULE.
    // Return null to match reef-b-app behavior.
    if (data.length < 2) {
      return null;
    }
    // PARITY: reef-b-app does NOT implement opcode 0x26, so we return null.
    // This method should never be called in practice, but we return null for safety.
    return null;
  }

  LedRecord? parseRecordReturn(Uint8List data) {
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

  void handlePreviewAck(_DeviceSession session, Uint8List data) {
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
    emitRecordState(session);
  }

  void handleDeleteRecordAck(_DeviceSession session, Uint8List data) {
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
      // PARITY: reef-b-app does not derive schedules from records.
      // Removed _rebuildSchedulesFromRecords() call.
      session.resolveRecordMutationSuccess();
    } else {
      session.cache.recordStatus = LedRecordStatus.error;
      session.resolveRecordMutationFailure();
    }
    emitRecordState(session);
  }

  void handleClearRecordsAck(_DeviceSession session, Uint8List data) {
    if (data.length != 4) {
      return;
    }
    final int result = data[2] & 0xFF;
    if (result == 0x01) {
      session.cache.clearRecords();
      session.cache.recordStatus = LedRecordStatus.idle;
      session.cache.previewingRecordId = null;
      // PARITY: reef-b-app does not derive schedules from records.
      // Removed _rebuildSchedulesFromRecords() call.
      session.resolveRecordMutationSuccess();
    } else {
      session.cache.recordStatus = LedRecordStatus.error;
      session.resolveRecordMutationFailure();
    }
    session.cache.pendingClearRecords = false;
    emitRecordState(session);
  }

  void handleMutationAck(_DeviceSession session, Uint8List data) {
    if (session.cache.pendingScheduleId != null) {
      handleScheduleAck(session, data);
      return;
    }
    handleDeleteRecordAck(session, data);
  }

  void handleScheduleAck(_DeviceSession session, Uint8List data) {
    if (data.length != 4) {
      return;
    }
    final bool success = (data[2] & 0xFF) == 0x01;
    if (success) {
      session.cache.status = LedStatus.idle;
      final String? pendingId = session.cache.pendingScheduleId;
      if (pendingId != null) {
        session.cache.pendingSceneId = null;
        session.cache.pendingPresetSceneCode = null;
        session.cache.pendingCustomSceneChannels = null;
        session.cache.setMode(LedMode.record);
        session.cache.activeScheduleId = pendingId;
        session.cache.activeSceneId = null;
      }
    } else {
      session.cache.status = LedStatus.error;
    }
    session.cache.pendingScheduleId = null;
    emitLedState(session);
  }

  void handleChannelLevels(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app treats 0x33 (CMD_LED_DIMMING) as ACK only, not data return.
    // Payload: [0x33, 0x01, result(0x00/0x01), checksum] = 4 bytes
    // 0x00 = failed, 0x01 = success
    // Channel levels are already updated in setChannelLevels() before sending command.
    if (data.length != 4) {
      return; // Invalid payload
    }

    final bool success = (data[2] & 0xFF) == 0x01;
    if (success) {
      // ACK success: channel levels already updated in setChannelLevels()
      // No additional state update needed
      session.cache.status = LedStatus.idle;
    } else {
      // ACK failed: revert channel levels? Or keep current state?
      // reef-b-app doesn't revert, so we keep current state
      session.cache.status = LedStatus.error;
    }
    emitLedState(session);
  }

  void handleTimeCorrectionAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x20, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel triggers sync on success
    if (success) {
      _requestSync(session);
    }
  }

  void handleSetRecordAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x27, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    final bool success = (data[2] & 0xFF) == 0x01;
    if (success) {
      // PARITY: reef-b-app ViewModel calls ledInformation.addRecord(LedRecord(...))
      // Note: We need pending record data (hour, minute, channels) to create the record
      // This requires tracking pending state when setRecord is called
      // For now, we'll need to add pendingRecordData to _LedInformationCache
      final pending = session.cache.pendingRecordData;
      if (pending != null) {
        final record = LedRecord(
          id: _recordIdForMinutes(pending.minutesFromMidnight),
          minutesFromMidnight: pending.minutesFromMidnight,
          channelLevels: pending.channelLevels,
        );
        session.cache.saveRecord(record);
        session.cache.pendingRecordData = null;
      }
      session.cache.recordStatus = LedRecordStatus.idle;
      session.resolveRecordMutationSuccess();
    } else {
      session.cache.recordStatus = LedRecordStatus.error;
      session.resolveRecordMutationFailure();
    }
    emitRecordState(session);
  }

  void handleStartRecordAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x2B, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    final bool success = (data[2] & 0xFF) == 0x01;
    if (success) {
      // PARITY: reef-b-app calls ledInformation?.setMode(LedMode.RECORD)
      session.cache.setMode(LedMode.record);
      session.cache.status = LedStatus.idle;
    } else {
      session.cache.status = LedStatus.error;
    }
    emitLedState(session);
  }

  void handleResetAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x2E, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel calls dbResetDevice(DeviceReset(nowDevice.id)) on success
    // koralcore already handles invalidate + sync in resetToDefault(), so ACK just confirms
    if (success) {
      // Reset command already triggered invalidate + sync, ACK confirms completion
      // No additional action needed
    }
    // Note: Status is already set to syncing in resetToDefault(), will be updated at sync END
  }

  void handleEnterDimmingModeAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x32, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    // ignore: unused_local_variable
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel only logs success/failure, no state update
    // ACK is handled, no additional action needed
  }

  void handleExitDimmingModeAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x34, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel only logs success/failure, no state update
    // ACK is handled, no additional action needed
  }

  void handlePresetSceneAck(_DeviceSession session, Uint8List data) {
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
    emitLedState(session);
  }

  void handleCustomSceneAck(_DeviceSession session, Uint8List data) {
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
    emitLedState(session);
  }

  void reconcileSceneStateFromSync(_DeviceSession session) {
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

  void finalizeSync(_DeviceSession session) {
    // PARITY: reef-b-app only notifies END, no state merging.
    // State is already updated immediately when RETURN opcodes are received.
    // This method only cleans up sync state and notifies completion.
    
    // Clean up pending states
    session.cache.recordStatus = LedRecordStatus.idle;
    session.cache.pendingRecordId = null;
    session.cache.pendingRecordData = null;
    session.cache.pendingClearRecords = false;
    session.cache.previewingRecordId = null;
    
    // Finish sync
    session.cache.finishSync();
    session.syncInFlight = false;
    
    // Emit final state (reef-b-app ViewModel reads state directly, but koralcore needs to notify UI)
    emitLedState(session);
    emitRecordState(session);
  }

  void finalizeMutation(_DeviceSession session) {
    // PARITY: Verified against reef-b-app CommandManager.kt.
    // - 0x2F (DELETE_RECORD): ViewModel calls ledInformation.deleteRecord() on SUCCESS
    // - 0x30 (CLEAR_RECORD): ViewModel calls ledInformation.clearRecord() on SUCCESS
    // - 0x27 (SET_RECORD): ViewModel updates state on SUCCESS
    // koralcore handles these in _handleDeleteRecordAck, _handleClearRecordsAck, _handleSetRecordAck.
    // This method only finalizes mutation state, which is already aligned.
    session.syncInFlight = false;
    emitLedState(session);
    emitRecordState(session);
  }

  Future<void> sendCommand(String deviceId, Uint8List payload) async {
    try {
      await _bleAdapter.writeBytes(
        deviceId: deviceId,
        data: payload,
        options: _writeOptions,
      );
    } catch (error) {
      // PARITY: Handle BLE command errors
      // Update session state to error and notify UI
      final _DeviceSession? session = _sessions[deviceId];
      if (session != null) {
        session.cache.status = LedStatus.error;
        emitLedState(session);
        emitRecordState(session);
      }
      // Re-throw to allow caller to handle if needed
      rethrow;
    }
  }

  void emitLedState(_DeviceSession session) {
    session.ledStateController.add(session.cache.snapshotState());
  }

  void emitRecordState(_DeviceSession session) {
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
  // PARITY: Removed activeSync. reef-b-app updates state immediately, no buffering.
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
  _PendingRecordData? pendingRecordData;
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
    status = LedStatus.applying;
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
    pendingRecordData = null;
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
    pendingRecordData = null;
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

  LedStateSchedule? findSchedule(String scheduleId) {
    for (final LedStateSchedule schedule in schedules) {
      if (schedule.scheduleId == scheduleId) {
        return schedule;
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

// PARITY: Removed _SyncSession class. reef-b-app updates state immediately, no buffering.


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

// ignore: unused_element
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

class _ScheduleApplicationContext {
  const _ScheduleApplicationContext({
    required this.scheduleCode,
    required this.enabled,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.recurrenceMask,
    required this.orderedChannels,
  });

  final int scheduleCode;
  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final int recurrenceMask;
  final List<int> orderedChannels;
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

_ScheduleApplicationContext _resolveScheduleApplicationContext(
  _LedInformationCache cache,
  String scheduleId,
) {
  final LedStateSchedule? schedule = cache.findSchedule(scheduleId);
  if (schedule == null) {
    throw StateError(
      'Schedule "$scheduleId" is not available for ${cache.deviceId}.',
    );
  }
  final _HourMinute start = _minutesToHourMinute(schedule.window.startMinutesFromMidnight);
  final _HourMinute end = _minutesToHourMinute(schedule.window.endMinutesFromMidnight);
  final List<int> channels = _scheduleSpectrum(schedule.channelLevels);
  return _ScheduleApplicationContext(
    scheduleCode: _scheduleCodeFromId(schedule.scheduleId),
    enabled: schedule.enabled,
    startHour: start.hour,
    startMinute: start.minute,
    endHour: end.hour,
    endMinute: end.minute,
    recurrenceMask: _recurrenceMaskFromLabel(schedule.window.recurrenceLabel),
    orderedChannels: channels,
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
const String _setRecordErrorMessage = 'Failed to set LED record.';
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

class _HourMinute {
  const _HourMinute({required this.hour, required this.minute});

  final int hour;
  final int minute;
}

_HourMinute _minutesToHourMinute(int minutes) {
  if (minutes < 0 || minutes >= 24 * 60) {
    throw StateError('Invalid minutes-from-midnight: $minutes');
  }
  final int hour = minutes ~/ 60;
  final int minute = minutes % 60;
  return _HourMinute(hour: hour, minute: minute);
}

int _recurrenceMaskFromLabel(String label) {
  if (label.toLowerCase() == 'daily') {
    return 0x7F;
  }
  return 0x00;
}

int _scheduleCodeFromId(String scheduleId) {
  final RegExp digits = RegExp(r'(\d+)$');
  final Match? match = digits.firstMatch(scheduleId);
  if (match != null) {
    return int.parse(match.group(1)!) & 0xFF;
  }
  final RegExp hex = RegExp(r'^[0-9a-fA-F]+$');
  if (hex.hasMatch(scheduleId) && scheduleId.length >= 2) {
    return int.parse(scheduleId.substring(0, 2), radix: 16) & 0xFF;
  }
  throw StateError('Unable to derive schedule code from "$scheduleId".');
}

List<int> _scheduleSpectrum(Map<String, int> channels) {
  final List<int> ordered = <int>[
    _channelIntensity(channels, 'red'),
    _channelIntensity(channels, 'green'),
    _channelIntensity(channels, 'blue'),
    _channelIntensity(channels, 'coldWhite') == 0
        ? _channelIntensity(channels, 'warmWhite')
        : _channelIntensity(channels, 'coldWhite'),
    _channelIntensity(channels, 'uv'),
  ];
  return ordered;
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

// ---------------------------------------------------------------------------
// Internal helper classes
// ---------------------------------------------------------------------------

/// Pending record data for SET_RECORD ACK handling.
class _PendingRecordData {
  _PendingRecordData({
    required this.minutesFromMidnight,
    required this.channelLevels,
  });

  final int minutesFromMidnight;
  final Map<String, int> channelLevels;
}
