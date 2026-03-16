REEF B BLE Protocol Specification
1. Overview

REEF B devices communicate with the mobile application through Bluetooth Low Energy (BLE).

The protocol is a binary command-response protocol where:

APP → DEVICE  (Command)
DEVICE → APP  (Response / Notification)

Each packet follows this format:

[Opcode][Length][Payload][Checksum]
Field    Description
Opcode    Command ID
Length    Payload length
Payload    Command data
Checksum    Byte checksum

Checksum rule:

checksum = sum(all previous bytes) & 0xFF
2. BLE Lifecycle

Standard connection flow:

Scan
↓
Connect
↓
Service Discovery
↓
Enable Notification
↓
Time Correction
↓
Device Sync
↓
Normal Operation

Sequence:

connect
↓
0x20 / 0x60  time correction
↓
0x21 / 0x65  sync information
↓
device returns state packets
↓
repository rebuild
3. LED Device Protocol
Command Range
0x20 – 0x34
Core Commands
Opcode    Command
0x20    Time correction
0x21    Sync information
0x27    Set record
0x28    Use preset scene
0x29    Use custom scene
0x2A    Preview start/stop
4. koralDose Protocol
Command Range
0x60 – 0x7D
4.1 Device Configuration
Opcode    Command
0x60    Time correction
0x61    Set delay time
0x62    Set rotating speed

Payload example:

[0x61][0x02][delay_H][delay_L][checksum]
4.2 Manual Dosing
Opcode    Command
0x63    Manual start
0x64    Manual stop

Payload:

[opcode][0x01][headNo][checksum]
4.3 Device Sync
Opcode    Command
0x65    Sync information

Device returns schedule packets:

0x66 delay
0x67 speed
0x68 single schedule
0x69 24hr weekly
0x6A 24hr range
0x6B custom weekly
0x6C custom range
0x6D custom detail
4.4 Schedule Commands
Opcode    Command
0x6E    Single immediate
0x6F    Single timed
0x70    24hr weekly
0x71    24hr range
0x72    Custom weekly
0x73    Custom range
0x74    Custom detail
4.5 Calibration
Opcode    Command
0x75    Start adjust
0x76    Adjust result
0x77    Get adjust history

Device response:

0x78 history detail
4.6 Maintenance
Opcode    Command
0x79    Clear record
0x7A    Get today total volume
0x7D    Device reset
5. Response Packet Formats
0x7A Today Total Volume

Payload:

[0x7A]
[len]
[headNo]
[nonRecord_H]
[nonRecord_L]
[record_H]
[record_L]
[checksum]

Meaning:

Field    Description
nonRecord    manual dosing volume
record    scheduled dosing volume

Conversion:

ml = raw * doseRawToMlFactor
6. Data Models
PumpHeadMode

Defines dosing schedule mode:

single
24hr weekly
24hr range
custom weekly
custom range
DropHeadRecordDetail

Used for custom schedule entries.

Fields:

start time
end time
volume
speed
7. Repository State Model
Android
DropInformation

Stores:

delay time
rotating speed
schedule modes
custom details
history
daily totals
Flutter
DeviceSession / dosing repository

Stores:

delayTime
rotatingSpeed
PumpHeadMode
detail records
history entries
todayDoseMl
8. Command Queue

BLE writes must be serialized.

Recommended flow:

enqueue command
↓
write characteristic
↓
wait callback
↓
next command

Parallel writes must be avoided.

9. Error Handling

ACK responses:

Value    Meaning
0x00    fail
0x01    success

Special cases:

0x63 manual start
0x02 → blocked by scheduled dosing
10. Implementation References
Android
CommandManager.kt
parseCommand()
Flutter
dosing_command_builder.dart
ble_dosing_repository_impl.dart
11. Verified Parity Status
Section    Status
Command Coverage    PASS
Parser Coverage    PASS
