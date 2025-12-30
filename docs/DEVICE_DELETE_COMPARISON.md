# 設備刪除功能對照表

**比對日期**: 2024-12-28  
**目標**: 100% 對照 reef-b-app 的設備刪除功能

---

## 1. 刪除流程資訊流

### reef-b-app

#### 1.1 進入選擇模式
1. **觸發**: 點擊 Toolbar 的 `btn_choose` 按鈕
2. **邏輯**: `DeviceFragment.setListener()` → `btnChoose.setOnClickListener`
3. **狀態更新**:
   - `deviceAdapter.triggerDeleteMode(true)` - 啟用刪除模式
   - `mainViewModel.deleteModeLiveData.value = true` - 更新 MainActivity Toolbar
   - `deviceAdapter.deleteList.clear()` - 清空選擇列表

#### 1.2 選擇設備
1. **觸發**: 點擊設備卡片（在刪除模式下）
2. **邏輯**: `DeviceAdapter.bind()` → `binding.root.setOnClickListener`
   - 如果 `deleteMode == true`: 調用 `addDeleteItem(data)`
   - 如果 `deleteMode == false`: 調用 `listener.onClickDevice(data)`
3. **狀態更新**:
   - `deleteList.add(device)` 或 `deleteList.remove(device)`
   - `notifyDataSetChanged()` - 更新 UI（顯示/隱藏 `img_check`）

#### 1.3 點擊刪除按鈕
1. **觸發**: 點擊 Toolbar 的 `btn_delete` ImageView
2. **邏輯**: `DeviceFragment.setListener()` → `btnDelete.setOnClickListener`
3. **檢查流程**:
   ```kotlin
   val tmpList = deviceAdapter.getDeleteList()
   if (tmpList.isEmpty()) {
       return@setOnClickListener
   }
   tmpList.forEach {
       if (it.type == DeviceType.LED && !viewModel.canDeleteDevice(it)) {
           createDeleteLedMasterDialog()  // 顯示主燈刪除限制對話框
           return@setOnClickListener
       }
   }
   createDeleteLedDialog()  // 顯示刪除確認對話框
   ```

#### 1.4 主燈刪除限制對話框
1. **對話框**: `createDeleteLedMasterDialog()`
2. **標題**: `dialog_device_delete_led_master_title` = "主從設定"
3. **內容**: `dialog_device_delete_led_master_content` = "欲刪除主燈，請先修改主從設定，將其他副燈設定為主燈"
4. **按鈕**: `dialog_device_delete_led_master_positive` = "我知道了"
5. **行為**: 點擊後關閉刪除模式（`isDeleteMode(false)`）

#### 1.5 刪除確認對話框
1. **對話框**: `createDeleteLedDialog()`
2. **標題**: 無（只有內容）
3. **內容**: `dialog_device_delete` = "是否刪除所選設備?"
4. **按鈕**:
   - 確認: `dialog_device_delete_led_positive` = "刪除"
   - 取消: `dialog_device_delete_led_negative` = "取消"
5. **行為**: 
   - 確認: 調用 `viewModel.deleteDevice(deviceAdapter.getDeleteList())`
   - 取消: 關閉對話框

#### 1.6 執行刪除
1. **方法**: `DeviceViewModel.deleteDevice(list: List<Device>)`
2. **流程**:
   ```kotlin
   list.forEach {
       dbDeleteDeviceById(it.id)
       if (it.macAddress == bleManager.getConnectDeviceMacAddress()) {
           bleManager.disConnect()  // 如果設備已連接，先斷開
       }
   }
   _deleteDeviceLiveData.value = true
   ```
3. **觀察者**: `DeviceFragment.setObserver()` → `deleteDeviceLiveData.observe()`
   - `true`: 顯示成功 Toast (`toast_delete_device_successful`)，刷新列表 (`getAllDevice()`)
   - `false`: 顯示失敗 Toast (`toast_delete_device_failed`)
   - 關閉刪除模式: `isDeleteMode(false)`

### koralcore

#### 1.1 進入選擇模式
1. **觸發**: 點擊 AppBar 的 `leading` TextButton（`deviceSelectMode`）
2. **邏輯**: `DevicePage.build()` → `controller.enterSelectionMode`
3. **狀態更新**:
   - `_selectionMode = true`
   - `notifyListeners()` - 更新 UI

#### 1.2 選擇設備
1. **觸發**: 點擊設備卡片（在選擇模式下）
2. **邏輯**: `DeviceCard.build()` → `InkWell.onTap` → `onSelect?.call()`
3. **狀態更新**:
   - `controller.toggleSelection(device.id)`
   - `_selection.add(deviceId)` 或 `_selection.remove(deviceId)`
   - `notifyListeners()` - 更新 UI（顯示/隱藏 `img_check`）

