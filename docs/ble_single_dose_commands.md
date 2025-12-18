# Single Dose BLE Commands (0x6E / 0x6F)

Authoritative reference: **reef-b-app** (Android/iOS) production captures gathered via BleRecorder. All bytes, scaling rules, and checksum calculations mirror the app’s `getDropSingleImmediateCommand` and `getDropSingleTimelyCommand` implementations.

## Opcode 0x6E — Immediate Single Dose

| Index | Byte | Description | Notes |
| --- | --- | --- | --- |
| 0 | `0x6E` | Opcode | Fixed value. |
| 1 | `0x04` | Payload length | Number of bytes after index 1. |
| 2 | pumpId | Target pump number | 0–255. |
| 3 | volume_H | High byte of volume | Volume is `doseMl × 10`, rounded to nearest tenth and encoded big-endian. |
| 4 | volume_L | Low byte of volume | Same volume field, low byte. |
| 5 | speed | Pump speed selector | `0x01` low, `0x02` medium, `0x03` high. |
| 6 | checksum | Integrity byte | Sum of bytes 2–5, modulo 256. |

Volume scaling: the encoder multiplies the requested milliliters by 10 (`ml × 10`) and rounds to the nearest integer before splitting the 16-bit value into high/low bytes. Negative values or numbers outside `0x0000–0xFFFF` are rejected.

Checksum rule:

$$checksum = \left(\sum_{i=2}^{5} byte_i\right) \bmod 256$$

## Opcode 0x6F — Timed Single Dose

| Index | Byte | Description | Notes |
| --- | --- | --- | --- |
| 0 | `0x6F` | Opcode | Fixed value. |
| 1 | `0x09` | Payload length | Number of bytes after index 1. |
| 2 | pumpId | Target pump number | 0–255. |
| 3 | yearOffset | Year − 2000 | Example: 2025 → `25`. |
| 4 | month | Calendar month | 1–12. |
| 5 | day | Calendar day | 1–31. |
| 6 | hour | 24-hour hour field | 0–23. |
| 7 | minute | Minute | 0–59. |
| 8 | volume_H | High byte of raw volume | Caller provides pre-scaled integer (e.g., ml × 10). |
| 9 | volume_L | Low byte of raw volume | Same volume field, low byte. |
| 10 | speed | Pump speed selector | `0x01` low, `0x02` medium, `0x03` high. |
| 11 | checksum | Integrity byte | Sum of bytes 2–10, modulo 256. |

Volume handling: reef-b-app already scales the timed dose into an integer value (e.g., ml × 10). The encoder validates that the provided double is an integer and fits within `0x0000–0xFFFF`, then writes it big-endian.

Checksum rule:

$$checksum = \left(\sum_{i=2}^{10} byte_i\right) \bmod 256$$

## Shared Encoding Utilities

Common helpers for byte validation, volume handling, speed mapping, and checksum calculation live in [lib/domain/doser/encoder/single_dose_encoding_utils.dart](lib/domain/doser/encoder/single_dose_encoding_utils.dart). Both 0x6E and 0x6F encoders depend on this utility so future single-dose variants (e.g., schedule-based opcodes) can reuse the same enforcement logic.
