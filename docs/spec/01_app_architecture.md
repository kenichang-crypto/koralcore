# Reef B App Architecture Specification

This document defines the application architecture used by the Reef B mobile application and the requirements for the Flutter migration.

The architecture must maintain compatibility with the behavior of the existing Android (Kotlin) and iOS (Swift) implementations.

The Flutter application must reproduce the same device lifecycle, BLE communication flow, and device state management.

---

# Application Overview

The Reef B mobile application is a Bluetooth Low Energy (BLE) IoT control application.

Supported device types include:

koralLED – LED lighting controller

koralDose – dosing pump controller

The application allows users to:

discover devices

connect to devices

configure device settings

control lighting

control dosing pumps

synchronize schedules

retrieve device information

retrieve device history

---

# Architecture Layers

The application follows a layered architecture.

UI Layer (Flutter Widgets)

↓

Controller / ViewModel Layer

↓

Command Pipeline

↓

BLE Service Layer

↓

Device Firmware

---

# UI Layer

The UI layer is responsible for user interaction and rendering application state.

Responsibilities include:

displaying device list

displaying device control pages

displaying schedules

displaying device status

displaying connection status

UI widgets must not directly call BLE APIs.

All BLE operations must pass through the controller layer.

---

# Controller Layer

Controllers translate UI actions into device commands.

Controllers manage user interaction logic.

Examples include:

LED control controller

Dose control controller

Schedule editor controller

Calibration controller

Controllers communicate with the command pipeline.

Controllers update application state.

---

# Command Pipeline

The command pipeline is responsible for safe BLE communication.

All BLE commands must pass through the command queue.

Responsibilities include:

queue management

command execution

timeout handling

retry logic

command completion handling

Only one BLE command may execute at a time.

Parallel BLE operations are not allowed.

---

# BLE Service Layer

The BLE service manages Bluetooth operations.

Responsibilities include:

BLE scanning

device discovery

BLE connection

GATT service discovery

characteristic read/write

notification subscription

notification parsing

connection state monitoring

The BLE service must follow the BLE state machine defined in the specification.

---

# Device Firmware

Devices communicate with the application through BLE GATT services.

Each device implements:

device information service

command characteristic

notification characteristic

Device types include:

LED controller

Dosing pump controller

---

# Device Model

Each connected device is represented by a device model.

The device model contains the full device configuration and runtime state.

Device model includes:

device identifier (MAC address)

device name

device type

firmware version

device configuration

device schedule

device runtime state

Device models are stored in memory.

One device model exists for each saved device.

---

# State Management

The application maintains three primary state layers.

BLE State

Device State

UI State

BLE State tracks connection lifecycle.

Device State stores device configuration and runtime data.

UI State stores temporary user interface state.

Device State is the source of truth.

UI must derive state from Device State.

---

# Device Persistence

Devices discovered by the application may be saved.

Saved device information includes:

MAC address

device name

device type

Saved devices are stored locally.

Local storage mechanisms may include:

SharedPreferences

SQLite

Device persistence allows reconnecting to devices without scanning.

---

# Device Lifecycle

The device lifecycle includes the following stages:

device discovery

device selection

BLE connection

device initialization

device synchronization

device ready

device control

device disconnect

The lifecycle must follow the BLE state machine defined in the BLE specification.

---

# Command Execution Flow

Device commands follow a deterministic execution flow.

User action

↓

Controller generates command

↓

Command added to command queue

↓

Command executed via BLE write

↓

Device processes command

↓

Device response received via notification

↓

Device state updated

↓

UI updated

---

# Synchronization Model

After a successful BLE connection the application must synchronize device state.

Synchronization includes:

time synchronization

device information retrieval

device configuration retrieval

schedule retrieval

history retrieval

Device synchronization must complete before user interaction is allowed.

---

# Error Handling

The application must handle communication failures and device errors.

Possible error types include:

connection timeout

BLE communication failure

command timeout

device offline

protocol mismatch

Error recovery may include:

retrying operations

restarting BLE connection

clearing command queue

restarting synchronization.

---

# Migration Requirements for Flutter

The Flutter implementation must reproduce the same architecture and behavior.

Important rules:

BLE commands must pass through the command pipeline.

BLE state machine must match Android implementation.

Device synchronization must complete before device control.

Device state must be the source of truth for UI.

Command execution must remain sequential.

Flutter implementation must not introduce parallel BLE writes.
