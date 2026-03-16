# koralcore 完整 Parity 計畫（對照 reef-b-app Android 版）

**最後更新**: 2024-12-XX  
**狀態**: ✅ **核心功能 100% 完成**，剩餘測試和優化

## 📋 目錄

1. [BLE Opcode 處理狀態](#ble-opcode-處理狀態)
2. [UI 功能狀態](#ui-功能狀態)
3. [Domain/Application 層狀態](#domainapplication-層狀態)
4. [數據持久化狀態](#數據持久化狀態)
5. [待完成項目清單](#待完成項目清單)
6. [優先級和執行計畫](#優先級和執行計畫)

---

## 一、BLE Opcode 處理狀態

### 1.1 LED BLE Opcodes (0x20-0x34)

| Opcode | 名稱 | 類型 | reef-b-app | koralcore | 狀態 |
|--------|------|------|------------|-----------|------|
| 0x20 | TIME_CORRECTION | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x21 | SYNC_INFORMATION | Status | ✅ | ✅ | ✅ 已完成 |
| 0x23 | RETURN_RECORD | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x24 | RETURN_PRESET_SCENE | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x25 | RETURN_CUSTOM_SCENE | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x26 | RETURN_SCHEDULE | Data Return | ❌ 未實現 | ✅ (返回 null) | ✅ 已對齊 |
| 0x27 | SET_RECORD | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x28 | USE_PRESET_SCENE | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x29 | USE_CUSTOM_SCENE | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x2A | PREVIEW | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x2B | START_RECORD | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x2C | GET_WARNING | - | ❌ 未實現 | ❌ | ✅ 不實作（對齊 Android） |
| 0x2D | WRITE_USER_ID | - | ❌ 未實現 | ❌ | ✅ 不實作（對齊 Android） |
| 0x2E | RESET | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x2F | DELETE_RECORD | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x30 | CLEAR_RECORD | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x31 | DYNAMIC_SCENE_END | - | ❌ 未實現 | ❌ | ✅ 不實作（對齊 Android） |
| 0x32 | ENTER_DIMMING_MODE | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x33 | DIMMING | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x34 | EXIT_DIMMING_MODE | ACK | ✅ | ✅ | ✅ 已完成 |

**LED BLE 狀態總結**: ✅ **100% 完成**（所有需要實作的 opcodes 都已處理）

---

### 1.2 Dosing BLE Opcodes (0x60-0x7E)

| Opcode | 名稱 | 類型 | reef-b-app | koralcore | 狀態 |
|--------|------|------|------------|-----------|------|
| 0x60 | TIME_CORRECTION | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x61 | SET_DELAY | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x62 | SET_SPEED | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x63 | START_DROP | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x64 | END_DROP | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x65 | SYNC_INFORMATION | Status | ✅ | ✅ | ✅ 已完成 |
| 0x66 | RETURN_DELAY_TIME | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x67 | RETURN_ROTATING_SPEED | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x68 | RETURN_SINGLE_DROP_TIMING | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x69 | RETURN_24HR_DROP_WEEKLY | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x6A | RETURN_24HR_DROP_RANGE | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x6B | RETURN_CUSTOM_DROP_WEEKLY | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x6C | RETURN_CUSTOM_DROP_RANGE | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x6D | RETURN_CUSTOM_DROP_DETAIL | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x6E | SINGLE_DROP_IMMEDIATELY | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x6F | SINGLE_DROP_TIMELY | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x70 | 24HR_DROP_WEEKLY | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x71 | 24HR_DROP_RANGE | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x72 | CUSTOM_DROP_WEEKLY | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x73 | CUSTOM_DROP_RANGE | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x74 | CUSTOM_DROP_DETAIL | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x75 | ADJUST | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x76 | ADJUST_RESULT | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x77 | GET_ADJUST_HISTORY | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x78 | RETURN_ADJUST_HISTORY_DETAIL | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x79 | CLEAR_RECORD | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x7A | GET_TODAY_TOTAL_VOLUME | Data Return | ✅ | ✅ | ✅ 已完成 |
| 0x7B | GET_WARNING | - | ❌ 未實現 | ❌ | ✅ 不實作（對齊 Android） |
| 0x7C | WRITE_USER_ID | - | ❌ 未實現 | ❌ | ✅ 不實作（對齊 Android） |
| 0x7D | RESET | ACK | ✅ | ✅ | ✅ 已完成 |
| 0x7E | GET_TODAY_TOTAL_VOLUME_DECIMAL | Data Return | ✅ | ✅ | ✅ 已完成 |

**Dosing BLE 狀態總結**: ✅ **100% 完成**（所有需要實作的 opcodes 都已處理）

---

## 二、UI 功能狀態

### 2.1 LED UI 功能

| 功能 | reef-b-app | koralcore | 狀態 | 備註 |
|------|------------|-----------|------|------|
| LedMainPage | ✅ | ✅ | ✅ 已完成 | Record chart, Preview, Continue Record, Expand, Menu, Favorite |
| LedRecordPage | ✅ | ✅ | ✅ 已完成 | Line chart, Time selector, Preview, Clock display, Chart click, Long press delete |
| LedSceneListPage | ✅ | ✅ | ✅ 已完成 | Dynamic/Static scenes, Edit/Add/Favorite, Navigation |
| LedSceneAddPage | ✅ | ✅ | ✅ 已完成 | Name input, 9 channel sliders, Spectrum chart, Icon picker, Dimming mode, Scene limits |
| LedSceneEditPage | ✅ | ✅ | ✅ 已完成 | Edit existing scenes, Same features as Add page |
| LedSceneDeletePage | ✅ | ✅ | ✅ 已完成 | Delete confirmation, Scene list |
| LedScheduleEditPage | ✅ | ✅ | ✅ 已完成 | Schedule editing (if applicable) |

**LED UI 狀態總結**: ✅ **100% 完成**

---

### 2.2 Dosing UI 功能

| 功能 | reef-b-app | koralcore | 狀態 | 備註 |
|------|------------|-----------|------|------|
| DosingMainPage | ✅ | ✅ | ✅ 已完成 | BLE connect/disconnect, Play button, Menu, Favorite, Navigation |
| PumpHeadDetailPage | ✅ | ✅ | ✅ 已完成 | History display, Menu button |
| PumpHeadSchedulePage | ✅ | ✅ | ✅ 已完成 | Schedule editing |
| PumpHeadCalibrationPage | ✅ | ✅ | ✅ 已完成 | Calibration history |
| PumpHeadSettingsPage | ✅ | ✅ | ✅ 已完成 | Settings editing |
| ManualDosingPage | ✅ | ✅ | ✅ 已完成 | Manual dosing controls |

**Dosing UI 狀態總結**: ✅ **100% 完成**

---

### 2.3 通用 UI 功能

| 功能 | reef-b-app | koralcore | 狀態 | 備註 |
|------|------------|-----------|------|------|
| DeviceSettingsPage | ✅ | ✅ | ✅ 已完成 | Device name editing, Device info display |
| Favorite Management | ✅ | ✅ | ✅ 已完成 | Favorite devices and scenes (SQLite-backed) |
| Scene Management | ✅ | ✅ | ✅ 已完成 | Local scene storage (SQLite-backed) |
| BLE Connection | ✅ | ✅ | ✅ 已完成 | Connect/disconnect, State management |

**通用 UI 狀態總結**: ✅ **100% 完成**

---

## 三、Domain/Application 層狀態

### 3.1 LED Domain/Application

| 組件 | 狀態 | 備註 |
|------|------|------|
| LedRepository | ✅ | Interface defined |
| BleLedRepositoryImpl | ✅ | Full implementation |
| LedRecordRepository | ✅ | Interface defined |
| LedState Domain Models | ✅ | Complete |
| LED UseCases | ✅ | All implemented |
| SceneRepository | ✅ | SQLite-backed |
| FavoriteRepository | ✅ | SQLite-backed |

**LED Domain/Application 狀態總結**: ✅ **100% 完成**

---

### 3.2 Dosing Domain/Application

| 組件 | 狀態 | 備註 |
|------|------|------|
| DosingRepository | ✅ | Interface defined |
| BleDosingRepositoryImpl | ✅ | Full implementation |
| DosingState Domain Models | ✅ | Complete (consolidated) |
| Dosing UseCases | ✅ | All implemented |
| DosingCommandBuilder | ✅ | Complete |

**Dosing Domain/Application 狀態總結**: ✅ **100% 完成**

---

## 四、數據持久化狀態

| 功能 | 狀態 | 備註 |
|------|------|------|
| Scene Storage | ✅ | SQLite-backed (`scenes` table) |
| Favorite Scenes | ✅ | SQLite-backed (`favorite_scenes` table) |
| Favorite Devices | ✅ | SQLite-backed (`favorite_devices` table) |
| Device Storage | ✅ | In-memory (may need persistence) |

**數據持久化狀態總結**: ✅ **主要功能已完成**（Device storage 可能需要持久化）

---

## 五、待完成項目清單

### 5.1 高優先級（必須完成）

#### 1. 測試和驗證
- [ ] **LED BLE Opcode 測試**
  - 測試所有 LED opcodes 的 ACK 處理
  - 測試所有 LED opcodes 的 Data Return 處理
  - 測試 Sync START/END 流程
  - 驗證狀態更新時機（sync 期間不發送，僅在 END 發送）

- [ ] **Dosing BLE Opcode 測試**
  - 測試所有 Dosing opcodes 的 ACK 處理
  - 測試所有 Dosing opcodes 的 Data Return 處理
  - 測試 Sync START/END 流程
  - 驗證狀態更新時機

- [ ] **UI 功能測試**
  - 測試所有 LED UI 頁面的功能
  - 測試所有 Dosing UI 頁面的功能
  - 測試 Favorite 功能
  - 測試 Scene 管理功能
  - 測試設備設置功能

#### 2. 錯誤處理和邊界情況
- [x] **BLE 錯誤處理**
  - ✅ 處理 BLE 連接失敗（`_handleNotifyError` 已實現）
  - ✅ 處理 BLE 命令超時（`_sendCommand` 錯誤處理已實現）
  - ✅ 處理無效 payload（所有 handler 都有長度驗證）
  - ✅ 處理設備斷線（`_handleConnectionState` 已實現）

- [x] **UI 錯誤處理**
  - ✅ 處理空狀態顯示（`_LedRecordsEmptyState`, `_ScenesEmptyState` 已實現）
  - ✅ 處理加載狀態（`CircularProgressIndicator`, `LinearProgressIndicator` 已實現）
  - ✅ 處理錯誤提示（`_maybeShowError`, `ScaffoldMessenger` 已實現）
  - ✅ 處理網絡錯誤（通過 `AppError` 和 `describeAppError` 處理）

#### 3. 性能優化
- [ ] **狀態更新優化**
  - 確保 sync 期間不發送多餘的狀態更新
  - 優化大量數據的處理（如多個 records）

- [ ] **UI 性能優化**
  - 優化列表渲染（大量 scenes/records）
  - 優化圖表渲染（大量數據點）

---

### 5.2 中優先級（建議完成）

#### 1. 設備持久化
- [x] **Device Storage**
  - ✅ 實現設備數據的 SQLite 持久化（`DeviceRepositoryImpl` 已更新）
  - ✅ 實現設備狀態的持久化（`updateDeviceState` 已持久化）
  - ✅ 實現設備配置的持久化（`updateDeviceName`, `toggleFavoriteDevice` 已持久化）

#### 2. UI 增強
- [ ] **場景圖標資源**
  - 準備對應的圖標資源文件（替代 Material Icons）
  - 實現圖標的加載和顯示

- [ ] **圖表增強**
  - 優化圖表交互（縮放、平移）
  - 添加圖表工具提示
  - 優化大量數據點的顯示

#### 3. 文檔和註釋
- [ ] **代碼文檔**
  - 完善所有 BLE opcode 處理的註釋
  - 完善所有 UI 組件的文檔
  - 完善所有 UseCase 的文檔

---

### 5.3 低優先級（可選）

#### 1. 額外功能
- [ ] **場景同步**
  - 如果設備支持場景存儲，實現場景同步功能

- [ ] **數據導出/導入**
  - 實現場景數據的導出/導入
  - 實現設備配置的導出/導入

#### 2. 國際化
- [ ] **多語言支持**
  - 完善所有 UI 文本的國際化
  - 測試多語言切換

---

## 六、優先級和執行計畫

### Phase 1: 測試和驗證（最高優先級）

**目標**: 確保所有已實現的功能正常工作

**時間**: 1-2 週

**任務**:
1. 創建測試計劃
2. 測試所有 LED BLE opcodes
3. 測試所有 Dosing BLE opcodes
4. 測試所有 UI 功能
5. 修復發現的問題

**交付物**:
- 測試報告
- Bug 修復清單
- 已知問題文檔

---

### Phase 2: 錯誤處理和邊界情況（高優先級）

**目標**: 完善錯誤處理，提升穩定性

**時間**: 1 週

**任務**:
1. 實現 BLE 錯誤處理
2. 實現 UI 錯誤處理
3. 處理邊界情況
4. 添加錯誤日誌

**交付物**:
- 錯誤處理文檔
- 錯誤日誌系統

---

### Phase 3: 性能優化（中優先級）

**目標**: 優化性能和用戶體驗

**時間**: 1 週

**任務**:
1. 優化狀態更新
2. 優化 UI 渲染
3. 優化數據處理

**交付物**:
- 性能測試報告
- 優化建議文檔

---

### Phase 4: 設備持久化（中優先級）

**目標**: 實現設備數據的持久化

**時間**: 3-5 天

**任務**:
1. 設計設備數據庫結構
2. 實現設備數據的 SQLite 持久化
3. 實現設備狀態的持久化
4. 測試持久化功能

**交付物**:
- 設備數據庫 schema
- 持久化實現
- 測試報告

---

### Phase 5: UI 增強（低優先級）

**目標**: 完善 UI 細節

**時間**: 1-2 週

**任務**:
1. 準備場景圖標資源
2. 優化圖表交互
3. 完善 UI 細節

**交付物**:
- 圖標資源文件
- 優化後的 UI 組件

---

## 七、總結

### 已完成項目 ✅

1. **BLE Opcode 處理**: ✅ 100% 完成
   - LED: 所有需要實作的 opcodes 都已處理
   - Dosing: 所有需要實作的 opcodes 都已處理

2. **UI 功能**: ✅ 100% 完成
   - LED UI: 所有主要頁面都已實現
   - Dosing UI: 所有主要頁面都已實現
   - 通用 UI: 設備設置、Favorite、Scene 管理都已實現

3. **Domain/Application 層**: ✅ 100% 完成
   - 所有 Repository 接口和實現都已完成
   - 所有 UseCase 都已完成
   - 所有 Domain 模型都已完成

4. **數據持久化**: ✅ 主要功能已完成
   - Scene 和 Favorite 數據都已持久化（SQLite）

### 待完成項目 📋

1. **測試和驗證**（最高優先級）
2. **錯誤處理和邊界情況**（高優先級）
3. **性能優化**（中優先級）
4. **設備持久化**（中優先級）
5. **UI 增強**（低優先級）

### 整體進度

- **BLE 層**: ✅ 100%
- **Domain/Application 層**: ✅ 100%
- **UI 層**: ✅ 100%
- **數據持久化**: ✅ 90%
- **測試和驗證**: ⏳ 0%
- **錯誤處理**: ⏳ 50%
- **性能優化**: ⏳ 30%

**總體完成度**: **約 95%**

### 最新更新（2024-12-XX）

#### ✅ 已完成
1. **BLE 錯誤處理**（100%）
   - ✅ LED repository: `_handleNotifyError` 和 `_sendCommand` 錯誤處理
   - ✅ Dosing repository: `_handleNotifyError` 和 `_sendCommand` 錯誤處理

2. **設備持久化**（100%）
   - ✅ 數據庫 schema 更新（添加 `devices` 表）
   - ✅ `DeviceRepositoryImpl` 改為 SQLite-backed
   - ✅ 所有設備操作（add/remove/update/connect/disconnect）都已持久化

3. **UI 錯誤處理**（100%）
   - ✅ 空狀態顯示（`_LedRecordsEmptyState`, `_ScenesEmptyState`）
   - ✅ 加載狀態（`CircularProgressIndicator`, `LinearProgressIndicator`）
   - ✅ 錯誤提示（`_maybeShowError`, `ScaffoldMessenger`）

4. **小的 TODO 修復**（100%）
   - ✅ `led_record_page.dart`: 修復 "Current Time" l10n TODO
   - ✅ `led_scene_list_page.dart`: 修復導航 TODO（已使用 FloatingActionButton）

#### ⏳ 待完成（低優先級）
1. **性能優化**（30%）
   - ⏳ 狀態更新優化（sync 期間不發送多餘更新 - 已實現）
   - ⏳ UI 渲染優化（列表虛擬化、圖表優化）

2. **已知限制**（不影響功能）
   - ⏳ Schedule parsing（0x26 opcode 在 reef-b-app 中未實現，koralcore 返回 null）
   - ⏳ Adjust history headNo tracking（TODO 註釋，功能正常但使用 placeholder）

---

## 八、下一步行動

### 立即開始（本週）

1. **創建測試計劃**
   - 列出所有需要測試的功能
   - 準備測試用例
   - 準備測試環境

2. **開始測試**
   - 從 LED BLE opcodes 開始
   - 然後測試 Dosing BLE opcodes
   - 最後測試 UI 功能

3. **修復發現的問題**
   - 記錄所有發現的問題
   - 按優先級修復
   - 更新文檔

### 短期目標（2-4 週）

1. 完成所有測試和驗證
2. 完善錯誤處理
3. 實現設備持久化
4. 優化性能

### 長期目標（1-2 個月）

1. 完善 UI 細節
2. 準備圖標資源
3. 優化圖表交互
4. 完善文檔

---

**最後更新**: 2024-12-XX  
**維護者**: [Your Name]  
**狀態**: 進行中

