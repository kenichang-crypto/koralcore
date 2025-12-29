library;

import 'dart:async';
import 'dart:typed_data';
import '../../domain/doser_dosing/dosing_state.dart';
import '../../domain/doser_dosing/pump_head_adjust_history.dart';
import '../../domain/doser_dosing/pump_head_mode.dart';
import '../../domain/doser_dosing/pump_head_record_detail.dart';
import '../../domain/doser_dosing/pump_head_record_type.dart';
import '../../infrastructure/ble/ble_adapter.dart';
import '../../infrastructure/ble/ble_notify_bus.dart';
import '../../infrastructure/ble/dosing/dosing_command_builder.dart';
import '../../infrastructure/ble/platform_channels/ble_notify_packet.dart';
import '../../infrastructure/ble/transport/ble_transport_models.dart';
import '../../platform/contracts/dosing_repository.dart';

/// BLE-backed Dosing repository implementation.
///
/// PARITY: This implementation mirrors reef-b-app Android's DropInformation
/// and CommandManager.parseCommand() behavior for all Dosing opcodes (0x60-0x7E).
///
/// Key behaviors:
/// - Immediate state updates (no buffering during sync)
/// - State emission only at sync END (not during sync)
/// - Multi-device session management
class BleDosingRepositoryImpl implements DosingRepository {
  // Opcodes mirror reef-b-app; keep aligned with Android CommandManager.
  static const int _opcodeTimeCorrection = 0x60;
  static const int _opcodeSetDelay = 0x61;
  static const int _opcodeSetSpeed = 0x62;
  static const int _opcodeStartDrop = 0x63;
  static const int _opcodeEndDrop = 0x64;
  static const int _opcodeSyncInformation = 0x65; // START / END / FAILED
  static const int _opcodeReturnDelayTime = 0x66;
  static const int _opcodeReturnRotatingSpeed = 0x67;
  static const int _opcodeReturnSingleDropTiming = 0x68;
  static const int _opcodeReturn24hrDropWeekly = 0x69;
  static const int _opcodeReturn24hrDropRange = 0x6A;
  static const int _opcodeReturnCustomDropWeekly = 0x6B;
  static const int _opcodeReturnCustomDropRange = 0x6C;
  static const int _opcodeReturnCustomDropDetail = 0x6D;
  static const int _opcodeSingleDropImmediately = 0x6E;
  static const int _opcodeSingleDropTimely = 0x6F;
  static const int _opcode24hrDropWeekly = 0x70;
  static const int _opcode24hrDropRange = 0x71;
  static const int _opcodeCustomDropWeekly = 0x72;
  static const int _opcodeCustomDropRange = 0x73;
  static const int _opcodeCustomDropDetail = 0x74;
  static const int _opcodeAdjust = 0x75;
  static const int _opcodeAdjustResult = 0x76;
  static const int _opcodeGetAdjustHistory = 0x77;
  static const int _opcodeReturnAdjustHistoryDetail = 0x78;
  static const int _opcodeClearRecord = 0x79;
  static const int _opcodeGetTodayTotalVolume = 0x7A;
  static const int _opcodeReset = 0x7D;
  static const int _opcodeGetTodayTotalVolumeDecimal = 0x7E;
  // PARITY: 0x7B (GET_WARNING) and 0x7C (WRITE_USER_ID) are defined but not
  // implemented in reef-b-app Android, so we don't implement them either.

  BleDosingRepositoryImpl({
    required BleAdapter bleAdapter,
    DosingCommandBuilder? commandBuilder,
    Stream<BleNotifyPacket>? notifyStream,
    Stream<BleConnectionState>? connectionStream,
    BleWriteOptions? writeOptions,
  }) : _bleAdapter = bleAdapter,
       _commandBuilder = commandBuilder ?? const DosingCommandBuilder(),
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
  final DosingCommandBuilder _commandBuilder;
  final BleWriteOptions _writeOptions;
  final Map<String, _DeviceSession> _sessions = <String, _DeviceSession>{};
  StreamSubscription<BleNotifyPacket>? _notifySubscription;
  StreamSubscription<BleConnectionState>? _connectionSubscription;

  // ---------------------------------------------------------------------------
  // DosingRepository
  // ---------------------------------------------------------------------------

  @override
  Stream<DosingState> observeDosingState(String deviceId) {
    final _DeviceSession session = _ensureSession(deviceId);
    return session.dosingStateStream;
  }

  @override
  Future<DosingState?> getDosingState(String deviceId) async {
    final _DeviceSession session = _ensureSession(deviceId);
    return session.state;
  }

  @override
  Future<DosingState> resetToDefault(String deviceId) async {
    final _DeviceSession session = _ensureSession(deviceId);
    // PARITY: reef-b-app sends reset command and waits for ACK
    // On success, ViewModel calls resetDrop() which clears DB and triggers sync
    // koralcore: send reset command, ACK handler will clear info and request sync
    await _sendCommand(deviceId, _commandBuilder.reset());
    return session.state;
  }

