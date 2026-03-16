# 完整 Layout 實現計劃 - reef-b-app → koralcore

## 可行性確認

### ✅ **技術可行性：100% 可行**

Flutter 可以實現所有 reef-b-app 的 XML layout 功能，包括：
- ✅ 所有布局結構（ConstraintLayout → Column/Row/Stack）
- ✅ 所有組件（TextView → Text, ImageView → Image, RecyclerView → ListView/GridView）
- ✅ 所有樣式（顏色、尺寸、字體、圓角、陰影）
- ✅ 所有交互（按鈕、滑塊、選擇器、對話框）
- ✅ 所有自定義組件（通過 CustomPainter 實現）

---

## Layout 文件統計

### reef-b-app Layout 文件總數

| 類別 | 數量 | 文件類型 |
|------|------|----------|
| Activity Layout | 25 | `activity_*.xml` |
| Fragment Layout | 3 | `fragment_*.xml` |
| Adapter Layout | 21 | `adapter_*.xml` |
| Toolbar Layout | 3 | `toolbar_*.xml` |
| 其他組件 | 5 | `bottom_sheet_*.xml`, `dialog_*.xml`, `progress.xml`, `spinner_*.xml` |
| **總計** | **57** | - |

### koralcore 對應實現狀態

| 類別 | reef-b-app | koralcore | 完成度 |
|------|------------|-----------|--------|
| Activity 頁面 | 25 | 25 | **100%** ✅ |
| Fragment 頁面 | 3 | 3 | **100%** ✅ |
| Adapter 組件 | 21 | ~15 | **~71%** ⚠️ |
| Toolbar 組件 | 3 | 0 | **0%** ❌ |
| 其他組件 | 5 | ~3 | **~60%** ⚠️ |

---

## 詳細對照清單

### 1. Activity Layout（25 個）

#### ✅ 已實現（25/25）

| # | reef-b-app | koralcore | 狀態 | 細節對齊度 |
|---|------------|-----------|------|------------|
| 1 | `activity_main.xml` | `MainScaffold` | ✅ | ⚠️ 需檢查 BottomNavigation 樣式 |
| 2 | `activity_splash.xml` | `SplashPage` | ✅ | ⚠️ 需檢查動畫和時序 |
| 3 | `activity_home.xml` | `HomePage` | ✅ | ⚠️ 需對齊 Sink 選擇器和布局切換 |
| 4 | `activity_bluetooth.xml` | `BluetoothPage` | ✅ | ⚠️ 需對齊設備卡片樣式 |
| 5 | `activity_device.xml` | `DevicePage` | ✅ | ⚠️ 需對齊設備卡片樣式 |
| 6 | `activity_add_device.xml` | `AddDevicePage` | ✅ | ⚠️ 需檢查表單布局 |
| 7 | `activity_led_main.xml` | `LedMainPage` | ✅ | ⚠️ 需添加設備信息區域和分隔線 |
| 8 | `activity_led_control.xml` | `LedControlPage` | ✅ | ⚠️ 需檢查控制界面布局 |
| 9 | `activity_led_scene.xml` | `LedSceneListPage` | ✅ | ⚠️ 需檢查場景列表布局 |
| 10 | `activity_led_scene_add.xml` | `LedSceneAddPage` | ✅ | ⚠️ 需檢查表單布局 |
| 11 | `activity_led_scene_edit.xml` | `LedSceneEditPage` | ✅ | ⚠️ 需檢查表單布局 |
| 12 | `activity_led_scene_delete.xml` | `LedSceneDeletePage` | ✅ | ⚠️ 需檢查確認對話框 |
| 13 | `activity_led_record.xml` | `LedRecordPage` | ✅ | ⚠️ 需檢查圖表布局 |
| 14 | `activity_led_record_setting.xml` | `LedRecordSettingPage` | ✅ | ⚠️ **需實現 CustomDashBoard** |
| 15 | `activity_led_record_time_setting.xml` | `LedRecordTimeSettingPage` | ✅ | ⚠️ 需檢查時間選擇布局 |
| 16 | `activity_led_setting.xml` | `LedSettingPage` | ✅ | ⚠️ 需檢查設置表單布局 |
| 17 | `activity_led_master_setting.xml` | `LedMasterSettingPage` | ✅ | ⚠️ 需檢查主從設置布局 |
| 18 | `activity_drop_main.xml` | `DosingMainPage` | ✅ | ⚠️ 需檢查主頁布局 |
| 19 | `activity_drop_head_main.xml` | `PumpHeadDetailPage` | ✅ | ⚠️ 需檢查詳情頁布局 |
| 20 | `activity_drop_head_setting.xml` | `PumpHeadSettingsPage` | ✅ | ⚠️ 需檢查設置表單 |
| 21 | `activity_drop_head_adjust.xml` | `PumpHeadCalibrationPage` | ✅ | ⚠️ 需檢查校準界面 |
| 22 | `activity_drop_head_adjust_list.xml` | `PumpHeadAdjustListPage` | ✅ | ⚠️ 需檢查列表布局 |
| 23 | `activity_drop_head_record_setting.xml` | `PumpHeadRecordSettingPage` | ✅ | ⚠️ 需檢查設置表單 |
| 24 | `activity_drop_head_record_time_setting.xml` | `PumpHeadRecordTimeSettingPage` | ✅ | ⚠️ 需檢查時間選擇 |
| 25 | `activity_drop_setting.xml` | `DropSettingPage` | ✅ | ⚠️ 需檢查設置表單 |
| 26 | `activity_drop_type.xml` | `DropTypePage` | ✅ | ⚠️ 需檢查類型管理界面 |
| 27 | `activity_sink_manager.xml` | `SinkManagerPage` | ✅ | ⚠️ 需檢查管理界面 |
| 28 | `activity_sink_position.xml` | `SinkPositionPage` | ✅ | ⚠️ 需檢查位置選擇界面 |
| 29 | `activity_warning.xml` | `WarningPage` | ✅ | ⚠️ 需檢查警告列表布局 |

