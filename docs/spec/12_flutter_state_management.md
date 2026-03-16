# Flutter State Management

This document defines the application state management model used by the Flutter implementation of the Reef B mobile application.

The state architecture must reproduce the behavior of the Android ViewModel architecture while adapting it to Flutter state management patterns.

The application maintains three primary state layers.

BLEState

DeviceState

UIState

Each state layer has a specific responsibility.

---

# State Architecture Overview

The Flutter application separates runtime state into three logical layers.

BLE Layer

Device Layer

UI Layer

Flow

BLE events
→ update DeviceState
→ UI rebuild

UI must never directly modify BLE state.

Controllers must coordinate state updates.

---

# BLEState

BLEState represents the Bluetooth lifecycle.

BLEState tracks the current connection and scanning state.

BLEState fields include

adapterState

scanState

connectionState

connectedDeviceMAC

gattConnectionStatus

lastError

BLEState must only be modified by the BLE service.

BLEState drives connection indicators in the UI.

---

# BLEState Values

Typical connection states

DISCONNECTED

SCANNING

CONNECTING

CONNECTED

SYNCING

READY

ERROR

These states correspond to the BLE state machine defined in the BLE specification.

---

# DeviceState

DeviceState represents the configuration and runtime state of the connected device.

DeviceState is the authoritative source of device data.

DeviceState fields include

device identity

device configuration

LED configuration

dose configuration

device schedules

device runtime state

device history

DeviceState must update when synchronization occurs.

DeviceState must update when BLE notifications are received.

---

# DeviceState Structure

DeviceState may contain nested models.

Example structure

DeviceState

deviceInfo

ledState

doseState

scheduleState

historyState

connectionStatus

Each sub-model represents a logical component of the device.

---

# DeviceState Update Sources

DeviceState updates may originate from several sources.

BLE notification

command response

device synchronization

device reconnect

All updates must pass through the controller layer.

UI must not update DeviceState directly.

---

# UIState

UIState represents temporary UI information.

UIState does not represent device configuration.

Examples of UIState

loading indicators

preview mode active

dialog visibility

editing mode

selected schedule entry

UIState must not be stored on the device.

UIState may reset when UI pages change.

---

# State Flow

Typical state update flow

BLE notification received

↓

BLE service parses message

↓

controller updates DeviceState

↓

UI observes state change

↓

UI rebuilds affected widgets

Flutter reactive UI automatically reflects DeviceState changes.

---

# Command Execution State

Commands executed through the command queue may update DeviceState.

Example

LED channel update command

↓

command response received

↓

DeviceState updated

↓

UI reflects new channel value.

Command completion may also update UIState if UI interaction depends on the command result.

---

# State Consistency

DeviceState must always represent the firmware state.

Rules

firmware data overrides cached data

synchronization replaces local data

notifications update runtime state.

UI must never assume device state without confirmation.

---

# State Persistence

Some state must persist locally.

Persistent data includes

device list

device names

device identifiers

cached schedules (optional)

Persistent storage mechanisms may include

SharedPreferences

SQLite

secure storage.

Persistent data must reload during application startup.

---

# State Reset

State must reset under several conditions.

Device disconnect

BLE error

device removal

application restart

Reset behavior

BLEState resets to DISCONNECTED

DeviceState remains cached but marked offline

UIState resets to default.

---

# Multi-Page State Sharing

The application may contain multiple screens interacting with the same device.

Examples

LED control page

dose configuration page

device information page

These pages must observe the same DeviceState instance.

Shared state prevents inconsistencies.

---

# Controller Responsibility

Controllers act as the mediator between UI and DeviceState.

Controller responsibilities include

processing UI events

generating commands

updating DeviceState

handling synchronization

Controllers must ensure that state updates occur in a predictable order.

---

# Flutter Implementation Options

Flutter state management may use any reactive architecture.

Possible options

Provider

Riverpod

Bloc

Cubit

ValueNotifier

Regardless of the framework

DeviceState must remain the authoritative state source.

---

# Flutter Migration Requirements

Flutter implementation must follow these rules.

BLEState must track connection lifecycle.

DeviceState must store the full device configuration.

UIState must only contain temporary UI data.

UI must react to DeviceState changes.

Controllers must manage all state updates.

BLE notifications must update DeviceState.

The state architecture must preserve deterministic behavior of the original Android implementation.
