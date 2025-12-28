# UI 對照檢查與修正計畫

本文件檢查 `reef-b-app` 中的所有 UI Activity/Fragment 是否在 `koralcore` 中有對應實現，並制定分段修正計畫。

生成時間：2025-01-XX

---

## 一、reef-b-app UI 完整清單

### Activity 清單（26 個）

#### LED 相關（10 個）
1. `LedMainActivity` - LED 主頁面
2. `LedRecordActivity` - LED 記錄頁面
3. `LedRecordSettingActivity` - LED 記錄設置頁面
4. `LedRecordTimeSettingActivity` - LED 記錄時間設置頁面
5. `LedSceneActivity` - LED 場景列表頁面
6. `LedSceneAddActivity` - LED 場景添加頁面
7. `LedSceneEditActivity` - LED 場景編輯頁面
8. `LedSceneDeleteActivity` - LED 場景刪除頁面
9. `LedSettingActivity` - LED 設置頁面
10. `LedMasterSettingActivity` - LED Master 設置頁面

#### Dosing 相關（12 個）
11. `DropMainActivity` - Dosing 主頁面
12. `DropHeadMainActivity` - 泵頭主頁面
13. `DropHeadDetailPage` - 泵頭詳情頁面（對應 PumpHeadDetailPage）
14. `DropHeadSettingActivity` - 泵頭設置頁面
15. `DropHeadAdjustActivity` - 泵頭校正頁面
16. `DropHeadAdjustListActivity` - 泵頭校正列表頁面
17. `DropHeadRecordSettingActivity` - 泵頭記錄設置頁面
18. `DropHeadRecordTimeSettingActivity` - 泵頭記錄時間設置頁面
19. `DropSettingActivity` - Dosing 設置頁面
20. `DropTypeActivity` - 滴液類型管理頁面
21. `ScheduleEditPage` - 排程編輯頁面（對應 schedule_edit_page.dart）
22. `ManualDosingPage` - 手動滴液頁面（對應 manual_dosing_page.dart）

#### 通用功能（4 個）
23. `MainActivity` - 主頁面（對應 MainScaffold）
24. `AddDeviceActivity` - 添加設備頁面
25. `SinkManagerActivity` - 水槽管理頁面
26. `SinkPositionActivity` - 水槽位置選擇頁面
27. `WarningActivity` - 警告列表頁面
28. `SplashActivity` - 啟動頁面

### Fragment 清單（3 個）
1. `HomeFragment` - 首頁 Fragment
2. `BluetoothFragment` - 藍牙 Fragment
3. `DeviceFragment` - 設備 Fragment

---

## 二、koralcore UI 完整清單

### 頁面清單（23 個 _page.dart 文件）

#### LED 相關（10 個）
1. ✅ `led_main_page.dart` - LED 主頁面
2. ✅ `led_record_page.dart` - LED 記錄頁面
3. ❌ `led_record_setting_page.dart` - **缺失**
4. ❌ `led_record_time_setting_page.dart` - **缺失**
5. ✅ `led_scene_list_page.dart` - LED 場景列表頁面
6. ✅ `led_scene_add_page.dart` - LED 場景添加頁面
7. ✅ `led_scene_edit_page.dart` - LED 場景編輯頁面
8. ✅ `led_scene_delete_page.dart` - LED 場景刪除頁面
9. ✅ `led_setting_page.dart` - LED 設置頁面
10. ❌ `led_master_setting_page.dart` - **缺失**
11. ✅ `led_control_page.dart` - LED 控制頁面（額外）
12. ✅ `led_schedule_list_page.dart` - LED 排程列表頁面（額外）
13. ✅ `led_schedule_edit_page.dart` - LED 排程編輯頁面（額外）

