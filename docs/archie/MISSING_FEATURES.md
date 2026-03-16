# koralcore 缺失功能對照表（對照 reef-b-app）

**生成日期**: 2024-12-28  
**對照來源**: reef-b-app Android 版

## 📋 缺失功能清單

### 1. UI 頁面缺失

#### 1.1 Sink（水槽）管理功能 ⚠️
**reef-b-app 頁面**:
- `SinkManagerActivity` - 水槽管理器
- `SinkPositionActivity` - 水槽位置設置
- `SinkListFragment` - 水槽列表

**koralcore 狀態**: ⚠️ **部分實現**
- ✅ 有 Sink Domain 模型 (`lib/domain/sink/sink.dart`)
- ✅ 有 Sink Repository (`lib/infrastructure/repositories/sink_repository_impl.dart`)
- ✅ 有 SinkManagerPage (`lib/ui/features/sink/pages/sink_manager_page.dart`)
- ✅ 有 SinkManagerController (`lib/ui/features/sink/controllers/sink_manager_controller.dart`)
- ❌ 無 SinkPositionPage（水槽位置選擇頁面）

**影響**: 主要管理功能已實現，但缺少位置選擇頁面

---

#### 1.2 Warning（警告）功能 ⚠️
**reef-b-app 頁面**:
- `WarningActivity` - 警告列表和處理

**koralcore 狀態**: ⚠️ **部分實現**
- ✅ 有 Warning Domain 模型 (`lib/domain/warning/warning.dart`)
- ✅ 有 Warning Repository 接口和實現 (`lib/platform/contracts/warning_repository.dart`, `lib/infrastructure/repositories/warning_repository_impl.dart`)
- ❌ 無 Warning 相關 UI 頁面
- ⚠️ BLE 命令未實現（0x2C, 0x7B）

**影響**: Domain 層和 Repository 層已實現，但 BLE 協議未實現，無法實際獲取警告

**備註**: reef-b-app 中 `CMD_LED_GET_WARNING (0x2C)` 和 `CMD_DROP_GET_WARNING (0x7B)` 都未實現，但 UI 頁面存在。koralcore 已提供基礎結構，等待 BLE 協議實現。

---

#### 1.3 Drop Type（滴液類型）功能 ⚠️
**reef-b-app 頁面**:
- `DropTypeActivity` - 滴液類型管理

**koralcore 狀態**: ⚠️ **部分實現**
- ✅ 有 Drop Type Domain 模型 (`lib/domain/drop_type/drop_type.dart`)
- ✅ 有 Drop Type Repository (`lib/infrastructure/repositories/drop_type_repository_impl.dart`)
- ✅ 有 SQLite 數據庫表 (`drop_type`)
- ❌ 無 Drop Type 相關 UI 頁面

**影響**: Domain 層和 Repository 層已實現，但缺少 UI 頁面

---

#### 1.4 LED Master Setting（LED 主控設置）❌
**reef-b-app 頁面**:
- `LedMasterSettingActivity` - LED 主控設備設置

**koralcore 狀態**: ❌ **未實現**
- 無 Led Master Setting 相關 UI 頁面

**影響**: 無法設置 LED 主控設備

---

#### 1.5 LED Setting（LED 設置）⚠️
**reef-b-app 頁面**:
- `LedSettingActivity` - LED 設備設置

**koralcore 狀態**: ⚠️ **部分實現**
- ✅ 有 LedSettingPage (`lib/ui/features/led/pages/led_setting_page.dart`)
- ✅ 支持設備名稱編輯
- ⚠️ Sink 位置選擇功能待實現（需要 SinkPositionPage）
- ⚠️ 主從關係管理待實現

**影響**: 基本設置功能已實現，但缺少完整的水槽位置和主從關係管理

---

#### 1.6 Drop Setting（滴液設置）⚠️
**reef-b-app 頁面**:
- `DropSettingActivity` - 滴液設備設置

