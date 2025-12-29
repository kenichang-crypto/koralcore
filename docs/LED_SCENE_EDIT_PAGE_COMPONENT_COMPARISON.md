# LED 場景編輯頁面組件完整對照表

## 一、Toolbar 組件對照

| 組件 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **Toolbar 布局** | `toolbar_two_action.xml` | `ReefAppBar` | ✅ | 已對照 |
| **btnBack (返回)** | `@drawable/ic_close` (56×44dp) | `ReefAppBar.leading` (默認 `Icons.arrow_back`) | ⚠️ | **差異**：reef-b-app 使用 `ic_close`，koralcore 使用默認返回圖標 |
| **toolbarTitle (標題)** | `@string/activity_led_scene_edit_title` | `l10n.ledSceneEditTitle` | ✅ | 已對照 |
| **btnRight (完成/保存)** | `@string/activity_led_scene_edit_toolbar_right_btn` (MaterialButton) | `FloatingActionButton.extended` (Save) | ⚠️ | **差異**：reef-b-app 在 Toolbar，koralcore 使用 FloatingActionButton |
| **Divider** | `@layout/toolbar_two_action` 包含 divider (2dp) | `ReefAppBar.showDivider` | ✅ | 已對照 |

### 詳細對照

#### 1. btnBack (返回)

**reef-b-app**:
```xml
<!-- toolbar_two_action.xml -->
<ImageView
    android:id="@+id/btn_back"
    android:src="@drawable/ic_close"
    android:layout_width="@dimen/dp_56"
    android:layout_height="@dimen/dp_44"
    ... />
```

```kotlin
// LedSceneEditActivity.kt
binding.toolbarLedSceneEdit.btnBack.setImageResource(R.drawable.ic_close)
```

**koralcore**:
```dart
appBar: ReefAppBar(
  title: Text(l10n.ledSceneEditTitle),
  // leading 默認使用 Icons.arrow_back
),
```

**狀態**: ⚠️ **有差異**
- **reef-b-app**: 使用 `ic_close` 圖標
- **koralcore**: 使用默認的 `Icons.arrow_back` 圖標

**建議**: 使用 `Icons.close` 對照 `ic_close`

---

#### 2. btnRight (完成/保存)

**reef-b-app**:
```xml
<!-- toolbar_two_action.xml -->
<MaterialButton
    android:id="@+id/btn_right"
    android:text="@string/activity_led_scene_edit_toolbar_right_btn"
    android:layout_gravity="end|center_vertical"
    ... />
```

```kotlin
// LedSceneEditActivity.kt
binding.toolbarLedSceneEdit.btnRight.text = getString(R.string.activity_led_scene_edit_toolbar_right_btn)
binding.toolbarLedSceneEdit.btnRight.setOnClickListener {
    viewModel.editScene(iconAdapter.getNowSelect()) {
        (R.string.toast_name_is_empty).toast(this)
    }
}
```

**koralcore**:
```dart
floatingActionButton: FloatingActionButton.extended(
  heroTag: 'save',
  onPressed: (isConnected && !controller.isLoading)
      ? () async {
          final success = await controller.saveScene();
          // ...
        }
      : null,
  icon: const Icon(Icons.save),
  label: Text(l10n.actionSave),
),
```

**狀態**: ⚠️ **有差異**
- **reef-b-app**: 在 Toolbar 右側使用 MaterialButton
- **koralcore**: 使用 FloatingActionButton.extended 在底部

**建議**: 檢查是否需要將保存按鈕移到 Toolbar 右側

---

## 二、場景名稱輸入框對照

| 組件 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **tv_time_title (標題)** | `@string/led_scene_name` (caption1, text_aaaa) | `l10n.ledSceneNameLabel` (TextField labelText) | ✅ | 已對照 |
| **layout_name (輸入框容器)** | `TextInputLayout` (style: TextInputLayout) | `TextField` (OutlineInputBorder) | ✅ | 已對照 |
| **edt_name (輸入框)** | `TextInputEditText` (style: SingleLine, body) | `TextField` (onChanged) | ✅ | 已對照 |
| **位置** | marginStart=16dp, marginTop=12dp, marginEnd=16dp | paddingStart=16dp, paddingTop=12dp, paddingEnd=16dp | ✅ | 已對照 |
| **間距** | marginTop=4dp (從標題) | SizedBox(height=16dp) (在 TextField 後) | ⚠️ | **差異**：間距略有不同 |

### 詳細對照

