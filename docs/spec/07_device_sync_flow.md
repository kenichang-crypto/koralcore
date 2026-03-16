# Device Synchronization Flow

This document defines the device synchronization procedure used after a BLE connection is established.

The synchronization process ensures that the application state matches the firmware state of the device.

Flutter implementation must reproduce the same synchronization order used in the existing Android and iOS implementations.

Device synchronization occurs after the BLE connection lifecycle completes the handshake stage.

Synchronization must complete before the device is considered READY.

---

# Synchronization Overview

Device synchronization is required because the firmware is the authoritative source of configuration.

After connecting, the application must retrieve the full device state.

Synchronization includes:

device information

device configuration

device schedules

runtime state

history records

Synchronization ensures that the application and device are fully consistent.

---

# Synchronization Trigger

Synchronization begins after the following conditions are satisfied.

BLE connection established

GATT services discovered

notifications enabled

handshake completed

Transition

HANDSHAKE → SYNC_DEVICE_STATE

User interaction must remain disabled during synchronization.

---

# Synchronization Sequence

The synchronization process follows a strict order.

Step 1

device information request

Step 2

device capability discovery

Step 3

device configuration retrieval

Step 4

schedule retrieval

Step 5

history retrieval

Step 6

runtime state update

Once all steps complete

device state transitions to READY.

---

# Device Information Retrieval

The application must request device metadata.

Fields include

device model

firmware version

hardware version

protocol version

serial number

This information validates protocol compatibility.

---

# Capability Discovery

The application must determine the device capabilities.

Capabilities include

supported LED channels

maximum schedule entries

pump head count

history size

Capabilities determine UI behavior.

---

# Device Configuration Retrieval

The application retrieves device configuration stored on firmware.

Examples

LED channel configuration

LED preview mode

pump calibration values

pump enable flags

Configuration must be applied to DeviceState.

---

# Schedule Retrieval

Schedules stored on device must be retrieved.

Examples

LED daily schedule

dose schedule for each pump head

Schedules must replace any cached schedules stored locally.

Firmware schedules are authoritative.

---

# History Retrieval

Device history contains operational logs.

Examples

dose history

device runtime events

history timestamps

History may be paginated depending on firmware implementation.

History retrieval may occur asynchronously.

---

# Runtime State Retrieval

Runtime state includes the current operational state of the device.

Examples

current LED channel intensity

active schedule entry

pump running state

preview mode active

Runtime state must match the current firmware state.

---

# Synchronization Completion

Synchronization completes when all required data has been retrieved.

Completion actions

DeviceState updated

connection state set to READY

UI unlocked

device control enabled

---

# Synchronization Timeout

Synchronization must timeout if firmware fails to respond.

Default timeout

10 seconds per stage

If timeout occurs

synchronization considered failed.

Device state transitions to ERROR.

---

# Partial Synchronization Recovery

If a synchronization step fails

application may retry that step.

Example

schedule retrieval failure

retry schedule request.

Maximum retries

3

If retries fail

device may still enter READY with partial data.

UI should indicate incomplete data.

---

# Synchronization Cancellation

Synchronization must stop if the device disconnects.

Actions

cancel pending sync commands

clear command queue

reset synchronization state

---

# Sync Progress Tracking

The application should track synchronization progress.

Example stages

INFO_SYNC

CAPABILITY_SYNC

CONFIG_SYNC

SCHEDULE_SYNC

HISTORY_SYNC

RUNTIME_SYNC

Progress may be displayed to the user.

---

# Notification During Sync

Device notifications may arrive during synchronization.

Rules

notifications must update runtime state

notifications must not interrupt synchronization sequence

Synchronization commands must remain ordered.

---

# Device State Consistency

After synchronization

DeviceState must represent the firmware state.

Local cached data must never override firmware data.

---

# Resynchronization

Resynchronization may occur when:

connection restored

device settings changed externally

firmware update completed

Resynchronization repeats the same sequence.

---

# Flutter Migration Requirements

Flutter implementation must follow these rules.

Synchronization must occur after handshake.

Synchronization steps must follow the defined order.

User interaction must remain disabled until synchronization completes.

DeviceState must be updated only through synchronization or notifications.

Firmware state must override cached local data.
