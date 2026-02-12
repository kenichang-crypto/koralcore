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

  const BleScanResult({
    required this.deviceId,
    required this.name,
    required this.rssi,
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

  /// Run a BLE scan. Returns discovered devices (filtered by reef-b-app names).
  /// Calls [onUpdate] with cumulative results as scan progresses.
  Future<List<BleScanResult>> runScan({
    Duration? timeout,
    void Function(List<BleScanResult>)? onUpdate,
  }) async {
    if (await FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }

    final Map<String, BleScanResult> seen = {};

    void emitCurrent() {
      final list = List<BleScanResult>.from(seen.values)
        ..sort((a, b) => b.rssi.compareTo(a.rssi)); // Strongest signal first
      onUpdate?.call(list);
    }

    _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
      for (final sr in results) {
        final name = sr.advertisementData.advName.trim();
        // PARITY: reef-b-app filters by koralDOSE, coralDOSE, koralLED, coralLED
        if (!DeviceNameFilter.matches(name)) {
          continue;
        }
        final deviceId = sr.device.remoteId.str;
        seen[deviceId] = BleScanResult(
          deviceId: deviceId,
          name: name.isNotEmpty ? name : 'Unknown', // Empty adv name fallback
          rssi: sr.rssi,
        );
      }
      emitCurrent();
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: timeout ?? const Duration(seconds: 10),
      );
      debugPrint('BleScanService - 藍芽掃描: 掃描完成，發現 ${seen.length} 個裝置');
    } catch (e) {
      debugPrint('BleScanService - 藍芽掃描: 掃描錯誤 $e');
      rethrow;
    } finally {
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      await FlutterBluePlus.stopScan();
    }

    return List<BleScanResult>.from(seen.values)
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
  }
}