  // ---------------------------------------------------------------------------
  // Internal orchestration
  // ---------------------------------------------------------------------------

  _DeviceSession _ensureSession(String deviceId) {
    return _sessions.putIfAbsent(deviceId, () {
      final _DeviceSession session = _DeviceSession(deviceId: deviceId);
      _requestSync(session);
      return session;
    });
  }

  void _handlePacket(BleNotifyPacket packet) {
    final _DeviceSession session = _ensureSession(packet.deviceId);
    _handleDevicePacket(session, packet);
  }

  void _handleNotifyError(Object error, StackTrace stackTrace) {
    // PARITY: Surface BLE errors via cache + state emit.
    // When BLE notification stream errors, mark all sessions as error state
    for (final _DeviceSession session in _sessions.values) {
      // Update session state to indicate error (if DosingState has error field)
      // For now, emit current state to notify UI of the error
      _emitDosingState(session);
    }
  }

  void _handleConnectionState(BleConnectionState state) {
    final String? deviceId = state.deviceId;
    if (deviceId == null || deviceId.isEmpty) {
      return;
    }
    final _DeviceSession session = _ensureSession(deviceId);
    if (state.isDisconnected) {
      session.clearInformation();
      session.syncInFlight = false;
      _emitDosingState(session);
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
    session.syncInFlight = true;
    _sendCommand(session.deviceId, _commandBuilder.syncInformation());
  }

  Future<void> _sendCommand(String deviceId, Uint8List payload) async {
    // PARITY: reef-b-app calls ensureDoseCapabilityConfirmed() before sending
    // Dosing commands (opcodes >= 0x60) to Drop devices
    if (payload.isNotEmpty && payload[0] >= 0x60) {
      final _DeviceSession session = _ensureSession(deviceId);
      _ensureDoseCapabilityConfirmed(session);
      
      // PARITY: reef-b-app adds 200ms delay before sending Dosing commands (>= 0x60)
      // See BLEManager.kt: if (value.first() >= 0x60) { delay(200) }
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }

    try {
      await _bleAdapter.writeBytes(
        deviceId: deviceId,
        data: payload,
        options: _writeOptions,
      );
    } catch (error) {
      // PARITY: Handle BLE command errors
      // Update session state and notify UI
      final _DeviceSession? session = _sessions[deviceId];
      if (session != null) {
        _emitDosingState(session);
      }
      // Re-throw to allow caller to handle if needed
      rethrow;
    }
  }

  /// Detects dose format capability by sending 0x7E command.
  /// PARITY: Matches reef-b-app's detectDoseFormat() method.
  void _detectDoseFormat(_DeviceSession session, {int pumpIndex = 0}) {
    // PARITY: Set capability to UNKNOWN when starting detection
    session.doseCapability = _DoseCapability.unknown;

    // PARITY: Build 0x7E command: [0x7E, 0x01, pumpIndex, checksum]
    final int opcode = 0x7E;
    final int length = 0x01;
    final int normalizedPumpIndex = pumpIndex.clamp(0, 0xFF);

    // PARITY: XOR checksum for bytes [0x7E, 0x01, pumpIndex]
    final int checksum = (opcode ^ length ^ normalizedPumpIndex) & 0xFF;

    final Uint8List cmd = Uint8List.fromList(<int>[
      opcode,
      length,
      normalizedPumpIndex,
      checksum,
    ]);

    // Send command asynchronously (don't await, just queue it)
    _bleAdapter
        .writeBytes(
          deviceId: session.deviceId,
          data: cmd,
          options: _writeOptions,
        )
        .catchError((error) {
          // Ignore errors during detection - capability will remain UNKNOWN
        });
  }

  /// Ensures dose capability is confirmed before sending commands.
  /// PARITY: Matches reef-b-app's ensureDoseCapabilityConfirmed() method.
  void _ensureDoseCapabilityConfirmed(
    _DeviceSession session, {
    int pumpIndex = 0,
  }) {
    // PARITY: Only send 0x7E if capability is UNKNOWN
    if (session.doseCapability != _DoseCapability.unknown) {
      return;
    }

    // PARITY: Send 0x7E detection command
    _detectDoseFormat(session, pumpIndex: pumpIndex);
  }

  void _handleDevicePacket(_DeviceSession session, BleNotifyPacket packet) {
    final Uint8List data = packet.payload;
    if (data.isEmpty) {
      return;
    }
    final int opcode = data[0] & 0xFF;

    switch (opcode) {
      case _opcodeSyncInformation:
        _handleSyncInformation(session, data);
        break;
      case _opcodeReturnDelayTime:
        _handleReturnDelayTime(session, data);
        break;
      case _opcodeReturnRotatingSpeed:
        _handleReturnRotatingSpeed(session, data);
        break;
      case _opcodeReturnSingleDropTiming:
        _handleReturnSingleDropTiming(session, data);
        break;
      case _opcodeReturn24hrDropWeekly:
        _handleReturn24hrDropWeekly(session, data);
        break;
      case _opcodeReturn24hrDropRange:
        _handleReturn24hrDropRange(session, data);
        break;
      case _opcodeReturnCustomDropWeekly:
        _handleReturnCustomDropWeekly(session, data);
        break;
      case _opcodeReturnCustomDropRange:
        _handleReturnCustomDropRange(session, data);
        break;
      case _opcodeReturnCustomDropDetail:
        _handleReturnCustomDropDetail(session, data);
        break;
      case _opcodeGetTodayTotalVolume:
        _handleGetTodayTotalVolume(session, data);
        break;
      case _opcodeGetTodayTotalVolumeDecimal:
        _handleGetTodayTotalVolumeDecimal(session, data);
        break;
      case _opcodeReturnAdjustHistoryDetail:
        _handleReturnAdjustHistoryDetail(session, data);
        break;
      // ACK opcodes
      case _opcodeTimeCorrection:
        _handleTimeCorrectionAck(session, data);
        break;
      case _opcodeSetDelay:
        _handleSetDelayAck(session, data);
        break;
      case _opcodeSetSpeed:
        _handleSetSpeedAck(session, data);
        break;
      case _opcodeStartDrop:
        _handleStartDropAck(session, data);
        break;
      case _opcodeEndDrop:
        _handleEndDropAck(session, data);
        break;
      case _opcodeSingleDropImmediately:
        _handleSingleDropImmediatelyAck(session, data);
        break;
      case _opcodeSingleDropTimely:
        _handleSingleDropTimelyAck(session, data);
        break;
      case _opcode24hrDropWeekly:
        _handle24hrDropWeeklyAck(session, data);
        break;
      case _opcode24hrDropRange:
        _handle24hrDropRangeAck(session, data);
        break;
      case _opcodeCustomDropWeekly:
        _handleCustomDropWeeklyAck(session, data);
        break;
      case _opcodeCustomDropRange:
        _handleCustomDropRangeAck(session, data);
        break;
      case _opcodeCustomDropDetail:
        _handleCustomDropDetailAck(session, data);
        break;
      case _opcodeAdjust:
        _handleAdjustAck(session, data);
        break;
      case _opcodeAdjustResult:
        _handleAdjustResultAck(session, data);
        break;
      case _opcodeGetAdjustHistory:
        _handleGetAdjustHistoryAck(session, data);
        break;
      case _opcodeClearRecord:
        _handleClearRecordAck(session, data);
        break;
      case _opcodeReset:
        _handleResetAck(session, data);
        break;
      default:
        // Unknown opcode, ignore
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Sync handling
  // ---------------------------------------------------------------------------

  void _handleSyncInformation(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app uses 0x65 with data[2] to indicate sync status:
    // 0x01 = START, 0x02 = END, 0x00 = FAILED
    if (data.length < 3) {
      return; // Invalid payload
    }
    final int status = data[2] & 0xFF;
    switch (status) {
      case 0x01: // Sync START
        // PARITY: reef-b-app clears information on START
        session.clearInformation();
        session.syncInFlight = true;
        break;
      case 0x02: // Sync END
        // PARITY: reef-b-app only notifies END, no state merging.
        // State is already updated immediately when RETURN opcodes are received.
        _finalizeSync(session);
        break;
      case 0x00: // Sync FAILED
        session.syncInFlight = false;
        break;
      default:
        // Unknown status, ignore
        break;
    }
  }

  void _finalizeSync(_DeviceSession session) {
    // PARITY: reef-b-app only notifies END, no state merging.
    // State is already updated immediately when RETURN opcodes are received.
    // This method only cleans up sync state and notifies completion.
    session.syncInFlight = false;
    // PARITY: reef-b-app ViewModel reads state directly at sync END.
    // koralcore needs to notify UI via Stream.
    _emitDosingState(session);
  }

  void _emitDosingState(_DeviceSession session) {
    session.dosingStateController.add(session.state);
  }

  // ---------------------------------------------------------------------------
  // Data Return handlers
  // ---------------------------------------------------------------------------

  void _handleReturnDelayTime(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x66, len, highBit, lowBit, checksum] = 5 bytes
    if (data.length != 5) {
      return; // Invalid payload
    }
    final int highBit = data[2] & 0xFF;
    final int lowBit = data[3] & 0xFF;
    final int delayTime = (highBit << 8) | lowBit;

    // PARITY: reef-b-app calls dropReturnDelayTime(delayTime)
    // Update state immediately (reef-b-app updates DropInformation immediately)
    session.state = session.state.copyWith(delayTime: delayTime);

    // PARITY: reef-b-app doesn't emit state during sync, only at sync END.
    // State will be emitted at sync END via _finalizeSync().
  }

  void _handleReturnRotatingSpeed(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x67, len, headNo, rotatingRate, checksum] = 5 bytes
    if (data.length != 5) {
      return; // Invalid payload
    }
    final int headNo = data[2] & 0xFF;
    final int rotatingRate = data[3] & 0xFF;

    // PARITY: reef-b-app calls dropReturnRotatingRate(headNo, rotatingRate)
    // Update state immediately
    session.setRotatingSpeed(headNo, rotatingRate);

    // PARITY: reef-b-app doesn't emit state during sync, only at sync END.
    // State will be emitted at sync END via _finalizeSync().
  }

  void _handleReturnSingleDropTiming(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x68, len, headNo, year, month, day, hour, minute, totalDrop_H, totalDrop_L, speed, checksum] = 12 bytes
    if (data.length != 12) {
      return; // Invalid payload
    }
    final int headNo = data[2] & 0xFF;
    final int year = (data[3] & 0xFF) + 2000;
    final int month = data[4] & 0xFF;
    final int day = data[5] & 0xFF;
    final int hour = data[6] & 0xFF;
    final int minute = data[7] & 0xFF;
    final int totalDropHigh = data[8] & 0xFF;
    final int totalDropLow = data[9] & 0xFF;
    final int totalDrop = (totalDropHigh << 8) | totalDropLow;
    final int speed = data[10] & 0xFF;

    final String timeString =
        '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')} '
        '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';

    // PARITY: reef-b-app calls dropInformation.setMode(headNo, DropHeadMode(mode=SINGLE, ...))
    session.setMode(
      headNo,
      PumpHeadMode(
        mode: PumpHeadRecordType.single,
        timeString: timeString,
        totalDrop: totalDrop,
        rotatingSpeed: speed,
      ),
    );

    // PARITY: reef-b-app doesn't emit state during sync, only at sync END.
    // State will be emitted at sync END via _finalizeSync().
  }

  void _handleReturn24hrDropWeekly(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x69, len, headNo, mon, tue, wed, thu, fri, sat, sun, totalDrop_H, totalDrop_L, speed, checksum] = 14 bytes
    if (data.length != 14) {
      return; // Invalid payload
    }
    final int headNo = data[2] & 0xFF;
    final List<bool> runDay = [
      (data[3] & 0xFF) != 0, // Monday
      (data[4] & 0xFF) != 0, // Tuesday
      (data[5] & 0xFF) != 0, // Wednesday
      (data[6] & 0xFF) != 0, // Thursday
      (data[7] & 0xFF) != 0, // Friday
      (data[8] & 0xFF) != 0, // Saturday
      (data[9] & 0xFF) != 0, // Sunday
    ];
    final int totalDropHigh = data[10] & 0xFF;
    final int totalDropLow = data[11] & 0xFF;
    final int totalDrop = (totalDropHigh << 8) | totalDropLow;
    final int speed = data[12] & 0xFF;

    // PARITY: reef-b-app calls dropInformation.setMode(headNo, DropHeadMode(mode=_24HR, runDay=..., ...))
    session.setMode(
      headNo,
      PumpHeadMode(
        mode: PumpHeadRecordType.h24,
        runDay: runDay,
        totalDrop: totalDrop,
        rotatingSpeed: speed,
      ),
    );

    // PARITY: reef-b-app doesn't emit state during sync, only at sync END.
    // State will be emitted at sync END via _finalizeSync().
  }

  void _handleReturn24hrDropRange(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x6A, len, headNo, startYear, startMonth, startDay, endYear, endMonth, endDay, totalDrop_H, totalDrop_L, speed, checksum] = 13 bytes
    if (data.length != 13) {
      return; // Invalid payload
    }
    final int headNo = data[2] & 0xFF;
    final int startYear = (data[3] & 0xFF) + 2000;
    final int startMonth = data[4] & 0xFF;
    final int startDay = data[5] & 0xFF;
    final int endYear = (data[6] & 0xFF) + 2000;
    final int endMonth = data[7] & 0xFF;
    final int endDay = data[8] & 0xFF;
    final int totalDropHigh = data[9] & 0xFF;
    final int totalDropLow = data[10] & 0xFF;
    final int totalDrop = (totalDropHigh << 8) | totalDropLow;
    final int speed = data[11] & 0xFF;

    final String timeString =
        '${startYear.toString().padLeft(4, '0')}-'
        '${startMonth.toString().padLeft(2, '0')}-'
        '${startDay.toString().padLeft(2, '0')} ~ '
        '${endYear.toString().padLeft(4, '0')}-'
        '${endMonth.toString().padLeft(2, '0')}-'
        '${endDay.toString().padLeft(2, '0')}';

    // PARITY: reef-b-app calls dropInformation.setMode(headNo, DropHeadMode(mode=_24HR, timeString=..., ...))
    session.setMode(
      headNo,
      PumpHeadMode(
        mode: PumpHeadRecordType.h24,
        timeString: timeString,
        totalDrop: totalDrop,
        rotatingSpeed: speed,
      ),
    );

    // PARITY: reef-b-app doesn't emit state during sync, only at sync END.
    // State will be emitted at sync END via _finalizeSync().
  }

  void _handleReturnCustomDropWeekly(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x6B, len, headNo, mon, tue, wed, thu, fri, sat, sun, checksum] = 12 bytes
    if (data.length != 12) {
      return; // Invalid payload
    }
    final int headNo = data[2] & 0xFF;
    final List<bool> runDay = [
      (data[3] & 0xFF) != 0, // Monday
      (data[4] & 0xFF) != 0, // Tuesday
      (data[5] & 0xFF) != 0, // Wednesday
      (data[6] & 0xFF) != 0, // Thursday
      (data[7] & 0xFF) != 0, // Friday
      (data[8] & 0xFF) != 0, // Saturday
      (data[9] & 0xFF) != 0, // Sunday
    ];

    // PARITY: reef-b-app calls dropInformation.setMode(headNo, DropHeadMode(mode=CUSTOM, runDay=..., ...))
    session.setMode(
      headNo,
      PumpHeadMode(mode: PumpHeadRecordType.custom, runDay: runDay),
    );

    // PARITY: reef-b-app doesn't emit state during sync, only at sync END.
    // State will be emitted at sync END via _finalizeSync().
  }

  void _handleReturnCustomDropRange(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x6C, len, headNo, startYear, startMonth, startDay, endYear, endMonth, endDay, checksum] = 11 bytes
    if (data.length != 11) {
      return; // Invalid payload
    }
    final int headNo = data[2] & 0xFF;
    final int startYear = (data[3] & 0xFF) + 2000;
    final int startMonth = data[4] & 0xFF;
    final int startDay = data[5] & 0xFF;
    final int endYear = (data[6] & 0xFF) + 2000;
    final int endMonth = data[7] & 0xFF;
    final int endDay = data[8] & 0xFF;

    final String timeString =
        '${startYear.toString().padLeft(4, '0')}-'
        '${startMonth.toString().padLeft(2, '0')}-'
        '${startDay.toString().padLeft(2, '0')} ~ '
        '${endYear.toString().padLeft(4, '0')}-'
        '${endMonth.toString().padLeft(2, '0')}-'
        '${endDay.toString().padLeft(2, '0')}';

    // PARITY: reef-b-app calls dropInformation.setMode(headNo, DropHeadMode(mode=CUSTOM, timeString=..., ...))
    session.setMode(
      headNo,
      PumpHeadMode(mode: PumpHeadRecordType.custom, timeString: timeString),
    );

    // PARITY: reef-b-app doesn't emit state during sync, only at sync END.
    // State will be emitted at sync END via _finalizeSync().
  }

  void _handleReturnCustomDropDetail(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x6D, len, headNo, startHour, startMinute, endHour, endMinute, dropTime, totalDrop_H, totalDrop_L, speed, checksum] = 12 bytes
    if (data.length != 12) {
      return; // Invalid payload
    }
    final int headNo = data[2] & 0xFF;
    final int startHour = data[3] & 0xFF;
    final int startMinute = data[4] & 0xFF;
    final int endHour = data[5] & 0xFF;
    final int endMinute = data[6] & 0xFF;
    final int dropTime = data[7] & 0xFF;
    final int totalDropHigh = data[8] & 0xFF;
    final int totalDropLow = data[9] & 0xFF;
    final int totalDrop = (totalDropHigh << 8) | totalDropLow;
    final int speed = data[10] & 0xFF;

    final String timeString =
        '${startHour.toString().padLeft(2, '0')}:'
        '${startMinute.toString().padLeft(2, '0')} ~ '
        '${endHour.toString().padLeft(2, '0')}:'
        '${endMinute.toString().padLeft(2, '0')}';

    // PARITY: reef-b-app calls dropInformation.setDetail(headNo, DropHeadRecordDetail(...))
    final detail = PumpHeadRecordDetail(
      timeString: timeString,
      dropTime: dropTime,
      totalDrop: totalDrop,
      rotatingSpeed: speed,
    );
    session.setDetail(headNo, detail);

    // PARITY: reef-b-app doesn't emit state during sync, only at sync END.
    // State will be emitted at sync END via _finalizeSync().
  }

  void _handleGetTodayTotalVolume(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x7A, len, headNo, nonRecord_H, nonRecord_L, record_H, record_L, checksum] = 8 bytes
    if (data.length != 8) {
      return; // Invalid payload
    }
    final int headNo = data[2] & 0xFF;
    final int nonRecordHigh = data[3] & 0xFF;
    final int nonRecordLow = data[4] & 0xFF;
    final int nonRecordTotalDrop = (nonRecordHigh << 8) | nonRecordLow;
    final int recordHigh = data[5] & 0xFF;
    final int recordLow = data[6] & 0xFF;
    final int recordTotalDrop = (recordHigh << 8) | recordLow;

    // PARITY: reef-b-app only sets LEGACY_7A if capability is UNKNOWN
    if (session.doseCapability == _DoseCapability.unknown) {
      session.doseCapability = _DoseCapability.legacy7A;
    }

    // PARITY: reef-b-app updates todayDoseMl for debugging (0x7A uses integer format)
    // Note: reef-b-app uses the first byte (nonRecord) as todayDoseMl for 0x7A
    // But actually, reef-b-app uses recordTotalDrop as todayDoseMl
    // Let's use recordTotalDrop as it represents the total recorded dose
    session.todayDoseMl = recordTotalDrop.toDouble();

    // PARITY: reef-b-app calls dropInformation.setDropVolume(headId, nonRecord, record)
    // Note: reef-b-app uses Float, but old firmware (0x7A) uses integer
    session.setDropVolume(
      headNo,
      nonRecord: nonRecordTotalDrop.toDouble(),
      record: recordTotalDrop.toDouble(),
    );

    // PARITY: reef-b-app doesn't emit state during sync, only at sync END.
    // State will be emitted at sync END via _finalizeSync().
  }

  void _handleGetTodayTotalVolumeDecimal(
    _DeviceSession session,
    Uint8List data,
  ) {
    // PARITY: reef-b-app payload: [0x7E, len, headNo, nonRecord_H, nonRecord_L, record_H, record_L, checksum] = 8 bytes
    if (data.length != 8) {
      return; // Invalid payload
    }
    final int headNo = data[2] & 0xFF;
    final int nonRecordHigh = data[3] & 0xFF;
    final int nonRecordLow = data[4] & 0xFF;
    final int nonRecordTotalDrop = (nonRecordHigh << 8) | nonRecordLow;
    final int recordHigh = data[5] & 0xFF;
    final int recordLow = data[6] & 0xFF;
    final int recordTotalDrop = (recordHigh << 8) | recordLow;

    // PARITY: reef-b-app sets DECIMAL_7E when receiving 0x7E response
    session.doseCapability = _DoseCapability.decimal7E;

    // PARITY: reef-b-app updates todayDoseMl for debugging (0x7E uses decimal format, divide by 10)
    // reef-b-app: todayDoseMl = raw / 10f
    session.todayDoseMl = recordTotalDrop / 10.0;

    // PARITY: reef-b-app calls dropInformation.setDropVolume(headId, nonRecord, record)
    // Note: new firmware (0x7E) uses decimal (divide by 10)
    session.setDropVolume(
      headNo,
      nonRecord: nonRecordTotalDrop / 10.0,
      record: recordTotalDrop / 10.0,
    );

    // PARITY: reef-b-app doesn't emit state during sync, only at sync END.
    // State will be emitted at sync END via _finalizeSync().
  }

  void _handleReturnAdjustHistoryDetail(
    _DeviceSession session,
    Uint8List data,
  ) {
    // PARITY: reef-b-app payload: [0x78, len, headNo, year, month, day, hour, minute, second, volume_H, volume_L, speed, checksum] = 13 bytes
    if (data.length != 13) {
      return; // Invalid payload
    }
    final int headNo = data[2] & 0xFF;
    final int year = (data[3] & 0xFF) + 2000;
    final int month = data[4] & 0xFF;
    final int day = data[5] & 0xFF;
    final int hour = data[6] & 0xFF;
    final int minute = data[7] & 0xFF;
    final int second = data[8] & 0xFF;
    final int volumeHigh = data[9] & 0xFF;
    final int volumeLow = data[10] & 0xFF;
    final int volume = (volumeHigh << 8) | volumeLow;
    final int speed = data[11] & 0xFF;

    final String timeString =
        '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')} '
        '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:'
        '${second.toString().padLeft(2, '0')}';

    // PARITY: reef-b-app calls dropInformation.setHistory(headNo, DropAdjustHistory(...))
    final history = PumpHeadAdjustHistory(
      timeString: timeString,
      volume: volume,
      rotatingSpeed: speed,
    );
    final bool isComplete = session.setHistory(headNo, history);

    // PARITY: reef-b-app doesn't emit state during sync, only at sync END.
    // State will be emitted at sync END via _finalizeSync().

    // PARITY: reef-b-app calls dropGetAdjustHistoryState(COMMAND_STATUS.END) when complete
    if (isComplete) {
      // TODO: Notify adjust history complete
    }
  }

  // ---------------------------------------------------------------------------
  // ACK handlers
  // ---------------------------------------------------------------------------

  void _handleTimeCorrectionAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x60, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel triggers sync on success
    if (success) {
      _requestSync(session);
    }
  }

  void _handleSetDelayAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x61, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel only logs success/failure, no state update
    // ACK is handled, no additional action needed
  }

  void _handleSetSpeedAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x62, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel only logs success/failure, no state update
    // ACK is handled, no additional action needed
  }

  void _handleStartDropAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x63, len, result(0x00/0x01/0x02), checksum] = 4 bytes
    // 0x00=FAILED, 0x01=SUCCESS, 0x02=FAILED_ING (正在排程滴液中)
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final int result = data[2] & 0xFF;
    // PARITY: reef-b-app ViewModel updates manualDropState on SUCCESS
    // Repository layer doesn't track manual drop state, so no state update needed
    // ACK is handled, no additional action needed
  }

  void _handleEndDropAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x64, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel updates manualDropState on SUCCESS
    // Repository layer doesn't track manual drop state, so no state update needed
    // ACK is handled, no additional action needed
  }

  void _handleSingleDropImmediatelyAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x6E, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel only logs success/failure, no state update
    // ACK is handled, no additional action needed
  }

  void _handleSingleDropTimelyAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x6F, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel only logs success/failure, no state update
    // ACK is handled, no additional action needed
  }

  void _handle24hrDropWeeklyAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x70, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel only logs success/failure, no state update
    // Schedule state is updated via RETURN opcodes during sync, not via ACK
    // ACK is handled, no additional action needed
  }

  void _handle24hrDropRangeAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x71, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel only logs success/failure, no state update
    // Schedule state is updated via RETURN opcodes during sync, not via ACK
    // ACK is handled, no additional action needed
  }

  void _handleCustomDropWeeklyAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x72, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel only logs success/failure, no state update
    // Schedule state is updated via RETURN opcodes during sync, not via ACK
    // ACK is handled, no additional action needed
  }

  void _handleCustomDropRangeAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x73, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel only logs success/failure, no state update
    // Schedule state is updated via RETURN opcodes during sync, not via ACK
    // ACK is handled, no additional action needed
  }

  void _handleCustomDropDetailAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x74, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel only logs success/failure, no state update
    // Schedule detail is updated via RETURN opcodes during sync, not via ACK
    // ACK is handled, no additional action needed
  }

  void _handleAdjustAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x75, len, result(0x00/0x01/0x02), checksum] = 4 bytes
    // 0x00=FAILED, 0x01=START, 0x02=END
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final int result = data[2] & 0xFF;
    // PARITY: reef-b-app ViewModel only logs START/END/FAILED, no state update
    // Adjust state is managed by ViewModel, not DropInformation
    // ACK is handled, no additional action needed
  }

  void _handleAdjustResultAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x76, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    // ignore: unused_local_variable
    final bool success = (data[2] & 0xFF) == 0x01;
    // PARITY: reef-b-app ViewModel only logs success/failure, no state update
    // Adjust result state is managed by ViewModel, not DropInformation
    // ACK is handled, no additional action needed
  }

  void _handleGetAdjustHistoryAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x77, len, size, checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    final int size = data[2] & 0xFF;
    // PARITY: Verified against reef-b-app DropHeadAdjustListViewModel.kt:196.
    // ViewModel calls: dropInformation.initAdjustHistory(nowDropHead.headId, dropGetAdjustHistorySize)
    // The headId comes from ViewModel's context (nowDropHead.headId), not from the ACK payload.
    // koralcore needs to track the headId from the command context when sending the request.
    // For now, using 0 as placeholder until command context tracking is implemented.
    session.initAdjustHistory(0, size);
    // PARITY: reef-b-app ViewModel triggers START/END based on size
    // If size > 0, ViewModel sets loading=true and waits for RETURN opcodes
    // If size == 0, ViewModel sets loading=false and shows empty history
    // Repository layer doesn't manage loading state, so no action needed
  }

  void _handleClearRecordAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x79, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    final bool success = (data[2] & 0xFF) == 0x01;
    if (success) {
      // PARITY: Verified against reef-b-app DropHeadRecordSettingViewModel.kt:705.
      // ViewModel calls: dropInformation.setMode(nowDropHead.headId, DropHeadMode())
      // The headId comes from ViewModel's context (nowDropHead.headId), not from the ACK payload.
      // koralcore needs to track the headId from the command context when sending the request.
      // For now, we can't clear mode without knowing which head to clear.
      // This will be fixed when command context tracking is implemented.
    }
    // PARITY: reef-b-app ViewModel only logs success/failure, no other state update
    // ACK is handled, no additional action needed (until we have headId context)
  }

  void _handleResetAck(_DeviceSession session, Uint8List data) {
    // PARITY: reef-b-app payload: [0x7D, len, result(0x00/0x01), checksum] = 4 bytes
    if (data.length != 4) {
      return; // Invalid payload
    }
    final bool success = (data[2] & 0xFF) == 0x01;
    if (success) {
      // PARITY: reef-b-app ViewModel calls resetDrop() which may trigger sync
      // For now, we clear information and request sync to refresh state
      session.clearInformation();
      _requestSync(session);
    }
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  void dispose() {
    _notifySubscription?.cancel();
    _connectionSubscription?.cancel();
    for (final _DeviceSession session in _sessions.values) {
      session.dosingStateController.close();
    }
    _sessions.clear();
  }
}

