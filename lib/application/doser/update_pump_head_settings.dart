import '../common/app_error.dart';
import '../common/app_error_code.dart';

/// Placeholder use case for updating pump head settings.
/// Actual BLE wiring will be connected once transport surfaces the APIs.
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
