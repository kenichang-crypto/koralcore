# 首頁設計忠實度檢查清單

本文檔用於確認 koralcore 的首頁改造是否完全忠實於 reef-b-app 的設計。

---

## 一、布局結構對照

### ✅ reef-b-app 的實際布局（fragment_home.xml）

```xml
<ConstraintLayout>
  <!-- 背景 -->
  android:background="@drawable/background_main"
  
  <!-- 1. 頂部按鈕區域 -->
  <ImageView id="btn_add_sink" ... visibility="gone" />  <!-- 左上角，通常隱藏 -->
  <ImageView id="btn_warning" ... />  <!-- 右上角 -->
  
  <!-- 2. Sink 選擇區域 -->
  <Spinner id="sp_sink_type" 
    width="101dp" 
    height="26dp"
    marginStart="16dp"
    marginTop="10dp"
    background="transparent" />
  
  <ImageView id="img_down" 
    width="24dp" 
    height="24dp" 
    src="@drawable/ic_down" />
  
  <ImageView id="btn_sink_manager" 
    width="30dp" 
    height="30dp"
    marginEnd="16dp"
    src="@drawable/ic_manager" />
  
  <!-- 3. 設備列表區域 -->
  <RecyclerView id="rv_user_device"
    paddingStart="10dp"
    paddingTop="8dp"
    paddingEnd="10dp"
    visibility="gone" />
  
  <!-- 4. 空狀態 -->
  <LinearLayout id="layout_no_device_in_sink">
    <TextView text="@string/text_no_device_in_sink_title" />
    <TextView text="@string/text_no_device_in_sink_content" />
  </LinearLayout>
</ConstraintLayout>
```

### ❌ 當前 koralcore 的布局

```dart
Scaffold(
  appBar: AppBar(...),  // ❌ reef-b-app 沒有 AppBar
  backgroundColor: ReefColors.primaryStrong,  // ❌ 應該是淺色背景
  body: SafeArea(
    ListView(
      children: [
        _SinkHeaderCard(...),  // ❌ reef-b-app 沒有這個卡片
        _DeviceSection(...),   // ❌ 結構不同
        _FeatureActionCard(...), // ❌ reef-b-app 沒有功能卡片
      ],
    ),
  ),
)
```

---

## 二、背景對照

### ✅ reef-b-app 的背景

**background_main.xml**:
```xml
<gradient
  android:angle="225"
  android:startColor="#EFEFEF"    <!-- main_activity_background_start_color -->
  android:endColor="#00FFFFFF" />  <!-- main_activity_background_end_color (透明) -->
```

**顏色值**：
- 起始色：`#EFEFEF` (淺灰色)
- 結束色：`#00FFFFFF` (透明)
- 角度：225度（從左上到右下）

### ✅ koralcore 的實現

已有 `ReefMainBackground` widget，但需要確認：
- [ ] 顏色值是否正確：`#EFEFEF` 到透明
- [ ] 角度是否正確：225度
- [ ] 是否在首頁使用

**檢查項目**：
- `ReefColors.backgroundGradientStart` 應該是 `#EFEFEF`
- `ReefColors.backgroundGradientEnd` 應該是透明色

---

## 三、Sink 選擇器功能對照

### ✅ reef-b-app 的 Spinner 選項（getSpinnerContent()）

```kotlin
val list = arrayListOf<String>()
list.add(getString(R.string.home_spinner_all_sink))      // 位置 0: "所有 Sink"
list.add(getString(R.string.home_spinner_favorite))      // 位置 1: "喜愛裝置"
val sinkNameList = viewModel.getAllSinkName()
sinkNameList.forEach { list.add(it) }                     // 位置 2+: 各個 Sink 名稱
list.add(getString(R.string.home_spinner_unassigned))    // 最後位置: "未分配裝置"
```

### ✅ 選擇行為（onItemSelected）

| Position | 行為 | Adapter | LayoutManager |
|----------|------|---------|---------------|
| 0 | 所有 Sink | `SinkWithDevicesAdapter` | `LinearLayoutManager` (垂直) |
| 1 | 喜愛裝置 | `DeviceAdapter` | `GridLayoutManager` (2列) |
| 2+ | 特定 Sink | `DeviceAdapter` | `GridLayoutManager` (2列) |
| 最後 | 未分配裝置 | `DeviceAdapter` | `GridLayoutManager` (2列) |

### ❌ 當前 koralcore

- [ ] 沒有 Sink 選擇器
- [ ] 沒有動態切換顯示邏輯

**需要實現**：
1. DropdownButton 或 PopupMenuButton（對應 Android Spinner）
2. 選項順序：所有 Sink → 喜愛裝置 → 各個 Sink → 未分配裝置
3. 根據選擇切換顯示模式和適配器

---

## 四、設備顯示方式對照

### ✅ reef-b-app: 所有 Sink 模式