**reef-b-app**:
```xml
<TextView
    android:id="@+id/tv_time_title"
    android:layout_marginStart="@dimen/dp_16"
    android:layout_marginTop="@dimen/dp_12"
    android:layout_marginEnd="@dimen/dp_16"
    android:text="@string/led_scene_name"
    android:textAppearance="@style/caption1"
    android:textColor="@color/text_aaaa" />

<com.google.android.material.textfield.TextInputLayout
    android:id="@+id/layout_name"
    android:layout_marginTop="@dimen/dp_4"
    ...>
    <com.google.android.material.textfield.TextInputEditText
        android:id="@+id/edt_name"
        style="@style/SingleLine"
        android:textAppearance="@style/body"
        ... />
</com.google.android.material.textfield.TextInputLayout>
```

**koralcore**:
```dart
TextField(
  decoration: InputDecoration(
    labelText: l10n.ledSceneNameLabel,
    hintText: l10n.ledSceneNameHint,
    border: const OutlineInputBorder(),
  ),
  controller: TextEditingController(text: controller.name),
  onChanged: controller.setName,
),
```

**狀態**: ✅ **已對照**（功能相同，UI 樣式略有差異）

---

## 三、場景圖標選擇器對照

| 組件 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **tv_scene_icon_title (標題)** | `@string/led_scene_icon` (caption1, text_aaaa) | `SceneIconPicker` 內部標題 "Scene Icon" | ⚠️ | **差異**：koralcore 使用硬編碼英文，應使用本地化字符串 |
| **rv_scene_icon (圖標列表)** | `RecyclerView` (horizontal, paddingStart/End=8dp) | `ListView.builder` (horizontal) | ✅ | 已對照 |
| **圖標數量** | 11 個圖標 (0-10) | 11 個圖標 (0-10) | ✅ | 已對照 |
| **圖標樣式** | `adapter_scene_icon.xml` (CardView, 40×40dp, cornerRadius=24dp) | `Card` (40×40dp, borderRadius=24dp) | ✅ | 已對照 |
| **位置** | marginTop=24dp (從 layout_name) | SizedBox(height=16dp) (從 TextField) | ⚠️ | **差異**：間距不同 |

### 詳細對照

**reef-b-app**:
```xml
<TextView
    android:id="@+id/tv_scene_icon_title"
    android:layout_marginTop="@dimen/dp_24"
    android:text="@string/led_scene_icon"
    android:textAppearance="@style/caption1"
    android:textColor="@color/text_aaaa" />

<androidx.recyclerview.widget.RecyclerView
    android:id="@+id/rv_scene_icon"
    android:paddingStart="@dimen/dp_8"
    android:paddingEnd="@dimen/dp_8"
    android:layout_marginTop="@dimen/dp_4"
    ... />
```

**koralcore**:
```dart
// SceneIconPicker
Column(
  children: [
    Text(
      'Scene Icon', // ⚠️ 硬編碼，應使用 l10n.ledSceneIcon
      style: Theme.of(context).textTheme.titleMedium,
    ),
    const SizedBox(height: ReefSpacing.sm),
    SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 11,
        // ...
      ),
    ),
  ],
)
```

**狀態**: ⚠️ **有差異**
- **reef-b-app**: 使用本地化字符串 `@string/led_scene_icon`
- **koralcore**: 使用硬編碼英文 "Scene Icon"

**建議**: 使用 `l10n.ledSceneIcon` 對照 `@string/led_scene_icon`

---

## 四、光譜圖表對照

| 組件 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **chart_spectrum (光譜圖表)** | `LineChart` (height=176dp, marginStart/End=22dp, marginTop=24dp) | `LedSpectrumChart` (height=72, compact=true) | ⚠️ | **差異**：高度不同（176dp vs 72dp），邊距不同 |

### 詳細對照

**reef-b-app**:
```xml
<com.github.mikephil.charting.charts.LineChart
    android:id="@+id/chart_spectrum"
    android:layout_width="match_parent"
    android:layout_height="@dimen/dp_176"
    android:layout_marginStart="@dimen/dp_22"
    android:layout_marginTop="@dimen/dp_24"
    android:layout_marginEnd="@dimen/dp_22"
    ... />
```

```kotlin
// LedSceneEditActivity.kt
val spectrumUtil = SpectrumUtil(
    binding.chartSpectrum,
    binding.slUvLight,
    binding.slPurpleLight,
    // ... 所有滑塊
).init()
```

**koralcore**:
```dart
if (controller.channelLevels.isNotEmpty)
  LedSpectrumChart.fromChannelMap(
    controller.channelLevels,
    height: 72, // ⚠️ 應該是 176dp
    compact: true,
  ),
```

