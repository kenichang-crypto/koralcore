# 設備管理頁面對照表

**比對日期**: 2024-12-28  
**目標**: 100% 對照 reef-b-app 的設備管理頁面

---

## 1. 進入畫面資訊流

### reef-b-app

1. **導航方式**: 從 `MainActivity` 底部導航欄點擊第三個 Tab（`deviceFragment`）
2. **Fragment 初始化**:
   - `DeviceFragment.onCreateView()`: 載入 `fragment_device.xml`
   - `DeviceFragment.onViewCreated()`: 調用 `setView()`, `setListener()`, `setObserver()`
   - `DeviceFragment.onResume()`: 調用 `viewModel.getAllDevice()`
3. **Toolbar 更新**:
   - `MainActivity.onDestinationChanged()`: 當 `destination.id == R.id.deviceFragment` 時
     - 顯示 Toolbar (`toolbarMain.root.visibility = View.VISIBLE`)
     - 隱藏 `btnDelete` (`btnDelete.visibility = View.GONE`)
     - 根據 `deviceIsEmptyLiveData` 顯示/隱藏 `btnChoose`
     - 設置 `toolbarTitle.text = getString(R.string.fragment_device_title)`
     - 顯示 `btnRight` (警告圖標)

### koralcore

1. **導航方式**: 從 `MainScaffold` 底部導航欄點擊第三個 Tab（`DevicePage`）
2. **頁面初始化**:
   - `DevicePage.initState()`: 添加 `WidgetsBindingObserver`
   - `WidgetsBinding.instance.addPostFrameCallback()`: 調用 `BleReadinessController.refresh()` 和 `DeviceListController.refresh()`
3. **AppBar 顯示**:
   - 使用 `ReefAppBar`，根據 `selectionMode` 動態顯示 `leading` 和 `actions`

### 差異

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| Toolbar 位置 | MainActivity 中共享 | DevicePage 中獨立 | ⚠️ 需修正 |
| 初始化時機 | `onResume()` | `addPostFrameCallback()` | ✅ 對照 |
| 刷新邏輯 | `viewModel.getAllDevice()` | `DeviceListController.refresh()` | ✅ 對照 |

---

## 2. 畫面內容對照

### 2.1 背景

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 背景資源 | `@drawable/background_main` | `ReefMainBackground` | ✅ 對照 |

### 2.2 Toolbar/AppBar

#### reef-b-app Toolbar (`toolbar_app.xml`)

- **位置**: `MainActivity` 中共享
- **高度**: `?attr/actionBarSize`
- **背景**: `@color/white`
- **組件**:
  - `btn_choose` (MaterialButton): 選擇模式按鈕
    - 位置: `layout_gravity="start|center_vertical"`
    - 尺寸: `minWidth="@dimen/dp_57"`, `minHeight="@dimen/dp_28"`
    - 邊距: `layout_marginEnd="@dimen/dp_8"`
    - 可見性: 根據 `deviceIsEmptyLiveData` 動態顯示/隱藏
    - 文字: `@string/fragment_device_select` (選取)
  - `btn_delete` (ImageView): 刪除按鈕
    - 位置: `layout_gravity="start"`
    - 尺寸: `@dimen/dp_24 x @dimen/dp_24`
    - 圖標: `@drawable/ic_delete`
    - 可見性: 根據 `deleteModeLiveData` 動態顯示/隱藏
  - `toolbar_title` (TextView): 標題
    - 位置: `layout_gravity="center"`
    - 文字: `@string/fragment_device_title` (Device)
    - 樣式: `@style/body`, `@color/text_aaaa`
  - `btn_right` (ImageView): 警告按鈕
    - 位置: `layout_gravity="end"`
    - 尺寸: `@dimen/dp_56 x @dimen/dp_44`
    - 圖標: `@drawable/ic_warning`
    - 邊距: `paddingStart/End="@dimen/dp_16"`, `paddingTop/Bottom="@dimen/dp_10"`

#### koralcore AppBar (`ReefAppBar`)

- **位置**: `DevicePage` 中獨立
- **背景**: `ReefColors.primary`
- **前景**: `ReefColors.onPrimary`
- **組件**:
  - `leading`: 選擇模式時顯示 `CommonIconHelper.getCloseIcon()`
  - `title`: 根據 `selectionMode` 顯示 `deviceSelectionCount` 或 `deviceHeader`
  - `actions`: 選擇模式時顯示刪除按鈕 (`TextButton`)