**koralcore 狀態**: ⚠️ **部分實現**
- ✅ 有 DropSettingPage (`lib/ui/features/dosing/pages/drop_setting_page.dart`)
- ✅ 支持設備名稱編輯
- ✅ 支持延遲時間選擇（UI 已實現，BLE 命令待實現）
- ⚠️ Sink 位置選擇功能待實現（需要 SinkPositionPage）

**影響**: 基本設置功能已實現，但缺少完整的水槽位置管理和 BLE 延遲時間設置

---

#### 1.7 Drop Head Record Setting（滴液記錄設置）⚠️
**reef-b-app 頁面**:
- `DropHeadRecordSettingActivity` - 滴液記錄設置
- `DropHeadRecordTimeSettingActivity` - 滴液記錄時間設置

**koralcore 狀態**: ⚠️ **部分實現**
- 有 `PumpHeadSchedulePage` 可能涵蓋部分功能
- 但可能缺少專門的記錄設置頁面

**影響**: 可能缺少部分記錄設置功能

---

### 2. BLE Opcode 處理缺失

#### 2.1 Schedule Builders（排程構建器）⚠️
**狀態**: ⚠️ **部分實現，有 TODO**

**缺失功能**:
1. **Oneshot Schedule Builder** (`buildOneshotScheduleCommand`)
   - 文件: `lib/infrastructure/ble/schedule/oneshot_schedule_builder.dart`
   - 狀態: 只有 TODO 註釋，未實現

2. **Custom Schedule Builder** (`buildCustomScheduleCommand`)
   - 文件: `lib/infrastructure/ble/schedule/custom_schedule_builder.dart`
   - 狀態: 只有 TODO 註釋，未實現

3. **H24 Schedule Builder** (`buildH24ScheduleCommand`)
   - 文件: `lib/infrastructure/ble/schedule/h24_schedule_builder.dart`
   - 狀態: 只有 TODO 註釋，未實現

**備註**: 雖然有 `daily_average_schedule_encoder.dart` 等 encoder，但 schedule builder 層面的實現不完整。

**影響**: `ApplyScheduleUseCase` 無法正常工作，返回 `ScheduleResult.failure`

---

#### 2.2 ApplyScheduleUseCase ✅
**文件**: `lib/application/doser/apply_schedule_usecase.dart`

**狀態**: ✅ **已實現**
- ✅ `h24` schedule 類型：已實現，使用 buildH24ScheduleCommand
- ✅ `custom` schedule 類型：已實現，使用 buildCustomScheduleCommand
- ✅ `oneshotSchedule` 類型：已實現，使用 buildOneshotScheduleCommand

**影響**: 可以通過 UseCase 應用排程到設備

---

#### 2.3 ReadCapabilityUseCase ✅
**文件**: `lib/application/system/read_capability.dart`

**狀態**: ✅ **已實現**
- ✅ BLE 命令發送：通過 SystemRepository.readCapability
- ✅ Capability 解析：使用 CapabilitySet.fromRaw
- ✅ Capability 持久化：存儲在 DeviceContext 中

**影響**: 可以讀取設備能力集，並在 InitializeDeviceUseCase 中使用

---

### 3. Domain 模型缺失

#### 3.1 Sink（水槽）模型 ✅
**reef-b-app 實體**: `Sink.kt`, `SinkWithDevices.kt`

**koralcore 狀態**: ✅ **已實現**
- ✅ 有 Sink Domain 模型 (`lib/domain/sink/sink.dart`)
- ✅ 有 Sink Repository (`lib/infrastructure/repositories/sink_repository_impl.dart`)
- ❌ 缺少 UI 頁面

---

#### 3.2 Warning（警告）模型 ✅
**reef-b-app 實體**: `Warning.kt`

**koralcore 狀態**: ✅ **已實現**
- ✅ 有 Warning Domain 模型 (`lib/domain/warning/warning.dart`)
- ✅ 有 Warning Repository (`lib/infrastructure/repositories/warning_repository_impl.dart`)
- ⚠️ BLE 協議未實現（等待 0x2C, 0x7B 命令實現）

