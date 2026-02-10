# L5 方案 B - 完整功能實現計劃

**決策日期**: 2026-01-03  
**方案**: 從 Parity Mode 轉為 Feature Implementation Mode  
**目標**: L5 評分從 33% 提升至 85%+

---

## 🎯 執行策略

### 核心原則

1. ✅ **保留 UI 結構**（已達 100% Parity）
2. ✅ **實現業務邏輯**（Controller、UseCase、Repository）
3. ✅ **恢復互動行為**（onPressed、onChanged）
4. ✅ **實現 BLE 通訊**（Command、ACK、State）
5. ✅ **驗證點擊時機**（與 Android 一致）

---

## 📋 實施階段

### 第一階段：核心頁面（2 週）

**優先級 P0 - 主要流程頁面**

#### 1. DosingMainPage ⭐
**預計時間**: 8-10 小時

**需實現功能**:
- [x] BLE 連線/斷線按鈕
- [x] Pump Head Card 導航
- [x] 立即執行單次滴液（Play Button）
- [x] BLE Sync (0x65)
- [x] 立即執行 BLE (0x6E)
- [x] 讀取今日總量 (0x7E/0x7A)

**架構**:
```
DosingMainPage (UI)
    ↓
DosingMainController (State Management)
    ↓
UseCases:
  - ConnectDeviceUseCase
  - SyncDosingStateUseCase
  - ExecuteImmediateDosingUseCase
    ↓
Repositories:
  - BleDosingRepository (BLE 指令)
  - DeviceRepository (裝置狀態)
```

**Android 對照**:
- `DropMainActivity.kt`
- `DropMainViewModel.kt`

---

#### 2. LedMainPage ⭐
**預計時間**: 8-10 小時

**需實現功能**:
- [x] Toolbar 功能選單
- [x] Scene 切換
- [x] BLE 發送場景 (0x32/0x33)
- [x] 調光模式切換

**架構**:
```
LedMainPage (UI)
    ↓
LedMainController
    ↓
UseCases:
  - SwitchSceneUseCase
  - EnterDimmingModeUseCase
    ↓
Repositories:
  - BleLedRepository
```

**Android 對照**:
- `LedMainActivity.kt`
- `LedMainViewModel.kt`

---

### 第二階段：設定頁面（2 週）

**優先級 P1 - 高頻使用設定**

#### 3. DropSettingPage
**預計時間**: 6-8 小時

**需實現功能**:
- [x] 編輯裝置名稱
- [x] 選擇水槽位置
- [x] 選擇延遲時間
- [x] 儲存設定 + BLE (0x6F)

**架構**:
```
DropSettingPage (UI)
    ↓
DropSettingController
    ↓
UseCases:
  - UpdateDeviceNameUseCase
  - UpdateSinkPositionUseCase
  - SetDelayTimeUseCase (BLE)
    ↓
Repositories:
  - DeviceRepository
  - BleDosingRepository
```

---

#### 4. PumpHeadSettingsPage
**預計時間**: 6-8 小時

**需實現功能**:
- [x] 選擇滴液種類
- [x] Toggle 最大滴液量
- [x] 編輯最大滴液量
- [x] 選擇轉速
- [x] 儲存 + BLE (0x73)

---

#### 5. LedSettingPage
**預計時間**: 6-8 小時

**需實現功能**:
- [x] 調整 LED 設定
- [x] 儲存設定 + BLE

---

### 第三階段：排程功能（3 週）

**優先級 P2 - 複雜業務邏輯**

#### 6. PumpHeadRecordSettingPage
**預計時間**: 10-12 小時

**需實現功能**:
- [x] 選擇排程類型
- [x] 新增/編輯/刪除時段
- [x] 設定滴液量、轉速
- [x] 選擇執行時間（立即/每週/時段/時間點）
- [x] 儲存排程 + BLE (0x6B-0x6E)

**複雜度**: ⭐⭐⭐⭐⭐

---

#### 7. PumpHeadRecordTimeSettingPage
**預計時間**: 6-8 小時

**需實現功能**:
- [x] 選擇開始/結束時間
- [x] 選擇滴液次數
- [x] 編輯滴液量
- [x] 選擇轉速
- [x] 儲存時段設定

---

#### 8. LedRecordSettingPage
**預計時間**: 10-12 小時

**需實現功能**:
- [x] LED 排程設定
- [x] 起始強度、日出日落
- [x] 緩啟動、月光模式
- [x] 儲存 + BLE

---