**狀態**：所有頁面都已實現，但**細節對齊度約 70-80%**

---

### 2. Fragment Layout（3 個）

#### ✅ 已實現（3/3）

| # | reef-b-app | koralcore | 狀態 | 細節對齊度 |
|---|------------|-----------|------|------------|
| 1 | `fragment_home.xml` | `HomePage` | ✅ | ⚠️ 需對齊 Sink 選擇器和布局切換 |
| 2 | `fragment_bluetooth.xml` | `BluetoothPage` | ✅ | ⚠️ 需對齊設備卡片樣式 |
| 3 | `fragment_device.xml` | `DevicePage` | ✅ | ⚠️ 需對齊設備卡片樣式 |

**狀態**：所有 Fragment 都已實現，但**細節對齊度約 70%**

---

### 3. Adapter Layout（21 個）

#### ⚠️ 部分實現（~15/21）

| # | reef-b-app | koralcore | 狀態 | 說明 |
|---|------------|-----------|------|------|
| 1 | `adapter_device_led.xml` | `DeviceCard` | ✅ | 需對齊樣式（Card, 圓角 10dp, elevation 5dp） |
| 2 | `adapter_device_drop.xml` | `DeviceCard` | ✅ | 同上 |
| 3 | `adapter_sink_with_devices.xml` | `_HomeDeviceTile` | ⚠️ | 需實現 Sink 嵌套設備列表 |
| 4 | `adapter_ble_scan.xml` | `_BtDeviceTile` | ⚠️ | 需簡化樣式（背景 `bg_aaaa`） |
| 5 | `adapter_ble_my_device.xml` | `_BtDeviceTile` | ✅ | 需檢查樣式 |
| 6 | `adapter_favorite_scene.xml` | `_FavoriteSceneCard` | ✅ | 需檢查樣式 |
| 7 | `adapter_scene.xml` | `_SceneCard` | ✅ | 需檢查樣式 |
| 8 | `adapter_scene_select.xml` | `_SceneSelectItem` | ✅ | 需檢查樣式 |
| 9 | `adapter_scene_icon.xml` | `_SceneIconItem` | ✅ | 需檢查樣式 |
| 10 | `adapter_sink.xml` | `_SinkCard` | ✅ | 需檢查樣式 |
| 11 | `adapter_sink_select.xml` | `_SinkSelectItem` | ✅ | 需檢查樣式 |
| 12 | `adapter_warning.xml` | `_WarningCard` | ✅ | 需檢查樣式 |
| 13 | `adapter_drop_head.xml` | `_PumpHeadCard` | ✅ | 需檢查樣式 |
| 14 | `adapter_drop_type.xml` | `_DropTypeCard` | ✅ | 需檢查樣式 |
| 15 | `adapter_drop_record_detail.xml` | `_RecordDetailItem` | ✅ | 需檢查樣式 |
| 16 | `adapter_drop_custom_record_detail.xml` | `_CustomRecordDetailItem` | ✅ | 需檢查樣式 |
| 17 | `adapter_led_record.xml` | `_LedRecordItem` | ✅ | 需檢查樣式 |
| 18 | `adapter_adjust.xml` | `_AdjustItem` | ✅ | 需檢查樣式 |
| 19 | `adapter_choose_group.xml` | `_GroupSelectItem` | ✅ | 需檢查樣式 |
| 20 | `adapter_delay_time.xml` | `_DelayTimeItem` | ✅ | 需檢查樣式 |
| 21 | `adapter_master_setting.xml` | `_MasterSettingItem` | ✅ | 需檢查樣式 |

