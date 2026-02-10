# L5 方案 B - 完整功能實現計劃（修訂版）

**決策日期**: 2026-01-03  
**方案**: 從 Parity Mode → Feature Implementation Mode  
**目標**: L5 評分從 33% 提升至 85%+  
**涵蓋範圍**: 26 個頁面（A 區 6 個 + B 區 3 個 + C 區 17 個）

---

## 📊 完整頁面清單

### A. App 啟動 / 主框架（6 個頁面）

| Android UI | Flutter Page | Feature | 狀態 | Mode | 優先級 |
|-----------|-------------|---------|------|------|--------|
| SplashActivity | SplashPage | splash | Built - Incorrect | Correction | P0 |
| MainActivity | MainShellPage | app/home | Built - Incorrect | Correction | P0 |
| HomeFragment | HomeTabPage | home | Built - Incorrect | Correction | P0 |
| BluetoothFragment | BluetoothTabPage | device/bluetooth | Built - Incorrect | Correction | P1 |
| DeviceFragment | DeviceTabPage | device | Built - Incorrect | Correction | P1 |
| WarningActivity | WarningPage | warning | Not Built | Create/Correction | P2 |

---

### B. 裝置 / 水槽管理（3 個頁面）

| Android UI | Flutter Page | Feature | 狀態 | Mode | 優先級 |
|-----------|-------------|---------|------|------|--------|
| SinkManagerActivity | SinkManagerPage | sink | Built - Incorrect | Correction | P1 |
| SinkPositionActivity | SinkPositionPage | sink | Not Built | Create/Correction | P2 |
| AddDeviceActivity | AddDevicePage | device | Not Built | Create/Correction | P2 |

---

### C. 裝置模組（17 個頁面）

#### C-1. Dosing 模組（9 個頁面）

| Android UI | Flutter Page | Feature | 狀態 | Mode | 優先級 |
|-----------|-------------|---------|------|------|--------|
| DropMainActivity | DosingMainPage | doser | Built - Parity | Feature Impl | P0 ⭐ |
| DropSettingActivity | DropSettingPage | doser | Built - Parity | Feature Impl | P1 |
| DropHeadMainActivity | PumpHeadDetailPage | doser | Built - Parity | Feature Impl | P1 |
| DropHeadSettingActivity | PumpHeadSettingsPage | doser | Built - Parity | Feature Impl | P1 |
| DropHeadRecordSettingActivity | PumpHeadRecordSettingPage | doser | Built - Parity | Feature Impl | P2 |
| DropHeadRecordTimeSettingActivity | PumpHeadRecordTimeSettingPage | doser | Built - Parity | Feature Impl | P2 |
| DropHeadAdjustListActivity | PumpHeadAdjustListPage | doser | Built - Parity | Feature Impl | P2 |
| DropHeadAdjustActivity | PumpHeadCalibrationPage | doser | Built - Parity | Feature Impl | P2 |
| DropTypeActivity | DropTypePage | doser | Built - Parity | Feature Impl | P2 |

#### C-2. LED 模組（8 個頁面）

| Android UI | Flutter Page | Feature | 狀態 | Mode | 優先級 |
|-----------|-------------|---------|------|------|--------|
| LedMainActivity | LedMainPage | led | Built - Partial | Feature Impl | P0 ⭐ |
| LedSceneActivity | LedScenePage | led | Built - Parity | Feature Impl | P2 |
| LedSceneAddActivity | LedSceneAddPage | led | Built - Parity | Feature Impl | P2 |
| LedSceneEditActivity | LedSceneEditPage | led | Built - Parity | Feature Impl | P2 |
| LedSceneDeleteActivity | LedSceneDeletePage | led | Built - Parity | Feature Impl | P2 |
| LedRecordActivity | LedRecordPage | led | Built - Parity | Feature Impl | P2 |
| LedRecordTimeSettingActivity | LedRecordTimeSettingPage | led | Built - Parity | Feature Impl | P2 |
| LedRecordSettingActivity | LedRecordSettingPage | led | Built - Parity | Feature Impl | P2 |
| LedSettingActivity | LedSettingPage | led | Built - Parity | Feature Impl | P1 |
| LedMasterSettingActivity | LedMasterSettingPage | led | Built - Parity | Feature Impl | P2 |

---

## 🎯 修訂版實施階段（10 週）

### 第零階段：基礎框架（1 週，P0）⭐⭐⭐

**目標**: 確保 App 基本流程可運行

#### 0.1 SplashPage（2-3 小時）
- 啟動動畫
- 初始化流程
- 導航到 MainShellPage

#### 0.2 MainShellPage（4-6 小時）
- Bottom Navigation
- Tab 切換邏輯
- 狀態保持