#### Dosing 相關（9 個）
14. ✅ `dosing_main_page.dart` - Dosing 主頁面
15. ✅ `pump_head_detail_page.dart` - 泵頭詳情頁面
16. ✅ `pump_head_settings_page.dart` - 泵頭設置頁面
17. ✅ `pump_head_calibration_page.dart` - 泵頭校正頁面（對應 DropHeadAdjustActivity）
18. ❌ `pump_head_adjust_list_page.dart` - **缺失**（對應 DropHeadAdjustListActivity）
19. ❌ `pump_head_record_setting_page.dart` - **缺失**（對應 DropHeadRecordSettingActivity）
20. ❌ `pump_head_record_time_setting_page.dart` - **缺失**（對應 DropHeadRecordTimeSettingActivity）
21. ✅ `drop_setting_page.dart` - Dosing 設置頁面
22. ❌ `drop_type_page.dart` - **缺失**（對應 DropTypeActivity）
23. ✅ `schedule_edit_page.dart` - 排程編輯頁面
24. ✅ `manual_dosing_page.dart` - 手動滴液頁面

#### 通用功能（4 個）
25. ✅ `home_page.dart` - 首頁
26. ✅ `bluetooth_page.dart` - 藍牙頁面
27. ✅ `device_page.dart` - 設備頁面
28. ❌ `add_device_page.dart` - **缺失**（對應 AddDeviceActivity）
29. ✅ `sink_manager_page.dart` - 水槽管理頁面
30. ❌ `sink_position_page.dart` - **缺失**（對應 SinkPositionActivity）
31. ❌ `warning_page.dart` - **缺失**（對應 WarningActivity）
32. ❌ `splash_page.dart` - **缺失**（對應 SplashActivity）
33. ✅ `device_settings_page.dart` - 設備設置頁面（額外）

---

## 三、對照表

| reef-b-app | koralcore | 狀態 | 優先級 |
|------------|-----------|------|--------|
| **LED 相關** |
| LedMainActivity | led_main_page.dart | ✅ 已實現 | - |
| LedRecordActivity | led_record_page.dart | ✅ 已實現 | - |
| LedRecordSettingActivity | led_record_setting_page.dart | ❌ 缺失 | 🟡 中 |
| LedRecordTimeSettingActivity | led_record_time_setting_page.dart | ❌ 缺失 | 🟡 中 |
| LedSceneActivity | led_scene_list_page.dart | ✅ 已實現 | - |
| LedSceneAddActivity | led_scene_add_page.dart | ✅ 已實現 | - |
| LedSceneEditActivity | led_scene_edit_page.dart | ✅ 已實現 | - |
| LedSceneDeleteActivity | led_scene_delete_page.dart | ✅ 已實現 | - |
| LedSettingActivity | led_setting_page.dart | ✅ 已實現 | - |
| LedMasterSettingActivity | led_master_setting_page.dart | ❌ 缺失 | 🟡 中 |
| **Dosing 相關** |
| DropMainActivity | dosing_main_page.dart | ✅ 已實現 | - |
| DropHeadMainActivity | pump_head_detail_page.dart | ✅ 已實現 | - |
| DropHeadSettingActivity | pump_head_settings_page.dart | ✅ 已實現 | - |
| DropHeadAdjustActivity | pump_head_calibration_page.dart | ✅ 已實現 | - |
| DropHeadAdjustListActivity | pump_head_adjust_list_page.dart | ❌ 缺失 | 🟡 中 |
| DropHeadRecordSettingActivity | pump_head_record_setting_page.dart | ❌ 缺失 | 🔴 高 |
| DropHeadRecordTimeSettingActivity | pump_head_record_time_setting_page.dart | ❌ 缺失 | 🔴 高 |
| DropSettingActivity | drop_setting_page.dart | ✅ 已實現 | - |
| DropTypeActivity | drop_type_page.dart | ❌ 缺失 | 🟡 中 |
| **通用功能** |
| MainActivity | MainScaffold | ✅ 已實現 | - |
| AddDeviceActivity | add_device_page.dart | ❌ 缺失 | 🟡 中 |
| SinkManagerActivity | sink_manager_page.dart | ✅ 已實現 | - |
| SinkPositionActivity | sink_position_page.dart | ❌ 缺失 | 🟡 中 |
| WarningActivity | warning_page.dart | ❌ 缺失 | 🟡 中 |
| SplashActivity | splash_page.dart | ❌ 缺失 | 🟢 低 |
| HomeFragment | home_page.dart | ✅ 已實現 | - |
| BluetoothFragment | bluetooth_page.dart | ✅ 已實現 | - |
| DeviceFragment | device_page.dart | ✅ 已實現 | - |

