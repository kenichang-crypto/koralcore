import '../../domain/doser_dosing/doser_schedule.dart';
import '../../domain/doser_dosing/doser_schedule_type.dart';
import '../../platform/contracts/device_repository.dart';

/// ScheduleResult
///
/// Lightweight success/failure result for scheduling operations.
class ScheduleResult {
  final bool isSuccess;
  final String? reason;

  const ScheduleResult._({required this.isSuccess, this.reason});

  const ScheduleResult.success() : this._(isSuccess: true);

  const ScheduleResult.failure({String? reason})
    : this._(isSuccess: false, reason: reason);
}

/// ApplyScheduleUseCase
///
/// Application orchestration for applying a `DoserSchedule` to the current
/// device. Manual / single commands (BLE 15/16) are **not** handled here.
class ApplyScheduleUseCase {
  final DeviceRepository deviceRepository;

  const ApplyScheduleUseCase({required this.deviceRepository});

  /// Executes the scheduling flow.
  ///
  Future<ScheduleResult> execute({required DoserSchedule schedule}) async {
    // 1) TODO: deviceRepository.getCurrentDevice() to ensure we act on the
    //    correct target and load product/capability metadata.

    // 2) NOTE: Schedule is assumed valid; caller must invoke
    //    DoserScheduleValidator beforehand (Application layer does not repeat
    //    domain validation).

    // 3) TODO: Determine if the current device supports oneshot_schedule
    //    (BLE commands 32–34). Only koralDose 4K should pass this check.

    // 4) TODO: Branch based on schedule.type (manual / BLE 15 / BLE 16 are
    //    intentionally excluded from this UseCase).
    switch (schedule.type) {
      case DoserScheduleType.h24:
      case DoserScheduleType.custom:
        // TODO: Invoke existing schedule BLE flow for 24h/custom via
        //    deviceRepository.applySchedule(...) or equivalent adapter call.
        // TODO: Return ScheduleResult.success() once BLE command finishes.
        return const ScheduleResult.failure(
          reason: 'ApplyScheduleUseCase (h24/custom) not implemented yet',
        );

      case DoserScheduleType.oneshotSchedule:
        // TODO: Ensure device capability/productId confirms koralDose 4K.
        // TODO: Invoke BLE 32–34 builder flow via deviceRepository adapter
        //    hooks (no BLE implementation here).
        // TODO: Return ScheduleResult.success() once BLE chain finishes.
        return const ScheduleResult.failure(
          reason: 'ApplyScheduleUseCase (oneshot) not implemented yet',
        );
    }
  }
}