### 差異

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| Toolbar 位置 | MainActivity 共享 | DevicePage 獨立 | ⚠️ 需修正 |
| 選擇按鈕 | `btn_choose` (MaterialButton) | 無（使用 AppBar leading） | ⚠️ 需修正 |
| 刪除按鈕 | `btn_delete` (ImageView) | `TextButton` (在 actions 中) | ⚠️ 需修正 |
| 標題位置 | 居中 | 左對齊（`padding: EdgeInsets.only(left: ReefSpacing.lg)`） | ⚠️ 需修正 |
| 警告按鈕 | `btn_right` (ImageView) | 無 | ⚠️ 需修正 |

---

## 3. 設備列表對照

### 3.1 列表布局

#### reef-b-app

- **組件**: `RecyclerView` (`rv_user_device`)
- **LayoutManager**: `GridLayoutManager(context, 2)` (2列)
- **邊距**: 
  - `marginStart="@dimen/dp_10"`
  - `marginTop="@dimen/dp_8"`
  - `marginEnd="@dimen/dp_10"`
  - `marginBottom="@dimen/dp_8"`
- **可見性**: 根據設備列表是否為空動態顯示/隱藏
- **Adapter**: `DeviceAdapter`
  - 使用 `AsyncListDiffer` 進行差異更新
  - 支持刪除模式 (`deleteMode`)
  - 排序邏輯: `sortedByDescending { it.master }.sortedBy { it.group }.sortedByDescending { it.sinkId }.sortedByDescending { it.favorite }`
    - 優先級: 喜愛裝置 > 群組 > 主燈

#### koralcore

- **組件**: `SliverGrid`
- **GridDelegate**: `SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2)`
- **邊距**: 
  - `padding: EdgeInsets.symmetric(horizontal: ReefSpacing.xl)` (24dp)
  - `mainAxisSpacing: ReefSpacing.lg` (16dp)
  - `crossAxisSpacing: ReefSpacing.lg` (16dp)
- **childAspectRatio**: 0.95
- **排序**: 未明確排序邏輯

### 差異

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 水平邊距 | 10dp | 24dp | ⚠️ 需修正 |
| 垂直邊距 | 8dp (top/bottom) | 16dp (spacing) | ⚠️ 需修正 |
| 排序邏輯 | 喜愛 > 群組 > 主燈 | 無 | ⚠️ 需修正 |

---

## 4. 設備卡片對照

### 4.1 LED 設備卡片 (`adapter_device_led.xml`)

#### reef-b-app

- **根容器**: `MaterialCardView`
  - `cardCornerRadius="@dimen/dp_10"`
  - `cardElevation="@dimen/dp_5"`
  - `layout_margin="@dimen/dp_6"`
- **內部布局**: `ConstraintLayout`
  - `paddingStart/End="@dimen/dp_12"`
  - `paddingTop/Bottom="@dimen/dp_10"`
- **組件**:
  1. `img_led`: LED 圖標
     - 尺寸: `width="@dimen/dp_0"` (wrap_content), `height="@dimen/dp_50"`
     - 位置: `constraintStart_toStartOf="parent"`, `constraintTop_toTopOf="parent"`
  2. `img_ble_state`: BLE 狀態圖標
     - 尺寸: `@dimen/dp_14 x @dimen/dp_14`
     - 位置: `constraintEnd_toEndOf="parent"`, `constraintTop_toTopOf="parent"`, `marginTop="@dimen/dp_12"`
     - 圖標: `ic_connect` (已連接) 或 `ic_disconnect` (未連接)
  3. `img_favorite`: 喜愛圖標
     - 尺寸: `@dimen/dp_14 x @dimen/dp_14`
     - 位置: `constraintEnd_toStartOf="@id/img_ble_state"`, `constraintTop_toTopOf="@id/img_ble_state"`
     - 圖標: `ic_favorite_select` (已喜愛) 或 `ic_favorite_unselect` (未喜愛)
  4. `img_led_master`: 主燈圖標
     - 尺寸: `@dimen/dp_12 x @dimen/dp_12`
     - 位置: `constraintEnd_toStartOf="@id/img_favorite"`, `marginStart="@dimen/dp_32"`, `marginEnd="@dimen/dp_4"`
     - 圖標: `ic_master`
     - 可見性: `View.GONE` (已註釋掉，不顯示)
  5. `tv_name`: 設備名稱
     - 樣式: `@style/caption1_accent`
     - 顏色: `@color/text_aa` (未連接) 或 `@color/text_aaaa` (已連接)
     - 位置: `constraintStart_toStartOf="parent"`, `constraintTop_toBottomOf="@id/img_led"`, `constraintEnd_toStartOf="@id/img_check"`
  6. `tv_position`: 位置（Sink 名稱）
     - 樣式: `@style/caption2`
     - 顏色: `@color/text_aa`
     - 位置: `constraintStart_toStartOf="parent"`, `constraintTop_toBottomOf="@id/tv_name"`, `constraintBottom_toBottomOf="parent"`
  7. `tv_group`: 群組標籤
     - 樣式: `@style/caption2`
     - 顏色: `@color/text_aa`
     - 文字: `"｜${group} A/B/C/D/E"` 或空字串
     - 可見性: `View.GONE` (默認隱藏)
  8. `img_check`: 選擇標記
     - 尺寸: `@dimen/dp_20 x @dimen/dp_20`
     - 位置: `constraintEnd_toEndOf="parent"`, `constraintTop_toTopOf="@id/tv_name"`, `constraintBottom_toBottomOf="parent"`
     - 圖標: `ic_check`
     - 可見性: 刪除模式且已選擇時顯示