#### 1.3 點擊刪除按鈕
1. **觸發**: 點擊 AppBar 的 `actions` IconButton（`ic_delete`）
2. **邏輯**: `DevicePage.build()` → `_confirmDelete(context, controller)`
3. **檢查流程**:
   ```dart
   if (controller.selectedIds.isEmpty) {
       return;  // 按鈕已禁用，不會觸發
   }
   // 在 _confirmDelete 中檢查主燈限制
   await controller.removeSelected();
   ```

#### 1.4 主燈刪除限制檢查
1. **位置**: `DeviceListController.removeSelected()`
2. **邏輯**:
   ```dart
   for (final id in targets) {
       final bool canDelete = await canDeleteDevice(id);
       if (!canDelete) {
           _setError(AppErrorCode.ledMasterCannotDelete);
           return;
       }
   }
   ```
3. **錯誤處理**: 顯示 `SnackBar`（通過 `_maybeShowError`）

#### 1.5 刪除確認對話框
1. **對話框**: `DevicePage._confirmDelete()`
2. **標題**: `deviceDeleteConfirmTitle` = "Remove devices?"
3. **內容**: `deviceDeleteConfirmMessage` = "The selected devices will be removed from this phone. This does not reset the hardware."
4. **按鈕**:
   - 確認: `deviceDeleteConfirmPrimary` = "Remove"
   - 取消: `deviceDeleteConfirmSecondary` = "Keep"
5. **行為**: 
   - 確認: 調用 `controller.removeSelected()`
   - 取消: 關閉對話框

#### 1.6 執行刪除
1. **方法**: `DeviceListController.removeSelected()`
2. **流程**:
   ```dart
   for (final id in targets) {
       await _removeDeviceUseCase.execute(deviceId: id);
   }
   exitSelectionMode();
   ```
3. **UseCase**: `RemoveDeviceUseCase.execute()`
   - 檢查設備是否連接，如果連接則先斷開
   - 從數據庫刪除設備
   - 清除當前會話（如果刪除的是當前設備）
4. **成功處理**: 顯示 `SnackBar` (`snackbarDeviceRemoved`)
5. **錯誤處理**: 顯示 `SnackBar`（通過 `_maybeShowError`）

---

## 2. UI 組件對照

### 2.1 選擇模式按鈕

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 位置 | Toolbar `btn_choose` (MaterialButton) | AppBar `leading` (TextButton) | ⚠️ 需修正 |
| 文字 | `fragment_device_select` = "選取" | `deviceSelectMode` = "Select" | ✅ |
| 顯示條件 | `deviceIsEmptyLiveData.value == false` | `controller.savedDevices.isEmpty == false` | ✅ |
| 點擊行為 | 切換 `isDeleteMode(true/false)` | `controller.enterSelectionMode()` | ✅ |

### 2.2 刪除按鈕

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 位置 | Toolbar `btn_delete` (ImageView 24x24dp) | AppBar `actions` (IconButton) | ✅ |
| 圖標 | `ic_delete` | `CommonIconHelper.getDeleteIcon()` | ✅ |
| 顯示條件 | `deleteModeLiveData.value == true` | `selectionMode == true` | ✅ |
| 禁用條件 | `deleteList.isEmpty()` | `selectedIds.isEmpty` | ✅ |
| 點擊行為 | 檢查主燈限制 → 顯示對話框 | `_confirmDelete()` | ✅ |

### 2.3 選擇標記

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 位置 | 設備卡片 `img_check` (20x20dp) | 設備卡片 `Positioned` (20x20dp) | ✅ |
| 圖標 | `ic_check` | `CommonIconHelper.getCheckIcon()` | ✅ |
| 顯示條件 | `deleteMode && deleteList.contains(data)` | `selectionMode && isSelected` | ✅ |
| 顏色 | 預設（未指定） | `ReefColors.info` | ⚠️ 需確認 |

### 2.4 標題文字

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 正常模式 | `fragment_device_title` = "設備" | `deviceHeader` = "My devices" | ⚠️ 需修正 |
| 選擇模式 | 無（保持 "設備"） | `deviceSelectionCount(count)` = "{count} selected" | ⚠️ 需修正 |

---

## 3. 對話框對照

### 3.1 主燈刪除限制對話框

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 標題 | `dialog_device_delete_led_master_title` = "主從設定" | ❌ 無（使用 SnackBar） | ❌ 需修正 |
| 內容 | `dialog_device_delete_led_master_content` = "欲刪除主燈，請先修改主從設定，將其他副燈設定為主燈" | ❌ 無（使用 SnackBar） | ❌ 需修正 |
| 按鈕 | `dialog_device_delete_led_master_positive` = "我知道了" | ❌ 無 | ❌ 需修正 |
| 行為 | 關閉刪除模式 | ❌ 無（只顯示錯誤） | ❌ 需修正 |

