/// BLE scan service using FlutterBluePlus.
///
/// Provides real platform BLE scanning. Scan results include deviceId, name, RSSI.
/// PARITY: reef-b-app BLEManager.scanLeDevice() / BluetoothViewModel.scanResult()
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'device_name_filter.dart';

/// Descriptor for a discovered BLE device.
class BleScanResult {
  final String deviceId;
  final String name;
  final int rssi;
  final List<String> serviceUuids;

  const BleScanResult({
    required this.deviceId,
    required this.name,
    required this.rssi,
    required this.serviceUuids,
  });

  Map<String, dynamic> toMap() => {
        'id': deviceId,
        'name': name,
        'rssi': rssi,
        'state': 'disconnected',
      };
}

/// Performs real BLE scanning via FlutterBluePlus.
///
/// Stream-based: emits results as they arrive via [onUpdate] callback during scan.
class BleScanService {
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  Future<void> _waitUntilBleReady() async {
    try {
      await FlutterBluePlus.adapterState
          .where((state) => state == BluetoothAdapterState.on)
          .timeout(const Duration(seconds: 5))
          .first;
    } catch (_) {
      throw Exception('Bluetooth adapter not ready');
    }
  }

  /// Run a BLE scan. Returns discovered devices (filtered by reef-b-app names).
  /// Calls [onUpdate] with cumulative results as scan progresses.
  Future<List<BleScanResult>> runScan({
    Duration? timeout,
    void Function(List<BleScanResult>)? onUpdate,
    Set<String>? skipDeviceIds,
  }) async {
    try {
      final List<BluetoothDevice> connected =
          await FlutterBluePlus.connectedDevices;
      if (connected.isNotEmpty) {
        debugPrint(
          'BleScanService - scan skipped: device already connected (${connected.map((d) => d.id.toString()).join(', ')})',
        );
        return const <BleScanResult>[];
      }
    } catch (e) {
      debugPrint('BleScanService - connectedDevices check failed: $e');
    }
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    final Map<String, BleScanResult> seen = {};

    void emitCurrent() {
      final list = List<BleScanResult>.from(seen.values)
        ..sort((a, b) => b.rssi.compareTo(a.rssi)); // Strongest signal first
      onUpdate?.call(list);
    }

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final sr in results) {
        final String deviceId = sr.device.remoteId.str;
        if (skipDeviceIds != null && skipDeviceIds.contains(deviceId)) {
          continue;
        }
        String name = sr.advertisementData.advName.trim();
        if (name.isEmpty) {
          name = sr.device.name.trim();
        }
        // PARITY: reef-b-app filters by koralDOSE, coralDOSE, koralLED, coralLED
        if (!DeviceNameFilter.matches(name)) {
          continue;
        }
        // final deviceId = sr.device.remoteId.str;
        seen[deviceId] = BleScanResult(
          deviceId: deviceId,
          name: name.isNotEmpty ? name : 'Unknown',
          rssi: sr.rssi,
          serviceUuids: sr.advertisementData.serviceUuids
                  ?.map((uuid) => uuid.toString())
                  .toList(growable: false) ??
              const <String>[],
        );
      }
      emitCurrent();
    });

    try {
      await _waitUntilBleReady();

      final duration = timeout ?? const Duration(seconds: 10);
      await FlutterBluePlus.startScan(timeout: duration);
      // On some Android devices startScan() returns immediately; wait for both
      // scan end signal and minimum duration so the scan actually runs.
      await Future.wait([
        FlutterBluePlus.isScanning.where((v) => v == false).first,
        Future.delayed(duration),
      ]);

      debugPrint('BleScanService - 藍芽掃描: 掃描完成，發現 ${seen.length} 個裝置');
    } catch (e) {
      debugPrint('BleScanService - scan error: $e');
      rethrow;
    } finally {
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
    }

    return List<BleScanResult>.from(seen.values)
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
  }

  /// Stops any ongoing scan and cleans up subscriptions.
  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
  }
}
