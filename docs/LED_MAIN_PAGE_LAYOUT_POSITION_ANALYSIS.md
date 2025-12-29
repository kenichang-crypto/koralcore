# LED 主頁 Layout 位置對照分析

## reef-b-app Layout 結構（ConstraintLayout）

### X, Y 軸位置關係

```
ConstraintLayout (根容器)
├── toolbar_led_main (include)
│   ├── constraintTop: parent.top
│   ├── constraintBottom: tv_name.top
│   ├── constraintStart: parent.start
│   └── constraintEnd: parent.end
│
├── tv_name (TextView)
│   ├── constraintTop: toolbar_led_main.bottom
│   ├── constraintBottom: tv_position.top
│   ├── constraintStart: parent.start (marginStart=16dp)
│   └── constraintEnd: btn_ble.start (marginEnd=4dp)
│
├── btn_ble (ImageView) - 48×32dp
│   ├── constraintTop: tv_name.top
│   ├── constraintBottom: tv_position.bottom
│   ├── constraintStart: tv_name.end
│   └── constraintEnd: parent.end (marginEnd=16dp)
│
├── tv_position (TextView)
│   ├── constraintTop: tv_name.bottom
│   ├── constraintBottom: tv_record_title.top
│   ├── constraintStart: tv_name.start
│   └── constraintEnd: tv_group.start
│
├── tv_group (TextView) - 可隱藏
│   ├── constraintTop: tv_position.top
│   ├── constraintBottom: tv_position.bottom
│   ├── constraintStart: tv_position.end (marginStart=4dp)
│   └── constraintEnd: btn_ble.start (marginEnd=4dp)
│
├── tv_record_title (TextView)
│   ├── constraintTop: tv_position.bottom (marginTop=20dp)
│   ├── constraintBottom: layout_record_background.top
│   ├── constraintStart: tv_name.start
│   └── constraintEnd: btn_record_more.start
│
├── btn_record_more (ImageView) - 24×24dp
│   ├── constraintTop: tv_record_title.top
│   ├── constraintBottom: tv_record_title.bottom
│   ├── constraintStart: tv_record_title.end (marginStart=16dp)
│   └── constraintEnd: parent.end (marginEnd=16dp)
│
├── layout_record_background (CardView)
│   ├── constraintTop: tv_record_title.bottom (marginTop=4dp)
│   ├── constraintBottom: tv_scene_title.top
│   ├── constraintStart: tv_record_title.start
│   └── constraintEnd: btn_record_more.end
│   │
│   └── layout_record (ConstraintLayout) - 可隱藏
│       ├── line_chart (LineChart) - height=242dp
│       │   ├── constraintTop: parent.top (margin=8dp)
│       │   ├── constraintBottom: btn_expand.top
│       │   ├── constraintStart: parent.start
│       │   └── constraintEnd: parent.end
│       │
│       ├── btn_expand (ImageView) - 24×24dp
│       │   ├── constraintTop: line_chart.bottom (marginTop=4dp)
│       │   ├── constraintBottom: parent.bottom (marginBottom=16dp)
│       │   ├── constraintStart: parent.start (marginStart=16dp)
│       │   └── constraintEnd: (未設置，默認與 start 相同)
│       │
│       ├── btn_preview (ImageView) - 24×24dp
│       │   ├── constraintTop: btn_expand.top
│       │   ├── constraintBottom: btn_expand.bottom
│       │   ├── constraintStart: (未設置)
│       │   └── constraintEnd: parent.end (marginEnd=16dp)
│       │
│       └── layout_record_pause (ConstraintLayout) - 可隱藏
│           └── btn_continue_record (MaterialButton)
│
├── tv_scene_title (TextView)
│   ├── constraintTop: layout_record_background.bottom (marginTop=24dp)
│   ├── constraintBottom: (未設置，wrap_content)
│   ├── constraintStart: tv_name.start
│   └── constraintEnd: btn_scene_more.start
│
├── btn_scene_more (ImageView) - 24×24dp
│   ├── constraintTop: tv_scene_title.top
│   ├── constraintBottom: tv_scene_title.bottom
│   ├── constraintStart: tv_scene_title.end (marginStart=16dp)
│   └── constraintEnd: parent.end (marginEnd=16dp)
│
└── rv_favorite_scene (RecyclerView)
    ├── constraintTop: tv_scene_title.bottom (marginTop=4dp)
    ├── constraintBottom: (未設置，wrap_content)
    ├── constraintStart: parent.start (paddingStart=8dp)
    └── constraintEnd: parent.end (paddingEnd=8dp)
```

### 關鍵位置約束

1. **tv_name 和 btn_ble 在同一行（Y 軸對齊）**：
   - `btn_ble.constraintTop = tv_name.top`
   - `btn_ble.constraintBottom = tv_position.bottom`（與 tv_position 底部對齊）

2. **tv_position 和 tv_group 在同一行（Y 軸對齊）**：
   - `tv_group.constraintTop = tv_position.top`
   - `tv_group.constraintBottom = tv_position.bottom`