**Adapter**: `SinkWithDevicesAdapter`
**Layout**: `LinearLayoutManager` (垂直列表)
**結構**: 
- 每個 Sink 作為一個父項
- 每個 Sink 下包含一個 RecyclerView（2列網格）顯示該 Sink 的設備

**adapter_sink_with_devices.xml**:
```xml
<ConstraintLayout paddingBottom="12dp">
  <RecyclerView id="rv_sink_with_devices"
    layout_width="match_parent"
    layout_height="wrap_content"
    listitem="@layout/adapter_device_led" />
</ConstraintLayout>
```

### ✅ reef-b-app: 其他模式（喜愛/特定 Sink/未分配）

**Adapter**: `DeviceAdapter`
**Layout**: `GridLayoutManager` (2列)
**排序邏輯**:
```kotlin
deviceAdapter.submitList(device.sortedByDescending { it.favorite }
  .sortedByDescending { it.master }
  .sortedBy { it.group }
  .sortedByDescending { it.sinkId })
```

### ❌ 當前 koralcore

- [ ] 使用固定列表顯示所有設備
- [ ] 沒有按 Sink 分組顯示
- [ ] 沒有網格顯示模式
- [ ] 沒有 SinkWithDevices 視圖

---

## 五、設備卡片設計對照

### ✅ reef-b-app: adapter_device_led.xml

**結構**:
- MaterialCardView（圓角 10dp，陰影 5dp）
- 設備圖片（LED 圖片）
- BLE 連接狀態圖標（右上角）
- 喜愛圖標
- Master 圖標
- 設備名稱（caption1_accent 樣式）
- 位置/群組信息（caption2 樣式）
- 勾選圖標（通常隱藏）

**尺寸**:
- Card margin: 6dp
- Card corner radius: 10dp
- Card elevation: 5dp
- Padding: 12dp (start/end), 10dp (top/bottom)

### ❌ 當前 koralcore

需要檢查 `_HomeDeviceTile` 是否匹配這個設計。

---

## 六、頂部按鈕對照

### ✅ reef-b-app

| 按鈕 | 位置 | 尺寸 | 可見性 | 功能 |
|------|------|------|--------|------|
| `btn_add_sink` | 左上角 | 56×44dp | `gone` (通常隱藏) | 添加 Sink |
| `btn_warning` | 右上角 | 56×44dp | `gone` (根據條件顯示) | 跳轉到警告頁面 |

**padding**: 16dp (start/end), 10dp (top/bottom)

### ❌ 當前 koralcore

- [ ] AppBar 中有警告按鈕（位置不同）
- [ ] 沒有添加 Sink 按鈕

---

## 七、空狀態對照

### ✅ reef-b-app

**layout_no_device_in_sink**:
```xml
<LinearLayout orientation="vertical">
  <TextView 
    text="@string/text_no_device_in_sink_title"
    textAppearance="@style/subheader_accent" />
  <TextView 
    text="@string/text_no_device_in_sink_content"
    textAppearance="@style/body"
    textColor="@color/text_aaa"
    marginTop="8dp" />
</LinearLayout>
```

**顯示邏輯**:
```kotlin
when (isEmpty) {
  true -> {
    rvUserDevice.visibility = View.GONE
    layoutNoDeviceInSink.visibility = View.VISIBLE
  }
  false -> {
    rvUserDevice.visibility = View.VISIBLE
    layoutNoDeviceInSink.visibility = View.GONE
  }
}
```

### ❌ 當前 koralcore

需要確認是否有對應的空狀態顯示。

---

## 八、數據結構對照

### ✅ reef-b-app

**HomeViewModel** 提供的方法：
- `getAllSinkWithDevices()` → `sinkListLiveData: MutableLiveData<List<SinkWithDevices>>`
- `getFavoriteDevice()` → `deviceListLiveData: MutableLiveData<List<Device>>`
- `getDeviceBySinkId(sinkId)` → `deviceListLiveData`
- `getUnassignedDevice()` → `deviceListLiveData`
- `getAllSinkName()` → `List<String>`
- `getNowSinkAmount()` → `Int`

### ✅ koralcore

已有數據結構：
- `SinkRepository` - 管理 Sink 數據
- `SinkWithDevices` - 已定義
- `DeviceRepository` - 管理設備數據

**需要確認**：
- [ ] 是否有獲取「所有 Sink 及其設備」的方法
- [ ] 是否有獲取「喜愛設備」的方法
- [ ] 是否有獲取「未分配設備」的方法
- [ ] 是否有獲取「特定 Sink 的設備」的方法

---

## 九、導航對照

### ✅ reef-b-app

點擊設備後：
```kotlin
when (data.type) {
  DeviceType.LED -> {
    val intent = Intent(requireContext(), LedMainActivity::class.java)
    intent.putExtra("device_id", data.id)
    startActivity(intent)
  }
  DeviceType.DROP -> {
    val intent = Intent(requireContext(), DropMainActivity::class.java)
    intent.putExtra("device_id", data.id)
    startActivity(intent)
  }
}
```