#### 0.3 HomeTabPage（4-6 小時）
- Sink Selector
- Device List
- 基本導航

#### 0.4 BluetoothTabPage（3-4 小時）
- Paired Devices List
- Available Devices List
- 基本 UI 互動

#### 0.5 DeviceTabPage（3-4 小時）
- Connected Devices List
- Device Type 分類
- 導航到詳細頁面

**小計**: 16-23 小時  
**L5 提升**: 33% → 40%

---

### 第一階段：核心功能頁面（2 週，P0）⭐⭐⭐

#### 1.1 DosingMainPage（8-10 小時）⭐
**功能**:
- [x] BLE 連線/斷線
- [x] Device Identification Section
- [x] Pump Head Card List (4 個)
- [x] Play Button 立即執行 (0x6E)
- [x] 導航到 PumpHeadDetailPage
- [x] BLE Sync (0x65)

**架構**:
```
DosingMainPage
  ↓
DosingMainController
  ↓
UseCases:
  - ConnectDeviceUseCase
  - SyncDosingStateUseCase
  - ExecuteImmediateDosingUseCase
  ↓
BleDosingRepository
```

---

#### 1.2 LedMainPage（8-10 小時）⭐
**功能**:
- [x] Toolbar 功能選單
- [x] Device Identification Section
- [x] Record/Preview Card
- [x] Scene List
- [x] Scene 切換 + BLE (0x32/0x33)
- [x] 進入調光模式

**架構**:
```
LedMainPage
  ↓
LedMainController
  ↓
UseCases:
  - SwitchSceneUseCase
  - EnterDimmingModeUseCase
  ↓
BleLedRepository
```

**小計**: 16-20 小時  
**L5 提升**: 40% → 55%

---

### 第二階段：設定頁面（2 週，P1）⭐⭐

#### 2.1 DropSettingPage（6-8 小時）
- 編輯裝置名稱
- 選擇水槽位置 → SinkManagerPage
- 選擇延遲時間 → PopupMenu
- 儲存 + BLE (0x6F)

#### 2.2 SinkManagerPage（4-6 小時）
- Sink List
- Add Sink (FAB)
- Edit/Delete Sink
- 返回選擇結果

#### 2.3 PumpHeadDetailPage（6-8 小時）
- Pump Head Info Card
- Record Section + More Button
- Adjust Section + More Button
- 導航到設定/排程/校正頁面

#### 2.4 PumpHeadSettingsPage（6-8 小時）
- 選擇滴液種類 → DropTypePage
- Toggle 最大滴液量
- 編輯最大滴液量
- 選擇轉速 → PopupMenu
- 儲存 + BLE (0x73)

#### 2.5 LedSettingPage（6-8 小時）
- LED 設定項目
- 儲存 + BLE

**小計**: 28-38 小時  
**L5 提升**: 55% → 70%

---

### 第三階段：排程功能（3 週，P2）⭐

#### 3.1 PumpHeadRecordSettingPage（10-12 小時）⭐⭐⭐⭐⭐
**複雜度極高**:
- 選擇排程類型 → PopupMenu (None/24hr/Single/Custom)
- Custom Record Details List
- Add Time → PumpHeadRecordTimeSettingPage
- Edit/Delete Time (Long Press)
- 編輯滴液量
- 選擇轉速 → PopupMenu
- RadioGroup: 立即執行/每週/時段/時間點
- Checkboxes: 星期選擇
- 儲存 + BLE (0x6B-0x6E)

#### 3.2 PumpHeadRecordTimeSettingPage（6-8 小時）
- 選擇開始時間 → PopupMenu
- 選擇結束時間 → PopupMenu
- 選擇滴液次數 → PopupMenu
- 編輯滴液量
- 選擇轉速 → PopupMenu
- 儲存時段設定

#### 3.3 LedRecordSettingPage（10-12 小時）
- 起始強度設定
- 日出/日落設定
- 緩啟動設定
- 月光模式設定
- 儲存 + BLE

#### 3.4 LedRecordPage（6-8 小時）
- Record Overview Card
- Clock Display
- Chart Placeholder
- Control Buttons
- Record List

#### 3.5 LedRecordTimeSettingPage（6-8 小時）
- Time Selection
- Spectrum Chart
- 9 Channel Sliders
- 儲存 + BLE

**小計**: 38-48 小時  
**L5 提升**: 70% → 80%

---

### 第四階段：場景管理（1 週，P2）

#### 4.1 LedScenePage（4-6 小時）
- Scene List (Dynamic + Static)
- Drag to Reorder
- Menu: Add/Edit/Delete

#### 4.2 LedSceneAddPage（4-6 小時）
- Scene Name Input
- Scene Icon Selector
- 儲存

#### 4.3 LedSceneEditPage（4-6 小時）
- Scene Name Edit
- Scene Icon Change
- 儲存