**狀態**: ⚠️ **有差異**
- **reef-b-app**: 高度 176dp，邊距 Start/End=22dp，Top=24dp
- **koralcore**: 高度 72dp，沒有明確的邊距設置

**建議**: 
1. 調整高度為 176dp
2. 添加邊距 Start/End=22dp，Top=24dp

---

## 五、通道滑塊對照

### 5.1 滑塊結構對照

每個通道滑塊包含：
1. **標題 TextView** (tv_xxx_light_title)
2. **數值 TextView** (tv_xxx_light)
3. **Slider** (sl_xxx_light)

### 5.2 通道順序對照

| 順序 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| 1 | UV Light | UV | ✅ |
| 2 | Purple Light | Purple | ✅ |
| 3 | Blue Light | Blue | ✅ |
| 4 | Royal Blue Light | Royal Blue | ✅ |
| 5 | Green Light | Green | ✅ |
| 6 | Red Light | Red | ✅ |
| 7 | Cold White Light | Cold White | ✅ |
| 8 | Warm White Light | Warm White | ✅ |
| 9 | Moon Light | Moon Light | ✅ |

**狀態**: ✅ **已對照**（順序相同）

---

### 5.3 滑塊組件詳細對照

#### UV Light 滑塊

**reef-b-app**:
```xml
<TextView
    android:id="@+id/tv_uv_light_title"
    android:layout_marginStart="@dimen/dp_6"
    android:layout_marginTop="@dimen/dp_16"
    android:text="@string/light_uv"
    android:textAppearance="@style/caption1"
    android:textColor="@color/text_aaaa"
    app:layout_constraintBottom_toTopOf="@id/sl_uv_light"
    app:layout_constraintEnd_toStartOf="@id/tv_uv_light"
    app:layout_constraintStart_toStartOf="@id/tv_scene_icon_title"
    app:layout_constraintTop_toBottomOf="@id/chart_spectrum" />

<TextView
    android:id="@+id/tv_uv_light"
    android:layout_marginStart="@dimen/dp_4"
    android:layout_marginEnd="@dimen/dp_6"
    android:text="0"
    android:textAppearance="@style/caption1"
    android:textColor="@color/text_aaa"
    app:layout_constraintBottom_toBottomOf="@id/tv_uv_light_title"
    app:layout_constraintEnd_toEndOf="@id/tv_scene_icon_title"
    app:layout_constraintStart_toEndOf="@id/tv_uv_light_title"
    app:layout_constraintTop_toTopOf="@id/tv_uv_light_title" />

<com.google.android.material.slider.Slider
    android:id="@+id/sl_uv_light"
    android:layout_marginStart="@dimen/dp_16"
    android:layout_marginEnd="@dimen/dp_16"
    android:value="0"
    android:valueFrom="0"
    android:valueTo="100"
    app:labelBehavior="gone"
    app:trackColorActive="@color/uv_light_color"
    app:trackColorInactive="@color/bg_press"
    app:trackHeight="@dimen/dp_2"
    app:layout_constraintBottom_toTopOf="@id/tv_purple_light_title"
    app:layout_constraintEnd_toEndOf="parent"
    app:layout_constraintStart_toStartOf="parent"
    app:layout_constraintTop_toBottomOf="@id/tv_uv_light_title" />
```

**koralcore**:
```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(ReefSpacing.md),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: theme.textTheme.titleSmall),
            ),
            Text(
              '$value%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: ReefSpacing.xs),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          label: '$value%',
          onChanged: enabled && controller.isDimmingMode
              ? (newValue) => controller.setChannelLevel(id, newValue.toInt())
              : null,
        ),
      ],
    ),
  ),
)
```

**狀態**: ⚠️ **有差異**
- **reef-b-app**: 
  - 標題和數值在同一行（使用 ConstraintLayout 約束）
  - 標題 marginStart=6dp，數值 marginStart=4dp, marginEnd=6dp
  - 滑塊 marginStart/End=16dp
  - 滑塊有自定義圖標 `setCustomThumbDrawable(R.drawable.ic_uv_light_thumb)`
  - 滑塊有顏色 `trackColorActive="@color/uv_light_color"`
- **koralcore**: 
  - 使用 Card 包裝，標題和數值在 Row 中
  - 沒有自定義滑塊圖標
  - 沒有設置滑塊顏色

**建議**: 
1. 檢查是否需要自定義滑塊圖標
2. 檢查是否需要設置滑塊顏色
3. 調整布局以對照 ConstraintLayout 的約束關係

---

## 六、保存按鈕對照

