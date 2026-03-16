# Dose Device Behavior

This document defines the behavior of dosing pump devices supported by the Reef B application.

Dosing pump devices automate the addition of liquid additives into the aquarium.

The Flutter implementation must reproduce the same behavior used by the existing Android and iOS applications.

Dosing devices support multiple pump heads, each with independent calibration and scheduling.

---

# Dose Device Overview

The dosing device contains multiple pump heads.

Typical configuration

4 pump heads

Each pump head can be configured independently.

Each pump head supports

manual dosing

automatic dosing schedule

calibration

runtime monitoring

---

# Pump Head Model

Each pump head contains the following fields.

pump head id

pump head name

enabled flag

calibration value

flow rate

schedule configuration

runtime state

Pump heads operate independently but share the same device.

---

# Calibration

Calibration determines the accuracy of the pump output.

Calibration procedure

run pump for a fixed duration

measure the liquid output

enter measured volume

The application calculates the pump flow rate.

Calibration must be performed before scheduling.

---

# Calibration Data

Calibration values include

ml_per_second

runtime_per_ml

calibration timestamp

Calibration values must be stored on the device.

The device uses these values to calculate dosing duration.

---

# Manual Dosing

Manual dosing allows the user to run the pump immediately.

User specifies

pump head

dose volume

Example

5 ml

Application converts volume to pump runtime using calibration data.

Command sent to device.

Pump runs immediately.

---

# Manual Dosing Constraints

Manual dosing must respect the following rules.

pump head must be enabled

device must be connected

calibration must exist

volume must be within allowed limits.

Manual dosing must not interfere with scheduled dosing.

---

# Dosing Schedule

Each pump head supports automatic dosing schedules.

Schedules define when and how much liquid is dispensed.

Schedule entries include

timestamp

dose volume

repeat pattern

Example schedule

08:00 5 ml

12:00 5 ml

20:00 5 ml

Schedules are stored on the device firmware.

---

# Schedule Modes

The dosing device supports three schedule modes.

24-hour even dosing

custom schedule

one-time dosing

Each pump head may use different modes.

---

# 24-Hour Even Dosing

Total daily dose is divided evenly across a 24-hour period.

Example

24 ml per day

dose every hour

1 ml per dose.

Even dosing reduces fluctuations in aquarium chemistry.

---

# Custom Schedule

Custom schedule allows user-defined dosing times.

Example

08:00 5 ml

14:00 3 ml

22:00 2 ml

Each entry runs independently.

The firmware triggers doses at the specified time.

---

# One-Time Dosing

One-time dosing schedules a single dose.

Example

dose 10 ml at 16:00

The schedule entry executes once.

After execution

entry is removed.

Used for temporary adjustments.

---

# Schedule Editing

Users may modify dosing schedules.

Operations include

add entry

edit entry

delete entry

enable or disable entry.

Schedule updates must be sent to the device.

Firmware becomes the authoritative schedule source.

---

# Schedule Constraints

Schedule entries must follow rules.

timestamps must be valid

volume must be positive

volume must not exceed device limits

duplicate timestamps should be avoided.

UI should validate schedules before sending commands.

---

# Dose History

Device may record dosing history.

History entries include

timestamp

pump head id

dose volume

execution result

History may be retrieved during device synchronization.

---

# Pump Runtime State

Runtime state indicates current pump behavior.

Fields include

pump running flag

remaining runtime

last dosing timestamp

error status.

Runtime state may update through BLE notifications.

---

# Dosing Error Conditions

Possible dosing errors include

calibration missing

pump jam

dose execution failure

invalid schedule entry

BLE communication failure.

Error handling actions

display error message

retry command

refresh device state.

---

# Schedule Synchronization

When device connects

application must retrieve pump schedules.

Firmware schedules override cached schedules.

When schedule modified

application must upload schedule to firmware.

After update

schedule must be retrieved again for verification.

---

# Concurrent Pump Operations

Pump heads operate independently.

However

the device firmware may limit simultaneous pump operation.

Application must respect firmware limitations.

---

# Safety Limits

Device may enforce safety limits.

Examples

maximum daily dose

maximum single dose

minimum interval between doses.

Application should validate limits when possible.

---

# Dose Command Types

Commands used for dosing devices include

MANUAL_DOSE

SET_CALIBRATION

UPDATE_DOSE_SCHEDULE

REQUEST_DOSE_SCHEDULE

REQUEST_DOSE_HISTORY

REQUEST_RUNTIME_STATE

All commands must pass through the BLE command queue.

---

# Flutter Migration Requirements

Flutter implementation must follow these rules.

Calibration must be required before scheduling.

Manual dosing must convert volume to runtime using calibration.

Schedules must be stored on device firmware.

Firmware must remain the authoritative source of dosing schedules.

All dosing commands must pass through the BLE command pipeline.

Device runtime state must update through BLE notifications.