#### 4.4 LedSceneDeletePage（4-6 小時）
- Scene List (Selectable)
- Multi-Select
- Delete Confirmation

**小計**: 16-24 小時  
**L5 提升**: 80% → 83%

---

### 第五階段：校正與其他（2 週，P2-P3）

#### 5.1 PumpHeadCalibrationPage（8-10 小時）⭐⭐⭐⭐
**複雜度高**:
- 多步驟流程（Step 1 → Step 2）
- Step 1: 選擇轉速 + 下一步 + BLE (0x74)
- Step 2: Timer + 編輯校正量 + 完成 + BLE (0x75)
- 取消/返回邏輯

#### 5.2 PumpHeadAdjustListPage（4-6 小時）
- Adjust History List
- 導航到 PumpHeadCalibrationPage

#### 5.3 DropTypePage（6-8 小時）
- Drop Type List (Radio)
- Add Type (FAB) → BottomSheet
- Edit Type → BottomSheet
- Delete Type (Long Press)
- 返回選擇結果

#### 5.4 LedMasterSettingPage（4-6 小時）
- Master/Slave 設定
- 配對邏輯
- 儲存 + BLE

#### 5.5 SinkPositionPage（4-6 小時）
- Sink Position List
- Select Position
- 返回結果

#### 5.6 AddDevicePage（4-6 小時）
- Device Name Input
- Sink Position Select
- 儲存

#### 5.7 WarningPage（4-6 小時）
- Warning List
- Filter/Sort
- 詳細資訊

**小計**: 34-48 小時  
**L5 提升**: 83% → 88%+

---

## 📊 總工作量評估（修訂版）

| 階段 | 頁面數 | 預計時間 | 優先級 | L5 提升 |
|------|--------|---------|--------|---------|
| **第零階段** | 5 個 | 16-23 小時 | P0 ⭐⭐⭐ | 33% → 40% |
| **第一階段** | 2 個 | 16-20 小時 | P0 ⭐⭐⭐ | 40% → 55% |
| **第二階段** | 5 個 | 28-38 小時 | P1 ⭐⭐ | 55% → 70% |
| **第三階段** | 5 個 | 38-48 小時 | P2 ⭐ | 70% → 80% |
| **第四階段** | 4 個 | 16-24 小時 | P2 | 80% → 83% |
| **第五階段** | 7 個 | 34-48 小時 | P2-P3 | 83% → 88%+ |
| **總計** | **26 個** | **148-201 小時** | - | **33% → 88%+** |

**預計完成時間**: 
- 全職：5-7 週
- 兼職：10-14 週

---

## 🏗️ 架構設計

### 模組劃分

```
koralcore/
├── lib/
│   ├── app/                    # 第零階段
│   │   ├── main/              # MainShellPage
│   │   ├── splash/            # SplashPage
│   │   └── warning/           # WarningPage
│   │
│   ├── features/
│   │   ├── home/              # HomeTabPage (第零階段)
│   │   ├── bluetooth/         # BluetoothTabPage (第零階段)
│   │   ├── device/            # DeviceTabPage (第零階段)
│   │   │
│   │   ├── doser/             # Dosing 模組
│   │   │   ├── presentation/
│   │   │   │   ├── pages/
│   │   │   │   │   ├── dosing_main_page.dart      # 第一階段
│   │   │   │   │   ├── drop_setting_page.dart     # 第二階段
│   │   │   │   │   ├── pump_head_detail_page.dart # 第二階段
│   │   │   │   │   ├── pump_head_settings_page.dart # 第二階段
│   │   │   │   │   ├── pump_head_record_setting_page.dart # 第三階段
│   │   │   │   │   ├── pump_head_record_time_setting_page.dart # 第三階段
│   │   │   │   │   ├── pump_head_calibration_page.dart # 第五階段
│   │   │   │   │   ├── pump_head_adjust_list_page.dart # 第五階段
│   │   │   │   │   └── drop_type_page.dart         # 第五階段
│   │   │   │   └── controllers/
│   │   │   │       ├── dosing_main_controller.dart
│   │   │   │       └── ...
│   │   │   ├── domain/
│   │   │   │   └── usecases/
│   │   │   └── data/
│   │   │       └── repositories/
│   │   │
│   │   ├── led/               # LED 模組
│   │   │   ├── presentation/
│   │   │   │   ├── pages/
│   │   │   │   │   ├── led_main_page.dart          # 第一階段
│   │   │   │   │   ├── led_setting_page.dart       # 第二階段
│   │   │   │   │   ├── led_record_setting_page.dart # 第三階段
│   │   │   │   │   ├── led_record_page.dart        # 第三階段
│   │   │   │   │   ├── led_record_time_setting_page.dart # 第三階段
│   │   │   │   │   ├── led_scene_page.dart         # 第四階段
│   │   │   │   │   ├── led_scene_add_page.dart     # 第四階段
│   │   │   │   │   ├── led_scene_edit_page.dart    # 第四階段
│   │   │   │   │   ├── led_scene_delete_page.dart  # 第四階段
│   │   │   │   │   └── led_master_setting_page.dart # 第五階段
│   │   │   │   └── controllers/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   │
│   │   └── sink/              # 水槽管理
│   │       └── presentation/
│   │           └── pages/
│   │               ├── sink_manager_page.dart      # 第二階段
│   │               ├── sink_position_page.dart     # 第五階段
│   │               └── add_device_page.dart        # 第五階段
│   │
│   ├── domain/                # 共用 Domain Layer
│   ├── infrastructure/        # BLE, Database
│   └── shared/                # Widgets, Helpers
```