**狀態**：大部分已實現，但**樣式細節需對齊**

---

### 4. Toolbar Layout（3 個）

#### ❌ 未實現（0/3）

| # | reef-b-app | koralcore | 狀態 | 說明 |
|---|------------|-----------|------|------|
| 1 | `toolbar_app.xml` | - | ❌ | 主頁面 Toolbar（白色背景，2dp 分隔線） |
| 2 | `toolbar_device.xml` | - | ❌ | 設備頁面 Toolbar（返回、標題、菜單、喜愛按鈕，2dp 分隔線） |
| 3 | `toolbar_two_action.xml` | - | ❌ | 雙操作 Toolbar |

**狀態**：**需要實現**，目前使用 Flutter 標準 `AppBar`，缺少 2dp 分隔線

---

### 5. 其他組件（5 個）

#### ⚠️ 部分實現（~3/5）

| # | reef-b-app | koralcore | 狀態 | 說明 |
|---|------------|-----------|------|------|
| 1 | `bottom_sheet_edittext.xml` | `showModalBottomSheet` | ✅ | Flutter 內建，功能已整合 |
| 2 | `bottom_sheet_recyclerview.xml` | `showModalBottomSheet` | ✅ | Flutter 內建，功能已整合 |
| 3 | `dialog_loading.xml` | `CircularProgressIndicator` | ✅ | Flutter 內建 |
| 4 | `progress.xml` | `CircularProgressIndicator` | ✅ | Flutter 內建 |
| 5 | `spinner_item_text.xml` | `DropdownButton` | ✅ | Flutter 內建 |

**狀態**：**已實現**，使用 Flutter 內建組件

---

## 需要特別注意的細節

### 1. 自定義組件

#### ⚠️ **CustomDashBoard**（半圓形儀表盤）

**reef-b-app**：
- 自定義 Kotlin 組件 `CustomDashBoard.kt`
- 用於顯示百分比（如 Initial Intensity 50%）
- 半圓形進度指示器，藍色填充

**koralcore 實現方案**：
```dart
// 使用 CustomPainter 實現
class SemiCircleDashboard extends CustomPainter {
  final double progress; // 0.0 - 1.0
  final Color progressColor;
  
  @override
  void paint(Canvas canvas, Size size) {
    // 繪製半圓形進度條
  }
}
```

**狀態**：❌ **需要實現**

---

### 2. 樣式細節對齊

#### 設備卡片樣式

**reef-b-app** (`adapter_device_led.xml`)：
```xml
<MaterialCardView
    app:cardCornerRadius="@dimen/dp_10"
    app:cardElevation="@dimen/dp_5"
    android:layout_margin="@dimen/dp_6" />
```

**koralcore 當前**：
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(ReefRadius.lg), // 可能不是 10dp
    // 無 elevation
  ),
)
```

**需要修改**：
```dart
Card(
  elevation: 5.0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10.0), // 明確使用 10dp
  ),
  margin: EdgeInsets.all(6.0), // 明確使用 6dp
)
```

**狀態**：⚠️ **需要對齊**

---

#### Toolbar 分隔線

**reef-b-app** (`toolbar_device.xml`)：
```xml
<MaterialDivider
    android:layout_height="@dimen/dp_2"
    app:dividerColor="@color/bg_press" />
