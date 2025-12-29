# 設備編輯功能對照分析

## 1. reef-b-app 中的編輯功能

### LED 設備編輯（LedSettingActivity）

#### UI 文件
- **`activity_led_setting.xml`** - LED 設置頁面布局
- **`LedSettingActivity.kt`** - LED 設置 Activity
- **`LedSettingViewModel.kt`** - LED 設置 ViewModel

#### 可編輯項目
1. **設備名稱** (`edtName`)
   - 文本輸入框
   - 保存時檢查：不能為空

2. **水槽位置** (`btnPosition`)
   - 按鈕，點擊後跳轉到 `SinkPositionActivity`
   - 顯示當前水槽名稱，或「未分配」
   - 可以選擇新水槽或設為未分配

#### 編輯邏輯（LedSettingViewModel.editDevice）

**步驟 1：驗證名稱**
```kotlin
if (edtName.isEmpty()) {
    nameIsEmpty()
    return
}
```

**步驟 2：判斷水槽位置是否改變**
- 如果 `nowDevice.sinkId == selectSinkId`（水槽位置沒變）：
  - 只更新設備名稱，保留 `master` 和 `group`
  
- 如果水槽位置改變：
  - **情況 A**：`selectSinkId == 0`（未分配水槽）
    - 清除 `sinkId`、`group`、`master`
  - **情況 B**：選擇新水槽
    - 調用 `addToWhichGroup(selectSinkId)` 查找可用群組
    - 如果所有群組都滿（返回 null）→ 調用 `sinkIsFull()`
    - 如果有可用群組 → 設置 `sinkId`、`group`，`master = false`

**步驟 3：保存到數據庫**
```kotlin
dbEditDevice(DeviceEdit(...))
```

#### 主燈移動限制（canMoveDevice）

**規則**：
- 如果設備未分配水槽 → 可以移動
- 如果群組內只有 1 個設備 → 可以移動（即使它是主燈）
- 如果群組內有多個設備：
  - 主燈（`master == true`）→ **不能移動**
  - 副燈（`master == false`）→ 可以移動

**錯誤提示**：
- `dialog_led_move_master_content` = "欲將此裝置移動到其他水槽請先修改主從設定，將其他副燈設定為主燈"

---

### DROP 設備編輯（DropSettingActivity）

#### UI 文件
- **`activity_drop_setting.xml`** - DROP 設置頁面布局
- **`DropSettingActivity.kt`** - DROP 設置 Activity
- **`DropSettingViewModel.kt`** - DROP 設置 ViewModel

#### 可編輯項目
1. **設備名稱** (`edtName`)
   - 文本輸入框
   - 保存時檢查：不能為空

2. **水槽位置** (`btnPosition`)
   - 按鈕，點擊後跳轉到 `SinkPositionActivity`
   - 顯示當前水槽名稱，或「未分配」
   - 可以選擇新水槽或設為未分配

3. **延遲時間** (`btnDelayTime`)
   - 按鈕，點擊後顯示 PopupMenu
   - 選項：15秒、30秒、1分鐘、2分鐘、3分鐘、4分鐘、5分鐘
   - **需要 BLE 連接**才能設置（`isConnectNowDevice()`）

#### 編輯邏輯（DropSettingViewModel.editDevice）

**步驟 1：驗證名稱**
```kotlin
if (edtName.isEmpty()) {
    nameIsEmpty()
    return
}
```

**步驟 2：判斷水槽位置是否改變**
- 如果 `nowDevice.sinkId == selectSinkId`（水槽位置沒變）：
  - 只更新設備名稱，保留 `master` 和 `group`
  
- 如果水槽位置改變：
  - **情況 A**：`selectSinkId == 0`（未分配水槽）
    - 清除 `sinkId`
  - **情況 B**：選擇新水槽
    - 檢查該水槽的 DROP 設備數量：`dbGetDropInSinkBySinkId(selectSinkId).size`
    - 如果 >= 4 → 調用 `sinkIsFull()`
    - 如果 < 4 → 更新 `sinkId`