#### koralcore (`DeviceCard`)

- **根容器**: `AnimatedContainer` + `ReefDeviceCard`
  - `borderRadius: BorderRadius.circular(10.0)`
  - `padding: EdgeInsets.all(ReefSpacing.lg)` (16dp)
- **組件**:
  1. `_DeviceIcon`: 設備圖標
     - 尺寸: `56 x 56`
     - 背景: `ReefColors.primary.withValues(alpha: 0.15)`
     - 圖標: `kDeviceLedIcon` 或 `kDeviceDoserIcon` (32x32)
  2. 設備名稱: `Text`
     - 樣式: `ReefTextStyles.subheaderAccent`
     - 顏色: `ReefColors.textPrimary`
  3. `_ChipLabel`: 設備類型標籤 (LED/Dosing)
     - 背景: `foreground.withValues(alpha: 0.12)`
  4. BLE 狀態圖標: `CommonIconHelper.getBluetoothIcon()`
     - 尺寸: 18x18
     - 顏色: 根據連接狀態動態變化
  5. 狀態文字: `Text` (Connected/Connecting/Disconnected)
  6. RSSI 顯示: `Text` (可選)
  7. 連接/斷開按鈕: `FilledButton` 或 `OutlinedButton`
  8. 選擇標記: `IconButton` (選擇模式時顯示)

### 差異

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 卡片邊距 | 6dp | 無（使用 Grid spacing） | ⚠️ 需修正 |
| 卡片內邊距 | 12dp (左右), 10dp (上下) | 16dp (全部) | ⚠️ 需修正 |
| LED 圖標尺寸 | 50dp 高度 | 56x56 | ⚠️ 需修正 |
| BLE 狀態圖標尺寸 | 14x14 | 18x18 | ⚠️ 需修正 |
| 喜愛圖標 | 14x14，右上角 | 無 | ⚠️ 需修正 |
| 主燈圖標 | 12x12（已隱藏） | 無 | ✅ 對照 |
| 群組標籤 | 顯示群組 A/B/C/D/E | 無 | ⚠️ 需修正 |
| 位置顯示 | Sink 名稱 | 無 | ⚠️ 需修正 |
| 連接按鈕 | 無（點擊卡片進入設備頁面） | 有（Connect/Disconnect 按鈕） | ⚠️ 需修正 |
| 選擇標記位置 | 右下角 | 右上角 | ⚠️ 需修正 |
| 選擇標記尺寸 | 20x20 | 24x24 | ⚠️ 需修正 |

---

## 5. 空狀態對照

### reef-b-app

- **容器**: `LinearLayout` (`layout_no_device`)
  - 位置: 居中 (`constraintBottom/Top/Start/End_to...="parent"`)
- **組件**:
  1. `ImageView`: 機器人圖標
     - 尺寸: `@dimen/dp_172 x @dimen/dp_199`
     - 圖標: `@drawable/img_device_robot`
     - 位置: `layout_gravity="center"`
  2. `TextView`: 標題
     - 文字: `@string/text_no_device_title` ("目前尚無裝置")
     - 樣式: `@style/subheader_accent`
     - 位置: `layout_gravity="center"`, `marginTop="@dimen/dp_39"`
  3. `MaterialButton`: 新增設備按鈕
     - ID: `btn_add_device`
     - 樣式: `@style/RoundedButton`
     - 文字: `@string/add_device` ("新增裝置")
     - 位置: `layout_gravity="center"`, `marginTop="@dimen/dp_8"`, `marginBottom="@dimen/dp_8"`
     - 點擊: 導航到 `bluetoothFragment`

