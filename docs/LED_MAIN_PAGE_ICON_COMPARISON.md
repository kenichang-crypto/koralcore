# LED 主頁圖標對照表

## 一、Toolbar 圖標對照

| 位置 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **btnBack (返回)** | `@drawable/ic_back` | `Icons.arrow_back` | ✅ | Material Icons 等效 |
| **btnFavorite (收藏)** | `ic_favorite_select` / `ic_favorite_unselect` | `Icons.favorite` / `Icons.favorite_border` | ✅ | Material Icons 等效 |
| **btnExpand (展開/橫屏切換)** | `@drawable/ic_zoom_in` | `Icons.fullscreen` / `Icons.fullscreen_exit` | ⚠️ | **差異**：reef-b-app 使用 `ic_zoom_in`，koralcore 使用 `fullscreen` |
| **btnMenu (菜單)** | `@drawable/ic_menu` | `Icons.more_vert` | ✅ | Material Icons 等效 |

### 詳細對照

#### 1. btnBack (返回)

**reef-b-app**:
```xml
<!-- toolbar_device.xml -->
<ImageView
    android:id="@+id/btn_back"
    android:src="@drawable/ic_back"
    ... />
```

**koralcore**:
```dart
leading: IconButton(
  icon: const Icon(Icons.arrow_back, color: ReefColors.onPrimary),
  ...
)
```

**狀態**: ✅ **已對照**（Material Icons 等效）

---

#### 2. btnFavorite (收藏)

**reef-b-app**:
```kotlin
// LedMainActivity.kt
when (device.favorite) {
    true -> {
        btnFavorite.setImageResource(R.drawable.ic_favorite_select)
    }
    else -> {
        btnFavorite.setImageResource(R.drawable.ic_favorite_unselect)
    }
}
```

**koralcore**:
```dart
icon: Icon(
  isFavorite ? Icons.favorite : Icons.favorite_border,
  color: isFavorite
      ? ReefColors.error
      : ReefColors.onPrimary.withValues(alpha: 0.7),
),
```

**狀態**: ✅ **已對照**（Material Icons 等效）

---

#### 3. btnExpand (展開/橫屏切換)

**reef-b-app**:
```xml
<!-- activity_led_main.xml -->
<ImageView
    android:id="@+id/btn_expand"
    android:src="@drawable/ic_zoom_in"
    ... />
```

**koralcore**:
```dart
icon: Icon(
  _isLandscape ? Icons.fullscreen_exit : Icons.fullscreen,
  color: ReefColors.onPrimary,
),
```

**狀態**: ⚠️ **有差異**
- **reef-b-app**: 使用 `ic_zoom_in`（放大圖標）
- **koralcore**: 使用 `fullscreen` / `fullscreen_exit`（全屏圖標）

**建議**: 檢查 `ic_zoom_in` 的實際外觀，可能需要使用 `Icons.zoom_in` 或 `Icons.open_in_full` 來更準確地對照。

---

#### 4. btnMenu (菜單)

**reef-b-app**:
```xml
<!-- toolbar_device.xml -->
<ImageView
    android:id="@+id/btn_menu"
    android:src="@drawable/ic_menu"
    ... />
```

**koralcore**:
```dart
PopupMenuButton<String>(
  icon: Icon(Icons.more_vert, color: ReefColors.onPrimary),
  ...
)
```

**狀態**: ✅ **已對照**（Material Icons 等效）

---

## 二、Device Info Section 圖標對照

| 位置 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **btnBle (BLE 連接狀態)** | `ic_connect_background` / `ic_disconnect_background` (48×32dp) | `Image.asset('assets/icons/bluetooth/ic_connect_background.png')` + fallback `Icons.bluetooth_connected` / `Icons.bluetooth_disabled` | ⚠️ | **差異**：koralcore 嘗試使用自定義圖標，但可能缺少資源文件，使用 Material Icons 作為 fallback |

### 詳細對照