**步驟 3：保存到數據庫**
```kotlin
dbEditDevice(DeviceEdit(...))
```

**步驟 4：設置延遲時間（需要 BLE 連接）**
- 如果設備已連接：發送 BLE 指令 `bleSetDelayTime(selectDelayTime)`
- 如果設備未連接：直接標記為成功

---

## 2. koralcore 中的實現

### LED 設備編輯（LedSettingPage）

#### 文件位置
- **`lib/ui/features/led/pages/led_setting_page.dart`**

#### 已實現功能
1. ✅ **設備名稱編輯**
   - 使用 `TextField` 輸入
   - 保存時檢查：不能為空
   - 使用 `UpdateDeviceNameUseCase` 更新名稱

2. ⚠️ **水槽位置編輯**（部分實現）
   - 有按鈕可以跳轉到 `SinkPositionPage`
   - **問題**：只顯示 SnackBar，沒有實際更新設備的 `sinkId`
   - **TODO**：`// TODO: Update device sink_id if selectedSinkId is not null`

#### 缺失功能
- ❌ 水槽位置更新邏輯（只顯示提示，未實際保存）
- ❌ 主燈移動限制檢查（`canMoveDevice()`）
- ❌ 群組自動分配邏輯（`addToWhichGroup()`）
- ❌ 水槽已滿檢查（LED 群組容量檢查）

---

### DROP 設備編輯（DropSettingPage）

#### 文件位置
- **`lib/ui/features/dosing/pages/drop_setting_page.dart`**

#### 已實現功能
1. ✅ **設備名稱編輯**
   - 使用 `TextField` 輸入
   - 保存時檢查：不能為空
   - 使用 `UpdateDeviceNameUseCase` 更新名稱

2. ⚠️ **水槽位置編輯**（未實現）
   - 有按鈕，但只顯示 "Coming soon" 提示
   - **TODO**：`// TODO: Navigate to SinkPositionPage`

3. ✅ **延遲時間選擇**（UI 已實現）
   - 有按鈕可以選擇延遲時間（15秒、30秒、1分鐘、2分鐘、3分鐘、4分鐘、5分鐘）
   - **問題**：保存時沒有實際發送 BLE 指令
   - **TODO**：`// TODO: Set delay time via BLE if connected`

#### 缺失功能
- ❌ 水槽位置更新邏輯（完全未實現）
- ❌ 水槽已滿檢查（DROP 設備數量限制，max 4）
- ❌ 延遲時間 BLE 指令發送

---

### 通用設備設置（DeviceSettingsPage）

#### 文件位置
- **`lib/ui/features/device/pages/device_settings_page.dart`**

#### 已實現功能
1. ✅ **設備名稱編輯**
   - 使用 `TextField` 輸入
   - 保存時檢查：不能為空
   - 使用 `UpdateDeviceNameUseCase` 更新名稱

#### 缺失功能
- ❌ 水槽位置編輯（註釋說明：未來階段添加）

---

## 3. 對照總結

| 功能 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **LED 設備** | | | |
| 編輯設備名稱 | ✅ | ✅ | 已實現 |
| 編輯水槽位置（UI） | ✅ | ⚠️ | 部分實現（未保存） |
| 編輯水槽位置（邏輯） | ✅ | ❌ | 缺失 |
| 主燈移動限制檢查 | ✅ | ❌ | 缺失 |
| 群組自動分配 | ✅ | ❌ | 缺失 |
| 水槽已滿檢查（LED） | ✅ | ❌ | 缺失 |
| **DROP 設備** | | | |
| 編輯設備名稱 | ✅ | ✅ | 已實現 |
| 編輯水槽位置（UI） | ✅ | ❌ | 未實現 |
| 編輯水槽位置（邏輯） | ✅ | ❌ | 缺失 |
| 編輯延遲時間（UI） | ✅ | ✅ | 已實現 |
| 編輯延遲時間（BLE） | ✅ | ❌ | 缺失 |
| 水槽已滿檢查（DROP） | ✅ | ❌ | 缺失 |

