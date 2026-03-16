# BLE Scan Rules

This document defines the BLE scanning behavior used by the Reef B application.

The Flutter implementation must reproduce the scanning behavior of the existing Android and iOS applications.

BLE scanning is responsible for:

- discovering nearby Reef B devices
- displaying available devices to the user
- enabling device connection

Scanning must be efficient and must not interfere with existing device connections.

---

# Scan Lifecycle

Scanning occurs during the following conditions:

application launch

user navigates to device discovery screen

user manually triggers device scan

device reconnect attempt

---

# Scan State

Scanning follows a simple lifecycle.

SCAN_IDLE

SCAN_ACTIVE

SCAN_TIMEOUT

SCAN_STOPPED

---

# SCAN_IDLE

The BLE adapter is idle.

No scanning activity.

Entry Conditions

application startup

scan completed

scan cancelled

Exit Condition

scan requested

Transition

SCAN_IDLE → SCAN_ACTIVE

---

# SCAN_ACTIVE

The BLE adapter is actively scanning for nearby devices.

Entry Action

startScan()

Scan Duration

10 seconds

Scan must automatically stop after timeout.

Exit Conditions

scan timeout reached

user stops scanning

device selected

Transitions

SCAN_ACTIVE → SCAN_TIMEOUT

SCAN_ACTIVE → SCAN_STOPPED

---

# SCAN_TIMEOUT

Scanning duration has expired.

Entry Action

stopScan()

Application displays discovered devices.

Transition

SCAN_TIMEOUT → SCAN_IDLE

---

# SCAN_STOPPED

Scanning was stopped manually.

Entry Conditions

user navigates away

device connection initiated

Exit

return to idle state

Transition

SCAN_STOPPED → SCAN_IDLE

---

# Device Discovery

During scanning the application receives scan results.

Each result contains

device name

MAC address

RSSI

advertised services

The application must process scan results immediately.

Discovered devices must appear in the device list.

---

# Device Filtering

The application must filter scan results.

Only valid Reef B devices should be shown.

Filtering rules include:

device name prefix

known service UUID

stored MAC addresses

Unknown devices may be ignored.

---

# Duplicate Scan Results

BLE advertisements are received repeatedly.

Duplicate devices must not appear multiple times.

Device list must merge results by MAC address.

Device entry must update:

RSSI

last seen timestamp

---

# RSSI Handling

RSSI indicates signal strength.

RSSI values must be updated when new advertisements are received.

RSSI may be displayed to the user to indicate device proximity.

Example ranges

-40 dBm very strong

-60 dBm strong

-80 dBm weak

---

# Device List Update

Device list must update in real time.

UI must refresh when:

new device discovered

RSSI updated

device disappears

Devices may disappear if advertisements stop.

---

# Scan While Connected

The application may scan while connected to a device.

Rules

scanning must not interrupt the active connection

scan results must not affect the active device

The connected device must remain stable.

---

# Device Selection

When a user selects a device

scan must stop.

Transition

SCAN_ACTIVE → SCAN_STOPPED

Next state

CONNECTING

---

# Scan Restart

Scan may restart when:

user refreshes device list

connection fails

user returns to device discovery screen

---

# Scan Error Handling

Possible scanning errors include:

BLE adapter disabled

permission missing

hardware failure

Error Handling

display error message

stop scanning

return to idle state.

---

# Flutter Migration Requirements

Flutter implementation must follow these rules:

Scan duration must remain 10 seconds.

Duplicate devices must merge by MAC address.

Scan must not disrupt active BLE connection.

Device list must update dynamically.

Scan must stop before connection begins.
