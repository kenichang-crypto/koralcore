# Device Model Specification

This document defines the device data model used by the Reef B application.

The device model represents the full configuration and runtime state of a BLE device.

The Flutter migration must reproduce the same device state structure used in the existing Android and iOS implementations.

Device models act as the single source of truth for the application state.

UI must always read data from the device model.

---

# Device Model Overview

Each physical BLE device is represented by a Device object.

The device model stores:

device identity

connection state

firmware information

device configuration

device schedules

runtime state

history data

Device models are created when a device is discovered or loaded from local storage.

---

# Device Identity

Every device has a unique identifier.

Fields

MAC address

device name

device type

serial number

The MAC address is used for BLE connection.

---

# Device Type

The application supports multiple device types.

Examples

LED controller

dosing pump controller

Future devices may include:

wave pump

temperature controller

Each device type contains different configuration models.

---

# Device Connection State

The device model must track connection status.

Connection states

DISCONNECTED

CONNECTING

CONNECTED

SYNCING

READY

OFFLINE

The connection state is updated by the BLE state machine.

---

# Firmware Information

Each device reports firmware information.

Fields

firmware version

hardware version

protocol version

device capabilities

Firmware information is retrieved during the handshake process.

---

# Device Configuration

Device configuration contains user-defined settings stored on the device.

Examples

LED schedule

LED channel intensity

dose schedule

pump calibration

These settings must be synchronized during device connection.

---

# LED Device Model

LED devices contain lighting configuration.

Fields

channel intensity values

lighting schedule

current lighting mode

preview status

supported channels

Channel intensity values are stored as percentages.

Example

0–100

---

# LED Channel Model

Each LED channel represents a spectrum band.

Example channels

UV

Violet

Royal Blue

Blue

White

Red

Green

Channel fields

channel id

channel name

intensity value

enabled flag

---

# LED Schedule Model

LED schedule defines lighting behavior over time.

Schedule entry fields

timestamp

channel intensities

transition duration

Example schedule

08:00 sunrise

12:00 peak

18:00 sunset

22:00 off

Schedules are stored on device.

---

# LED Runtime State

LED runtime state represents current lighting behavior.

Fields

current mode

active schedule entry

current channel intensities

preview active

Runtime state is updated through BLE notifications.

---

# Dose Device Model

Dosing pump devices contain pump configuration.

Fields

pump head configuration

dose schedule

calibration data

dose history

runtime state

---

# Pump Head Model

Each dosing device contains multiple pump heads.

Typical number

4

Each pump head operates independently.

Pump head fields

pump head id

pump head name

calibration value

flow rate

enabled flag

---

# Calibration Model

Calibration determines pump accuracy.

Fields

ml_per_second

pump_runtime

last calibration date

Calibration must be performed before scheduling.

---

# Dose Schedule Model

Each pump head may contain multiple schedule entries.

Fields

timestamp

dose volume

repeat rule

Example

08:00 5 ml

14:00 3 ml

22:00 2 ml

Schedules stored on device.

---

# Dose History Model

Dose history records pump activity.

Fields

timestamp

pump head id

volume dosed

result status

History may be stored on device or retrieved periodically.

---

# Device Runtime State

Runtime state contains temporary data.

Examples

device temperature

current pump status

current LED output

connection quality

Runtime state updated through BLE notifications.

---

# Device Persistence

Saved devices must be stored locally.

Stored fields

MAC address

device name

device type

last connection timestamp

Device configuration may also be cached locally.

Persistence allows faster device reconnect.

---

# Device State Updates

Device state must update through BLE events.

Sources of state updates

BLE notification

command response

device synchronization

Device state must not be modified directly by UI.

---

# Device Synchronization

After connection the application must synchronize device state.

Synchronization retrieves

device information

device configuration

device schedules

device history

Synchronization ensures that DeviceState matches firmware state.

---

# Device Removal

Users may remove devices from the application.

Device removal must:

delete stored device entry

clear cached configuration

remove device from UI list

Device may be rediscovered through scanning.

---

# Flutter Migration Requirements

Flutter implementation must follow these rules.

DeviceState must be the single source of truth.

UI must read state from DeviceState.

Controllers must update DeviceState.

BLE notifications must update runtime state.

Device configuration must synchronize after connection.
