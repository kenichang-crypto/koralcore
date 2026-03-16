# LED Device Behavior

This document defines the behavior of LED controller devices supported by the Reef B application.

LED devices provide multi-channel lighting control for reef aquariums.

The Flutter implementation must reproduce the same behavior implemented in the existing Android and iOS applications.

The LED device supports multiple control modes including schedule control, scene control, and preview mode.

---

# LED Device Overview

LED devices control multiple spectrum channels.

Typical spectrum channels include

UV

Violet

Royal Blue

Blue

White

Red

Green

Each channel supports intensity values.

Intensity range

0–100 percent.

The device firmware controls the actual PWM output.

The application controls configuration and schedules.

---

# LED Control Modes

The LED device supports several control modes.

Schedule Mode

Scene Mode

Custom Mode

Preview Mode

Only one mode can be active at a time.

---

# Schedule Mode

Schedule mode allows the device to automatically control lighting throughout the day.

Schedules are stored on the device firmware.

Schedule entries define lighting states at specific times.

Example schedule

08:00 sunrise

12:00 peak intensity

18:00 sunset

22:00 lights off

The firmware interpolates channel intensities between schedule points.

---

# Schedule Entry Model

Each schedule entry contains the following fields.

timestamp

channel intensity values

transition duration

Example

timestamp = 08:00

UV = 10

Blue = 40

White = 20

transition = 30 minutes

---

# Schedule Editing

Users may edit the lighting schedule.

Editing actions include

add schedule entry

modify schedule entry

delete schedule entry

reorder entries

Schedule modifications must be sent to the device.

Firmware becomes the authoritative source of schedule data.

---

# Scene Mode

Scene mode allows selecting predefined lighting scenes.

Examples of scenes

reef daylight

coral growth

deep blue

moonlight

Scenes are predefined configurations stored in firmware.

Selecting a scene immediately updates LED channel intensities.

Scene mode overrides schedule mode until disabled.

---

# Custom Mode

Custom mode allows manual control of individual channel intensities.

Users adjust sliders for each channel.

Example

UV 20%

Royal Blue 70%

White 35%

Custom mode changes apply immediately.

Custom values may optionally be saved as schedule entries.

---

# Preview Mode

Preview mode allows temporary lighting adjustments.

Preview mode is used to visualize lighting before saving configuration.

Preview behavior

schedule execution is paused

preview channel intensities override schedule output

preview duration limited.

Preview ends when

user exits preview

preview timeout reached

schedule resumes.

---

# Preview Timeout

Default preview timeout

5 minutes.

If timeout reached

device automatically exits preview mode.

Schedule resumes.

---

# LED Command Types

Commands used to control LED behavior include

SET_CHANNEL_INTENSITY

SET_SCENE

START_PREVIEW

STOP_PREVIEW

UPDATE_SCHEDULE

REQUEST_SCHEDULE

REQUEST_RUNTIME_STATE

All commands must pass through the BLE command pipeline.

---

# Runtime State

Runtime state describes the current lighting output.

Fields include

current mode

current channel intensities

active schedule entry

preview active flag

runtime timestamp

Runtime state may update through BLE notifications.

---

# Channel Update Behavior

When channel intensities change

device output must update immediately.

Changes may occur due to

schedule execution

scene selection

custom control

preview mode.

Application UI must reflect runtime channel values.

---

# Schedule Execution

Firmware executes schedule automatically.

Application must not attempt to enforce schedule timing.

Application responsibility

schedule editing

schedule upload

schedule retrieval.

Firmware responsibility

schedule timing

channel interpolation

PWM output.

---

# Schedule Synchronization

When device connects

application must retrieve the schedule from firmware.

Firmware schedule overrides cached local schedule.

Schedule edits must be pushed to firmware.

After update

schedule must be retrieved again for verification.

---

# Channel Constraints

Channel values must respect valid ranges.

Minimum

0 percent

Maximum

100 percent

Invalid values must be rejected.

UI sliders must enforce limits.

---

# Multi-Channel Updates

Multiple channel values may be updated in a single command.

Example

update all channels simultaneously.

This ensures smooth lighting transitions.

---

# Runtime Notifications

Firmware may send notifications for

channel intensity changes

mode changes

schedule transitions

Application must update DeviceState based on notifications.

---

# LED Error Handling

Possible LED control errors

invalid schedule

unsupported channel

firmware mismatch

BLE communication failure

Error handling actions

display error message

retry command

refresh device state.

---

# Flutter Migration Requirements

Flutter implementation must follow these rules.

LED channel intensities must remain in the range 0–100.

Preview mode must pause schedule execution.

Schedule must be stored on device firmware.

Firmware must remain the authoritative schedule source.

All LED commands must pass through the BLE command queue.

Device runtime state must update through BLE notifications.