// ---------------------------------------------------------------------------
// Internal state management
// ---------------------------------------------------------------------------

/// Dose capability detection state.
/// PARITY: Matches reef-b-app's DoseCapability enum.
enum _DoseCapability {
  unknown, // 尚未確認（不是舊韌體）
  legacy7A, // 明確確認為舊韌體
  decimal7E, // 明確確認為新韌體
}

/// Device session for Dosing state management.
/// PARITY: Similar to _DeviceSession in BleLedRepositoryImpl.
class _DeviceSession {
  _DeviceSession({required this.deviceId})
    : state = DosingState.empty(deviceId),
      dosingStateController = StreamController<DosingState>.broadcast(),
      doseCapability = _DoseCapability.unknown,
      todayDoseMl = 0.0 {
    // Emit initial state when listener subscribes
    dosingStateController.onListen = () {
      dosingStateController.add(state);
    };
  }

  final String deviceId;
  DosingState state;
  bool syncInFlight = false;
  final StreamController<DosingState> dosingStateController;
  _DoseCapability doseCapability;

  /// Today's total dose volume in ml (0.1 ml precision for new firmware).
  ///
  /// PARITY: Matches reef-b-app's `todayDoseMl: Float` in BLEManager.
  /// Note: This is for BLE debugging purposes only, not displayed in UI,
  /// and not stored in DropInformation.
  double todayDoseMl;

