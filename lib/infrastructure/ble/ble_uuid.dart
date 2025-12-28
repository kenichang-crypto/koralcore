/// BLE UUID constants for LED and Dosing devices.
///
/// These UUIDs match the definitions in reef-b-app's UUID.kt file.
library;

/// LED device BLE service UUID.
const String uuidLedService = '00010203-0405-0607-0809-0a0b0c0dffc0';

/// LED device BLE write characteristic UUID.
const String uuidLedWrite = '00010203-0405-0607-0809-0a0b0c0dffc3';

/// LED device BLE notify characteristic UUID.
const String uuidLedNotify = '00010203-0405-0607-0809-0a0b0c0dffc1';

/// Dosing device BLE service UUID.
const String uuidDropService = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';

/// Dosing device BLE write characteristic UUID.
const String uuidDropWrite = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';

/// Dosing device BLE notify characteristic UUID.
const String uuidDropNotify = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';

/// LED device name for scanning filter.
///
/// Note: Originally "ReefLED 90W", changed to "coralLED EX" per reef-b-app.
const String ledDeviceName = 'coralLED EX';

/// Dosing device name for scanning filter.
const String dropDeviceName = 'coralDOSE 4H';

/// All LED-related UUIDs.
const List<String> ledUuids = <String>[
  uuidLedService,
  uuidLedWrite,
  uuidLedNotify,
];

/// All Dosing-related UUIDs.
const List<String> dropUuids = <String>[
  uuidDropService,
  uuidDropWrite,
  uuidDropNotify,
];

/// All device names for scanning filter.
const List<String> deviceNames = <String>[
  ledDeviceName,
  dropDeviceName,
];

/// All service UUIDs.
const List<String> serviceUuids = <String>[
  uuidLedService,
  uuidDropService,
];

/// All characteristic UUIDs.
const List<String> characteristicUuids = <String>[
  uuidLedWrite,
  uuidLedNotify,
  uuidDropWrite,
  uuidDropNotify,
];

