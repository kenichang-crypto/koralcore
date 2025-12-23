import '../doser/apply_schedule_usecase.dart';
import '../doser/schedule_result.dart';
import '../doser/single_dose_immediate_usecase.dart';
import '../doser/single_dose_timed_usecase.dart';
import '../led/apply_led_schedule_usecase.dart';
import '../led/led_schedule_result.dart';
import '../../domain/doser_dosing/pump_speed.dart';
import '../../domain/doser_dosing/single_dose_immediate.dart';
import '../../domain/doser_dosing/single_dose_timed.dart';
import '../../domain/doser_schedule/custom_window_schedule_definition.dart';
import '../../domain/doser_schedule/daily_average_schedule_definition.dart';
import '../../domain/doser_schedule/schedule_weekday.dart';
import '../../domain/led_lighting/led_channel.dart';
import '../../domain/led_lighting/led_channel_group.dart';
import '../../domain/led_lighting/led_channel_value.dart';
import '../../domain/led_lighting/led_daily_schedule.dart';
import '../../domain/led_lighting/led_intensity.dart';
import '../../domain/led_lighting/led_schedule.dart';
import '../../domain/led_lighting/led_schedule_type.dart';
import '../../domain/led_lighting/led_spectrum.dart';
import '../../domain/led_lighting/time_of_day.dart';
import '../../domain/led_lighting/weekday.dart';

/// Runs a canned end-to-end BLE command sequence so developers can observe the
/// hardened transport queue in action. Each invocation sends:
/// 1. Immediate single dose (BLE 0x6E)
/// 2. Timed single dose (BLE 0x6F)
/// 3. Daily average schedule (BLE 0x70)
/// 4. Custom window schedule (BLE 0x72/0x73/0x74 as needed)
/// 5. LED daily schedule (BLE 0x81)
class BleTransportDebugPlaybook {
  final SingleDoseImmediateUseCase singleDoseImmediateUseCase;
  final SingleDoseTimedUseCase singleDoseTimedUseCase;
  final ApplyScheduleUseCase applyScheduleUseCase;
  final ApplyLedScheduleUseCase applyLedScheduleUseCase;

  const BleTransportDebugPlaybook({
    required this.singleDoseImmediateUseCase,
    required this.singleDoseTimedUseCase,
    required this.applyScheduleUseCase,
    required this.applyLedScheduleUseCase,
  });

  Future<BleTransportDebugReport> runSampleSequence({
    required String deviceId,
  }) async {
    await singleDoseImmediateUseCase.execute(
      deviceId: deviceId,
      dose: _sampleImmediateDose(),
    );

    await singleDoseTimedUseCase.execute(
      deviceId: deviceId,
      dose: _sampleTimedDose(),
    );

    final ScheduleResult dailyAverageResult = await applyScheduleUseCase
        .applyDailyAverageSchedule(
          deviceId: deviceId,
          schedule: _sampleDailyScheduleDefinition(deviceId),
        );

    final ScheduleResult customWindowResult = await applyScheduleUseCase
        .applyCustomWindowSchedule(
          deviceId: deviceId,
          schedule: _sampleCustomWindowScheduleDefinition(deviceId),
        );

    final LedScheduleResult ledScheduleResult = await applyLedScheduleUseCase
        .execute(
          deviceId: deviceId,
          scheduleId: 'daily_curve',
          schedule: _sampleLedSchedule(),
        );

    return BleTransportDebugReport(
      immediateDoseSent: true,
      timedDoseScheduled: true,
      dailyAverageResult: dailyAverageResult,
      customWindowResult: customWindowResult,
      ledScheduleResult: ledScheduleResult,
    );
  }

  SingleDoseImmediate _sampleImmediateDose() {
    return const SingleDoseImmediate(
      pumpId: 1,
      doseMl: 2.5,
      speed: PumpSpeed.medium,
    );
  }

