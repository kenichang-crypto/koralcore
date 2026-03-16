# BLE Connection Rules

This document defines the BLE connection behavior used by the Reef B application.

The Flutter implementation must reproduce the same connection logic used by the Android and iOS applications.

BLE connection rules determine:

- how devices are connected
- how connection retries occur
- how disconnections are handled
- how reconnection occurs

All BLE connection operations must follow the rules defined in this document.

---

# Connection Overview

The connection process follows this sequence.

scan
→ device discovered
→ user selects device
→ connect BLE
→ service discovery
→ notification enable
→ device handshake
→ device synchronization
→ READY

Connection must complete before any device commands can be executed.

---

# Device Identification

Devices are uniquely identified by their MAC address.

Device fields

MAC address

device name

device type

firmware version

Connection attempts must use the MAC address of the selected device.

---

# Connect Procedure

When user selects a device

The application performs the following steps.

stop scanning

initiate BLE connection

connect using device MAC address

wait for connection callback

---

# connectBLE Operation

Connection initiated using BLE GATT.

Entry action

connectBLE(device)

Expected callback

onConnectionStateChange(STATE_CONNECTED)

If successful

transition to service discovery.

---

# Connection Timeout

Connection attempts must timeout.

Timeout duration

10 seconds

If connection not established within timeout

connection state becomes ERROR.

Application must close GATT connection.

---

# Connection Retry

BLE connection may fail due to Android BLE stack issues.

Example

GATT status 133

When status 133 occurs

retry connection.

Retry parameters

maximum retries

5

retry delay

2 seconds

Retry must attempt connection using the same device MAC address.

---

# Retry Failure

If retry limit reached

device connection considered failed.

Device state becomes

OFFLINE

User must be notified.

User may manually retry connection.

---

# Service Discovery

After connection established

application must discover GATT services.

Operation

discoverServices()

Expected callback

onServicesDiscovered()

If services discovered

transition to notification setup.

If service discovery fails

transition to ERROR.

---

# Notification Setup

Device communication relies on BLE notifications.

Application must enable notification on required characteristics.

Operation

setCharacteristicNotification()

write CCCD descriptor.

Connection must not proceed until notification setup completes.

---

# Handshake Procedure

After notifications enabled

application performs device handshake.

Handshake tasks

request firmware version

verify protocol compatibility

retrieve device capabilities

Handshake ensures correct protocol version.

If handshake fails

disconnect device.

---

# Reconnection Behavior

If connection drops unexpectedly

application may attempt reconnection.

Conditions for reconnection

device previously connected

user did not manually disconnect

Reconnection procedure

attempt connectBLE using saved MAC address.

Retry rules same as initial connection.

---

# Manual Disconnect

User may disconnect device.

Disconnect procedure

cancel pending commands

clear command queue

disconnect BLE GATT

close connection.

Device state becomes

DISCONNECTED

---

# Unexpected Disconnect

Unexpected disconnect may occur due to

device power loss

out of range

BLE error

When unexpected disconnect occurs

application must

clear command queue

reset BLE state

notify UI

optionally reconnect.

---

# Background Behavior

If application moves to background

connection may remain active.

If connection drops while backgrounded

reconnect when application returns to foreground.

---

# Device Switching

If user selects another device

application must

disconnect current device

connect to new device.

Simultaneous device connections are not allowed.

---

# Flutter Migration Requirements

Flutter implementation must follow these rules.

Connection timeout must remain 10 seconds.

Retry attempts must remain 5.

Retry delay must remain 2 seconds.

Scanning must stop before connection begins.

Connection must not proceed until notifications are enabled.

Handshake must complete before synchronization begins.