  Stream<DosingState> get dosingStateStream => dosingStateController.stream;

  // Helper methods for state updates
  void clearInformation() {
    // PARITY: reef-b-app calls mode.replaceAll { DropHeadMode() }
    state = state.cleared();
  }

  void setMode(int headNo, PumpHeadMode mode) {
    // PARITY: reef-b-app calls this.mode[no] = mode
    state = state.withMode(headNo, mode);
  }

  PumpHeadMode getMode(int headNo) {
    // PARITY: reef-b-app calls this.mode[no]
    return state.getMode(headNo);
  }

  List<PumpHeadMode> getModes() {
    // PARITY: reef-b-app calls this.mode.toList()
    return state.pumpHeadModes;
  }

  void setRotatingSpeed(int headNo, int rotatingSpeed) {
    // PARITY: reef-b-app calls dropReturnRotatingRate(headNo, rotatingSpeed)
    final currentMode = state.getMode(headNo);
    final newMode = currentMode.copyWith(rotatingSpeed: rotatingSpeed);
    state = state.withMode(headNo, newMode);
  }

  void setDetail(int headNo, PumpHeadRecordDetail detail) {
    // PARITY: reef-b-app calls dropInformation.setDetail(headNo, detail)
    state = state.withAddedRecordDetail(headNo, detail);
  }

