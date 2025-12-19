library;

import 'dart:async';

import '../../platform/contracts/device_repository.dart';
import 'device_snapshot.dart';

/// Scans for BLE devices and exposes the live repository stream as typed data.
class ScanDevicesUseCase {
  final DeviceRepository deviceRepository;

  ScanDevicesUseCase({required this.deviceRepository});

  /// Triggers a scan and returns the snapshot captured at the end of the scan.
  Future<List<DeviceSnapshot>> execute({Duration? timeout}) async {
    final results = await deviceRepository.scanDevices(timeout: timeout);
    return results.map(DeviceSnapshot.fromMap).toList(growable: false);
  }

  /// Observes the repository for changes to the device list.
  Stream<List<DeviceSnapshot>> observe() {
    return deviceRepository.observeDevices().map(
      (items) => items.map(DeviceSnapshot.fromMap).toList(growable: false),
    );
  }
}