---

## 4. 需要實現的功能

### 高優先級

#### 1. LED 設備水槽位置更新
- **位置**：`lib/ui/features/led/pages/led_setting_page.dart`
- **需要實現**：
  - 從 `SinkPositionPage` 返回後，更新設備的 `sinkId`
  - 實現群組自動分配邏輯（`addToWhichGroup()`）
  - 實現水槽已滿檢查（LED 群組容量，max 4 per group）
  - 實現主燈移動限制檢查（`canMoveDevice()`）

#### 2. DROP 設備水槽位置更新
- **位置**：`lib/ui/features/dosing/pages/drop_setting_page.dart`
- **需要實現**：
  - 實現水槽位置選擇 UI（跳轉到 `SinkPositionPage`）
  - 從 `SinkPositionPage` 返回後，更新設備的 `sinkId`
  - 實現水槽已滿檢查（DROP 設備數量，max 4 per sink）

#### 3. DROP 設備延遲時間 BLE 設置
- **位置**：`lib/ui/features/dosing/pages/drop_setting_page.dart`
- **需要實現**：
  - 保存時，如果設備已連接，發送 BLE 指令設置延遲時間
  - 需要實現 `SetDosingDelayTimeUseCase` 或類似功能

### 中優先級

#### 4. 創建設備編輯 UseCase
- **建議**：創建 `UpdateDeviceSinkUseCase` 統一處理設備水槽更新
- **功能**：
  - 檢查水槽容量（LED 群組或 DROP 設備數量）
  - 自動分配群組（LED）
  - 更新設備的 `sinkId`、`group`、`master`

#### 5. 主燈移動限制 UI 提示
- **位置**：`lib/ui/features/led/pages/led_setting_page.dart`
- **需要實現**：
  - 在選擇新水槽前，檢查 `canMoveDevice()`
  - 如果不能移動，顯示錯誤對話框（類似 reef-b-app 的 `createLedMoveMasterDialog()`）

---

## 5. 關鍵代碼對照

### reef-b-app: LED 水槽位置更新邏輯

```kotlin
fun editDevice(sinkIsFull: () -> Unit, nameIsEmpty: () -> Unit) {
    if (edtName.isEmpty()) {
        nameIsEmpty()
        return
    }
    
    if (nowDevice.sinkId == selectSinkId) {
        // 水槽位置沒變，只更新名稱
        dbEditDevice(DeviceEdit(
            id = nowDevice.id,
            name = edtName,
            sinkId = selectSinkId,
            master = nowDevice.master,
            group = nowDevice.group
        ))
    } else {
        if (selectSinkId == 0) {
            // 未分配水槽
            dbEditDevice(DeviceEdit(
                id = nowDevice.id,
                name = edtName,
                sinkId = null,
                group = null,
                master = null
            ))
        } else {
            // 選擇新水槽，查找可用群組
            val group = addToWhichGroup(selectSinkId)
            if (group == null) {
                sinkIsFull() // 所有群組都滿
            } else {
                dbEditDevice(DeviceEdit(
                    id = nowDevice.id,
                    name = edtName,
                    sinkId = selectSinkId,
                    master = false,
                    group = group
                ))
            }
        }
    }
}
```

### reef-b-app: DROP 水槽位置更新邏輯

```kotlin
fun editDevice(sinkIsFull: () -> Unit, nameIsEmpty: () -> Unit) {
    if (edtName.isEmpty()) {
        nameIsEmpty()
        return
    }
    
    if (nowDevice.sinkId == selectSinkId) {
        // 水槽位置沒變，只更新名稱
        dbEditDevice(DeviceEdit(...))
    } else {
        if (selectSinkId == 0) {
            // 未分配水槽
            dbEditDevice(DeviceEdit(
                id = nowDevice.id,
                name = edtName,
                sinkId = null
            ))
        } else {
            // 選擇新水槽，檢查 DROP 設備數量
            val dropInSinkAmount = dbGetDropInSinkBySinkId(selectSinkId).size
            if (dropInSinkAmount >= 4) {
                sinkIsFull() // 水槽已滿（max 4 DROP devices）
            } else {
                dbEditDevice(DeviceEdit(
                    id = nowDevice.id,
                    name = edtName,
                    sinkId = selectSinkId
                ))
            }
        }
    }
}
```