#### btnBle (BLE 連接狀態)

**reef-b-app**:
```xml
<!-- activity_led_main.xml -->
<ImageView
    android:id="@+id/btn_ble"
    android:layout_width="@dimen/dp_48"
    android:layout_height="@dimen/dp_32"
    android:src="@drawable/ic_disconnect_background"
    ... />
```

```kotlin
// LedMainActivity.kt
when (isConnect) {
    true -> {
        binding.btnBle?.setImageResource(R.drawable.ic_connect_background)
    }
    false -> {
        binding.btnBle?.setImageResource(R.drawable.ic_disconnect_background)
    }
}
```

**koralcore**:
```dart
Widget _buildBleStateIcon(bool isConnected) {
  try {
    return Image.asset(
      isConnected
          ? 'assets/icons/bluetooth/ic_connect_background.png'
          : 'assets/icons/bluetooth/ic_disconnect_background.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildMaterialBleIcon(isConnected);
      },
    );
  } catch (e) {
    return _buildMaterialBleIcon(isConnected);
  }
}

Widget _buildMaterialBleIcon(bool isConnected) {
  return Container(
    decoration: BoxDecoration(
      color: isConnected
          ? ReefColors.primary // #6F916F (green) when connected
          : ReefColors.surfaceMuted, // #F7F7F7 (grey) when disconnected
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(
      child: Icon(
        isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
        ...
      ),
    ),
  );
}
```

**狀態**: ⚠️ **有差異**
- **reef-b-app**: 使用自定義圖標 `ic_connect_background` / `ic_disconnect_background`
- **koralcore**: 嘗試使用自定義圖標，但可能缺少資源文件，使用 Material Icons 作為 fallback

**建議**: 
1. 檢查 `assets/icons/bluetooth/ic_connect_background.png` 和 `ic_disconnect_background.png` 是否存在
2. 如果不存在，需要從 reef-b-app 複製這些圖標資源
3. 確保圖標尺寸為 48×32dp

---

## 三、Record Section 圖標對照

| 位置 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **btnRecordMore (Record 更多)** | `ic_more_enable` / `ic_more_disable` (24×24dp) | `Icons.more_horiz` | ⚠️ | **差異**：reef-b-app 有啟用/禁用狀態的不同圖標，koralcore 只有一個圖標 |
| **btnExpand (展開)** | `@drawable/ic_zoom_in` (24×24dp) | 未實現 | ❌ | **缺失**：koralcore 的 Record Section 中沒有展開按鈕 |
| **btnPreview (預覽)** | `ic_preview` / `ic_stop` (24×24dp) | `Icons.play_arrow` / `Icons.stop` | ✅ | Material Icons 等效 |
| **btnContinueRecord (繼續 Record)** | 未找到具體圖標 | `Icons.play_circle_outline` | ⚠️ | **需確認**：reef-b-app 中此按鈕的圖標 |

### 詳細對照

#### 1. btnRecordMore (Record 更多)

**reef-b-app**:
```xml
<!-- activity_led_main.xml -->
<ImageView
    android:id="@+id/btn_record_more"
    android:layout_width="@dimen/dp_24"
    android:layout_height="@dimen/dp_24"
    android:src="@drawable/ic_more_disable"
    ... />
```

```kotlin
// LedMainActivity.kt
when (isConnect) {
    true -> {
        binding.btnRecordMore?.setImageResource(R.drawable.ic_more_enable)
    }
    false -> {
        binding.btnRecordMore?.setImageResource(R.drawable.ic_more_disable)
    }
}
```

**koralcore**:
```dart
IconButton(
  icon: const Icon(Icons.more_horiz),
  iconSize: 24,
  onPressed: featuresEnabled ? ... : null,
)
```

**狀態**: ⚠️ **有差異**
- **reef-b-app**: 使用 `ic_more_enable`（啟用）和 `ic_more_disable`（禁用）兩種圖標
- **koralcore**: 只使用 `Icons.more_horiz`，通過 `enabled` 屬性控制可用性

