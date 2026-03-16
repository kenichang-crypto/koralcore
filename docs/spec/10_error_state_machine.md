# Error State Machine

This document defines the error handling behavior used by the Reef B mobile application.

The application must handle BLE communication errors, device errors, and command failures.

Flutter implementation must reproduce the same error handling behavior used in the existing Android and iOS applications.

Error handling ensures that the application remains stable even when communication failures occur.

---

# Error Overview

Errors may occur during several stages of device operation.

Possible error categories include

BLE connection errors

GATT operation failures

command execution failures

device offline events

protocol mismatch errors

timeout errors

Each error must trigger a deterministic recovery process.

---

# Error States

The system may enter one of the following error states.

BLE_ERROR

CONNECTION_TIMEOUT

COMMAND_TIMEOUT

DEVICE_OFFLINE

PROTOCOL_ERROR

SYNC_ERROR

QUEUE_ERROR

Each error state requires specific recovery behavior.

---

# BLE_ERROR

BLE_ERROR occurs when the Bluetooth stack reports an unexpected failure.

Possible triggers include

GATT operation failure

notification failure

BLE adapter malfunction

unexpected disconnect

Recovery procedure

close GATT connection

reset BLE state

clear command queue

notify UI

Transition

BLE_ERROR → DISCONNECTED

---

# CONNECTION_TIMEOUT

CONNECTION_TIMEOUT occurs when the application cannot establish a BLE connection within the allowed time.

Default connection timeout

10 seconds

Recovery procedure

close GATT connection

reset connection state

notify UI

User may retry connection.

---

# COMMAND_TIMEOUT

COMMAND_TIMEOUT occurs when a command does not receive a response within the expected time.

Default command timeout

5 seconds

Recovery actions

mark command failed

remove command from queue

continue queue execution

notify controller

Controller may retry the operation.

---

# DEVICE_OFFLINE

DEVICE_OFFLINE occurs when the device becomes unreachable.

Possible causes

device power loss

out of BLE range

device reboot

unexpected disconnect

Recovery actions

clear command queue

update device connection state

notify UI

optionally attempt reconnection.

---

# PROTOCOL_ERROR

PROTOCOL_ERROR occurs when the application and firmware protocol versions are incompatible.

Possible causes

firmware update

application version mismatch

invalid device response

Recovery actions

disconnect device

display protocol error message

prevent further commands.

---

# SYNC_ERROR

SYNC_ERROR occurs when device synchronization fails.

Possible causes

missing firmware response

invalid configuration data

schedule retrieval failure

Recovery actions

retry synchronization step

maximum retries

3

If retries fail

device may enter READY with partial data.

UI should display synchronization warning.

---

# QUEUE_ERROR

QUEUE_ERROR occurs when the command queue becomes inconsistent.

Possible triggers

command never completed

notification mismatch

queue deadlock

Recovery actions

clear command queue

cancel active command

reset pipeline state.

---

# Error Detection Sources

Errors may originate from several components.

BLE service

command pipeline

device synchronization

device firmware

Error detection must propagate to the application controller.

---

# Error Propagation

Error flow

BLE Service

↓

Command Pipeline

↓

Controller

↓

DeviceState update

↓

UI update

UI must display appropriate error information.

---

# Command Failure Behavior

When a command fails

command must be marked as failed.

Queue must continue executing remaining commands.

Command failure must not block the queue.

---

# Queue Reset Conditions

The command queue must reset under the following conditions.

device disconnect

BLE error

protocol mismatch

manual device disconnect

Queue reset procedure

cancel active command

clear pending commands

reset queue state to IDLE.

---

# Automatic Reconnection

The application may attempt reconnection when unexpected disconnect occurs.

Reconnection rules

device previously connected

user did not manually disconnect

Retry parameters

maximum attempts

5

retry delay

2 seconds

If reconnection fails

device state becomes OFFLINE.

---

# UI Error Reporting

UI must inform the user when errors occur.

Examples

connection failed

device disconnected

command failed

schedule synchronization failed

Error messages should guide the user toward recovery.

---

# Error Logging

Errors should be logged for debugging purposes.

Log fields

timestamp

error type

device identifier

command identifier

BLE status code.

Logs assist in diagnosing firmware or application issues.

---

# Flutter Migration Requirements

Flutter implementation must follow these rules.

BLE errors must reset the connection state.

Command timeouts must not block the queue.

Device offline events must clear the command queue.

Protocol errors must prevent further commands.

Queue errors must trigger a full queue reset.

Error recovery must maintain application stability.