  void setDropVolume(
    int headId, {
    required double nonRecord,
    required double record,
  }) {
    // PARITY: reef-b-app calls dropInformation.setDropVolume(headId, nonRecord, record)
    state = state.withDropVolume(
      headNo: headId,
      recordDrop: record,
      otherDrop: nonRecord,
    );
  }

  // Track expected history size for each head
  final Map<int, int> _expectedHistorySize = {};

  void initAdjustHistory(int headNo, int size) {
    // PARITY: reef-b-app calls dropInformation.initAdjustHistory(headNo, size)
    // Initialize with empty list and track expected size
    _expectedHistorySize[headNo] = size;
    state = state.withAdjustHistory(headNo, []);
  }

  bool setHistory(int headNo, PumpHeadAdjustHistory history) {
    // PARITY: reef-b-app calls dropInformation.setHistory(headNo, history)
    final currentHistory = state.getAdjustHistory(headNo) ?? [];
    // PARITY: reef-b-app checks if history already exists
    if (currentHistory.contains(history)) {
      return false;
    }
    final newHistory = [...currentHistory, history];
    state = state.withAdjustHistory(headNo, newHistory);
    // PARITY: reef-b-app returns true when history is complete
    final expectedSize = _expectedHistorySize[headNo] ?? 0;
    return expectedSize > 0 && newHistory.length >= expectedSize;
  }
}
