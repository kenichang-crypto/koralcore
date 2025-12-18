/// ScanDevicesUseCase
///
/// Application-level orchestration for scanning BLE devices.
/// This file is a skeleton that documents the execution order,
/// the adapters/repositories to call, and the state transitions.
///
/// Execution order:
/// 1. Set state -> scanning
/// 2. Invoke BLE adapter to start scan (adapter: BLEAdapter.scan)
/// 3. Collect device advertisement events (name, rssi)
/// 4. Return devices list; set state -> idle (or stopped)
///
/// Adapters / Repositories called:
/// - Platform BLE adapter (e.g. `bleAdapter.scan()`)
/// - Local device repository to mark discovered (optional)
///
/// State transitions:
/// - idle -> scanning -> idle
///
library;

import '../../platform/contracts/device_repository.dart';

class ScanDevicesUseCase {
  final DeviceRepository deviceRepository;

  ScanDevicesUseCase({required this.deviceRepository});

  /// Starts scanning for devices.
  /// Returns a future that completes when scanning stops or times out.
  Future<void> execute({Duration? timeout}) async {
    // 1) Set state: scanning
    // TODO: notify presentation layer / use a stream

    // 2) Call BLE adapter to start scanning
    // TODO: call: bleAdapter.startScan(timeout: timeout)
    // uses DeviceRepository.scanDevices
    final devices = await deviceRepository.scanDevices(timeout: timeout);
    // TODO: map `devices` to presentation model

    // 3) Collect events
    // TODO: on each advertisement -> map to Presentation model (name, rssi)

    // 4) End scan and set state -> idle
    // TODO: bleAdapter.stopScan(); notify presentation
    // TODO: return or emit `devices`
  }
}