**建議**: 
1. 檢查是否需要視覺上區分啟用/禁用狀態
2. 如果需要，可以使用 `Icons.more_horiz`（啟用）和 `Icons.more_horiz_outlined`（禁用）

---

#### 2. btnExpand (展開)

**reef-b-app**:
```xml
<!-- activity_led_main.xml layout_record -->
<ImageView
    android:id="@+id/btn_expand"
    android:layout_width="@dimen/dp_24"
    android:layout_height="@dimen/dp_24"
    android:src="@drawable/ic_zoom_in"
    ... />
```

**koralcore**:
```dart
// 未實現 - Record Section 中沒有展開按鈕
```

**狀態**: ❌ **缺失**
- **reef-b-app**: Record Section 中有展開按鈕（`btn_expand`）
- **koralcore**: Record Section 中沒有展開按鈕

**建議**: 
1. 檢查 `_RecordChartSection` 是否需要添加展開按鈕
2. 如果需要，使用 `Icons.zoom_in` 或 `Icons.open_in_full`

---

#### 3. btnPreview (預覽)

**reef-b-app**:
```kotlin
// LedMainActivity.kt
when (it) {
    true -> {
        binding.btnPreview.setImageResource(R.drawable.ic_stop)
    }
    false -> {
        binding.btnPreview.setImageResource(R.drawable.ic_preview)
    }
}
```

**koralcore**:
```dart
IconButton(
  icon: Icon(
    controller.isPreviewing
        ? Icons.stop
        : Icons.play_arrow,
  ),
  ...
)
```

**狀態**: ✅ **已對照**（Material Icons 等效）

---

#### 4. btnContinueRecord (繼續 Record)

**reef-b-app**:
```xml
<!-- activity_led_main.xml layout_record_pause -->
<MaterialButton
    android:id="@+id/btn_continue_record"
    android:text="@string/continue_record"
    ... />
```

**koralcore**:
```dart
IconButton(
  icon: const Icon(Icons.play_circle_outline),
  tooltip: l10n.ledContinueRecord,
  ...
)
```

**狀態**: ⚠️ **需確認**
- **reef-b-app**: 使用 `MaterialButton` 顯示文字 "繼續執行"
- **koralcore**: 使用 `IconButton` 顯示圖標 `Icons.play_circle_outline`

**建議**: 
1. 檢查 reef-b-app 中此按鈕是否有圖標
2. 如果沒有圖標，可能需要調整為按鈕樣式而非圖標按鈕

---

## 四、Scene Section 圖標對照

| 位置 | reef-b-app | koralcore | 狀態 | 備註 |
|------|-----------|-----------|------|------|
| **btnSceneMore (Scene 更多)** | `ic_more_enable` / `ic_more_disable` (24×24dp) | `Icons.more_horiz` | ⚠️ | **差異**：reef-b-app 有啟用/禁用狀態的不同圖標，koralcore 只有一個圖標 |
| **Favorite Scene Cards** | `ic_none` 或場景特定圖標 | `Icons.favorite` | ⚠️ | **差異**：reef-b-app 使用場景圖標，koralcore 使用 `Icons.favorite` |

### 詳細對照

#### 1. btnSceneMore (Scene 更多)

**reef-b-app**:
```xml
<!-- activity_led_main.xml -->
<ImageView
    android:id="@+id/btn_scene_more"
    android:layout_width="@dimen/dp_24"
    android:layout_height="@dimen/dp_24"
    android:src="@drawable/ic_more_disable"
    ... />
```

```kotlin
// LedMainActivity.kt
when (isConnect) {
    true -> {
        binding.btnSceneMore?.setImageResource(R.drawable.ic_more_enable)
    }
    false -> {
        binding.btnSceneMore?.setImageResource(R.drawable.ic_more_disable)
    }
}
```

