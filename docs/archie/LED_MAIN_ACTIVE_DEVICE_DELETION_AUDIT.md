# Audit: Active Device Deletion While Inside LedMainPage

## Scope

1. Verify behavior when `activeDeviceId` becomes null while on LedMainPage (or nested Led pages)
2. Ensure no null dereference in LedMainPage and Led controllers
3. Ensure user is redirected safely to Device tab if needed

---

## Findings

### 1. LedMainPage – when activeDeviceId becomes null

| Check | Status | Notes |
|-------|--------|-------|
| deviceName display | Safe | `session.activeDeviceName ?? l10n.ledDetailUnknownDevice` – uses fallback |
| isBleConnected | Safe | `session.isBleConnected` is `_activeDeviceId != null` – shows disconnected |
| Null dereference | None | No direct use of `activeDeviceId` in LedMainPage |

**Behavior**: Page shows "Unknown device" and disconnected state. No crash.

### 2. Led controllers – null safety

| Controller | Status | Notes |
|------------|--------|-------|
| LedSceneListController | Safe | All methods check `if (deviceId == null)` and return early or set error |
| LedControlController | Safe | refresh(), applyChanges() check null |
| LedRecordController | Acceptable | `_deviceId` set at init, never cleared. Uses `_deviceId!` but `_deviceId` stays non-null (stale ID). Use case calls may fail with AppError, no crash |
| LedSceneEditController | Safe | Checks `deviceId == null` |
| LedRecordSettingController | Safe | Checks null |
| LedRecordTimeSettingController | Safe | Checks null |
| LedScheduleListController | Safe | Checks null |
| LedScheduleSummaryController | Safe | Checks null |

### 3. LedMainDeviceInfoSection

| Check | Status | Notes |
|-------|--------|-------|
| _loadDeviceInfo(deviceId) | Safe | Returns `{'positionName': null, 'groupName': null}` when `deviceId == null` |
| _handleBleIconTap | Safe | `if (deviceId == null) return` |

**Note**: LedMainDeviceInfoSection is not used in the current LedMainPage (LedMainPage uses `_DeviceIdentificationSection`). Safe if reused.

### 4. Redirect when activeDeviceId becomes null

| Check | Status | Notes |
|-------|--------|-------|
| LedMainPage redirect | Missing | User remains on LedMainPage showing "Unknown device". No automatic pop. |
| DosingMainPage redirect | Partial | initState checks null and pops; no handling for mid-session null |
| Nested Led pages | N/A | LedRecordPage, LedRecordSettingPage, etc. pushed from LedMainPage; if parent pops, stack behavior varies |

**Unsafe assumption**: That `activeDeviceId` stays valid for the lifetime of LedMainPage. If it becomes null (device deleted from Device tab while user is elsewhere, or future "delete from Led menu"), the page stays visible with stale/empty content.

---

## Summary of Unsafe Assumptions

1. **activeDeviceId remains valid**: LedMainPage (and nested pages) assume `activeDeviceId` stays set. When it is cleared in `_onSavedDevices`, the page shows fallback ("Unknown device") but does not redirect.
2. **LedRecordController._deviceId**: Captured at init and never updated. If `session.activeDeviceId` changes, `_deviceId` is stale. No null crash, but use case calls can fail with errors.

---

## Implemented Fix: Redirect on activeDeviceId Clear

Add a redirect when `activeDeviceId` becomes null so the user returns to the main shell (Device tab), consistent with DosingMainPage’s init check.

**LedMainPage**: When `session.activeDeviceId == null`, schedule `Navigator.popUntil((r) => r.isFirst)` to return to MainShellPage.

**DosingMainPage**: Same logic for consistency (handles edge case where device is removed mid-session).