### koralcore

- **組件**: `EmptyStateWidget`
  - `title`: `l10n.deviceEmptyTitle`
  - `subtitle`: `l10n.deviceEmptySubtitle`
  - `imageAsset`: `kDeviceEmptyIcon`
  - `iconSize`: 48
  - `useCard`: true
  - `action`: `FilledButton` (掃描按鈕)

### 差異

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 圖標尺寸 | 172x199 | 48x48 | ⚠️ 需修正 |
| 圖標資源 | `img_device_robot` | `kDeviceEmptyIcon` | ⚠️ 需修正 |
| 標題文字 | "目前尚無裝置" | `deviceEmptyTitle` | ⚠️ 需檢查字串 |
| 按鈕文字 | "新增裝置" | "掃描" | ⚠️ 需修正 |
| 按鈕行為 | 導航到 Bluetooth 頁面 | 刷新掃描 | ⚠️ 需修正 |
| 標題間距 | 39dp (marginTop) | 無明確間距 | ⚠️ 需修正 |

---

## 6. 選擇模式對照

### reef-b-app

1. **進入選擇模式**:
   - 點擊 `btn_choose` → `isDeleteMode(true)`
   - `deviceAdapter.triggerDeleteMode(true)`
   - `mainViewModel.deleteModeLiveData.value = true`
   - `MainActivity` 顯示 `btn_delete`
2. **選擇設備**:
   - 點擊設備卡片 → `addDeleteItem(data)`
   - 顯示 `img_check` (選擇標記)
3. **刪除設備**:
   - 點擊 `btn_delete` → 檢查刪除列表
   - 如果是 LED 主燈且不能刪除 → `createDeleteLedMasterDialog()`
   - 否則 → `createDeleteLedDialog()`
4. **退出選擇模式**:
   - 再次點擊 `btn_choose` → `isDeleteMode(false)`
   - 或刪除完成後自動退出

### koralcore

1. **進入選擇模式**:
   - 點擊 "選取" 按鈕 → `controller.enterSelectionMode`
   - AppBar 顯示 `leading` (關閉圖標) 和 `actions` (刪除按鈕)
   - 標題顯示 `deviceSelectionCount`
2. **選擇設備**:
   - 點擊設備卡片 → `controller.toggleSelection(device.id)`
   - 顯示選擇邊框和選擇標記
3. **刪除設備**:
   - 點擊刪除按鈕 → `_confirmDelete()`
   - 顯示確認對話框
4. **退出選擇模式**:
   - 點擊關閉圖標 → `controller.exitSelectionMode`

### 差異

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 選擇按鈕位置 | Toolbar 左側 | AppBar leading | ⚠️ 需修正 |
| 刪除按鈕位置 | Toolbar 左側 | AppBar actions | ⚠️ 需修正 |
| 主燈刪除檢查 | 有 | 無 | ⚠️ 需修正 |
| 刪除對話框 | 兩個（主燈/一般） | 一個 | ⚠️ 需修正 |

---

## 7. 點擊行為對照

### reef-b-app

- **正常模式**: 點擊設備卡片 → `listener.onClickDevice(data)` → 根據設備類型導航到 `LedMainActivity` 或 `DropMainActivity`
- **選擇模式**: 點擊設備卡片 → `addDeleteItem(data)` → 切換選擇狀態

### koralcore

- **正常模式**: 點擊設備卡片 → 無行為（或顯示設備詳情）
- **選擇模式**: 點擊設備卡片 → `controller.toggleSelection(device.id)`

### 差異

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 正常模式點擊 | 導航到設備主頁 | 無行為 | ⚠️ 需修正 |

---

## 8. 資訊流對照

### reef-b-app

1. **頁面初始化**:
   ```
   DeviceFragment.onResume()
   → viewModel.getAllDevice()
   → dbGetAllDevice()
   → deviceListLiveData.postValue()
   → DeviceFragment.setObserver()
   → deviceAdapter.submitList(device.sortedBy...)
   → RecyclerView 更新
   ```