  SingleDoseTimed _sampleTimedDose() {
    final DateTime target = DateTime.now().add(const Duration(minutes: 3));
    return SingleDoseTimed(
      pumpId: 1,
      doseMl: 3.0,
      speed: PumpSpeed.high,
      executeAt: target,
    );
  }

  DailyAverageScheduleDefinition _sampleDailyScheduleDefinition(
    String deviceId,
  ) {
    return DailyAverageScheduleDefinition(
      scheduleId: 'debug-daily-$deviceId',
      pumpId: 1,
      repeatDays: <ScheduleWeekday>{
        ScheduleWeekday.monday,
        ScheduleWeekday.wednesday,
        ScheduleWeekday.friday,
      },
      slots: <DailyDoseSlot>[
        DailyDoseSlot(hour: 9, minute: 0, doseMl: 1.0, speed: PumpSpeed.medium),
        DailyDoseSlot(hour: 18, minute: 30, doseMl: 1.2, speed: PumpSpeed.high),
      ],
    );
  }

  CustomWindowScheduleDefinition _sampleCustomWindowScheduleDefinition(
    String deviceId,
  ) {
    return CustomWindowScheduleDefinition(
      scheduleId: 'debug-window-$deviceId',
      pumpId: 1,
      chunks: <ScheduleWindowChunk>[
        ScheduleWindowChunk(
          chunkIndex: 0,
          windowStartMinute: 8 * 60,
          windowEndMinute: 10 * 60,
          events: <WindowDoseEvent>[
            WindowDoseEvent(minuteOffset: 5, doseMl: 0.8, speed: PumpSpeed.low),
            WindowDoseEvent(
              minuteOffset: 40,
              doseMl: 1.2,
              speed: PumpSpeed.medium,
            ),
          ],
        ),
      ],
    );
  }

  LedSchedule _sampleLedSchedule() {
    return LedSchedule(
      type: LedScheduleType.daily,
      daily: LedDailySchedule(
        channelGroup: LedChannelGroup.fullSpectrum,
        points: <LedDailyPoint>[
          LedDailyPoint(
            time: const TimeOfDay(hour: 9, minute: 0),
            spectrum: _spectrum(<int>[120, 80, 64, 90, 45]),
          ),
          LedDailyPoint(
            time: const TimeOfDay(hour: 19, minute: 30),
            spectrum: _spectrum(<int>[190, 150, 120, 200, 80]),
          ),
        ],
        repeatOn: const <Weekday>[Weekday.mon, Weekday.wed, Weekday.fri],
      ),
    );
  }

  LedSpectrum _spectrum(List<int> values) {
    if (values.length != LedChannelGroup.fullSpectrum.channelOrder.length) {
      throw StateError('Spectrum sample must include 5 channel values.');
    }
    final List<LedChannelValue> channels = <LedChannelValue>[];
    final List<LedChannel> order = LedChannelGroup.fullSpectrum.channelOrder;
    for (int i = 0; i < order.length; i++) {
      channels.add(
        LedChannelValue(channel: order[i], intensity: LedIntensity(values[i])),
      );
    }
    return LedSpectrum(
      channelGroup: LedChannelGroup.fullSpectrum,
      channels: channels,
    );
  }
}

/// Captures the outcome of the debug sequence so callers can surface the
/// status inside tooling or UI panels.
class BleTransportDebugReport {
  final bool immediateDoseSent;
  final bool timedDoseScheduled;
  final ScheduleResult dailyAverageResult;
  final ScheduleResult customWindowResult;
  final LedScheduleResult ledScheduleResult;

  const BleTransportDebugReport({
    required this.immediateDoseSent,
    required this.timedDoseScheduled,
    required this.dailyAverageResult,
    required this.customWindowResult,
    required this.ledScheduleResult,
  });

  bool get allSucceeded =>
      immediateDoseSent &&
      timedDoseScheduled &&
      dailyAverageResult.isSuccess &&
      customWindowResult.isSuccess &&
      ledScheduleResult.isSuccess;
}