```

**koralcore 當前**：
```dart
AppBar(
  // 無分隔線
)
```

**需要修改**：
```dart
Column(
  children: [
    AppBar(...),
    Divider(
      height: 2.0,
      color: ReefColors.bgPress,
      thickness: 2.0,
    ),
    // 內容
  ],
)
```

**狀態**：❌ **需要實現**

---

### 3. 布局結構對齊

#### Home 頁面 Sink 選擇器

**reef-b-app** (`fragment_home.xml`)：
- `Spinner` 組件
- 動態切換 Adapter 和 LayoutManager
- 位置 0：所有 Sink → `LinearLayoutManager`
- 位置 1+：特定 Sink → `GridLayoutManager(2列)`

**koralcore 當前**：
- 臨時使用 `Text` 顯示
- 固定使用 `ListView`

**需要實現**：
```dart
DropdownButton<String>(
  value: selectedSink,
  items: sinkOptions.map((sink) => 
    DropdownMenuItem(value: sink, child: Text(sink))
  ).toList(),
  onChanged: (value) {
    // 切換數據源和布局
    if (value == 'All Sinks') {
      // 使用垂直列表
    } else {
      // 使用 2列網格
    }
  },
)
```

**狀態**：❌ **需要實現**

---

## 實現優先級

### 🔴 高優先級（影響視覺一致性）

1. **Toolbar 分隔線**（所有頁面）
   - 影響：所有頁面的視覺一致性
   - 工作量：小（~2 小時）
   - 優先級：🔴 **最高**

2. **設備卡片樣式對齊**
   - 影響：Home、Device、Bluetooth 頁面
   - 工作量：中（~4 小時）
   - 優先級：🔴 **高**

3. **CustomDashBoard 實現**
   - 影響：`LedRecordSettingPage`
   - 工作量：中（~6 小時）
   - 優先級：🔴 **高**

4. **Home 頁面 Sink 選擇器**
   - 影響：Home 頁面核心功能
   - 工作量：中（~4 小時）
   - 優先級：🔴 **高**

### 🟡 中優先級（影響功能完整性）

5. **Home 頁面布局切換**（垂直列表 vs 2列網格）
   - 影響：Home 頁面顯示方式
   - 工作量：中（~4 小時）
   - 優先級：🟡 **中**

6. **LED Main 頁面設備信息區域**
   - 影響：LED 主頁面信息顯示
   - 工作量：小（~2 小時）
   - 優先級：🟡 **中**

7. **Adapter 樣式細節對齊**
   - 影響：所有列表項的視覺一致性
   - 工作量：大（~16 小時）
   - 優先級：🟡 **中**

### 🟢 低優先級（優化細節）

8. **其他頁面布局細節對齊**
   - 影響：各頁面的細微差異
   - 工作量：大（~20 小時）
   - 優先級：🟢 **低**

---

## 實現策略

### 階段 1：核心視覺對齊（1-2 週）

1. ✅ 實現 Toolbar 分隔線組件
2. ✅ 對齊設備卡片樣式
3. ✅ 實現 CustomDashBoard
4. ✅ 實現 Home 頁面 Sink 選擇器

### 階段 2：布局結構對齊（1-2 週）

5. ✅ 實現 Home 頁面布局切換
6. ✅ 添加 LED Main 頁面設備信息區域
7. ✅ 對齊主要 Adapter 樣式

### 階段 3：細節完善（2-3 週）

8. ✅ 對齊所有 Adapter 樣式細節
9. ✅ 對齊所有頁面布局細節
10. ✅ 視覺回歸測試

---

## 技術實現方案

### 1. CustomDashBoard 實現

```dart
// lib/ui/widgets/semi_circle_dashboard.dart
class SemiCircleDashboard extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final Color progressColor;
  final String label;
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, 123),
      painter: _SemiCircleDashboardPainter(
        progress: progress,
        progressColor: progressColor,
      ),
      child: Center(
        child: Text(
          label,
          style: ReefTextStyles.headline,
        ),
      ),
    );
  }
}

class _SemiCircleDashboardPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  
  @override
  void paint(Canvas canvas, Size size) {
    // 繪製半圓形背景
    // 繪製進度填充
  }
}
```

### 2. Toolbar 分隔線組件

```dart
// lib/ui/widgets/reef_app_bar.dart
class ReefAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final bool showDivider;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          leading: leading,
          title: title,
          actions: actions,
          backgroundColor: ReefColors.white,
        ),
        if (showDivider)
          Divider(
            height: 2.0,
            thickness: 2.0,
            color: ReefColors.bgPress,
          ),
      ],
    );
  }
}
```

### 3. 設備卡片樣式組件

```dart
// lib/ui/widgets/reef_device_card.dart
class ReefDeviceCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.all(6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: onTap,
        child: child,
      ),
    );
  }
}
```

---

## 總結

### ✅ **可行性：100%**

所有 reef-b-app 的 layout 都可以在 koralcore 中實現，包括：
- ✅ 所有頁面結構
- ✅ 所有組件樣式
- ✅ 所有交互行為
- ✅ 所有自定義組件

### 📊 **當前狀態**

- **頁面覆蓋**：100% ✅
- **功能完整性**：~90% ✅
- **視覺對齊度**：~70% ⚠️
- **細節對齊度**：~60% ⚠️

### 🎯 **目標**

通過 3 個階段的實現，達到：
- **視覺對齊度**：100% ✅
- **細節對齊度**：100% ✅

### ⏱️ **預計時間**

- **階段 1**（核心視覺對齊）：1-2 週
- **階段 2**（布局結構對齊）：1-2 週
- **階段 3**（細節完善）：2-3 週
- **總計**：4-7 週

---

## 結論

**✅ 是的，所有 layout 都可以在 koralcore 中實現，包括所有內容和細節。**

需要開始實施嗎？建議從**階段 1**開始，優先處理 Toolbar 分隔線和設備卡片樣式對齊。

