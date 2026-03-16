# Cursor Task: BLE Behavior Parity Audit

Goal
Verify that Flutter BLE implementation matches Android behavior.

Reference Android project:
reef-b-app

Flutter project:
koralcore/lib

Spec documents:
docs/spec

Rules

1. Android implementation is the behavior authority.
2. Do NOT modify files inside reef-b-app.
3. Only analyze and report differences.
4. Output results to BLE_PARITY_AUDIT.md

---

Step 1 — Analyze Android BLE architecture

Locate and analyze:

BLEManager
BleContainer
CommandManager
DropMainViewModel
LedMainViewModel

Extract the following behavior:

BLE state machine
scan rules
connect retry rules
notification handling
command pipeline
timeout rules

---

Step 2 — Analyze Flutter BLE architecture

Locate Flutter equivalents:

data/ble/ble_adapter_impl.dart
data/ble/ble_container.dart
data/ble/ble_scan_service.dart
data/ble/transport
data/ble/response
data/ble/encoder

Extract:

scan lifecycle
connect lifecycle
notify routing
command sending
response parsing
state updates

---

Step 3 — Compare behaviors

Compare Android vs Flutter:

1. BLE State Machine
2. Scan lifecycle
3. Connection retry rules
4. Notification routing
5. Command queue model
6. Response parsing
7. Device state synchronization

---

Step 4 — Detect risks

Identify:

race conditions
missing retries
scan before adapter ready
command collisions
notify/state mismatch

---

Step 5 — Generate report

Create file:

BLE_PARITY_AUDIT.md

Include:

Architecture comparison
Behavior mismatches
Risk analysis
Recommended fixes

Do NOT modify Flutter code.
Only produce audit report.
