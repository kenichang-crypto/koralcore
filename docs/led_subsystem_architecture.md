# LED Subsystem Architecture

_Status: based on reef-b-app captures from firmware 1.11 (Android build 540)._

## 1. Observed BLE Command Set

| Opcode | reef-b-app label | Purpose | Notes |
| --- | --- | --- | --- |
| `0x81` | `getLedDailyCommand` | Apply multi-point daily spectrum schedule. | Includes channel group selector, weekday repeat mask, and per-point spectra. |
| `0x82` | `getLedWindowCommand` | Apply fixed-spectrum window (custom start/end). | Single start/end window plus spectrum payload. |
| `0x83` | `getLedSceneCommand` | Apply named scene preset within a window. | Scene ID maps to firmware presets (0–255). |

All LED commands reuse the same low-level framing used by dosing:

1. Byte `0` → opcode.
2. Byte `1` → payload length (number of bytes that follow).
3. Bytes `2..n` → command-specific body.
4. Final byte → checksum (`sum(bytes[2..last-1]) mod 256`).

## 2. Channel / Spectrum Representation

reef-b-app always emits five spectral channels in a fixed order:

1. Red
2. Green
3. Blue
4. White
5. UV

The firmware refers to this bundle as channel group `0x01` (`fullSpectrum`). Additional groups (e.g., two-channel nano fixtures) are exposed via the same byte but are not yet observed in captures; koralcore keeps the enum extensible.

Each channel intensity is a single byte (`0–255`). No gamma curve or percentage scaling is applied—reef-b-app clamps UI sliders before encoding. Intensities are therefore raw PWM duty cycles.

## 3. Brightness Scaling Rules

Let $I_c$ represent the UI slider (0–100%). reef-b-app maps it to the BLE payload via:

$$byte_c = \text{round}(I_c \times 2.55)$$

The encoder never rescales once intensities are expressed as bytes. koralcore mirrors this by storing canonical `LedIntensity` values (0–255) and leaving any percentage math to the UI/application layer.

## 4. Scheduling & Timing Semantics

### Weekday Repeat Mask

Weekdays are encoded as a 7-bit mask starting at bit `0 = Monday`. Given a set $W$ of `Weekday` entries:

$$mask = \sum_{d \in W} 2^{position(d)}$$

Where `position(mon)=0`, `position(tue)=1`, …, `position(sun)=6`.

### Time Encoding

All LED commands use literal 24h `HH` / `MM` bytes. There is no timezone or epoch math. For window-style commands, start is inclusive and end is exclusive, matching reef-b-app behavior when overlapping windows are configured.

## 5. Command Layouts

### 0x81 — Daily Schedule

```
[0] opcode (0x81)
[1] payloadLength
[2] channelGroup (0x01 = fullSpectrum)
[3] repeatMask
[4] pointCount (N)
Then for each point i ∈ [0, N):
  [5 + i*7] hour
  [6 + i*7] minute
  [7..11] spectrum bytes (R,G,B,W,UV)
[last] checksum (sum bytes[2..last-1] mod 256)
```

### 0x82 — Custom Window

```
[0] opcode (0x82)
[1] payloadLength
[2] channelGroup
[3] startHour
[4] startMinute
[5] endHour
[6] endMinute
[7..11] spectrum bytes (R,G,B,W,UV)
[12] repeatMask
[last] checksum
```

### 0x83 — Scene Window

```
[0] opcode (0x83)
[1] payloadLength
[2] sceneId (firmware preset 0–255)
[3] startHour
[4] startMinute
[5] endHour
[6] endMinute
[7] repeatMask
[8..12] baked scene spectrum bytes (R,G,B,W,UV)
[last] checksum
```

Scene commands do not include an explicit channel group—the firmware infers it from the preset ID. However, koralcore retains the full spectrum definition so that verification tooling can ensure we emit the same channel order as reef-b-app.

## 6. Verification Hooks

For each opcode we maintain placeholder golden payloads captured from reef-b-app. The encoder verifier compares koralcore bytes with either the supplied capture or these placeholders so we can safely evolve byte math without live hardware.

- `verifyLedDailySchedule` → expects opcode `0x81`.
- `verifyLedCustomSchedule` → expects opcode `0x82`.
- `verifyLedSceneSchedule` → expects opcode `0x83`.

Until capture data is populated, the verifiers run in *self* mode (expected == actual) via the debug hooks introduced in `lib/infrastructure/ble/debug/`.

## 7. Next Steps

1. Integrate LED encoders with the BLE transport once schedule orchestration is in place.
2. Capture golden payloads from reef-b-app and update `golden_payloads.dart`.
3. Add property-based tests that assert repeat-mask and checksum math across randomized schedules.
