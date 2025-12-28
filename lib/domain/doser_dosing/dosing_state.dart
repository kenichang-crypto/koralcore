library;

import 'pump_head_mode.dart';
import 'pump_head_adjust_history.dart';
import 'pump_head_record_detail.dart';

/// Dosing state representing the current state of all pump heads.
///
/// PARITY: Mirrors reef-b-app Android's DropInformation class.
///
/// This represents the **current state** of all pump heads as returned from
/// BLE sync operations. It manages 4 pump heads (indexed 0-3).
class DosingState {
  /// Device ID
  final String deviceId;

  /// Pump head modes (4 heads, indexed 0-3)
  final List<PumpHeadMode> pumpHeadModes;

  /// Adjust history for each pump head (4 heads, indexed 0-3)
  /// null means no history has been initialized or fetched
  final List<List<PumpHeadAdjustHistory>?> adjustHistory;

  /// Delay time in seconds (from opcode 0x66)
  final int? delayTime;

  const DosingState({
    required this.deviceId,
    required this.pumpHeadModes,
    required this.adjustHistory,
    this.delayTime,
  }) : assert(pumpHeadModes.length == 4,
          'pumpHeadModes must have exactly 4 elements'),
       assert(adjustHistory.length == 4,
          'adjustHistory must have exactly 4 elements');

  /// Creates an empty DosingState for a device
  factory DosingState.empty(String deviceId) {
    return DosingState(
      deviceId: deviceId,
      pumpHeadModes: List.generate(
        4,
        (_) => const PumpHeadMode(),
        growable: false,
      ),
      adjustHistory: List.filled(4, null),
    );
  }

  /// Gets the mode for a specific pump head (0-3)
  PumpHeadMode getMode(int headNo) {
    if (headNo >= 0 && headNo < pumpHeadModes.length) {
      return pumpHeadModes[headNo];
    }
    return const PumpHeadMode();
  }

  /// Gets the adjust history for a specific pump head (0-3)
  List<PumpHeadAdjustHistory>? getAdjustHistory(int headNo) {
    if (headNo >= 0 && headNo < adjustHistory.length) {
      return adjustHistory[headNo];
    }
    return null;
  }

  DosingState copyWith({
    String? deviceId,
    List<PumpHeadMode>? pumpHeadModes,
    List<List<PumpHeadAdjustHistory>?>? adjustHistory,
    int? delayTime,
  }) {
    return DosingState(
      deviceId: deviceId ?? this.deviceId,
      pumpHeadModes: pumpHeadModes ?? this.pumpHeadModes,
      adjustHistory: adjustHistory ?? this.adjustHistory,
      delayTime: delayTime ?? this.delayTime,
    );
  }

  /// Creates a new state with updated mode for a specific pump head
  DosingState withMode(int headNo, PumpHeadMode mode) {
    if (headNo < 0 || headNo >= pumpHeadModes.length) {
      return this;
    }
    final List<PumpHeadMode> newModes = List.from(pumpHeadModes);
    newModes[headNo] = mode;
    return copyWith(pumpHeadModes: newModes);
  }

  /// Creates a new state with updated adjust history for a specific pump head
  DosingState withAdjustHistory(
    int headNo,
    List<PumpHeadAdjustHistory> history,
  ) {
    if (headNo < 0 || headNo >= adjustHistory.length) {
      return this;
    }
    final List<List<PumpHeadAdjustHistory>?> newHistory =
        List.from(adjustHistory);
    newHistory[headNo] = history;
    return copyWith(adjustHistory: newHistory);
  }

  /// Creates a new state with added adjust history entry for a specific pump head
  DosingState withAddedAdjustHistory(
    int headNo,
    PumpHeadAdjustHistory history,
  ) {
    if (headNo < 0 || headNo >= adjustHistory.length) {
      return this;
    }
    final List<List<PumpHeadAdjustHistory>?> newHistory =
        List.from(adjustHistory);
    final List<PumpHeadAdjustHistory> currentHistory =
        newHistory[headNo] ?? [];
    if (!currentHistory.contains(history)) {
      newHistory[headNo] = [...currentHistory, history];
    }
    return copyWith(adjustHistory: newHistory);
  }

  /// Creates a new state with updated drop volume for a specific pump head
  DosingState withDropVolume({
    required int headNo,
    required double recordDrop,
    double? otherDrop,
  }) {
    if (headNo < 0 || headNo >= pumpHeadModes.length) {
      return this;
    }
    final PumpHeadMode currentMode = pumpHeadModes[headNo];
    final PumpHeadMode newMode = currentMode.copyWith(
      recordDrop: recordDrop,
      otherDrop: otherDrop,
    );
    return withMode(headNo, newMode);
  }

  /// Creates a new state with added record detail for a specific pump head.
  ///
  /// PARITY: Mirrors reef-b-app's setDetail() behavior:
  /// - Checks if detail with same timeString already exists
  /// - If not exists, adds detail and updates totalDrop
  DosingState withAddedRecordDetail(
    int headNo,
    PumpHeadRecordDetail detail,
  ) {
    if (headNo < 0 || headNo >= pumpHeadModes.length) {
      return this;
    }
    final PumpHeadMode currentMode = pumpHeadModes[headNo];
    // PARITY: reef-b-app checks if detail already exists by timeString
    final bool exists = currentMode.recordDetail.any(
      (d) => d.timeString == detail.timeString,
    );
    if (exists) {
      // PARITY: reef-b-app does nothing if detail already exists
      return this;
    }
    // PARITY: reef-b-app adds detail.totalDrop to current totalDrop
    final int newTotalDrop =
        (currentMode.totalDrop ?? 0) + detail.totalDrop;
    final List<PumpHeadRecordDetail> newDetails = [
      ...currentMode.recordDetail,
      detail,
    ];
    final PumpHeadMode newMode = currentMode.copyWith(
      totalDrop: newTotalDrop,
      recordDetail: newDetails,
    );
    return withMode(headNo, newMode);
  }

  /// Creates a new state with cleared information (all modes reset)
  DosingState cleared() {
    return DosingState.empty(deviceId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DosingState &&
        other.deviceId == deviceId &&
        _listEquals(other.pumpHeadModes, pumpHeadModes) &&
        _listEquals(other.adjustHistory, adjustHistory) &&
        other.delayTime == delayTime;
  }

  @override
  int get hashCode => Object.hash(
        deviceId,
        pumpHeadModes,
        adjustHistory,
        delayTime,
      );

  @override
  String toString() =>
      'DosingState(deviceId: $deviceId, pumpHeadModes: $pumpHeadModes, '
      'adjustHistory: $adjustHistory, delayTime: $delayTime)';

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

