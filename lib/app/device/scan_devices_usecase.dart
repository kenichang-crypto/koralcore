library;

import 'dart:async';

import '../../data/ble/ble_scan_service.dart';
import '../../platform/contracts/device_repository.dart';
import 'device_snapshot.dart';

/// Scans for BLE devices and exposes the live repository stream as typed data.
class ScanDevicesUseCase {
  final DeviceRepository deviceRepository;

  ScanDevicesUseCase({required this.deviceRepository});

  /// Triggers a scan and returns BLE scan results.
  Future<List<BleScanResult>> execute({Duration? timeout}) {
    return deviceRepository.scanDevices(timeout: timeout);
  }

  /// Observes the repository for changes to the device list.
  Stream<List<DeviceSnapshot>> observe() {
    return deviceRepository.observeDevices().map(
      (items) => items.map(DeviceSnapshot.fromMap).toList(growable: false),
    );
  }
}
