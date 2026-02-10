/// ConnectDeviceUseCase
///
/// Orchestrates establishing a BLE connection to a device.
///
/// Execution order:
/// 1. Set state -> connecting
/// 2. Call BLE adapter to connect (adapter: bleAdapter.connect(deviceId))
/// 3. Await connection success/failure
/// 4. On success -> trigger InitializeDeviceUseCase
/// 5. On failure -> set state -> disconnected / error
///
/// Adapters / Repositories called:
/// - BLE Adapter (connect/observe connection state)
/// - Local device repository (mark connected)
/// - Application: InitializeDeviceUseCase (on success)
///
library;

import '../../domain/device/capability_set.dart';
import '../../domain/device/device_context.dart';
import '../../domain/device/device_product.dart';
import '../../domain/device/firmware_version.dart';
import '../../platform/contracts/device_repository.dart';
import '../common/app_error.dart';
import '../common/app_error_code.dart';
import '../session/current_device_session.dart';
import 'initialize_device_usecase.dart';

class ConnectDeviceUseCase {
  final DeviceRepository deviceRepository;
  final CurrentDeviceSession currentDeviceSession;
  final InitializeDeviceUseCase initializeDeviceUseCase;

  ConnectDeviceUseCase({
    required this.deviceRepository,
    required this.currentDeviceSession,
    required this.initializeDeviceUseCase,
  });

  Future<void> execute({required String deviceId}) async {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.invalidParam,
        message: 'deviceId must not be empty',
      );
    }

    await deviceRepository.updateDeviceState(deviceId, 'connecting');

    try {
      await deviceRepository.connect(deviceId);
      await deviceRepository.setCurrentDevice(deviceId);

      // KC-A3-Final: Explicitly removed direct call to InitializeDeviceUseCase.
      // Logic moved to DeviceConnectionCoordinator to enforce "Reconnect == Fresh Connect" semantics.
      // The coordinator observes the native connection stream and triggers initialization.
      // 
      // await initializeDeviceUseCase.execute(deviceId: deviceId);
    } on AppError {
      rethrow;
    } catch (error) {
      await deviceRepository.updateDeviceState(deviceId, 'disconnected');
      throw AppError(
        code: AppErrorCode.transportError,
        message: 'Failed to connect: $error',
      );
    }
  }
}
