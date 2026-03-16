# BLE Command Pipeline

This document defines the BLE command execution model used by the Reef B application.

All device commands must pass through a deterministic command pipeline.

This mechanism ensures stable BLE communication and prevents concurrent write conflicts.

The command pipeline must be reproduced exactly in the Flutter migration.

---

# Command Pipeline Overview

BLE devices cannot handle multiple simultaneous write operations.

The application must enforce sequential command execution.

Command flow

UI Action
→ Controller
→ Command Queue
→ BLE Write
→ Device Execution
→ Notification Response
→ Queue Continue

Only one command may be active at a time.

---

# Command Queue

The command queue stores pending commands.

Queue behavior

FIFO (first in, first out)

Commands executed sequentially.

New commands appended to queue.

Queue ensures that BLE writes do not overlap.

---

# Command Structure

Each command contains the following fields.

commandId

deviceId

commandType

payload

timeout

retryCount

callback

Example command types

LED_SET_INTENSITY

LED_PREVIEW_START

LED_PREVIEW_STOP

DOSE_MANUAL

DOSE_CALIBRATION

DEVICE_INFO_REQUEST

SCHEDULE_UPDATE

---

# Command Execution

When a command is added to the queue

If queue is idle

execute immediately.

If queue is busy

command waits.

Execution steps

write BLE characteristic

wait for notification response

mark command complete

start next command.

---

# BLE Write Operation

BLE write uses the device command characteristic.

Operation

writeCharacteristic()

The payload must follow the device protocol.

Write operation must be synchronous within the pipeline.

Next command must not start until response received.

---

# Notification Response

Device responses are received through BLE notifications.

Notification handler must match response to command.

Matching fields

commandId

commandType

Once matched

command marked completed.

Queue proceeds to next command.

---

# Command Timeout

Commands must timeout if response not received.

Default timeout

5 seconds

If timeout occurs

command considered failed.

Queue continues to next command.

Timeout prevents queue deadlock.

---

# Command Retry

Some commands may be retried.

Retry conditions

temporary BLE failure

notification delay

Retry parameters

maximum retries

2

Retry delay

1 second

If retries exhausted

command marked failed.

---

# Command Failure Handling

Command failures must not block queue.

Failure actions

notify controller

update device state if necessary

continue queue execution.

UI may display error message.

---

# Queue Reset

Queue must reset when connection lost.

Events requiring queue reset

device disconnect

BLE error

protocol mismatch

Reset procedure

clear queue

cancel active command

reset pipeline state.

---

# Command Priority

Commands normally executed FIFO.

Some commands may require priority.

Example

disconnect

connection reset

Priority commands may preempt queue.

---

# Concurrent Command Prevention

Controllers must never send commands directly to BLE.

Controllers must only submit commands to queue.

This rule prevents concurrent BLE writes.

---

# Queue State

Queue maintains internal state.

States

IDLE

EXECUTING

WAITING_RESPONSE

RETRYING

FAILED

---

# Device Response Handling

Notification handler must:

parse device response

update DeviceState

notify queue

notify controller

UI must not directly process BLE notifications.

---

# Pipeline Example

Example command sequence

User changes LED intensity

↓

Controller generates command

↓

Command added to queue

↓

Queue writes BLE characteristic

↓

Device executes command

↓

Device sends notification

↓

Queue receives response

↓

Queue starts next command.

---

# Queue Blocking Prevention

If command waits longer than timeout

queue must automatically release command.

Queue must never become permanently blocked.

---

# Flutter Migration Requirements

Flutter implementation must follow these rules.

Only one BLE write allowed at a time.

All commands must go through command queue.

Notification responses must complete commands.

Queue must reset when connection lost.

Command timeout must remain 5 seconds.

Retry count must remain 2.