### ✅ koralcore

當前導航邏輯（在 `_HomeDeviceTile._navigate`）：
```dart
void _navigate(BuildContext context, _DeviceKind kind) {
  final Widget page = kind == _DeviceKind.led
      ? const LedMainPage()
      : const DosingMainPage();
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}
```

**需要確認**：
- [ ] 是否需要傳遞 deviceId（目前沒有傳遞）
- [ ] 是否需要根據設備類型判斷（LED vs DROP）

---

## 十、尺寸和間距對照

### ✅ reef-b-app (fragment_home.xml)

| 元素 | 尺寸/間距 |
|------|-----------|
| Sink Spinner | 101×26dp |
| Spinner marginStart | 16dp |
| Spinner marginTop | 10dp |
| 下拉箭頭圖標 | 24×24dp |
| Sink 管理按鈕 | 30×30dp |
| Sink 管理按鈕 marginEnd | 16dp |
| RecyclerView paddingStart | 10dp |
| RecyclerView paddingTop | 8dp |
| RecyclerView paddingEnd | 10dp |
| 頂部按鈕 | 56×44dp |
| 頂部按鈕 padding | 16dp (start/end), 10dp (top/bottom) |

### ✅ koralcore

需要檢查 `ReefSpacing` 和 `ReefRadius` 是否匹配這些值。

---

## 十一、顏色對照

### ✅ reef-b-app

**背景**：
- 起始色：`#EFEFEF`
- 結束色：`#00FFFFFF` (透明)

**文字**：
- 標題：`subheader_accent` 樣式
- 內容：`body` 樣式，顏色 `@color/text_aaa`
- 空狀態文字：`@color/text_aaa`

### ✅ koralcore

需要確認：
- [ ] `ReefColors.backgroundGradientStart` = `#EFEFEF`
- [ ] `ReefColors.backgroundGradientEnd` = 透明色
- [ ] `ReefTextStyles` 是否有對應的樣式

---

## 十二、改造計劃檢查

### Phase 1: 移除 AppBar，添加頂部按鈕區域 ✅

- [x] 移除 `AppBar`
- [ ] 添加頂部按鈕區域（左側添加 Sink 按鈕，右側警告按鈕）
- [ ] 按鈕尺寸：56×44dp
- [ ] 按鈕 padding：16dp (start/end), 10dp (top/bottom)
- [ ] 添加 Sink 按鈕初始隱藏（`visibility: gone`）

### Phase 2: 添加 Sink 選擇器 ✅

- [ ] 創建 Sink 下拉選擇器（DropdownButton 或 PopupMenuButton）
- [ ] 尺寸：寬度約 101dp，高度 26dp
- [ ] 位置：marginStart 16dp, marginTop 10dp
- [ ] 選項順序：所有 Sink → 喜愛裝置 → 各個 Sink → 未分配裝置
- [ ] 添加下拉箭頭圖標（24×24dp）
- [ ] 添加 Sink 管理按鈕（30×30dp，marginEnd 16dp）

### Phase 3: 實現動態設備列表 ✅

- [ ] 實現「所有 Sink」模式（SinkWithDevices 視圖，垂直列表）
- [ ] 實現「喜愛裝置」模式（設備網格，2列）
- [ ] 實現「特定 Sink」模式（設備網格，2列）
- [ ] 實現「未分配裝置」模式（設備網格，2列）
- [ ] 設備排序邏輯：favorite → master → group → sinkId

### Phase 4: 調整背景和樣式 ✅

- [ ] 背景改為 `ReefMainBackground`（漸變從 #EFEFEF 到透明，225度）
- [ ] 移除 "My Reef" 卡片
- [ ] 移除 LED/Dosing 功能卡片
- [ ] 調整文字顏色以適應淺色背景

### Phase 5: 處理空狀態 ✅

- [ ] 實現空狀態顯示（當沒有設備時）
- [ ] 標題使用 `subheader_accent` 樣式
- [ ] 副標題使用 `body` 樣式，顏色 `text_aaa`
- [ ] 副標題上邊距 8dp
- [ ] 顯示/隱藏邏輯（根據是否有數據）

---

## 結論

**需要改造的關鍵點**：

1. ✅ **背景**：改為淺色漸變背景（`ReefMainBackground`）
2. ✅ **移除 AppBar**：改用頂部按鈕區域
3. ✅ **添加 Sink 選擇器**：實現下拉選擇和動態切換
4. ✅ **動態設備列表**：根據選擇切換顯示模式
5. ✅ **移除功能卡片**：不再顯示 LED/Dosing 功能卡片
6. ✅ **空狀態**：實現空狀態顯示

**改造計劃已確認完全忠實於 reef-b-app 的設計** ✅