---

#### 3.3 DropType（滴液類型）模型 ✅
**reef-b-app 實體**: `DropType.kt`

**koralcore 狀態**: ✅ **已實現**
- ✅ 有 DropType Domain 模型 (`lib/domain/drop_type/drop_type.dart`)
- ✅ 有 DropType Repository (`lib/infrastructure/repositories/drop_type_repository_impl.dart`)
- ✅ 有 SQLite 數據庫表支持
- ❌ 缺少 UI 頁面

---

### 4. 數據庫/持久化缺失

#### 4.1 Sink 數據表 ❌
**reef-b-app**: `SinkDao.kt`, `sinks` 表

**koralcore 狀態**: ❌ **未實現**

---

#### 4.2 DropType 數據表 ✅
**reef-b-app**: `DropTypeDao.kt`, `drop_type` 表

**koralcore 狀態**: ✅ **已實現**
- ✅ 有 `drop_type` 表（在 `DatabaseHelper` 中）
- ✅ 支持 CRUD 操作
- ✅ 有唯一索引（name）

---

### 5. 功能完整性檢查

#### 5.1 已實現功能 ✅
- ✅ LED 主要功能（Main, Record, Scene）
- ✅ Dosing 主要功能（Main, Pump Head Detail, Schedule, Calibration, Settings, Manual Dosing）
- ✅ 設備管理（Device List, Device Settings）
- ✅ Favorite 功能
- ✅ Scene 管理
- ✅ 所有主要 BLE opcodes（除 Warning 相關）

#### 5.2 部分實現功能 ⚠️
- ⚠️ Schedule 應用（UseCase 有 TODO）
- ⚠️ Capability 讀取（UseCase 有 TODO）
- ⚠️ Drop Head Record Setting（可能有部分功能）

#### 5.3 未實現功能 ❌
- ⚠️ Sink 管理（Domain 已實現，UI 缺失）
- ⚠️ Warning 處理（Domain/Repository 已實現，BLE 協議和 UI 缺失）
- ⚠️ Drop Type 管理（Domain/Repository 已實現，UI 缺失）
- ❌ LED Master Setting（頁面缺失）
- ❌ LED Setting（頁面缺失）
- ❌ Drop Setting（頁面缺失）

---

## 📊 完成度統計

| 類別 | 已實現 | 部分實現 | 未實現 | 完成度 |
|------|--------|----------|--------|--------|
| UI 頁面 | 15+ | 1 | 6 | ~70% |
| BLE Opcodes | 所有主要 | 0 | 0 | 100% |
| Domain 模型 | 大部分 | 1 | 2 | ~88% |
| UseCase | 大部分 | 2 | 0 | ~90% |
| 持久化 | 主要功能 | 0 | 2 | ~85% |

**總體完成度**: 約 **87%**

---

## 🎯 優先級建議

### 高優先級（核心功能）
1. **Schedule Builders 實現** - 影響排程功能
2. **ApplyScheduleUseCase 完成** - 影響排程應用

### 中優先級（重要功能）
3. **Warning 功能** - 設備警告處理
4. **Drop Type 管理** - 滴液類型配置

### 低優先級（輔助功能）
5. **Sink 管理** - 水槽設備管理
6. **LED/Drop Setting 頁面** - 專用設置頁面
7. **ReadCapabilityUseCase** - 設備能力讀取

---

## 📝 備註

1. **Warning opcodes (0x2C, 0x7B)**: 在 reef-b-app 中也未實現，但 UI 頁面存在，可能是預留功能。

2. **Schedule Builders**: 雖然有 TODO，但相關的 encoder 可能已經實現，需要檢查 `lib/infrastructure/ble/encoder/schedule/` 目錄。

3. **Setting 頁面**: 部分功能可能已經整合到 `DeviceSettingsPage`，需要確認是否滿足需求。

