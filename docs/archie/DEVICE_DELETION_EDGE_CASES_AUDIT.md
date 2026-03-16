# Device Deletion Edge Cases Audit

## Audit Scope

1. Active device deleted → AppSession + CurrentDeviceSession cleanup
2. selectionMode reset when leaving Device tab
3. No navigation in selectionMode

---

## Findings

### 1. Active device deleted

| Check | Status | Notes |
|-------|--------|-------|
| AppSession clears activeDeviceId | **MISSING** | When user `setActiveDevice(id)` then deletes from Device tab, `_activeDeviceId` was never cleared. |
| CurrentDeviceSession.clear() | **PARTIAL** | RemoveDeviceUseCase only cleared when `getCurrentDevice() == deviceId`. After `disconnect()` the repo's `_currentDeviceId` is null, and `currentDeviceSession.context?.deviceId` (from `setActiveDevice`) was not checked. |
| AppSession resubscribes (pumpHeads, ledState) | **MISSING** | When active device deleted, subscriptions were not cleared. |

**Root cause**: AppSession derives `_activeDeviceId` from two paths:
- `_onDevices`: connected device only (cleared on disconnect).
- `setActiveDevice()`: can set device even when not connected (e.g. navigating to LedMainPage).

When a device set via `setActiveDevice` is deleted, neither path cleared it. `_onSavedDevices` receives the new list without the deleted device but did nothing.

### 2. selectionMode reset when leaving Device tab

| Check | Status | Notes |
|-------|--------|-------|
| Exit on tab switch | **MISSING** | `DeviceListController.exitSelectionMode()` was never called when user switched from Device tab (index 2) to Home or Bluetooth. |

**Impact**: User could enter selection mode, switch to Bluetooth, then back to Device — selection mode stayed active. Requirement: reset when leaving Device tab.

### 3. No navigation in selectionMode

| Check | Status | Notes |
|-------|--------|-------|
| DeviceCard onTap behavior | **OK** | `DeviceCard` uses `onTap: selectionMode ? onSelect : onTap` — in selection mode it calls `onSelect` (toggle), not `onTap` (navigate). No change needed. |

---

## Missing Lifecycle Calls

1. **AppSession._onSavedDevices**: When `_activeDeviceId` is no longer in saved devices, clear:
   - `_activeDeviceId`, `_activeDeviceName`
   - `CurrentDeviceSession.clear()`
   - `_resubscribePumpHeads(null)`, `_resubscribeLedState(null)`

2. **RemoveDeviceUseCase**: Also clear `CurrentDeviceSession` when deleted device matches `currentDeviceSession.context?.deviceId` (covers `setActiveDevice` case when repo `getCurrentDevice()` was already cleared by disconnect).

3. **MainShellPage bottom nav onTap**: When `prevIndex == 2 && index != 2`, call `DeviceListController.exitSelectionMode()`.

---

## Proposed Minimal Patch

See `device_deletion_edge_cases.patch`.
