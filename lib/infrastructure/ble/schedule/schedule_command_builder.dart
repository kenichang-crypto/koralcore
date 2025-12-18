import '../../../domain/doser_dosing/doser_schedule.dart';
import '../../../domain/doser_dosing/doser_schedule_type.dart';

import 'custom_schedule_builder.dart';
import 'h24_schedule_builder.dart';
import 'oneshot_schedule_builder.dart';

/// Central entry point to convert a `DoserSchedule` into a BLE payload.
List<int> buildScheduleCommand(DoserSchedule schedule) {
	switch (schedule.type) {
		case DoserScheduleType.h24:
			return buildH24ScheduleCommand(schedule);
		case DoserScheduleType.custom:
			return buildCustomScheduleCommand(schedule);
		case DoserScheduleType.oneshotSchedule:
			return buildOneshotScheduleCommand(schedule);
		default:
			throw UnsupportedError('Unsupported schedule type: ${schedule.type}');
	}
}
import '...??'