2. **設備列表更新**:
   ```
   viewModel.deviceListLiveData.observe()
   → viewDeviceIsEmpty(device.isEmpty())
   → deviceAdapter.submitList(device.sortedBy...)
   ```

3. **選擇模式切換**:
   ```
   btn_choose 點擊
   → isDeleteMode(true/false)
   → deviceAdapter.triggerDeleteMode(true/false)
   → mainViewModel.deleteModeLiveData.value = true/false
   → MainActivity 顯示/隱藏 btn_delete
   ```

4. **刪除設備**:
   ```
   btn_delete 點擊
   → deviceAdapter.getDeleteList()
   → viewModel.canDeleteDevice() 檢查
   → createDeleteLedMasterDialog() 或 createDeleteLedDialog()
   → viewModel.deleteDevice(list)
   → dbDeleteDeviceById()
   → bleManager.disConnect() (如果當前連接)
   → deleteDeviceLiveData.postValue(true)
   → viewModel.getAllDevice()
   ```

### koralcore

1. **頁面初始化**:
   ```
   DevicePage.initState()
   → addPostFrameCallback()
   → BleReadinessController.refresh()
   → DeviceListController.refresh()
   → DeviceListController._loadDevices()
   → deviceRepository.listSavedDevices()
   → deviceRepository.scanDevices()
   ```

2. **設備列表更新**:
   ```
   DeviceListController.savedDevices (Stream)
   → SliverGrid 自動更新
   ```

3. **選擇模式切換**:
   ```
   "選取" 按鈕點擊
   → controller.enterSelectionMode()
   → selectionMode = true
   → AppBar 更新
   ```

4. **刪除設備**:
   ```
   刪除按鈕點擊
   → _confirmDelete()
   → showDialog()
   → controller.removeSelected()
   → deviceRepository.removeDevice()
   → DeviceListController.refresh()
   ```

### 差異

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 數據來源 | 數據庫 (`dbGetAllDevice()`) | Repository (`listSavedDevices()`) | ✅ 對照 |
| 排序邏輯 | 喜愛 > 群組 > 主燈 | 無 | ⚠️ 需修正 |
| 刪除後刷新 | `getAllDevice()` | `refresh()` | ✅ 對照 |
| 主燈檢查 | `canDeleteDevice()` | 無 | ⚠️ 需修正 |

---

## 9. 需要修正的問題

### 高優先級

1. **Toolbar 位置**: 應改為在 `MainScaffold` 中共享，而不是在 `DevicePage` 中獨立
2. **選擇按鈕**: 應添加 `btn_choose` 按鈕到 Toolbar 左側
3. **刪除按鈕**: 應改為 `ImageView` (`ic_delete`)，位置在 Toolbar 左側
4. **警告按鈕**: 應添加 `btn_right` 到 Toolbar 右側
5. **設備卡片布局**: 應對照 `adapter_device_led.xml` 和 `adapter_device_drop.xml`
6. **空狀態**: 應使用 `img_device_robot` (172x199)，按鈕應導航到 Bluetooth 頁面
7. **排序邏輯**: 應實現喜愛 > 群組 > 主燈的排序
8. **點擊行為**: 正常模式應導航到設備主頁
9. **主燈刪除檢查**: 應實現 `canDeleteDevice()` 邏輯

### 中優先級

1. **列表邊距**: 應改為 10dp (水平), 8dp (垂直)
2. **卡片邊距**: 應改為 6dp
3. **卡片內邊距**: 應改為 12dp (左右), 10dp (上下)
4. **圖標尺寸**: LED 圖標 50dp 高度，BLE 狀態 14x14
5. **喜愛圖標**: 應添加右上角喜愛圖標 (14x14)
6. **群組標籤**: 應顯示群組 A/B/C/D/E
7. **位置顯示**: 應顯示 Sink 名稱
8. **選擇標記**: 應改為右下角，尺寸 20x20

### 低優先級

1. **標題位置**: 應居中對齊
2. **標題間距**: 空狀態標題應有 39dp 上邊距

---

## 10. 總結

### 當前對照狀態

- **進入畫面資訊流**: 80% (Toolbar 位置不同)
- **畫面內容**: 60% (多處差異)
- **組件**: 50% (卡片布局差異大)
- **圖標**: 70% (部分圖標缺失)
- **Layout**: 60% (邊距、尺寸差異)
- **位置**: 50% (多處位置不對)
- **資訊流**: 70% (排序邏輯缺失)

### 總體評分: 60%

需要大量修正以達到 100% 對照。