### 第四階段：校正與其他（2 週）

**優先級 P3 - 低頻使用功能**

#### 9. PumpHeadCalibrationPage
**預計時間**: 8-10 小時

**需實現功能**:
- [x] 多步驟校正流程
- [x] 選擇轉速
- [x] 下一步 + BLE (0x74)
- [x] 編輯校正量
- [x] 完成校正 + BLE (0x75)
- [x] Timer 控制

**複雜度**: ⭐⭐⭐⭐

---

#### 10-15. 其他頁面
- PumpHeadAdjustListPage (4h)
- DropTypePage (6h)
- PumpHeadDetailPage (4h)
- LedScenePage (6h)
- LedSceneAddPage (4h)
- LedSceneEditPage (4h)
- LedSceneDeletePage (4h)
- LedRecordPage (6h)
- LedRecordTimeSettingPage (6h)
- LedMasterSettingPage (4h)
- SinkManagerPage (4h)
- SinkPositionPage (4h)
- AddDevicePage (4h)

---

## 📊 工作量評估

| 階段 | 頁面數 | 預計時間 | 優先級 |
|------|--------|---------|--------|
| **第一階段** | 2 個 | 16-20 小時 | P0 ⭐⭐⭐ |
| **第二階段** | 3 個 | 18-24 小時 | P1 ⭐⭐ |
| **第三階段** | 3 個 | 26-32 小時 | P2 ⭐ |
| **第四階段** | 12 個 | 60-70 小時 | P3 |
| **總計** | **20 個** | **120-146 小時** | - |

**預計完成時間**: 4-6 週（全職）或 8-12 週（兼職）

---

## 🏗️ 架構設計

### 層級劃分

```
┌─────────────────────────────────────────┐
│  Presentation Layer (UI)                │
│  - Page (StatelessWidget)               │
│  - Widgets                               │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Application Layer (Controller)         │
│  - ChangeNotifier / StateNotifier        │
│  - State Management                      │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Domain Layer (UseCase)                 │
│  - Business Logic                        │
│  - Validation                            │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Infrastructure Layer (Repository)       │
│  - BLE Communication                     │
│  - Data Persistence                      │
│  - External APIs                         │
└─────────────────────────────────────────┘
```

---

### 狀態管理

**選擇**: `ChangeNotifier` + `Provider`（已存在於專案中）

**狀態分類**:
1. **UI State**: Loading, Error, Success
2. **Data State**: Device, PumpHead, Schedule, etc.
3. **BLE State**: Connected, Disconnected, Syncing

---

### BLE 通訊流程

```
User Action (UI)
    ↓
Controller.method()
    ↓
UseCase.execute()
    ↓
Repository.sendCommand()
    ↓
BLE Command Builder (0x6E, 0x6F, etc.)
    ↓
BLE Adapter → Android Device
    ↓
ACK/RETURN Parser
    ↓
Update State
    ↓
UI Refresh
```

---

## 📝 實施規範

### Code Style

1. **命名規範**:
   ```dart
   // Controller
   class DosingMainController extends ChangeNotifier {
     Future<void> executeImmediateDosingAsync(String headId) async { }
   }
   
   // UseCase
   class ExecuteImmediateDosingUseCase {
     Future<Result<void>> call(String deviceId, String headId) async { }
   }
   
   // Repository
   abstract class BleDosingRepository {
     Future<void> sendImmediateDosingCommand(int headIndex);
   }
   ```

2. **Error Handling**:
   ```dart
   sealed class Result<T> {
     const Result();
   }
   
   class Success<T> extends Result<T> {
     final T data;
     const Success(this.data);
   }
   
   class Failure<T> extends Result<T> {
     final String message;
     const Failure(this.message);
   }
   ```

3. **State Pattern**:
   ```dart
   enum LoadingState { idle, loading, success, error }
   
   class DosingMainState {
     final LoadingState loadingState;
     final List<PumpHead> pumpHeads;
     final String? errorMessage;
     
     const DosingMainState({
       this.loadingState = LoadingState.idle,
       this.pumpHeads = const [],
       this.errorMessage,
     });
   }
   ```

---

### 測試策略

1. **Unit Tests**: UseCase, Repository
2. **Widget Tests**: Controller, UI
3. **Integration Tests**: End-to-End 流程

---

## 🚀 立即開始：第一階段第一個頁面

### DosingMainPage 實施計劃

#### Step 1: 恢復 Controller (1-2 小時)

**檔案**: `lib/features/doser/presentation/controllers/dosing_main_controller.dart`