3. **tv_record_title 和 btn_record_more 在同一行（Y 軸對齊）**：
   - `btn_record_more.constraintTop = tv_record_title.top`
   - `btn_record_more.constraintBottom = tv_record_title.bottom`

4. **tv_scene_title 和 btn_scene_more 在同一行（Y 軸對齊）**：
   - `btn_scene_more.constraintTop = tv_scene_title.top`
   - `btn_scene_more.constraintBottom = tv_scene_title.bottom`

5. **btn_expand 和 btn_preview 在同一行（Y 軸對齊）**：
   - `btn_preview.constraintTop = btn_expand.top`
   - `btn_preview.constraintBottom = btn_expand.bottom`

### 尺寸對照

| 組件 | 寬度 | 高度 | 位置 |
|------|------|------|------|
| toolbar_led_main | match_parent | wrap_content | top=0 |
| tv_name | 0dp (constrained) | wrap_content | start=16dp, top=8dp, end=btn_ble.start-4dp |
| btn_ble | 48dp | 32dp | end=16dp, 與 tv_name/tv_position 垂直居中 |
| tv_position | wrap_content | wrap_content | start=tv_name.start, top=tv_name.bottom |
| tv_group | wrap_content | wrap_content | start=tv_position.end+4dp, 與 tv_position 垂直居中 |
| tv_record_title | 0dp (constrained) | wrap_content | start=tv_name.start, top=tv_position.bottom+20dp |
| btn_record_more | 24dp | 24dp | end=16dp, 與 tv_record_title 垂直居中 |
| layout_record_background | 0dp (constrained) | wrap_content | start=tv_record_title.start, end=btn_record_more.end, top=tv_record_title.bottom+4dp |
| line_chart | match_parent | 242dp | margin=8dp |
| btn_expand | 24dp | 24dp | start=16dp, top=line_chart.bottom+4dp, bottom=16dp |
| btn_preview | 24dp | 24dp | end=16dp, 與 btn_expand 垂直居中 |
| tv_scene_title | 0dp (constrained) | wrap_content | start=tv_name.start, top=layout_record_background.bottom+24dp |
| btn_scene_more | 24dp | 24dp | end=16dp, 與 tv_scene_title 垂直居中 |
| rv_favorite_scene | match_parent | wrap_content | start=0dp (paddingStart=8dp), top=tv_scene_title.bottom+4dp |

---

## koralcore 當前實現問題

### 問題 1: 使用 ListView 只有 Y 軸排列

當前 koralcore 使用 `ListView`，所有組件都是垂直排列，無法實現 x, y 軸的約束關係。

### 問題 2: 添加了不存在的組件

koralcore 添加了以下組件，但這些在 reef-b-app 的 XML 中不存在：
- `_SceneListSection` - 不存在
- `_EntryTile` (LED Intensity/Scenes/Records/Schedule) - 不存在

**reef-b-app 的 activity_led_main.xml 只有這些組件**：
1. toolbar_led_main
2. tv_name
3. btn_ble
4. tv_position
5. tv_group
6. tv_record_title
7. btn_record_more
8. layout_record_background
9. tv_scene_title
10. btn_scene_more
11. rv_favorite_scene
12. progress

### 問題 3: X 軸位置不對應

例如：
- `btn_ble` 應該與 `tv_name` 和 `tv_position` 垂直居中，但當前實現可能只是簡單的右對齊
- `tv_group` 應該與 `tv_position` 在同一行，但當前實現可能只是簡單的 Row

---

## 解決方案

### 方案 1: 使用 CustomScrollView + SliverToBoxAdapter + Stack

對於需要 x, y 軸定位的組件，使用 `Stack` 或 `Positioned` 來實現約束關係。

### 方案 2: 使用 Column + Row 組合

對於同一行的組件，使用 `Row`；對於垂直排列的組件，使用 `Column`。

### 方案 3: 使用 ConstraintLayout 的 Flutter 等效實現

使用 `Align`、`Positioned`、`Stack` 等來實現 ConstraintLayout 的約束關係。

---

## 需要修復的內容

1. **移除不存在的組件**：
   - 移除 `_SceneListSection`
   - 移除所有 `_EntryTile`（LED Intensity/Scenes/Records/Schedule）

2. **修復 X, Y 軸位置**：
   - `btn_ble` 應該與 `tv_name` 和 `tv_position` 垂直居中
   - `tv_group` 應該與 `tv_position` 在同一行
   - `btn_record_more` 應該與 `tv_record_title` 垂直居中
   - `btn_scene_more` 應該與 `tv_scene_title` 垂直居中
   - `btn_preview` 應該與 `btn_expand` 垂直居中

3. **使用正確的布局方式**：
   - 不使用 `ListView`，改用 `CustomScrollView` + `SliverToBoxAdapter`
   - 對於需要 x, y 軸定位的組件，使用 `Stack` + `Positioned` 或 `Row` + `Align`

