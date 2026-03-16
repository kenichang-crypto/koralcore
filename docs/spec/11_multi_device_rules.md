# Multi Device Rules

This document defines how the Reef B application manages multiple BLE devices.

The application may store multiple devices but must enforce strict rules regarding connection and communication.

Flutter implementation must reproduce the same behavior used by the Android and iOS applications.

---

# Multi Device Overview

The application may manage multiple Reef B devices.

Examples

multiple LED controllers

multiple dosing pumps

future device types

Devices may be stored in the application even if they are not currently connected.

The application maintains a device list representing all known devices.

---

# Device List

The device list contains all devices known to the application.

Each device entry contains

MAC address

device name

device type

last connection timestamp

firmware version

connection state

Devices appear in the list even when disconnected.

Device list entries persist between application launches.

---

# Device Discovery

Devices may be discovered during BLE scanning.

If a discovered device matches an existing stored MAC address

the device entry must be updated.

If the device is new

a new device entry may be created.

Duplicate device entries must never be created.

Device uniqueness is determined by MAC address.

---

# Device Connection Rule

The application must allow only one active BLE connection at a time.

Simultaneous device connections are not allowed.

This rule simplifies BLE communication and avoids command conflicts.

If a device is already connected

another device cannot be connected until the first device disconnects.

---

# Device Switching

Device switching occurs when the user selects a different device.

Switch procedure

disconnect current device

clear command queue

reset BLE state

connect new device

Device switching must not occur while commands are executing.

Controllers must wait until queue becomes idle.

---

# Device Reconnection

Previously connected devices may reconnect automatically.

Reconnect conditions

device previously connected

device appears during scanning

user did not manually disconnect

Reconnect procedure

connect using stored MAC address.

Reconnect attempts follow the same retry rules used for normal connections.

---

# Device Removal

Users may remove a device from the device list.

Device removal procedure

delete device entry from storage

clear cached configuration

remove device from UI list

Removing a device does not affect the physical device.

The device may be rediscovered through scanning.

---

# Device Persistence

The device list must persist between application sessions.

Stored fields include

MAC address

device name

device type

last connection timestamp

Optional stored fields

firmware version

cached configuration

Local storage mechanisms may include

SharedPreferences

SQLite

secure storage.

---

# Device Offline Detection

A stored device may become offline.

Offline conditions include

device out of BLE range

device powered off

BLE communication failure

Offline devices remain in the device list.

Connection state must update to OFFLINE.

---

# Device Status Updates

Device entries must update dynamically.

Status updates include

RSSI changes

connection state changes

firmware updates

schedule synchronization

UI must reflect device status changes.

---

# Scan While Connected

The application may perform BLE scanning while connected to a device.

Rules

scanning must not interrupt the active connection

scan results must not affect the connected device

connected device must remain stable.

---

# Device Capability Differences

Different devices may support different features.

Examples

LED controllers support channel configuration

dosing pumps support pump scheduling

Controllers must determine device behavior using the device type and capability information retrieved during synchronization.

---

# Device Rename

Users may rename devices.

Device rename procedure

update local device name

store new name in local storage

Device rename does not change firmware data unless firmware supports renaming.

---

# Device Sorting

The device list may be sorted.

Example sorting rules

most recently connected first

signal strength

device type grouping

Sorting rules are defined by UI behavior.

---

# Device Conflict Prevention

The application must prevent command conflicts between devices.

Rules

only the connected device may receive commands

disconnected devices must not accept commands

command queue must be associated with the active device.

---

# Flutter Migration Requirements

Flutter implementation must follow these rules.

Only one BLE device may be connected at a time.

Device uniqueness must be determined by MAC address.

Device switching must disconnect the current device first.

Command queue must reset when switching devices.

Device list must persist across application sessions.

Offline devices must remain visible in the device list.