| 組件 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **btnRight (完成)** | Toolbar 右側 MaterialButton | FloatingActionButton.extended (底部) | ⚠️ | **差異**：位置和樣式不同 |
| **圖標** | 無圖標（純文字按鈕） | `Icons.save` | ⚠️ | **差異**：koralcore 有圖標 |
| **文字** | `@string/activity_led_scene_edit_toolbar_right_btn` | `l10n.actionSave` | ⚠️ | **需確認**：文字是否一致 |

### 詳細對照

**reef-b-app**:
```kotlin
// LedSceneEditActivity.kt
binding.toolbarLedSceneEdit.btnRight.text = getString(R.string.activity_led_scene_edit_toolbar_right_btn)
binding.toolbarLedSceneEdit.btnRight.setOnClickListener {
    viewModel.editScene(iconAdapter.getNowSelect()) {
        (R.string.toast_name_is_empty).toast(this)
    }
}
```

**koralcore**:
```dart
floatingActionButton: FloatingActionButton.extended(
  heroTag: 'save',
  onPressed: (isConnected && !controller.isLoading)
      ? () async {
          final success = await controller.saveScene();
          // ...
        }
      : null,
  icon: const Icon(Icons.save),
  label: Text(l10n.actionSave),
),
```

**狀態**: ⚠️ **有差異**
- **reef-b-app**: 在 Toolbar 右側，純文字按鈕
- **koralcore**: 在底部，帶圖標的 FloatingActionButton

**建議**: 檢查是否需要將保存按鈕移到 Toolbar 右側

---

## 七、進度指示器對照

| 組件 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **progress (加載指示器)** | `@layout/progress` (全屏覆蓋) | `CircularProgressIndicator` (在 ListView 中) | ⚠️ | **差異**：位置和樣式不同 |

### 詳細對照

**reef-b-app**:
```xml
<include
    android:id="@+id/progress"
    layout="@layout/progress"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:visibility="gone" />
```

```kotlin
// LedSceneEditActivity.kt
viewModel.loadingLiveData.observe(this) {
    when (it) {
        true -> {
            binding.progress.root.visibility = View.VISIBLE
        }
        false -> {
            binding.progress.root.visibility = View.GONE
        }
    }
}
```

**koralcore**:
```dart
if (controller.isLoading)
  const Padding(
    padding: EdgeInsets.all(ReefSpacing.md),
    child: Center(child: CircularProgressIndicator()),
  ),
```

**狀態**: ⚠️ **有差異**
- **reef-b-app**: 全屏覆蓋的進度指示器
- **koralcore**: 在 ListView 中的進度指示器

**建議**: 檢查是否需要全屏覆蓋的進度指示器

---

## 八、位置和間距對照

### 8.1 整體布局

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **根容器** | ConstraintLayout | Scaffold + ListView | ⚠️ |
| **ScrollView** | ScrollView (layout_led_record_time_setting) | ListView | ✅ |
| **內層容器** | ConstraintLayout (paddingStart/End=16dp, paddingTop=12dp) | ListView (paddingStart/End=16dp, paddingTop=12dp) | ✅ |

### 8.2 組件間距

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **tv_time_title** | marginTop=12dp | paddingTop=12dp | ✅ |
| **layout_name** | marginTop=4dp (從 tv_time_title) | - | ⚠️ |
| **tv_scene_icon_title** | marginTop=24dp (從 layout_name) | SizedBox(height=16dp) (從 TextField) | ⚠️ |
| **rv_scene_icon** | marginTop=4dp (從 tv_scene_icon_title) | SizedBox(height=16dp) (從 SceneIconPicker) | ⚠️ |
| **chart_spectrum** | marginTop=24dp (從 rv_scene_icon), marginStart/End=22dp | SizedBox(height=16dp) (從 SceneIconPicker) | ⚠️ |
| **tv_uv_light_title** | marginTop=16dp (從 chart_spectrum), marginStart=6dp | - | ⚠️ |
| **滑塊之間** | 通過 ConstraintLayout 約束（無明確間距） | Padding(bottom=8dp) | ⚠️ |
| **sl_moon_light** | marginBottom=40dp | paddingBottom=40dp (ListView) | ✅ |

**狀態**: ⚠️ **間距不完全一致**

---

## 九、文字對照