---

## 四、缺失頁面分析

### 高優先級（核心功能）

#### 1. DropHeadRecordSettingActivity → pump_head_record_setting_page.dart
**功能**：泵頭記錄設置（排程設置）
**影響**：影響排程功能完整性
**複雜度**：高

#### 2. DropHeadRecordTimeSettingActivity → pump_head_record_time_setting_page.dart
**功能**：泵頭記錄時間設置
**影響**：影響排程時間設置功能
**複雜度**：中

### 中優先級（重要功能）

#### 3. LedRecordSettingActivity → led_record_setting_page.dart
**功能**：LED 記錄設置
**影響**：影響 LED 記錄功能完整性
**複雜度**：中

#### 4. LedRecordTimeSettingActivity → led_record_time_setting_page.dart
**功能**：LED 記錄時間設置
**影響**：影響 LED 記錄時間設置功能
**複雜度**：中

#### 5. LedMasterSettingActivity → led_master_setting_page.dart
**功能**：LED Master 設置
**影響**：影響 LED Master 設備設置
**複雜度**：中

#### 6. DropTypeActivity → drop_type_page.dart
**功能**：滴液類型管理
**影響**：影響滴液類型配置功能
**複雜度**：低（Domain/Repository 已實現）

#### 7. DropHeadAdjustListActivity → pump_head_adjust_list_page.dart
**功能**：泵頭校正列表
**影響**：影響校正歷史查看功能
**複雜度**：低（已有 calibration_page）

#### 8. AddDeviceActivity → add_device_page.dart
**功能**：添加設備頁面
**影響**：影響設備添加流程
**複雜度**：中

#### 9. SinkPositionActivity → sink_position_page.dart
**功能**：水槽位置選擇
**影響**：影響設備位置分配功能
**複雜度**：低

#### 10. WarningActivity → warning_page.dart
**功能**：警告列表頁面
**影響**：影響警告查看功能（但 BLE 協議未實現）
**複雜度**：低（Domain/Repository 已實現）

### 低優先級（輔助功能）

#### 11. SplashActivity → splash_page.dart
**功能**：啟動頁面
**影響**：影響啟動體驗
**複雜度**：低

---

## 五、分段修正計畫

### Phase 1: 高優先級 - 排程設置功能（核心功能）

**目標**：補齊排程設置相關頁面

**任務**：
1. **pump_head_record_setting_page.dart**
   - 功能：泵頭記錄設置（排程設置）
   - 對應：`DropHeadRecordSettingActivity`
   - 複雜度：高
   - 預估時間：4-6 小時

2. **pump_head_record_time_setting_page.dart**
   - 功能：泵頭記錄時間設置
   - 對應：`DropHeadRecordTimeSettingActivity`
   - 複雜度：中
   - 預估時間：2-3 小時

**驗證**：
- 確保排程設置功能完整
- 確保時間設置功能正常

**預估總時間**：6-9 小時

---

### Phase 2: 中優先級 - LED 記錄設置功能

**目標**：補齊 LED 記錄設置相關頁面

**任務**：
1. **led_record_setting_page.dart**
   - 功能：LED 記錄設置
   - 對應：`LedRecordSettingActivity`
   - 複雜度：中
   - 預估時間：2-3 小時

2. **led_record_time_setting_page.dart**
   - 功能：LED 記錄時間設置
   - 對應：`LedRecordTimeSettingActivity`
   - 複雜度：中
   - 預估時間：2-3 小時

**驗證**：
- 確保 LED 記錄設置功能完整
- 確保時間設置功能正常

**預估總時間**：4-6 小時

---

### Phase 3: 中優先級 - 設備設置和類型管理

**目標**：補齊設備設置和類型管理頁面

**任務**：
1. **led_master_setting_page.dart**
   - 功能：LED Master 設置
   - 對應：`LedMasterSettingActivity`
   - 複雜度：中
   - 預估時間：2-3 小時

