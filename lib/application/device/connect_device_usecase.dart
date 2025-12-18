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

import '../../platform/contracts/device_repository.dart';

class ConnectDeviceUseCase {
  final DeviceRepository deviceRepository;

  ConnectDeviceUseCase({required this.deviceRepository});

  Future<void> execute({required String deviceId}) async {
    // 1) Set state: connecting
    // TODO: notify presentation

    // 2) Call BLE adapter to connect
    // TODO: await bleAdapter.connect(deviceId)

    // 3) Wait for connection result
    // TODO: if success -> call InitializeDeviceUseCase.execute(deviceId)
    // TODO: if failure -> set state disconnected and return error
    // Note: deviceRepository may be used to mark connecting state
    await deviceRepository.updateDeviceState(deviceId, 'connecting');
  }
}
