import '../../../app/common/app_error.dart';
import '../../../app/common/app_error_code.dart';

/// UpdatePumpHeadSettingsUseCase
///
/// Placeholder use case for updating pump head settings.
/// Actual BLE wiring will be connected once transport surfaces the APIs.
///
/// PARITY: Corresponds to reef-b-app's pump head settings update:
/// - DropHeadSettingActivity: updates drop head name, delay time, drop type
/// - DropHeadSettingViewModel: saves settings to database via DropHeadDao
/// - Settings include: name, delayTime, dropTypeId, maxDrop
/// - On save: updates database and refreshes UI
class UpdatePumpHeadSettingsUseCase {
  const UpdatePumpHeadSettingsUseCase();

  Future<void> execute({
    required String deviceId,
    required String headId,
    required String name,
    required int delaySeconds,
  }) async {
    if (name.trim().isEmpty) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'Pump head name cannot be empty.',
      );
    }

    // Simulate BLE round trip for now.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