2. **drop_type_page.dart**
   - 功能：滴液類型管理
   - 對應：`DropTypeActivity`
   - 複雜度：低（Domain/Repository 已實現）
   - 預估時間：2-3 小時

3. **add_device_page.dart**
   - 功能：添加設備頁面
   - 對應：`AddDeviceActivity`
   - 複雜度：中
   - 預估時間：3-4 小時

**驗證**：
- 確保設備設置功能完整
- 確保類型管理功能正常

**預估總時間**：7-10 小時

---

### Phase 4: 中優先級 - 輔助功能頁面

**目標**：補齊輔助功能頁面

**任務**：
1. **pump_head_adjust_list_page.dart**
   - 功能：泵頭校正列表
   - 對應：`DropHeadAdjustListActivity`
   - 複雜度：低（已有 calibration_page）
   - 預估時間：1-2 小時

2. **sink_position_page.dart**
   - 功能：水槽位置選擇
   - 對應：`SinkPositionActivity`
   - 複雜度：低
   - 預估時間：1-2 小時

3. **warning_page.dart**
   - 功能：警告列表頁面
   - 對應：`WarningActivity`
   - 複雜度：低（Domain/Repository 已實現，但 BLE 協議未實現）
   - 預估時間：2-3 小時

**驗證**：
- 確保輔助功能正常
- 確保警告頁面可以顯示（即使 BLE 未實現）

**預估總時間**：4-7 小時

---

### Phase 5: 低優先級 - 啟動頁面

**目標**：補齊啟動頁面

**任務**：
1. **splash_page.dart**
   - 功能：啟動頁面
   - 對應：`SplashActivity`
   - 複雜度：低
   - 預估時間：1-2 小時

**驗證**：
- 確保啟動頁面正常顯示
- 確保導航到主頁面正常

**預估總時間**：1-2 小時

---

## 六、總體修正計畫

### 優先級總結

| Phase | 優先級 | 頁面數 | 預估時間 | 必要性 |
|-------|--------|--------|----------|--------|
| Phase 1 | 🔴 高 | 2 | 6-9 小時 | 必需 |
| Phase 2 | 🟡 中 | 2 | 4-6 小時 | 建議 |
| Phase 3 | 🟡 中 | 3 | 7-10 小時 | 建議 |
| Phase 4 | 🟡 中 | 3 | 4-7 小時 | 可選 |
| Phase 5 | 🟢 低 | 1 | 1-2 小時 | 可選 |

**總計**：11 個缺失頁面，預估 22-34 小時

---

## 七、執行建議

### 第一階段（立即執行）
- ✅ Phase 1: 高優先級 - 排程設置功能
  - 這些是核心功能，影響排程功能完整性

### 第二階段（短期內執行）
- ⚠️ Phase 2: 中優先級 - LED 記錄設置功能
- ⚠️ Phase 3: 中優先級 - 設備設置和類型管理

### 第三階段（中期執行）
- ⚠️ Phase 4: 中優先級 - 輔助功能頁面

### 第四階段（可選）
- ⚠️ Phase 5: 低優先級 - 啟動頁面

---

## 八、詳細實現指南

### Phase 1 詳細步驟

#### 步驟 1.1: pump_head_record_setting_page.dart

**參考**：`DropHeadRecordSettingActivity.kt`

**功能需求**：
- 顯示泵頭排程設置選項
- 支持 24 小時均等、單次、客製化排程設置
- 支持排程參數配置（滴液量、時間等）

**實現要點**：
- 使用 `PumpHeadScheduleController`
- 整合 `ScheduleEditPage` 的功能
- 支持排程類型的選擇和配置

#### 步驟 1.2: pump_head_record_time_setting_page.dart

**參考**：`DropHeadRecordTimeSettingActivity.kt`

**功能需求**：
- 設置排程的執行時間
- 支持日期範圍選擇
- 支持重複設置（星期幾）

**實現要點**：
- 使用時間選擇器
- 支持日期範圍選擇
- 支持星期重複設置

---

### Phase 2 詳細步驟

#### 步驟 2.1: led_record_setting_page.dart

**參考**：`LedRecordSettingActivity.kt`

