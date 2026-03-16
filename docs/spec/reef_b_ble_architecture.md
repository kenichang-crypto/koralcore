REEF B BLE Architecture Specification

This document defines the overall BLE architecture used by REEF B IoT devices and applications.

It describes the layered design shared by:

Android app (reef-b-app)

Flutter app (koralcore)

Device firmware (LED / DOSE / future devices)

This architecture ensures consistent BLE behavior across platforms.

1 System Overview

REEF B devices communicate with the mobile application using Bluetooth Low Energy (BLE).

The BLE stack is structured into multiple layers to separate responsibilities:

UI Layer
    ↓
Application Logic Layer
    ↓
Device Repository Layer
    ↓
BLE Transport Layer
    ↓
BLE Protocol Layer
    ↓
Firmware

This separation ensures that UI logic, protocol handling, and transport are independent.

2 Architecture Layers
2.1 UI Layer

Handles user interaction and presentation.

Responsibilities:

Display device state

Trigger commands

Show sync progress

Display command results

Android:

ViewModel
Activities / Fragments

Flutter:

Controllers
Widgets
UseCases

UI never communicates directly with BLE.

All communication flows through repositories.

2.2 Application Logic Layer

Coordinates device operations.

Responsibilities:

Manage device sessions

Handle sync lifecycle

Convert UI actions into commands

Dispatch commands to repositories

Examples:

Android:

BluetoothViewModel
LedViewModel
DropViewModel

Flutter:

DeviceListController
ConnectDeviceUseCase
ScanDevicesUseCase
2.3 Device Repository Layer

Responsible for device-specific logic.

Repositories manage:

Device session state

Command building

Packet parsing

Sync lifecycle

LED repository:

BleLedRepository

DOSE repository:

BleDosingRepository

Responsibilities:

buildCommand()
sendCommand()
parseNotification()
updateDeviceState()
emitState()

Repositories interact with BLE only through the BLE adapter.

2.4 BLE Transport Layer

Responsible for BLE communication primitives.

Responsibilities:

Scan

Connect

Write

Enable notifications

Dispatch notification packets

Android implementation:

BLEManager
BleConnectionManager
BleContainer

Flutter implementation:

BleAdapterImpl
BlePlatformTransportWriter
BleNotifyBus

The transport layer does not understand device logic.

It only transmits packets.

2.5 Command Queue Layer

Ensures BLE commands are serialized.

BLE requires commands to be sent sequentially.

Android:

BLEManager.addQueue()
writeQueueCommand()

Flutter:

BleAdapterImpl._queue
_processQueue()
_executeCommand()

Rules:

Commands must not overlap

Next command only sent after previous completes

WRITE_TYPE_NO_RESPONSE commands require delay

Typical delay:

Android ≈ 200ms
Flutter ≈ 120ms
3 BLE Protocol Layer

Defined in:

docs/spec/reef_b_ble_protocol.md

Protocol responsibilities:

Packet structure

Opcode definitions

Payload formats

Response status

Example packet structure:

HEADER
OPCODE
PAYLOAD
CHECKSUM
4 Device Types

Current supported devices:

koralLED
koralDOSE

Future devices may include:

koralWave
koralTemp
koralController

Each device has its own repository and command builder.

5 Connection Lifecycle

BLE connection lifecycle:

scan
   ↓
device discovered
   ↓
connect
   ↓
service discovery
   ↓
enable notifications
   ↓
initial sync
   ↓
device ready
6 Sync Lifecycle

Immediately after notifications are enabled:

LED:

0x20  time correction
0x21  sync information

DOSE:

0x60  time correction
0x65  sync information

During sync:

device state cleared

incoming packets rebuild state

After sync:

sync finished
emit UI state
7 Notification Flow

Device → App communication occurs through notifications.

Flow:

BLE notify
    ↓
transport layer receives packet
    ↓
packet forwarded to BleNotifyBus
    ↓
repository receives packet
    ↓
packet parsed
    ↓
device state updated
    ↓
state emitted to UI
8 Device State Model

Android:

LedInformation
DropInformation

Flutter:

_DeviceSession
_LedInformationCache

State contains:

mode
records
scenes
channel levels
pump schedules
calibration data
daily volume
9 Command Flow

Command path:

UI action
    ↓
ViewModel / Controller
    ↓
Repository
    ↓
Command Builder
    ↓
BLE Adapter
    ↓
Command Queue
    ↓
BLE write
10 Disconnect Handling

When disconnect occurs:

clear characteristics
close GATT
reset sync state
clear device session
notify UI

Android:

BleContainer cleanup

Flutter:

BleConnectionManager
BleSyncGuard
DeviceSession reset
11 Error Handling

Common BLE errors:

status 133
connection timeout
write failure
unexpected packet size

Recovery strategy:

retry connection
reset queue
restart sync
12 Design Principles

This architecture follows several principles:

Separation of concerns

UI, BLE transport, and protocol logic are independent.

Deterministic command order

Commands always use a queue.

Sync-first model

Device state is rebuilt from device packets.

Cross-platform parity

Android and Flutter share the same architecture.

13 Source of Truth

The BLE protocol specification is authoritative.

docs/spec/reef_b_ble_protocol.md

Any protocol changes must update:

Firmware
Android
Flutter

in that order.

14 Future Extension

New devices can be added by implementing:

NewCommandBuilder
NewRepository
NewDeviceSession

The BLE transport and protocol layer remain unchanged.


stateDiagram-v2
    [*] --> DISCONNECTED

    DISCONNECTED --> SCANNING : startScan()
    SCANNING --> CONNECTING : connect(device)
    SCANNING --> DISCONNECTED : scanTimeout

    CONNECTING --> SERVICE_DISCOVERY : onConnectionStateChange(CONNECTED)
    CONNECTING --> DISCONNECTED : connectFail

    SERVICE_DISCOVERY --> ENABLE_NOTIFICATION : discoverServices()

    ENABLE_NOTIFICATION --> TIME_SYNC : enableCharacteristicNotification()

    TIME_SYNC --> DEVICE_SYNC : send time correction
    DEVICE_SYNC --> SYNC_RECEIVING : send sync information

    SYNC_RECEIVING --> READY : all state packets received

    READY --> COMMAND_EXECUTION : user commands

    COMMAND_EXECUTION --> READY : device response
