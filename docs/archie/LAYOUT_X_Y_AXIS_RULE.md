# Layout X, Y 軸對齊規則

## 📋 新規則

**要求**：要儘量在 koralcore 實現 reef-b-app 中的 layout，其位置不是只有 y 軸而已，還有 x 軸。

## 🔍 問題分析

### reef-b-app 的 Layout 方式

reef-b-app 使用 `ConstraintLayout`，所有組件都有明確的 x, y 軸約束關係：

```xml
<!-- 例如：btn_ble 的約束 -->
<ImageView
    android:id="@+id/btn_ble"
    android:layout_width="@dimen/dp_48"
    android:layout_height="@dimen/dp_32"
    android:layout_marginEnd="@dimen/dp_16"
    app:layout_constraintTop_toTopOf="@id/tv_name"      <!-- Y 軸：與 tv_name 頂部對齊 -->
    app:layout_constraintBottom_toBottomOf="@id/tv_position"  <!-- Y 軸：與 tv_position 底部對齊 -->
    app:layout_constraintStart_toEndOf="@id/tv_name"    <!-- X 軸：在 tv_name 右側 -->
    app:layout_constraintEnd_toEndOf="parent"           <!-- X 軸：右側對齊父容器 -->
    />
```

### koralcore 當前的問題

1. **使用 ListView 只有 Y 軸排列**：
   - 所有組件都是垂直排列
   - 無法實現 x, y 軸的約束關係

2. **X 軸位置不對應**：
   - `btn_ble` 應該與 `tv_name` 和 `tv_position` 垂直居中，但當前實現可能只是簡單的右對齊
   - `tv_group` 應該與 `tv_position` 在同一行，但當前實現可能只是簡單的 Row
   - `btn_record_more` 應該與 `tv_record_title` 垂直居中
   - `btn_scene_more` 應該與 `tv_scene_title` 垂直居中

## 📐 reef-b-app Layout 約束關係

### LED Main Page (`activity_led_main.xml`)

#### 1. Device Info Section

```
tv_name (TextView)
├── constraintTop: toolbar_led_main.bottom (marginTop=8dp)
├── constraintBottom: tv_position.top
├── constraintStart: parent.start (marginStart=16dp)
└── constraintEnd: btn_ble.start (marginEnd=4dp)

btn_ble (ImageView) - 48×32dp
├── constraintTop: tv_name.top                    <!-- Y 軸：與 tv_name 頂部對齊 -->
├── constraintBottom: tv_position.bottom          <!-- Y 軸：與 tv_position 底部對齊 -->
├── constraintStart: tv_name.end                  <!-- X 軸：在 tv_name 右側 -->
└── constraintEnd: parent.end (marginEnd=16dp)    <!-- X 軸：右側對齊父容器 -->

tv_position (TextView)
├── constraintTop: tv_name.bottom
├── constraintBottom: tv_record_title.top
├── constraintStart: tv_name.start
└── constraintEnd: tv_group.start

tv_group (TextView) - 可隱藏
├── constraintTop: tv_position.top               <!-- Y 軸：與 tv_position 頂部對齊 -->
├── constraintBottom: tv_position.bottom          <!-- Y 軸：與 tv_position 底部對齊 -->
├── constraintStart: tv_position.end (marginStart=4dp)  <!-- X 軸：在 tv_position 右側 -->
└── constraintEnd: btn_ble.start (marginEnd=4dp)  <!-- X 軸：在 btn_ble 左側 -->
```

#### 2. Record Section

```
tv_record_title (TextView)
├── constraintTop: tv_position.bottom (marginTop=20dp)
├── constraintBottom: layout_record_background.top
├── constraintStart: tv_name.start
└── constraintEnd: btn_record_more.start

btn_record_more (ImageView) - 24×24dp
├── constraintTop: tv_record_title.top             <!-- Y 軸：與 tv_record_title 頂部對齊 -->
├── constraintBottom: tv_record_title.bottom       <!-- Y 軸：與 tv_record_title 底部對齊 -->
├── constraintStart: tv_record_title.end (marginStart=16dp)  <!-- X 軸：在 tv_record_title 右側 -->
└── constraintEnd: parent.end (marginEnd=16dp)    <!-- X 軸：右側對齊父容器 -->

layout_record_background (CardView)
├── constraintTop: tv_record_title.bottom (marginTop=4dp)
├── constraintBottom: tv_scene_title.top
├── constraintStart: tv_record_title.start
└── constraintEnd: btn_record_more.end
```

#### 3. Scene Section

```
tv_scene_title (TextView)
├── constraintTop: layout_record_background.bottom (marginTop=24dp)
├── constraintBottom: (未設置，wrap_content)
├── constraintStart: tv_name.start
└── constraintEnd: btn_scene_more.start

btn_scene_more (ImageView) - 24×24dp
├── constraintTop: tv_scene_title.top              <!-- Y 軸：與 tv_scene_title 頂部對齊 -->
├── constraintBottom: tv_scene_title.bottom        <!-- Y 軸：與 tv_scene_title 底部對齊 -->
├── constraintStart: tv_scene_title.end (marginStart=16dp)  <!-- X 軸：在 tv_scene_title 右側 -->
└── constraintEnd: parent.end (marginEnd=16dp)    <!-- X 軸：右側對齊父容器 -->
```

## 🛠️ 解決方案

### 方案 1: 使用 CustomScrollView + SliverToBoxAdapter + Stack

對於需要 x, y 軸定位的組件，使用 `Stack` + `Positioned` 來實現約束關係。

**優點**：
- 可以精確控制 x, y 軸位置
- 支持滾動

**缺點**：
- 需要手動計算位置
- 代碼較複雜

