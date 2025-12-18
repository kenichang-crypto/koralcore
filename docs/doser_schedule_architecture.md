# Doser Schedule Architecture — Analysis & Plan

_Status: exploratory design; no runtime behavior changed._

## 1. Reef-b-app Behavior (24h & Custom)

Observations from current captures and PDF notes:

- **Opcode 0x70 (24h average dosing)**
  - Payload shape (per `verifySchedule24h_0x70`):
    `opcode → pumpId → repeatMask → slotCount → {hour, minute, doseLE}×N → pumpSpeed`.
  - Each slot is effectively an immediate single dose scheduled at an HH:MM boundary, encoded with the same ml×10 scaling and pump-speed byte mapping already defined for opcodes 0x6E/0x6F.
  - Reef-b-app treats “24h average” as a repeating day partition: user defines one or more slots, each representing a discrete single-dose execution within the day. The firmware handles repetition via `repeatMask` (bitset for days of week) + controller clock sync.

- **Opcodes 0x72/0x73/0x74 (custom schedule windows)**
  - Payload shape (per `verifyScheduleCustom_0x72_73_74`):
    `opcode → pumpId → chunkIndex → windowStart(minute-of-day, LE) → windowEnd → per-event doseLE → pumpSpeed`.
  - Reef-b-app slices long custom programs into chunks (multiple opcodes) but every “event” within those chunks is still a single-dose execution: pump, dose (ml×10), speed, timestamp relative to the day window.
  - `chunkIndex` + window metadata purely orchestrate when the single-dose template fires; actual liquid math is identical to opcodes 0x6E/0x6F.

**Conclusion:** both scheduling modes are higher-level orchestrations that sequence the same single-dose instruction multiple times with metadata controlling repeat windows and temporal grouping.

## 2. Proposed Domain Model (koralcore)

### Core concepts

| Concept | Description |
| --- | --- |
| `SingleDosePlan` | Reusable value object that captures pumpId, `doseMl`, and `PumpSpeed`. This maps 1:1 with the payload fields that `SingleDoseEncodingUtils` already understands. |
| `ScheduledDoseTrigger` | Describes when/why a `SingleDosePlan` should fire (absolute `DateTime`, minute-of-day, repeat mask, window chunk). |
| `DoserScheduleDefinition` | Aggregate capturing schedule metadata (schedule type, pump linkage, cadence) and a list of `ScheduledDoseTrigger`s referencing `SingleDosePlan`s. |
| `ScheduleType` | Enum: `immediate`, `timed`, `daily24h`, `customWindow`. (Immediate/Timed already implemented; new work focuses on the last two.) |

### 24h Average (opcode 0x70)

```
class DailyAverageScheduleDefinition implements DoserScheduleDefinition {
  final String scheduleId;
  final int pumpId;
  final RepeatMask repeatMask; // bitset for week days
  final List<DailyDoseSlot> slots; // ordered by time
}

class DailyDoseSlot implements ScheduledDoseTrigger {
  final int hour;
  final int minute;
  final SingleDosePlan dose; // pumpId tied to parent, doseMl, PumpSpeed
}
```

- Conversion to BLE: each `DailyDoseSlot` becomes a per-slot payload entry while `RepeatMask`, `slotCount`, and terminal `pumpSpeed` follow the opcode-0x70 framing. `SingleDoseEncodingUtils` is reused for the dose fields.

### Custom Schedule Windows (opcodes 0x72/0x73/0x74)

```
class CustomWindowScheduleDefinition implements DoserScheduleDefinition {
  final String scheduleId;
  final int pumpId;
  final List<CustomWindowChunk> chunks;
}

class CustomWindowChunk {
  final int chunkIndex;
  final int windowStartMinute; // 0-1440
  final int windowEndMinute;
  final List<WindowDoseEvent> events;
}

class WindowDoseEvent implements ScheduledDoseTrigger {
  final int minuteOffset; // relative to windowStart
  final SingleDosePlan dose;
}
```

- Each chunk eventually maps to one opcode in {0x72,0x73,0x74} depending on firmware constraints (e.g., number of events per opcode). `SingleDoseEncodingUtils` again supplies all byte math for `dose` and `speed`.

## 3. Separation of Concerns

| Layer | Responsibilities |
| --- | --- |
| **Scheduling domain layer** | Defines `DoserScheduleDefinition`, `DailyAverageScheduleDefinition`, `CustomWindowScheduleDefinition`, repeat masks, chunking, validation (e.g., non-overlapping slots). Pure data + rules, no bytes. |
| **Encoding layer** | Translates each `ScheduledDoseTrigger` into opcode-specific payloads, reusing: `SingleDoseEncodingUtils.requireByte`, `scaleDoseMlToTenths`/`requireRawDoseInt`, `mapPumpSpeedToByte`, `checksumFor`. |
| **Ble adapter layer** | Sends produced payloads using `BleAdapter`. |
| **Verification layer** | Continues to leverage `verifySchedule24h_0x70` and `verifyScheduleCustom_0x72_73_74`, comparing golden captures to encoded payloads per opcode. |

## 4. Opcode Summary & Reuse Plan

| Opcode | Purpose | Composition strategy | Reused helpers |
| --- | --- | --- | --- |
| 0x6E | Immediate single dose | Direct `SingleDosePlan` → payload | `SingleDoseEncodingUtils` (dose, speed, checksum) |
| 0x6F | Timed single dose | `SingleDosePlan` + absolute `DateTime` | Same helpers + schedule metadata for calendar fields |
| 0x70 | 24h average schedule | `DailyDoseSlot` list + repeat mask; each slot is a single-dose execution | `SingleDoseEncodingUtils` for per-slot dose/speed; new helper for repeat mask + slot framing |
| 0x72/0x73/0x74 | Custom schedule chunks | `CustomWindowChunk` + `WindowDoseEvent`s; each event is single-dose | Same helpers for dose/speed; chunk/window metadata encoded per opcode |

### Reuse
- Dose magnitude & pump-speed bytes: handled exclusively by `SingleDoseEncodingUtils`.
- Checksums: once per opcode payload, using the byte sequences mandated by firmware. (Schedule opcodes use their own checksum fields; plan is to expose convenience wrappers that eventually call `checksumFor` under the hood.)

## 5. Next Steps (Implementation Phase)
1. Introduce the domain model classes sketched above (`SingleDosePlan`, schedule definitions, repeat masks).
2. Hook application use cases (`set_dosing_schedule`, etc.) to produce these domain objects rather than raw maps.
3. Implement opcode 0x70/0x72-0x74 encoders that:
   - Traverse schedule definitions.
   - Use `SingleDoseEncodingUtils` for all per-dose math.
   - Fill in schedule-specific headers (repeat masks, chunk metadata, etc.).
4. Capture golden payloads via BleRecorder and wire them into `EncoderVerifier` for the new opcodes before enabling PASS requirements.

By treating every scheduled event as a composition over `SingleDosePlan`, we guarantee consistent scaling, speed mapping, and checksum calculations across all dosing commands while keeping schedule logic focused on temporal orchestration.
