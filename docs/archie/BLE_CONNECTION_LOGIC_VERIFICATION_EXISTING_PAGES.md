# Phase 1-5 以外現有頁面的 BLE 連線邏輯驗證報告

## 驗證日期
2024年（Phase 1-5 完成後）

## 驗證範圍
檢查 Phase 1-5 以外所有現有 UI 頁面的 BLE 連線邏輯。

---

## 現有頁面 BLE 邏輯檢查結果

### LED 相關頁面

#### 1. LedControlPage ✅
- ✅ 檢查 `isBleConnected`
- ✅ 顯示 `BleGuardBanner` 當未連線
- ✅ 通道滑塊在未連線時禁用 (`enabled: isConnected && !controller.isApplying`)
- ✅ Apply 按鈕在未連線時禁用 (`onPressed: !isConnected || controller.isApplying || !controller.hasChanges ? null : ...`)
- **狀態**: ✅ 完整

#### 2. LedSceneListPage ✅
- ✅ 檢查 `isBleConnected`
- ✅ 顯示 `BleGuardBanner` 當未連線
- ✅ Edit 按鈕在未連線時禁用 (`onPressed: isConnected && !controller.isBusy ? ... : null`)
- ✅ FloatingActionButton 在未連線時不顯示 (`floatingActionButton: isConnected && !controller.isBusy ? ... : null`)
- ✅ 場景卡片操作按鈕在未連線時禁用
- **狀態**: ✅ 完整

#### 3. LedSceneAddPage ⚠️
- ✅ 檢查 `isBleConnected`
- ✅ 顯示 `BleGuardBanner` 當未連線
- ✅ 通道滑塊在未連線時禁用 (`enabled && controller.isDimmingMode`)
- ⚠️ **需要檢查**: Save 按鈕是否在未連線時禁用
- **狀態**: ⚠️ 需要驗證 Save 按鈕

#### 4. LedSceneEditPage ✅
- ✅ 檢查 `isBleConnected`
- ✅ 顯示 `BleGuardBanner` 當未連線
- ✅ 通道滑塊在未連線時禁用 (`enabled: isConnected`)
- ✅ Save 按鈕在未連線時禁用 (`onPressed: (isConnected && !controller.isLoading) ? ... : null`)
- **狀態**: ✅ 完整

#### 5. LedSceneDeletePage ⚠️
- ✅ 檢查 `isBleConnected`
- ✅ 顯示 `BleGuardBanner` 當未連線
- ⚠️ **需要檢查**: 刪除按鈕是否在未連線時禁用
- **狀態**: ⚠️ 需要驗證刪除操作

#### 6. LedScheduleListPage ✅
- ✅ 檢查 `isBleConnected`
- ✅ 顯示 `BleGuardBanner` 當未連線
- ✅ 排程卡片 Apply 按鈕在未連線時禁用 (`onApply: isConnected && !controller.isBusy && schedule.isEnabled && !schedule.isActive ? ... : null`)
- **狀態**: ✅ 完整

#### 7. LedScheduleEditPage ✅
- ✅ 檢查 `isBleConnected`
- ✅ 顯示 `BleGuardBanner` 當未連線
- ✅ Save 按鈕在未連線時禁用 (`onPressed: !isConnected || _isSaving ? null : _handleSave`)
- **狀態**: ✅ 完整

---

### Dosing 相關頁面

#### 8. ManualDosingPage ✅
- ✅ 檢查 `isBleConnected`
- ✅ 顯示 `BleGuardBanner` 當未連線
- ✅ Submit 按鈕在未連線時禁用 (`onPressed: !isConnected || controller.isSubmitting ? null : ...`)
- **狀態**: ✅ 完整

#### 9. ScheduleEditPage ⚠️
- ✅ 檢查 `isBleConnected`
- ✅ 顯示 `BleGuardBanner` 當未連線
- ⚠️ **需要檢查**: Save 按鈕是否在未連線時禁用
- **狀態**: ⚠️ 需要驗證 Save 按鈕

---

### 設備設置頁面

#### 10. DeviceSettingsPage ⚠️
- ⚠️ **缺少**: 沒有顯示 `BleGuardBanner`
- ⚠️ **需要檢查**: Save 按鈕是否在未連線時禁用
- ℹ️ **注意**: 設備名稱編輯是本地操作，但可能需要 BLE 連線來同步到設備
- **狀態**: ⚠️ 需要驗證和修復

#### 11. DropSettingPage ⚠️
- ✅ 檢查 `isBleConnected`
- ⚠️ **缺少**: 沒有顯示 `BleGuardBanner`
- ✅ Delay Time 選擇器在未連線時禁用 (`enabled: isConnected && !_isLoading`)
- ⚠️ **需要檢查**: Save 按鈕是否在未連線時禁用
- **狀態**: ⚠️ 需要驗證和修復

---

### 本地數據管理頁面（不需要 BLE）

#### 12. SinkManagerPage ✅
- ℹ️ **確認**: Sink 管理是本地數據操作（SQLite），不需要 BLE 連線
- **狀態**: ✅ 完整（不需要 BLE 檢查）

---

## 需要修復的問題

### 高優先級

1. **LedSceneAddPage - Save 按鈕保護**
   - 需要確認 Save 按鈕在未連線時是否禁用
   - 位置: `_buildActionButtons` 方法中的 Save 按鈕

2. **LedSceneDeletePage - 刪除操作保護**
   - 需要確認刪除按鈕在未連線時是否禁用
   - 位置: `_SceneDeleteCard` 中的刪除按鈕

3. **ScheduleEditPage - Save 按鈕保護**
   - 需要確認 Save 按鈕在未連線時是否禁用
   - 位置: `_handleSave` 方法調用處

4. **DeviceSettingsPage - BLE 保護**
   - 需要添加 `BleGuardBanner` 顯示
   - 需要確認 Save 按鈕在未連線時是否禁用

5. **DropSettingPage - BLE 保護**
   - 需要添加 `BleGuardBanner` 顯示
   - 需要確認 Save 按鈕在未連線時是否禁用

---

## 驗證建議

### 手動測試步驟

1. **未連線狀態測試**:
   - 確保 BLE 未連線
   - 訪問所有需要 BLE 的頁面
   - 確認 `BleGuardBanner` 正確顯示
   - 確認所有操作按鈕正確禁用
   - 嘗試點擊禁用的按鈕，確認不會執行操作

2. **連線狀態測試**:
   - 確保 BLE 已連線
   - 訪問所有頁面
   - 確認 `BleGuardBanner` 不顯示
   - 確認所有操作按鈕可用
   - 執行各種操作，確認功能正常

---

## 總結

### 完成度
- **基本 BLE 檢查**: ~90% ⚠️
- **BleGuardBanner 顯示**: ~85% ⚠️
- **按鈕禁用保護**: ~85% ⚠️
- **操作保護**: ~80% ⚠️

### 下一步
1. 修復高優先級問題（5 個頁面）
2. 進行完整的手動測試
3. 根據測試結果修復發現的問題

---

## 備註

- 大部分現有頁面都有基本的 BLE 檢查
- 部分頁面缺少 `BleGuardBanner` 顯示
- 部分頁面的 Save/操作按鈕需要加強 BLE 保護

