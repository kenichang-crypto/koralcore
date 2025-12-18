# BLE Command Transport — Hardening Plan

_Status: analysis + proposal. No runtime behavior changed yet._

## 1. Current Adapter / Transport State

| Component | Findings |
| --- | --- |
| `BleAdapter` | Minimal abstraction that exposes `write(List<int>)` and `writeBytes(Uint8List)` with no guidance on sequencing, acknowledgement strategy, or retries. |
| `BleAdapterImpl` | Placeholder implementation; actual platform BLE calls are TODOs. The only concrete behavior is optional recording via `BleRecorder`. No queueing, timeout management, or distinction between write-with-response vs write-without-response. |
| `BleAdapterStub` | Pure no-op for tests; does not emulate transport latency/ordering. |
| Command ingestion | Higher layers call adapter methods directly, so rapid-fire scheduling (e.g., sending 0x72/0x73/0x74 bursts) will issue concurrent `Future`s without backpressure. |
| Logging/diagnostics | Only BLE recorder hooks exist; there is no structured log for transport state (queue depth, retries, MTU usage). |

## 2. Identified Risks

1. **Unbounded concurrency:** Multiple dosing commands can be `await`ed independently. Without a queue/lock, they may race, violating firmware expectations of strict opcode ordering.
2. **Missing delivery guarantees:** No timeout, retry, or acknowledgement handling is defined. Write failures (e.g., `GATT_ERROR`) would silently drop protocol actions.
3. **Write-with-response vs write-without-response:** The adapter never indicates which mode to use. Reef-b-app uses write-with-response for dosing commands to ensure the controller paces chunked transfers. Matching that behavior is critical for multi-payload schedules (0x72–0x74).
4. **Schedule bursts:** Custom schedules can require three opcodes back-to-back. Without pacing (inter-command delay and confirmation), later chunks could be ignored by firmware still parsing the previous window.
5. **Lack of visibility:** When preparing golden captures, we need deterministic evidence of what bytes were attempted, when retries occurred, and why failures happened. Recorder snapshots alone are insufficient when the underlying transport fails before the record hook.

## 3. Proposed Transport Hardening

### 3.1 Unified Dispatch Queue

- Introduce a single-command queue inside `BleAdapterImpl` that serializes all writes per `deviceId`.
- Each enqueue returns a `Future<void>` that completes when the command is written (or fails with a transport error).
- Internally track states: `pending`, `in-flight`, `completed`, `failed` for debug visibility.

### 3.2 Write Mode & Acknowledgement Policy

- Default all dosing opcodes (0x6E–0x74) to **write-with-response** to mimic reef-b-app until proven otherwise.
- After each write, wait for the BLE stack callback (success/failure) before dequeueing the next command.
- Add configurable `interCommandDelay` (default 40–60 ms) for schedule bursts to match reef-b-app pacing.

### 3.3 Timeout & Retry Semantics

- Configurable timeout per command (e.g., 3 seconds). If the BLE stack does not acknowledge within that window, fail the Future with a descriptive error.
- Retry policy: allow N retries (default 1) for transient GATT status codes; log each retry.
- Surface errors through a structured exception (`BleWriteException`) carrying opcode, attempt count, and underlying status.

### 3.4 Logging & Instrumentation

- Emit structured logs for each lifecycle event (queued → sent → ack → completed / failed). Include opcode, payload length, attempt index, and timestamps.
- Hook recorder *after* the transport confirms success to avoid logging bytes that never reached the device.
- Provide an optional `BleTransportObserver` interface for tests/debug runners to capture queue metrics and verify pacing.

## 4. Roadmap / Next Steps

1. **Adapter refactor:** Implement the dispatch queue + timeout logic above without touching domain/encoder layers. Provide dependency injection so tests can supply fake BLE stacks.
2. **Capability review:** Confirm with firmware whether any dosing opcodes may use write-without-response; parameterize per-command if necessary.
3. **Telemetry integration:** Feed the new logs into existing debug consoles or analytics so field engineers can correlate BLE failures with captured payloads.
4. **Golden validation dry-run:** Once the transport queue is in place, replay sample payloads (0x6E–0x74) through the adapter using the debug hooks to ensure ordering and pacing behave as expected before capturing actual reef-b-app sessions.

By hardening the transport layer now, the finalized dosing encoders can be exercised reliably during the upcoming golden-capture phase, minimizing future structural changes.
