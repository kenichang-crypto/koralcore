library;

import 'ble_uuid.dart';

/// Utility for filtering BLE device names during scanning.
/// 
/// PARITY: Matches reef-b-app's device name filtering logic:
/// - Android: BluetoothViewModel.scanResult() checks for "koralDOSE", "coralDOSE", "koralLED", "coralLED"
/// - iOS: NNScanner uses scanFilter.names with ["koralDOSE", "coralDOSE", "koralLED", "coralLED"]
class DeviceNameFilter {
  DeviceNameFilter._();

  /// All valid device name prefixes (case-insensitive).
  /// 
  /// PARITY: reef-b-app checks for:
  /// - "koralDOSE" / "coralDOSE" (Dosing devices)
  /// - "koralLED" / "coralLED" (LED devices)
  static const List<String> validPrefixes = <String>[
    'koralDOSE',
    'coralDOSE',
    'koralLED',
    'coralLED',
  ];

  /// Check if a device name matches the filter criteria.
  /// 
  /// PARITY: Matches reef-b-app's logic:
  /// - Returns false if name is null or empty
  /// - Returns true if name contains any valid prefix (case-insensitive)
  /// 
  /// Example:
  /// - "coralLED EX" -> true
  /// - "coralDOSE 4H" -> true
  /// - "koralLED" -> true
  /// - "SomeOtherDevice" -> false
  /// - null -> false
  /// - "" -> false
  static bool matches(String? deviceName) {
    if (deviceName == null || deviceName.isEmpty) {
      return false;
    }

    final lowerName = deviceName.toLowerCase();
    for (final prefix in validPrefixes) {
      if (lowerName.contains(prefix.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  /// Check if a device name matches a specific device type.
  /// 
  /// Returns:
  /// - true if name matches LED device pattern
  /// - false otherwise
  static bool isLedDevice(String? deviceName) {
    if (deviceName == null || deviceName.isEmpty) {
      return false;
    }

    final lowerName = deviceName.toLowerCase();
    return lowerName.contains('led');
  }

  /// Check if a device name matches a specific device type.
  /// 
  /// Returns:
  /// - true if name matches Dosing device pattern
  /// - false otherwise
  static bool isDosingDevice(String? deviceName) {
    if (deviceName == null || deviceName.isEmpty) {
      return false;
    }

    final lowerName = deviceName.toLowerCase();
    return lowerName.contains('dose');
  }

  /// Get the device type from device name.
  /// 
  /// Returns:
  /// - "LED" if name matches LED pattern
  /// - "DROP" if name matches Dosing pattern
  /// - null if name doesn't match any pattern
  static String? getDeviceType(String? deviceName) {
    if (isLedDevice(deviceName)) {
      return 'LED';
    }
    if (isDosingDevice(deviceName)) {
      return 'DROP';
    }
    return null;
  }

  /// Filter a list of device names, returning only those that match.
  /// 
  /// PARITY: This can be used to filter scan results before processing.
  static List<String> filter(List<String?> deviceNames) {
    return deviceNames
        .where((name) => matches(name))
        .map((name) => name!)
        .toList();
  }
}