**koralcore**:
```dart
IconButton(
  icon: const Icon(Icons.more_horiz),
  iconSize: 24,
  onPressed: featuresEnabled ? ... : null,
)
```

**狀態**: ⚠️ **有差異**
- **reef-b-app**: 使用 `ic_more_enable`（啟用）和 `ic_more_disable`（禁用）兩種圖標
- **koralcore**: 只使用 `Icons.more_horiz`，通過 `enabled` 屬性控制可用性

**建議**: 同 btnRecordMore

---

#### 2. Favorite Scene Cards

**reef-b-app**:
```xml
<!-- adapter_favorite_scene.xml -->
<MaterialButton
    android:icon="@drawable/ic_none"
    ... />
```

**koralcore**:
```dart
ElevatedButton.icon(
  icon: Icon(
    Icons.favorite, // TODO: Use scene icon (ic_none or scene-specific icon)
    size: 20,
  ),
  ...
)
```

**狀態**: ⚠️ **有差異**
- **reef-b-app**: 使用 `ic_none` 或場景特定圖標
- **koralcore**: 使用 `Icons.favorite`，有 TODO 註釋表示需要使用場景圖標

**建議**: 
1. 檢查是否需要使用場景特定圖標
2. 如果需要，需要實現場景圖標的映射邏輯

---

## 五、總結

### ✅ 已完全對照的圖標（5 個）

1. **btnBack (返回)** - `Icons.arrow_back`
2. **btnFavorite (收藏)** - `Icons.favorite` / `Icons.favorite_border`
3. **btnMenu (菜單)** - `Icons.more_vert`
4. **btnPreview (預覽)** - `Icons.play_arrow` / `Icons.stop`

### ⚠️ 有差異的圖標（6 個）

1. **btnExpand (展開/橫屏切換)** - reef-b-app 使用 `ic_zoom_in`，koralcore 使用 `Icons.fullscreen`
2. **btnBle (BLE 連接狀態)** - reef-b-app 使用自定義圖標，koralcore 嘗試使用但可能缺少資源文件
3. **btnRecordMore (Record 更多)** - reef-b-app 有啟用/禁用狀態的不同圖標，koralcore 只有一個圖標
4. **btnSceneMore (Scene 更多)** - reef-b-app 有啟用/禁用狀態的不同圖標，koralcore 只有一個圖標
5. **btnContinueRecord (繼續 Record)** - reef-b-app 使用按鈕文字，koralcore 使用圖標按鈕
6. **Favorite Scene Cards** - reef-b-app 使用場景圖標，koralcore 使用 `Icons.favorite`

### ❌ 缺失的圖標（1 個）

1. **btnExpand (Record Section 展開)** - reef-b-app 有，koralcore 沒有

---

## 六、修復建議

### 高優先級

1. **檢查 BLE 圖標資源文件**：
   - 確認 `assets/icons/bluetooth/ic_connect_background.png` 和 `ic_disconnect_background.png` 是否存在
   - 如果不存在，從 reef-b-app 複製這些圖標資源

2. **實現 Record Section 展開按鈕**：
   - 檢查是否需要添加展開按鈕
   - 如果需要，使用 `Icons.zoom_in` 或 `Icons.open_in_full`

### 中優先級

3. **btnExpand (橫屏切換)**：
   - 檢查 `ic_zoom_in` 的實際外觀
   - 考慮使用 `Icons.zoom_in` 或 `Icons.open_in_full` 來更準確地對照

4. **btnRecordMore / btnSceneMore**：
   - 考慮使用 `Icons.more_horiz`（啟用）和 `Icons.more_horiz_outlined`（禁用）來區分狀態

### 低優先級

5. **Favorite Scene Cards**：
   - 實現場景圖標的映射邏輯
   - 使用場景特定圖標而非 `Icons.favorite`

6. **btnContinueRecord**：
   - 檢查是否需要調整為按鈕樣式而非圖標按鈕