| 文字資源 | reef-b-app | koralcore | 狀態 |
|---------|-----------|-----------|------|
| **場景名稱標題** | `@string/led_scene_name` | `l10n.ledSceneNameLabel` | ✅ |
| **場景圖標標題** | `@string/led_scene_icon` | "Scene Icon" (硬編碼) | ⚠️ |
| **UV Light** | `@string/light_uv` | "UV" (硬編碼) | ⚠️ |
| **Purple Light** | `@string/light_purple` | "Purple" (硬編碼) | ⚠️ |
| **Blue Light** | `@string/light_blue` | "Blue" (硬編碼) | ⚠️ |
| **Royal Blue Light** | `@string/light_royal_blue` | "Royal Blue" (硬編碼) | ⚠️ |
| **Green Light** | `@string/light_green` | "Green" (硬編碼) | ⚠️ |
| **Red Light** | `@string/light_red` | "Red" (硬編碼) | ⚠️ |
| **Cold White Light** | `@string/light_cold_white` | "Cold White" (硬編碼) | ⚠️ |
| **Warm White Light** | `@string/light_warm_white` | "Warm White" (硬編碼) | ⚠️ |
| **Moon Light** | `@string/light_moon` | "Moon Light" (硬編碼) | ⚠️ |
| **保存按鈕** | `@string/activity_led_scene_edit_toolbar_right_btn` | `l10n.actionSave` | ⚠️ |

**狀態**: ⚠️ **多處使用硬編碼文字，應使用本地化字符串**

---

## 十、圖標對照

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **btnBack** | `@drawable/ic_close` | `Icons.arrow_back` (默認) | ⚠️ |
| **滑塊圖標** | `ic_uv_light_thumb`, `ic_purple_light_thumb`, 等 | 無（使用默認滑塊） | ⚠️ |
| **場景圖標** | 自定義圖標資源 | Material Icons 等效 | ⚠️ |

**狀態**: ⚠️ **需要對照圖標資源**

---

## 十一、功能對照

| 功能 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **場景名稱輸入** | `doAfterTextChanged` → `viewModel.setName()` | `onChanged` → `controller.setName()` | ✅ |
| **場景圖標選擇** | `iconAdapter.setNowSelect()` → `viewModel.editScene(iconId)` | `onIconSelected` → `controller.setIconId()` | ✅ |
| **滑塊值變更** | `addOnChangeListener` → `viewModel.setSlXxxLight()` → `bleDimming()` | `onChanged` → `controller.setChannelLevel()` → `_sendDimmingCommand()` | ✅ |
| **進入調光模式** | 數據加載完成後 `viewModel.bleDimming()` | 數據加載完成後 `enterDimmingMode()` | ✅ |
| **保存場景** | `viewModel.editScene()` → 檢查名稱 → 保存到數據庫 | `controller.saveScene()` → 檢查名稱 → 保存到數據庫 | ✅ |
| **返回處理** | `clickBtnBack()` → `bleExitDimmingMode()` | `dispose()` → `exitDimmingMode()` | ✅ |

**狀態**: ✅ **功能已對照**

---

## 十二、總結

### ✅ 已完全對照

1. **場景名稱輸入框** - 功能已對照
2. **通道滑塊功能** - 滑塊值變更和 BLE 命令發送已對照
3. **進入/退出調光模式** - 時機和邏輯已對照
4. **保存場景** - 邏輯已對照

### ⚠️ 需要修復

1. **Toolbar 返回按鈕圖標** - 應使用 `Icons.close` 對照 `ic_close`
2. **保存按鈕位置** - 應移到 Toolbar 右側對照 reef-b-app
3. **場景圖標標題** - 應使用本地化字符串 `l10n.ledSceneIcon`
4. **通道標題文字** - 應使用本地化字符串而非硬編碼
5. **光譜圖表高度** - 應調整為 176dp
6. **光譜圖表邊距** - 應添加 marginStart/End=22dp, marginTop=24dp
7. **滑塊自定義圖標** - 應添加自定義滑塊圖標（`ic_uv_light_thumb` 等）
8. **滑塊顏色** - 應設置 `trackColorActive` 對應的顏色
9. **組件間距** - 應對照 ConstraintLayout 的約束關係調整間距
10. **進度指示器** - 應使用全屏覆蓋的進度指示器

### ❌ 缺失的組件

無

---

## 十三、修復優先級

### 高優先級

1. **保存按鈕位置** - 移到 Toolbar 右側
2. **Toolbar 返回按鈕圖標** - 使用 `Icons.close`
3. **本地化字符串** - 所有硬編碼文字應使用本地化字符串

### 中優先級

4. **光譜圖表尺寸和邊距** - 調整為 176dp 高度，添加邊距
5. **組件間距** - 對照 ConstraintLayout 約束調整
6. **滑塊自定義圖標和顏色** - 添加自定義圖標和顏色

### 低優先級

7. **進度指示器樣式** - 使用全屏覆蓋的進度指示器