**功能需求**：
- LED 記錄設置選項
- 記錄時間範圍設置
- 記錄頻率設置

#### 步驟 2.2: led_record_time_setting_page.dart

**參考**：`LedRecordTimeSettingActivity.kt`

**功能需求**：
- LED 記錄時間設置
- 時間範圍選擇
- 重複設置

---

### Phase 3 詳細步驟

#### 步驟 3.1: led_master_setting_page.dart

**參考**：`LedMasterSettingActivity.kt`

**功能需求**：
- LED Master 設備設置
- Master 設備選擇
- Master 設備配置

#### 步驟 3.2: drop_type_page.dart

**參考**：`DropTypeActivity.kt`

**功能需求**：
- 滴液類型列表
- 添加/編輯/刪除滴液類型
- 類型使用情況顯示

**實現要點**：
- 使用 `DropTypeRepository`
- 實現 CRUD 操作
- 顯示類型使用情況

#### 步驟 3.3: add_device_page.dart

**參考**：`AddDeviceActivity.kt`

**功能需求**：
- 設備掃描
- 設備選擇
- 設備添加流程

---

### Phase 4 詳細步驟

#### 步驟 4.1: pump_head_adjust_list_page.dart

**參考**：`DropHeadAdjustListActivity.kt`

**功能需求**：
- 顯示泵頭校正歷史列表
- 支持篩選和排序
- 支持查看詳情

**實現要點**：
- 可以重用 `pump_head_calibration_page.dart` 的部分邏輯
- 主要差異是列表視圖 vs 詳情視圖

#### 步驟 4.2: sink_position_page.dart

**參考**：`SinkPositionActivity.kt`

**功能需求**：
- 顯示水槽列表
- 選擇設備位置
- 分配設備到水槽

#### 步驟 4.3: warning_page.dart

**參考**：`WarningActivity.kt`

**功能需求**：
- 顯示警告列表
- 支持篩選（按設備、時間）
- 支持清除警告

**實現要點**：
- 使用 `WarningRepository`
- 即使 BLE 未實現，也要顯示 UI 結構
- 可以顯示空狀態或模擬數據

---

### Phase 5 詳細步驟

#### 步驟 5.1: splash_page.dart

**參考**：`SplashActivity.kt`

**功能需求**：
- 顯示啟動畫面
- 初始化檢查
- 導航到主頁面

**實現要點**：
- 簡單的啟動畫面
- 可以添加初始化邏輯
- 自動導航到主頁面

---

## 九、注意事項

1. **功能整合**：
   - 某些功能可能已經整合到其他頁面
   - 需要檢查現有頁面是否已經包含所需功能

2. **BLE 協議依賴**：
   - Warning 頁面依賴 BLE 協議（0x2C, 0x7B），但這些協議在 reef-b-app 中也未實現
   - 可以先實現 UI 結構，等待 BLE 協議實現

3. **頁面重用**：
   - 某些頁面功能相似，可以重用組件
   - 例如 `pump_head_adjust_list_page` 可以重用 `pump_head_calibration_page` 的部分邏輯

4. **導航整合**：
   - 確保新頁面的導航路徑正確
   - 確保與現有頁面的導航一致

---

## 十、完成度統計

### 當前狀態

| 類別 | 已實現 | 缺失 | 完成度 |
|------|--------|------|--------|
| LED 頁面 | 10 | 3 | 77% |
| Dosing 頁面 | 9 | 4 | 69% |
| 通用頁面 | 4 | 4 | 50% |
| **總計** | **23** | **11** | **68%** |

### 完成後狀態

| 類別 | 已實現 | 缺失 | 完成度 |
|------|--------|------|--------|
| LED 頁面 | 13 | 0 | 100% |
| Dosing 頁面 | 13 | 0 | 100% |
| 通用頁面 | 8 | 0 | 100% |
| **總計** | **34** | **0** | **100%** |

---

## 十一、下一步行動

1. **立即開始 Phase 1**：補齊排程設置功能
2. **準備 Phase 2-3**：收集更多實現細節
3. **逐步完成**：按優先級順序完成所有缺失頁面