### koralcore: 當前實現（LED）

```dart
// 在 led_setting_page.dart 中
MaterialButton(
  onPressed: () async {
    final String? selectedSinkId = await Navigator.of(context)
        .push<String>(MaterialPageRoute(
          builder: (_) => SinkPositionPage(initialSinkId: currentSinkId),
        ));
    // TODO: Update device sink_id if selectedSinkId is not null
    if (selectedSinkId != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(selectedSinkId.isEmpty
            ? l10n.sinkPositionNotSet
            : l10n.sinkPositionSet)),
      );
    }
  },
)
```

**問題**：只顯示 SnackBar，沒有實際更新設備的 `sinkId`。

---

## 6. 需要創建/修改的文件

### 需要創建
1. **`lib/application/device/update_device_sink_usecase.dart`**
   - 處理設備水槽更新邏輯
   - 檢查容量限制
   - 自動分配群組（LED）

### 需要修改
1. **`lib/ui/features/led/pages/led_setting_page.dart`**
   - 實現水槽位置更新邏輯
   - 添加主燈移動限制檢查
   - 添加錯誤處理

2. **`lib/ui/features/dosing/pages/drop_setting_page.dart`**
   - 實現水槽位置選擇和更新
   - 實現延遲時間 BLE 設置

3. **`lib/platform/contracts/device_repository.dart`**
   - 可能需要添加更新設備水槽的方法（或使用現有的 `addSavedDevice`）

---

## 7. 關鍵業務邏輯

### LED 群組自動分配（addToWhichGroup）

**reef-b-app 邏輯**：
```kotlin
private fun addToWhichGroup(id: Int): LedGroup? {
    val deviceGroupInSink = dbGetDeviceBySinkId(id).map { it.group }
    if (deviceGroupInSink.count { it == LedGroup.A } < 4) {
        return LedGroup.A
    } else if (deviceGroupInSink.count { it == LedGroup.B } < 4) {
        return LedGroup.B
    } else if (deviceGroupInSink.count { it == LedGroup.C } < 4) {
        return LedGroup.C
    } else if (deviceGroupInSink.count { it == LedGroup.D } < 4) {
        return LedGroup.D
    } else if (deviceGroupInSink.count { it == LedGroup.E } < 4) {
        return LedGroup.E
    }
    return null // 所有群組都滿
}
```

**規則**：
- 按順序檢查群組 A、B、C、D、E
- 如果群組內設備數量 < 4，則分配到該群組
- 如果所有群組都滿，返回 null（觸發「水槽已滿」錯誤）

### DROP 設備數量限制

**reef-b-app 邏輯**：
```kotlin
val dropInSinkAmount = dbGetDropInSinkBySinkId(selectSinkId).size
if (dropInSinkAmount >= 4) {
    sinkIsFull() // 水槽已滿（max 4 DROP devices）
}
```

**規則**：
- 每個水槽最多 4 個 DROP 設備
- 如果已達到上限，不能添加新設備

---

## 8. 錯誤消息對照

### reef-b-app 錯誤消息
- `toast_name_is_empty` = "名稱不能為空"
- `toast_sink_is_full` = "水槽已滿"
- `toast_setting_successful` = "設定成功"
- `toast_setting_failed` = "設定失敗"
- `dialog_led_move_master_content` = "欲將此裝置移動到其他水槽請先修改主從設定，將其他副燈設定為主燈"

### koralcore 錯誤消息
- ✅ `deviceNameEmpty` - 已存在
- ⚠️ `sinkFull` - 已存在（`errorSinkFull`），但需要確認是否用於編輯場景
- ✅ `deviceSettingsSaved` - 已存在
- ❌ 缺少「設定失敗」消息
- ❌ 缺少「主燈不能移動」消息

