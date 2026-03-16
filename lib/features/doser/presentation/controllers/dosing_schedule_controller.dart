import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../data/ble/ble_adapter.dart';
import '../../../../data/ble/dosing/dosing_command_builder.dart';

/// Sends dosing schedule BLE commands (0x6E~0x74).
class DosingScheduleController {
  final BleAdapter bleAdapter;
  final DosingCommandBuilder commandBuilder;

  DosingScheduleController({
    required this.bleAdapter,
    required this.commandBuilder,
  });

  Future<void> createSingleImmediately({
    required String deviceId,
    required int headNo,
    required int volumeMl,
    required int speed,
  }) async {
    final cmd = commandBuilder.singleDropImmediately(
      headNo: headNo,
      volume: _toProtocolVolume(volumeMl),
      speed: speed,
    );
    await bleAdapter.writeBytes(deviceId: deviceId, data: cmd);
  }

  Future<void> createSingleTimely({
    required String deviceId,
    required int headNo,
    required DateTime runAt,
    required int volumeMl,
    required int speed,
  }) async {
    final cmd = commandBuilder.singleDropTimely(
      headNo: headNo,
      year: runAt.year,
      month: runAt.month,
      day: runAt.day,
      hour: runAt.hour,
      minute: runAt.minute,
      volume: _toProtocolVolume(volumeMl),
      speed: speed,
    );
    await bleAdapter.writeBytes(deviceId: deviceId, data: cmd);
  }

  Future<void> create24Weekly({
    required String deviceId,
    required int headNo,
    required bool monday,
    required bool tuesday,
    required bool wednesday,
    required bool thursday,
    required bool friday,
    required bool saturday,
    required bool sunday,
    required int volumeMl,
    required int speed,
  }) async {
    final cmd = commandBuilder.h24DropWeekly(
      headNo: headNo,
      monday: monday,
      tuesday: tuesday,
      wednesday: wednesday,
      thursday: thursday,
      friday: friday,
      saturday: saturday,
      sunday: sunday,
      volume: _toProtocolVolume(volumeMl),
      speed: speed,
    );
    await bleAdapter.writeBytes(deviceId: deviceId, data: cmd);
  }

  Future<void> create24Range({
    required String deviceId,
    required int headNo,
    required DateTime startDate,
    required DateTime endDate,
    required int volumeMl,
    required int speed,
  }) async {
    final cmd = commandBuilder.h24DropRange(
      headNo: headNo,
      startYear: startDate.year,
      startMonth: startDate.month,
      startDay: startDate.day,
      endYear: endDate.year,
      endMonth: endDate.month,
      endDay: endDate.day,
      volume: _toProtocolVolume(volumeMl),
      speed: speed,
    );
    await bleAdapter.writeBytes(deviceId: deviceId, data: cmd);
  }

  Future<void> createCustomWeekly({
    required String deviceId,
    required int headNo,
    required bool monday,
    required bool tuesday,
    required bool wednesday,
    required bool thursday,
    required bool friday,
    required bool saturday,
    required bool sunday,
    required int count,
  }) async {
    final cmd = commandBuilder.customDropWeekly(
      headNo: headNo,
      monday: monday,
      tuesday: tuesday,
      wednesday: wednesday,
      thursday: thursday,
      friday: friday,
      saturday: saturday,
      sunday: sunday,
      count: count,
    );
    await bleAdapter.writeBytes(deviceId: deviceId, data: cmd);
  }

  Future<void> createCustomRange({
    required String deviceId,
    required int headNo,
    required DateTime startDate,
    required DateTime endDate,
    required int count,
  }) async {
    final cmd = commandBuilder.customDropRange(
      headNo: headNo,
      startYear: startDate.year,
      startMonth: startDate.month,
      startDay: startDate.day,
      endYear: endDate.year,
      endMonth: endDate.month,
      endDay: endDate.day,
      count: count,
    );
    await bleAdapter.writeBytes(deviceId: deviceId, data: cmd);
  }

  Future<void> createCustomDetail({
    required String deviceId,
    required int headNo,
    required TimeOfDay start,
    required TimeOfDay end,
    required int times,
    required int volumeMl,
    required int speed,
  }) async {
    final cmd = commandBuilder.customDropDetail(
      headNo: headNo,
      startHour: start.hour,
      startMinute: start.minute,
      endHour: end.hour,
      endMinute: end.minute,
      times: times,
      volume: _toProtocolVolume(volumeMl),
      speed: speed,
    );
    await bleAdapter.writeBytes(deviceId: deviceId, data: cmd);
  }

  Future<void> clearSchedule({
    required String deviceId,
    required int headNo,
  }) async {
    final Uint8List command = commandBuilder.clearRecord(headNo);
    await bleAdapter.writeBytes(deviceId: deviceId, data: command);
  }

  int _toProtocolVolume(int volumeMl) => volumeMl * 10;
}