### 方案 2: 使用 Column + Row 組合 + Align

對於同一行的組件，使用 `Row`；對於垂直排列的組件，使用 `Column`。使用 `Align` 來實現垂直居中。

**優點**：
- 代碼較簡單
- 易於維護

**缺點**：
- 某些複雜的約束關係可能難以實現

### 方案 3: 使用 Stack + Positioned（推薦）

對於需要精確 x, y 軸定位的組件，使用 `Stack` + `Positioned` 來實現 ConstraintLayout 的約束關係。

**優點**：
- 可以精確控制 x, y 軸位置
- 完全對照 ConstraintLayout 的約束關係

**缺點**：
- 需要手動計算位置
- 代碼較複雜

## 📋 需要修復的內容

### 1. LED Main Page (`led_main_page.dart`)

#### 1.1 Device Info Section

**當前問題**：
- `btn_ble` 只是簡單的右對齊，沒有與 `tv_name` 和 `tv_position` 垂直居中

**需要修復**：
- 使用 `Stack` + `Positioned` 來實現 `btn_ble` 的約束關係
- `btn_ble` 應該：
  - Y 軸：與 `tv_name` 頂部對齊，與 `tv_position` 底部對齊（垂直居中於兩者之間）
  - X 軸：在 `tv_name` 右側，右側對齊父容器（marginEnd=16dp）

#### 1.2 Record Section

**當前問題**：
- `btn_record_more` 只是簡單的右對齊，沒有與 `tv_record_title` 垂直居中

**需要修復**：
- 使用 `Row` + `Align` 來實現 `btn_record_more` 的約束關係
- `btn_record_more` 應該：
  - Y 軸：與 `tv_record_title` 垂直居中
  - X 軸：在 `tv_record_title` 右側，右側對齊父容器（marginEnd=16dp）

#### 1.3 Scene Section

**當前問題**：
- `btn_scene_more` 只是簡單的右對齊，沒有與 `tv_scene_title` 垂直居中

**需要修復**：
- 使用 `Row` + `Align` 來實現 `btn_scene_more` 的約束關係
- `btn_scene_more` 應該：
  - Y 軸：與 `tv_scene_title` 垂直居中
  - X 軸：在 `tv_scene_title` 右側，右側對齊父容器（marginEnd=16dp）

### 2. 其他頁面

需要檢查所有頁面，確保 x, y 軸位置都對照 reef-b-app 的 ConstraintLayout。

## 🎯 實施計劃

### Phase 1: LED Main Page Device Info Section

1. **修復 `btn_ble` 的 x, y 軸位置**：
   - 使用 `Stack` + `Positioned` 來實現約束關係
   - 確保 `btn_ble` 與 `tv_name` 和 `tv_position` 垂直居中

### Phase 2: LED Main Page Record Section

1. **修復 `btn_record_more` 的 x, y 軸位置**：
   - 使用 `Row` + `Align` 來實現約束關係
   - 確保 `btn_record_more` 與 `tv_record_title` 垂直居中

### Phase 3: LED Main Page Scene Section

1. **修復 `btn_scene_more` 的 x, y 軸位置**：
   - 使用 `Row` + `Align` 來實現約束關係
   - 確保 `btn_scene_more` 與 `tv_scene_title` 垂直居中

### Phase 4: 其他頁面

1. **檢查所有頁面**：
   - 確保所有組件的 x, y 軸位置都對照 reef-b-app 的 ConstraintLayout

## 📝 代碼示例

### 示例 1: btn_ble 的 x, y 軸定位

```dart
// 使用 Stack + Positioned 來實現 btn_ble 的約束關係
Stack(
  children: [
    // tv_name 和 tv_position 的 Column
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // tv_name
        Text(deviceName, ...),
        // tv_position
        Text(positionName, ...),
      ],
    ),
    // btn_ble - 使用 Positioned 來實現約束關係
    Positioned(
      right: ReefSpacing.md, // marginEnd=16dp
      top: 0, // 與 tv_name 頂部對齊
      bottom: 0, // 與 tv_position 底部對齊（需要計算 tv_position 的高度）
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () => _handleBleIconTap(context, appContext),
          child: SizedBox(
            width: 48, // dp_48
            height: 32, // dp_32
            child: _buildBleStateIcon(isConnected),
          ),
        ),
      ),
    ),
  ],
)
```

### 示例 2: btn_record_more 的 x, y 軸定位

```dart
// 使用 Row + Align 來實現 btn_record_more 的約束關係
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中
  children: [
    // tv_record_title
    Expanded(
      child: Text(
        l10n.record,
        style: ReefTextStyles.bodyAccent,
      ),
    ),
    // btn_record_more
    Padding(
      padding: EdgeInsets.only(
        left: ReefSpacing.md, // marginStart=16dp
        right: ReefSpacing.md, // marginEnd=16dp
      ),
      child: IconButton(
        icon: const Icon(Icons.more_horiz),
        iconSize: 24,
        onPressed: ...,
      ),
    ),
  ],
)
```

## ✅ 檢查清單

- [ ] LED Main Page Device Info Section：`btn_ble` 的 x, y 軸位置已修復
- [ ] LED Main Page Record Section：`btn_record_more` 的 x, y 軸位置已修復
- [ ] LED Main Page Scene Section：`btn_scene_more` 的 x, y 軸位置已修復
- [ ] 所有其他頁面的 x, y 軸位置都已檢查並修復

## 📚 參考文檔

- `LED_MAIN_PAGE_LAYOUT_POSITION_ANALYSIS.md` - LED 主頁 Layout 位置對照分析
- `activity_led_main.xml` - reef-b-app 的 LED 主頁 XML layout