### 3.2 刪除確認對話框

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 標題 | ❌ 無 | `deviceDeleteConfirmTitle` = "Remove devices?" | ⚠️ 需修正 |
| 內容 | `dialog_device_delete` = "是否刪除所選設備?" | `deviceDeleteConfirmMessage` = "The selected devices will be removed from this phone. This does not reset the hardware." | ⚠️ 需修正 |
| 確認按鈕 | `dialog_device_delete_led_positive` = "刪除" | `deviceDeleteConfirmPrimary` = "Remove" | ⚠️ 需修正 |
| 取消按鈕 | `dialog_device_delete_led_negative` = "取消" | `deviceDeleteConfirmSecondary` = "Keep" | ⚠️ 需修正 |

---

## 4. 成功/失敗提示對照

### 4.1 成功提示

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 類型 | Toast | SnackBar | ⚠️ 需確認 |
| 文字 | `toast_delete_device_successful` = "刪除設備成功" | `snackbarDeviceRemoved` = "Device removed" | ⚠️ 需修正 |

### 4.2 失敗提示

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 類型 | Toast | SnackBar | ⚠️ 需確認 |
| 文字 | `toast_delete_device_failed` = "刪除設備失敗" | `describeAppError(l10n, errorCode)` | ⚠️ 需修正 |

---

## 5. 差異總結

### 高優先級（必須修正）

1. **主燈刪除限制對話框**
   - ❌ koralcore 使用 SnackBar，應改為對話框
   - ❌ 缺少對話框標題、內容、按鈕文字
   - ❌ 缺少關閉刪除模式的行為

2. **刪除確認對話框**
   - ⚠️ koralcore 有標題，reef-b-app 無標題
   - ⚠️ 對話框內容文字不一致
   - ⚠️ 按鈕文字不一致

3. **成功/失敗提示**
   - ⚠️ 文字不一致（需要對照 reef-b-app 的 strings.xml）

4. **標題文字**
   - ⚠️ 正常模式標題不一致
   - ⚠️ 選擇模式標題不一致

### 中優先級（建議修正）

1. **選擇模式按鈕位置**
   - ⚠️ reef-b-app 在 Toolbar `btn_choose`，koralcore 在 AppBar `leading`
   - 需要確認是否要改為在 MainScaffold 中共享 Toolbar

2. **選擇標記顏色**
   - ⚠️ 需要確認 reef-b-app 的顏色

---

## 6. 需要修正的項目

### 6.1 添加缺失的本地化字串

需要添加以下字串到所有語言的 ARB 文件：
- `dialog_device_delete_led_master_title`
- `dialog_device_delete_led_master_content`
- `dialog_device_delete_led_master_positive`
- `dialog_device_delete` (修正現有的 `deviceDeleteConfirmMessage`)
- `dialog_device_delete_led_positive` (修正現有的 `deviceDeleteConfirmPrimary`)
- `dialog_device_delete_led_negative` (修正現有的 `deviceDeleteConfirmSecondary`)
- `toast_delete_device_successful` (修正現有的 `snackbarDeviceRemoved`)
- `toast_delete_device_failed`
- `fragment_device_title` (修正現有的 `deviceHeader`)

### 6.2 修正對話框實現

1. **主燈刪除限制對話框**
   - 改為使用 `showDialog` 而不是 `SnackBar`
   - 添加對話框標題、內容、按鈕
   - 添加關閉刪除模式的行為

2. **刪除確認對話框**
   - 移除標題（對照 reef-b-app）
   - 修正對話框內容文字
   - 修正按鈕文字

### 6.3 修正成功/失敗提示

1. **成功提示**
   - 修正文字為 `toast_delete_device_successful`

2. **失敗提示**
   - 添加 `toast_delete_device_failed` 字串
   - 在刪除失敗時顯示此提示

### 6.4 修正標題文字

1. **正常模式標題**
   - 修正為 `fragment_device_title`

2. **選擇模式標題**
   - 需要確認 reef-b-app 是否在選擇模式時改變標題

---

## 7. 實現狀態

- **功能實現**: 80%
- **UI 對照**: 70%
- **對話框對照**: 50%
- **文字對照**: 60%
- **資訊流對照**: 90%

**總體評分**: 70%

---

## 8. 下一步行動

1. 添加缺失的本地化字串
2. 修正主燈刪除限制對話框
3. 修正刪除確認對話框
4. 修正成功/失敗提示
5. 修正標題文字