---

## 🚀 詳細實施步驟

### 第零階段 Week 1: 基礎框架

#### Day 1-2: SplashPage + MainShellPage
```dart
// Step 1: SplashPage (2-3h)
class SplashPage extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  Future<void> _initialize() async {
    // 初始化 BLE, Database, etc.
    await Future.delayed(Duration(seconds: 2));
    Navigator.pushReplacement(context, MainShellPage());
  }
}

// Step 2: MainShellPage (4-6h)
class MainShellPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTabPage(),
          BluetoothTabPage(),
          DeviceTabPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: l10n.tabHome),
          NavigationDestination(icon: Icon(Icons.bluetooth), label: l10n.tabBluetooth),
          NavigationDestination(icon: Icon(Icons.devices), label: l10n.tabDevice),
        ],
      ),
    );
  }
}
```

#### Day 3-4: Tab Pages
```dart
// Step 3: HomeTabPage (4-6h)
class HomeTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SinkSelector(),  // Fixed
        Expanded(child: _DeviceList()),  // Scrollable
      ],
    );
  }
}

// Step 4: BluetoothTabPage (3-4h)
// Step 5: DeviceTabPage (3-4h)
```

---

### 第一階段 Week 2-3: 核心功能

**詳細步驟見前文 DosingMainPage 和 LedMainPage 實施步驟**

---

## 📈 進度追蹤

### Week-by-Week 里程碑

| 週次 | 階段 | 完成頁面 | 累計頁面 | L5 評分 |
|------|------|---------|---------|---------|
| **Week 1** | 第零階段 | 5 個 | 5 | 40% |
| **Week 2-3** | 第一階段 | 2 個 | 7 | 55% |
| **Week 4-5** | 第二階段 | 5 個 | 12 | 70% |
| **Week 6-8** | 第三階段 | 5 個 | 17 | 80% |
| **Week 9** | 第四階段 | 4 個 | 21 | 83% |
| **Week 10-11** | 第五階段 | 7 個 | 26 | **88%+** |

---

## ✅ 驗收標準

### 每個頁面完成 Checklist

- [ ] UI 結構維持 100% Parity
- [ ] 所有 Android 可操作 UI 已實現
- [ ] 所有 onPressed/onChanged 已啟用
- [ ] BLE 指令發送正確
- [ ] ACK/RETURN 處理正確
- [ ] 錯誤處理完整
- [ ] L5-3 點擊時機與 Android 一致
- [ ] 導航流程正確
- [ ] 無 linter errors
- [ ] 基本測試通過

### 階段完成 Checklist

- [ ] 所有該階段頁面完成
- [ ] 集成測試通過
- [ ] L5 評分達到目標
- [ ] 性能測試通過
- [ ] Code Review 完成

---

## 🎯 立即行動（修訂版）

### 今日任務 (2026-01-03)

1. ✅ 產出 L5 審核報告
2. ✅ 產出方案 B 完整實施計劃（修訂版）
3. ⏳ 開始第零階段：SplashPage
   - [ ] 實現 SplashPage UI
   - [ ] 實現初始化邏輯
   - [ ] 實現導航到 MainShellPage
   - [ ] 測試啟動流程

---

## 📄 相關文件

1. `L5_INTERACTION_COMPLETE_AUDIT.md` - L5 審核報告
2. `L5_FEATURE_IMPLEMENTATION_PLAN.md` - 本實施計劃
3. `MANDATORY_PARITY_RULES.md` - Parity 規則
4. `FULL_CONTEXT_REAUDIT.md` - 全面審核報告

---

**執行計劃完成日期**: 2026-01-03  
**涵蓋頁面**: 26 個（A 區 6 + B 區 3 + C 區 17）  
**預計專案完成日期**: 2026-03-14 (10-14 週後)  
**目標**: L5 評分從 33% 提升至 88%+

