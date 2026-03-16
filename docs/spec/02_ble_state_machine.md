# BLE Connection State Machine

This document defines the deterministic BLE lifecycle used by the Reef B mobile application.

The state machine must be implemented exactly in the Flutter migration to maintain compatibility with the existing Android and iOS applications.

The BLE lifecycle controls:

- device scanning
- device discovery
- connection establishment
- GATT service discovery
- notification subscription
- device initialization
- device synchronization
- reconnection
- error handling

All BLE operations must respect the state machine defined here.

---

# BLE Lifecycle Overview

The BLE connection lifecycle consists of the following states:

DISCONNECTED

SCANNING

DEVICE_DISCOVERED

CONNECTING

SERVICE_DISCOVERY

ENABLE_NOTIFICATION

HANDSHAKE

SYNC_DEVICE_STATE

READY

DISCONNECTING

ERROR

---

# State Transition Overview

DISCONNECTED
→ SCANNING
→ DEVICE_DISCOVERED
→ CONNECTING
→ SERVICE_DISCOVERY
→ ENABLE_NOTIFICATION
→ HANDSHAKE
→ SYNC_DEVICE_STATE
→ READY

Failure paths

CONNECTING → ERROR

SERVICE_DISCOVERY → ERROR

ENABLE_NOTIFICATION → ERROR

HANDSHAKE → ERROR

SYNC_DEVICE_STATE → ERROR

---

# DISCONNECTED

This is the default BLE state.

Entry Conditions

- application launch
- device disconnected
- connection error
- manual user disconnect

Allowed Operations

- start scanning
- reconnect to saved device
- display device list

Exit Trigger

scanLeDevice()

Transition

DISCONNECTED → SCANNING

---

# SCANNING

The application scans for nearby BLE devices.

Entry Action

Start BLE scan.

Scan Parameters

scan timeout = 10 seconds

Scan Filters

- device name
- service UUID
- stored MAC addresses

Device information collected

device name

MAC address

RSSI

advertised services

Exit Conditions

scan timeout

user selects device

Transitions

SCANNING → DEVICE_DISCOVERED

SCANNING → DISCONNECTED

---

# DEVICE_DISCOVERED

A device has been discovered during scanning.

The device is displayed in the device list.

Device Information

device name

MAC address

signal strength

service identifiers

User may select device to connect.

Transition

DEVICE_DISCOVERED → CONNECTING

---

# CONNECTING

The application attempts to establish a BLE GATT connection.

Entry Action

connectBLE(device)

Connection Timeout

10 seconds

Retry Behavior

If GATT error status = 133

retry connection

maximum retry count = 5

retry delay = 2 seconds

Exit Condition

onConnectionStateChange(STATE_CONNECTED)

Transitions

CONNECTING → SERVICE_DISCOVERY

CONNECTING → ERROR

---

# SERVICE_DISCOVERY

The application discovers available GATT services.

Entry Action

discoverServices()

Exit Condition

onServicesDiscovered()

Transitions

SERVICE_DISCOVERY → ENABLE_NOTIFICATION

SERVICE_DISCOVERY → ERROR

---

# ENABLE_NOTIFICATION

BLE notifications must be enabled for device communication.

Entry Actions

setCharacteristicNotification()

write CCCD descriptor

Important Rule

The device must not be considered fully connected until notification setup is successful.

Exit Condition

CCCD descriptor write success

Transition

ENABLE_NOTIFICATION → HANDSHAKE

Failure

ENABLE_NOTIFICATION → ERROR

---

# HANDSHAKE

The application validates communication with the device.

Handshake operations include:

firmware version request

protocol compatibility validation

device capability discovery

Handshake ensures that the application and firmware use compatible protocols.

Exit Condition

handshake completed successfully

Transition

HANDSHAKE → SYNC_DEVICE_STATE

Failure

HANDSHAKE → ERROR

---

# SYNC_DEVICE_STATE

The application synchronizes device data.

Operations include

time synchronization

device information retrieval

LED configuration retrieval

dose schedule retrieval

history retrieval

User interaction must be disabled during synchronization.

Exit Condition

all required synchronization tasks completed

Transition

SYNC_DEVICE_STATE → READY

Failure

SYNC_DEVICE_STATE → ERROR

---

# READY

Device is fully connected and synchronized.

Allowed Operations

LED control

dose control

schedule editing

manual dosing

preview lighting

Commands must pass through the command pipeline.

DeviceState becomes authoritative.

---

# DISCONNECTING

The application disconnects from the device.

Entry Actions

disconnect()

close GATT connection

Exit Condition

GATT connection closed

Transition

DISCONNECTING → DISCONNECTED

---

# ERROR

An error occurred during BLE operation.

Possible Triggers

connection timeout

GATT error

notification enable failure

command timeout

unexpected device disconnect

Error Handling

close GATT connection

clear command queue

reset BLE state

notify UI

Transition

ERROR → DISCONNECTED

---

# Reconnection Policy

If connection drops unexpectedly

Reconnect Conditions

device previously connected

user did not manually disconnect

Reconnect Procedure

DISCONNECTED
→ CONNECTING

Reconnect Attempts

maximum 5 retries

Retry Delay

2 seconds

If reconnect fails

device state becomes offline

UI must notify user.

---

# Background Behavior

If application moves to background

BLE connection may remain active.

If connection drops while backgrounded

reconnect when application returns to foreground.

---

# Timeout Summary

Scan timeout

10 seconds

Connection timeout

10 seconds

Command timeout

5 seconds

Retry attempts

5

Retry delay

2 seconds