**需實現**:
```dart
class DosingMainController extends ChangeNotifier {
  final ConnectDeviceUseCase _connectDeviceUseCase;
  final SyncDosingStateUseCase _syncDosingStateUseCase;
  final ExecuteImmediateDosingUseCase _executeImmediateDosingUseCase;
  
  DosingMainState _state = const DosingMainState();
  DosingMainState get state => _state;
  
  Future<void> initialize(String deviceId) async { }
  Future<void> connectBle() async { }
  Future<void> executeImmediate(String headId) async { }
}
```

---

#### Step 2: 實現 UseCases (2-3 小時)

**檔案**: `lib/domain/doser/usecases/`

1. `connect_device_usecase.dart`
2. `sync_dosing_state_usecase.dart`
3. `execute_immediate_dosing_usecase.dart`

---

#### Step 3: 恢復 Repository (2-3 小時)

**檔案**: `lib/infrastructure/ble/dosing/`

1. `ble_dosing_repository.dart` (interface)
2. `ble_dosing_repository_impl.dart` (implementation)

**需實現 BLE Commands**:
- 0x65: Sync Start
- 0x6E: Immediate Dosing
- 0x7E/0x7A: Read Today Totals

---

#### Step 4: 更新 UI (1-2 小時)

**檔案**: `lib/features/doser/presentation/pages/dosing_main_page.dart`

**修改**:
```dart
// 之前 (Parity Mode):
onPressed: null,  // ❌

// 之後 (Feature Mode):
onPressed: () => controller.executeImmediate(headId),  // ✅
```

---

#### Step 5: 測試與驗證 (1-2 小時)

**驗證項目**:
- [ ] BLE 連線功能正常
- [ ] Pump Head 導航正常
- [ ] 立即執行功能正常
- [ ] BLE 指令發送正確
- [ ] ACK 處理正確
- [ ] 狀態更新正確
- [ ] L5-3 點擊時機與 Android 一致

---

## 📈 進度追蹤

### 每日進度更新

**格式**:
```markdown
## 2026-01-03
- [x] 產出 L5 審核報告
- [x] 產出方案 B 實施計劃
- [ ] 開始 DosingMainPage Step 1

## 2026-01-04
- [ ] 完成 DosingMainPage Step 1-2
...
```

---

### 每週里程碑

| 週次 | 目標 | 完成頁面 | L5 評分 |
|------|------|---------|---------|
| **Week 1** | 第一階段完成 | DosingMainPage, LedMainPage | 50% |
| **Week 2** | 第二階段 50% | +DropSettingPage | 60% |
| **Week 3** | 第二階段完成 | +PumpHeadSettingsPage, LedSettingPage | 70% |
| **Week 4** | 第三階段 30% | +1 個排程頁面 | 75% |
| **Week 5-6** | 第三階段完成 | +所有排程頁面 | 80% |
| **Week 7-8** | 第四階段完成 | +所有其他頁面 | **85%+** |

---

## ✅ 驗收標準

### 每個頁面完成標準

- [ ] UI 結構維持 100% Parity
- [ ] 所有可操作 UI 已啟用
- [ ] 所有 onPressed 行為已實現
- [ ] BLE 指令發送正確
- [ ] ACK 處理正確
- [ ] 錯誤處理完整
- [ ] L5-3 點擊時機與 Android 一致
- [ ] 無 linter errors
- [ ] 通過基本測試

---

### L5 最終目標

```
L5-1 可操作 UI 清單: ✅ 100% (維持)
L5-2 點擊結果一致性: ✅ 90%+  (從 0% 提升)
L5-3 點擊時機一致性: ✅ 90%+  (可驗證)

━━━━━━━━━━━━━━━━━━━
  L5 整體評分: 85%+ ✅
━━━━━━━━━━━━━━━━━━━
```

---

## 🎯 立即行動

### 今日任務 (2026-01-03)

1. ✅ 產出 L5 審核報告
2. ✅ 產出方案 B 實施計劃
3. ⏳ 開始 DosingMainPage 實施
   - [ ] Step 1: 恢復 Controller
   - [ ] Step 2: 實現 UseCases
   - [ ] Step 3: 恢復 Repository
   - [ ] Step 4: 更新 UI
   - [ ] Step 5: 測試與驗證

---

**執行計劃完成日期**: 2026-01-03  
**預計專案完成日期**: 2026-02-28 (8 週後)  
**目標**: L5 評分從 33% 提升至 85%+

