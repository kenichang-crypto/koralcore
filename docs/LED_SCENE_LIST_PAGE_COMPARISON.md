# LED 場景列表頁面對照分析

## 📋 概述

本文檔詳細對照 reef-b-app 和 koralcore 的 LED 場景列表頁面，包括所有組件、layout、尺寸、圖標和功能。

---

## 一、Toolbar 對照

### reef-b-app: `toolbar_two_action.xml`

```xml
<androidx.constraintlayout.widget.ConstraintLayout>
    <ImageView
        android:id="@+id/btn_back"
        android:layout_width="@dimen/dp_24"
        android:layout_height="@dimen/dp_24"
        android:src="@drawable/ic_back"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent" />
    
    <TextView
        android:id="@+id/toolbar_title"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:textAppearance="@style/title1"
        app:layout_constraintStart_toEndOf="@id/btn_back"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent" />
    
    <ImageView
        android:id="@+id/btn_edit"
        android:layout_width="@dimen/dp_24"
        android:layout_height="@dimen/dp_24"
        android:src="@drawable/ic_edit"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent" />
</androidx.constraintlayout.widget.ConstraintLayout>
```

**組件**：
- `btn_back`: 24×24dp，返回按鈕
- `toolbar_title`: 標題文字（title1 樣式）
- `btn_edit`: 24×24dp，編輯按鈕（進入刪除場景頁面）

### koralcore: `ReefAppBar`

```dart
ReefAppBar(
  title: Text(l10n.ledScenesListTitle),
  actions: [
    IconButton(
      icon: const Icon(Icons.edit),
      tooltip: l10n.ledScenesActionEdit,
      onPressed: isConnected && !controller.isBusy
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LedSceneDeletePage(),
                ),
              );
            }
          : null,
    ),
  ],
)
```

**對照狀態**：

| 組件 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **返回按鈕** | btn_back (24×24dp, ic_back) | AppBar 自動提供 | ✅ |
| **標題** | toolbar_title (title1) | Text(l10n.ledScenesListTitle) | ✅ |
| **編輯按鈕** | btn_edit (24×24dp, ic_edit) | IconButton(Icons.edit) | ✅ |
| **編輯按鈕功能** | 進入 LedSceneDeleteActivity | 進入 LedSceneDeletePage | ✅ |
| **編輯按鈕啟用條件** | 未明確（可能在 ViewModel 中） | isConnected && !controller.isBusy | ⚠️ |

---

## 二、主內容區域對照

### reef-b-app: `activity_led_scene.xml`

```xml
<androidx.constraintlayout.widget.ConstraintLayout
    android:id="@+id/layout_led_scene"
    android:layout_width="match_parent"
    android:layout_height="0dp"
    android:paddingStart="@dimen/dp_16"
    android:paddingTop="@dimen/dp_14"
    android:paddingEnd="@dimen/dp_16"
    android:paddingBottom="@dimen/dp_14"
    app:layout_constraintTop_toBottomOf="@id/toolbar_led_scene"
    app:layout_constraintBottom_toBottomOf="parent">

    <!-- 動態場景標題 -->
    <TextView
        android:id="@+id/tv_dynamic_scene"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:text="@string/led_dynamic_scene"
        android:textAppearance="@style/body_accent"
        android:textColor="@color/text_aaaa"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintBottom_toTopOf="@id/rv_dynamic_scene" />

    <!-- 動態場景列表 -->
    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rv_dynamic_scene"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        app:layout_constraintTop_toBottomOf="@id/tv_dynamic_scene"
        app:layout_constraintStart_toStartOf="@id/tv_dynamic_scene"
        app:layout_constraintEnd_toEndOf="@id/tv_dynamic_scene"
        app:layout_constraintBottom_toTopOf="@id/tv_static_scene" />

    <!-- 靜態場景標題 -->
    <TextView
        android:id="@+id/tv_static_scene"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_marginTop="@dimen/dp_24"
        android:text="@string/led_static_scene"
        android:textAppearance="@style/body_accent"
        android:textColor="@color/text_aaaa"
        app:layout_constraintTop_toBottomOf="@id/rv_dynamic_scene"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toStartOf="@id/btn_add_scene"
        app:layout_constraintBottom_toTopOf="@id/rv_static_scene" />

    <!-- 添加場景按鈕 -->
    <ImageView
        android:id="@+id/btn_add_scene"
        android:layout_width="@dimen/dp_24"
        android:layout_height="@dimen/dp_24"
        android:layout_marginStart="@dimen/dp_16"
        android:src="@drawable/ic_add_btn"
        app:layout_constraintTop_toTopOf="@id/tv_static_scene"
        app:layout_constraintBottom_toBottomOf="@id/tv_static_scene"
        app:layout_constraintStart_toEndOf="@id/tv_static_scene"
        app:layout_constraintEnd_toEndOf="parent" />

    <!-- 靜態場景列表 -->
    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/rv_static_scene"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        app:layout_constraintTop_toBottomOf="@id/tv_static_scene"
        app:layout_constraintStart_toStartOf="@id/tv_static_scene"
        app:layout_constraintEnd_toEndOf="@id/btn_add_scene" />
</androidx.constraintlayout.widget.ConstraintLayout>
```

**Layout 結構**：
- 根容器：`layout_led_scene` (ConstraintLayout)
  - padding: 16/14/16/14dp
  - 約束：top = toolbar.bottom, bottom = parent.bottom
- 動態場景標題：`tv_dynamic_scene`
  - 樣式：body_accent, text_aaaa
  - 約束：top = parent.top, bottom = rv_dynamic_scene.top
- 動態場景列表：`rv_dynamic_scene` (RecyclerView)
  - 約束：top = tv_dynamic_scene.bottom, bottom = tv_static_scene.top
- 靜態場景標題：`tv_static_scene`
  - marginTop: 24dp
  - 樣式：body_accent, text_aaaa
  - 約束：top = rv_dynamic_scene.bottom, end = btn_add_scene.start
- 添加場景按鈕：`btn_add_scene` (ImageView)
  - 尺寸：24×24dp
  - marginStart: 16dp
  - 圖標：ic_add_btn
  - 約束：top/bottom = tv_static_scene.top/bottom, start = tv_static_scene.end
- 靜態場景列表：`rv_static_scene` (RecyclerView)
  - 約束：top = tv_static_scene.bottom, start/end = tv_static_scene/btn_add_scene

### koralcore: `LedSceneListPage`

```dart
body: ReefMainBackground(
  child: SafeArea(
    child: RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: EdgeInsets.only(
          left: ReefSpacing.md, // dp_16
          top: 14, // dp_14
          right: ReefSpacing.md, // dp_16
          bottom: 14, // dp_14
        ),
        children: [
          // 副標題
          Text(l10n.ledScenesListSubtitle, ...),
          SizedBox(height: ReefSpacing.md),
          
          // 頻譜圖表（如果有）
          if (controller.currentChannelLevels.isNotEmpty) ...[
            LedSpectrumChart.fromChannelMap(...),
            SizedBox(height: ReefSpacing.md),
          ],
          
          // BLE 連接提示（如果未連接）
          if (!isConnected) ...[
            BleGuardBanner(),
            SizedBox(height: ReefSpacing.xl),
          ],
          
          // 動態場景區塊
          if (controller.dynamicScenes.isNotEmpty) ...[
            Text(l10n.ledDynamicScene, ...),
            SizedBox(height: ReefSpacing.xs),
            ...controller.dynamicScenes.map((scene) => _SceneCard(...)),
            SizedBox(height: ReefSpacing.md),
          ],
          
          // 靜態場景區塊
          if (controller.staticScenes.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.ledStaticScene, ...),
                if (isConnected && !controller.isBusy)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => Navigator.push(LedSceneAddPage()),
                  ),
              ],
            ),
            SizedBox(height: ReefSpacing.xs),
            ...controller.staticScenes.map((scene) => _SceneCard(...)),
          ],
        ],
      ),
    ),
  ),
)
```

**對照狀態**：

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **根容器 padding** | 16/14/16/14dp | 16/14/16/14dp | ✅ |
| **動態場景標題** | tv_dynamic_scene (body_accent, text_aaaa) | Text(l10n.ledDynamicScene) | ✅ |
| **動態場景列表** | rv_dynamic_scene (RecyclerView) | ...dynamicScenes.map(_SceneCard) | ✅ |
| **靜態場景標題** | tv_static_scene (body_accent, text_aaaa, marginTop=24dp) | Text(l10n.ledStaticScene) | ⚠️ |
| **添加場景按鈕位置** | btn_add_scene (24×24dp, 與 tv_static_scene 同一行) | IconButton(Icons.add, 在 Row 中) | ✅ |
| **靜態場景列表** | rv_static_scene (RecyclerView) | ...staticScenes.map(_SceneCard) | ✅ |
| **RefreshIndicator** | ❌ 無 | ✅ 有 | ⚠️ |
| **副標題** | ❌ 無 | ✅ Text(l10n.ledScenesListSubtitle) | ⚠️ |
| **頻譜圖表** | ❌ 無 | ✅ LedSpectrumChart | ⚠️ |
| **BLE 連接提示** | ❌ 無 | ✅ BleGuardBanner | ⚠️ |

---

## 三、場景卡片對照

### reef-b-app: `adapter_scene.xml`

```xml
<com.google.android.material.card.MaterialCardView
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginTop="@dimen/dp_8"
    app:cardBackgroundColor="@color/bg_aaa"
    app:cardCornerRadius="@dimen/dp_8"
    app:cardElevation="0dp"
    app:strokeWidth="2dp"
    app:strokeColor="@color/bg_primary">

    <androidx.constraintlayout.widget.ConstraintLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:paddingStart="@dimen/dp_8"
        android:paddingTop="@dimen/dp_6"
        android:paddingEnd="@dimen/dp_12"
        android:paddingBottom="@dimen/dp_6">

        <!-- 場景圖標 -->
        <ImageView
            android:id="@+id/img_icon"
            android:layout_width="@dimen/dp_24"
            android:layout_height="@dimen/dp_24"
            android:src="@drawable/ic_moon"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintBottom_toBottomOf="parent" />

        <!-- 場景名稱 -->
        <TextView
            android:id="@+id/tv_name"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_marginStart="@dimen/dp_8"
            android:textAppearance="@style/body"
            android:textColor="@color/text_aaaa"
            app:layout_constraintStart_toEndOf="@id/img_icon"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintEnd_toStartOf="@id/btn_play" />

        <!-- 播放按鈕 -->
        <ImageView
            android:id="@+id/btn_play"
            android:layout_width="@dimen/dp_20"
            android:layout_height="@dimen/dp_20"
            android:layout_marginStart="@dimen/dp_8"
            android:src="@drawable/ic_play_unselect"
            app:layout_constraintStart_toEndOf="@id/tv_name"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintEnd_toStartOf="@id/btn_favorite" />

        <!-- 喜愛按鈕 -->
        <ImageView
            android:id="@+id/btn_favorite"
            android:layout_width="@dimen/dp_20"
            android:layout_height="@dimen/dp_20"
            android:layout_marginStart="@dimen/dp_8"
            android:src="@drawable/ic_favorite_unselect"
            app:layout_constraintStart_toEndOf="@id/btn_play"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintBottom_toBottomOf="parent"
            app:layout_constraintEnd_toEndOf="parent" />
    </androidx.constraintlayout.widget.ConstraintLayout>
</com.google.android.material.card.MaterialCardView>
```

**組件尺寸和樣式**：
- CardView:
  - marginTop: 8dp
  - backgroundColor: bg_aaa (#F7F7F7)
  - cornerRadius: 8dp
  - elevation: 0dp
  - strokeWidth: 2dp (當選中時)
  - strokeColor: bg_primary (#6F916F)
- ConstraintLayout (內容):
  - padding: 8/6/12/6dp
- img_icon: 24×24dp
- tv_name: body 樣式, text_aaaa 顏色, marginStart=8dp
- btn_play: 20×20dp, marginStart=8dp
- btn_favorite: 20×20dp, marginStart=8dp

### koralcore: `_SceneCard`

```dart
Card(
  color: ReefColors.surfaceMuted, // bg_aaa
  elevation: 0, // dp_0
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(ReefSpacing.xs), // dp_8
    side: BorderSide(
      color: isActive ? ReefColors.primary : Colors.transparent,
      width: isActive ? 2 : 0, // strokeWidth 2 when active
    ),
  ),
  margin: EdgeInsets.only(top: ReefSpacing.xs), // dp_8 marginTop
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(ReefSpacing.xs),
    child: Padding(
      padding: EdgeInsets.only(
        left: ReefSpacing.xs, // dp_8 paddingStart
        top: ReefSpacing.sm, // dp_6 paddingTop
        right: ReefSpacing.md, // dp_12 paddingEnd
        bottom: ReefSpacing.sm, // dp_6 paddingBottom
      ),
      child: Row(
        children: [
          // Icon (img_icon) - 24×24dp
          SizedBox(
            width: 24, // dp_24
            height: 24, // dp_24
            child: Icon(sceneIcon, size: 24, ...),
          ),
          SizedBox(width: ReefSpacing.xs), // dp_8 marginStart
          // Name (tv_name) - body, text_aaaa
          Expanded(
            child: Text(
              sceneName,
              style: ReefTextStyles.body.copyWith(
                color: ReefColors.textPrimary, // text_aaaa
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: ReefSpacing.xs), // dp_8 marginStart
          // Play button (btn_play) - 20×20dp
          IconButton(
            icon: Image.asset(...),
            onPressed: onApply,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 20,
              minHeight: 20,
            ),
          ),
          SizedBox(width: ReefSpacing.xs), // dp_8 marginStart
          // Favorite button (btn_favorite) - 20×20dp
          if (isConnected && !controller.isBusy)
            IconButton(
              icon: Image.asset(...),
              onPressed: () => controller.toggleFavoriteScene(scene.id),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
            ),
        ],
      ),
    ),
  ),
)
```

**對照狀態**：

| 項目 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **Card marginTop** | 8dp | 8dp | ✅ |
| **Card backgroundColor** | bg_aaa (#F7F7F7) | ReefColors.surfaceMuted | ✅ |
| **Card cornerRadius** | 8dp | 8dp | ✅ |
| **Card elevation** | 0dp | 0dp | ✅ |
| **Card strokeWidth** | 2dp (選中時) | 2 (isActive 時) | ✅ |
| **Card strokeColor** | bg_primary (#6F916F) | ReefColors.primary | ✅ |
| **內容 padding** | 8/6/12/6dp | 8/6/12/6dp | ✅ |
| **圖標尺寸** | 24×24dp | 24×24dp | ✅ |
| **圖標 marginStart** | 0dp (在 ConstraintLayout 中) | 0dp (Row 中) | ✅ |
| **名稱樣式** | body, text_aaaa | ReefTextStyles.body, textPrimary | ✅ |
| **名稱 marginStart** | 8dp | 8dp (SizedBox) | ✅ |
| **播放按鈕尺寸** | 20×20dp | 20×20dp | ✅ |
| **播放按鈕 marginStart** | 8dp | 8dp (SizedBox) | ✅ |
| **喜愛按鈕尺寸** | 20×20dp | 20×20dp | ✅ |
| **喜愛按鈕 marginStart** | 8dp | 8dp (SizedBox) | ✅ |
| **卡片點擊** | ❌ 無（只有按鈕可點擊） | ✅ InkWell.onTap (進入編輯頁面) | ⚠️ |

---

## 四、圖標對照

### reef-b-app 圖標

| 圖標 | 資源名稱 | 尺寸 | 用途 |
|------|---------|------|------|
| **返回** | ic_back | 24×24dp | Toolbar 返回按鈕 |
| **編輯** | ic_edit | 24×24dp | Toolbar 編輯按鈕 |
| **添加** | ic_add_btn | 24×24dp | 靜態場景標題旁的添加按鈕 |
| **播放（未選中）** | ic_play_unselect | 20×20dp | 場景卡片播放按鈕 |
| **播放（選中）** | ic_play_select | 20×20dp | 場景卡片播放按鈕（當前場景） |
| **喜愛（未選中）** | ic_favorite_unselect | 20×20dp | 場景卡片喜愛按鈕 |
| **喜愛（選中）** | ic_favorite_select | 20×20dp | 場景卡片喜愛按鈕 |
| **場景圖標** | ic_moon, ic_thunder, ic_none, ic_custom | 24×24dp | 場景卡片圖標 |

### koralcore 圖標

| 圖標 | 資源名稱 | 尺寸 | 用途 |
|------|---------|------|------|
| **返回** | AppBar 自動提供 | - | Toolbar 返回按鈕 |
| **編輯** | Icons.edit | - | Toolbar 編輯按鈕 |
| **添加** | Icons.add | - | 靜態場景標題旁的添加按鈕 |
| **播放（未選中）** | ic_play_unselect.png (fallback: Icons.play_arrow_outlined) | 20×20dp | 場景卡片播放按鈕 |
| **播放（選中）** | ic_play_select.png (fallback: Icons.play_arrow) | 20×20dp | 場景卡片播放按鈕（當前場景） |
| **喜愛（未選中）** | ic_favorite_unselect.png (fallback: Icons.favorite_border) | 20×20dp | 場景卡片喜愛按鈕 |
| **喜愛（選中）** | ic_favorite_select.png (fallback: Icons.favorite) | 20×20dp | 場景卡片喜愛按鈕 |
| **場景圖標** | _sceneIcon() (Material Icons) | 24×24dp | 場景卡片圖標 |

**對照狀態**：

| 圖標 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **返回** | ic_back (24×24dp) | AppBar 自動 | ✅ |
| **編輯** | ic_edit (24×24dp) | Icons.edit | ⚠️ |
| **添加** | ic_add_btn (24×24dp) | Icons.add | ⚠️ |
| **播放（未選中）** | ic_play_unselect (20×20dp) | ic_play_unselect.png (fallback) | ⚠️ |
| **播放（選中）** | ic_play_select (20×20dp) | ic_play_select.png (fallback) | ⚠️ |
| **喜愛（未選中）** | ic_favorite_unselect (20×20dp) | ic_favorite_unselect.png (fallback) | ⚠️ |
| **喜愛（選中）** | ic_favorite_select (20×20dp) | ic_favorite_select.png (fallback) | ⚠️ |
| **場景圖標** | ic_moon, ic_thunder, etc. (24×24dp) | Material Icons | ⚠️ |

---

## 五、功能對照

### reef-b-app 功能

1. **返回按鈕** (`btn_back`)
   - 功能：`finish()` 關閉 Activity

2. **編輯按鈕** (`btn_edit`)
   - 功能：進入 `LedSceneDeleteActivity`
   - 啟用條件：未明確（可能在 ViewModel 中）

3. **添加場景按鈕** (`btn_add_scene`)
   - 功能：檢查是否可以添加（最多 5 個自訂場景），如果可以則進入 `LedSceneAddActivity`
   - 啟用條件：未明確（可能在 ViewModel 中）

4. **場景卡片點擊** (`onClickScene`)
   - 功能：進入 `LedSceneEditActivity`，傳遞 `scene_id`

5. **播放按鈕** (`onClickPlayScene`)
   - 功能：調用 `viewModel.clickSceneBtnPlay(data)`，應用場景

6. **喜愛按鈕** (`onClickFavoriteScene`)
   - 功能：調用 `viewModel.favoriteScene(data)`，切換喜愛狀態

### koralcore 功能

1. **返回按鈕**
   - 功能：AppBar 自動處理，關閉頁面

2. **編輯按鈕**
   - 功能：進入 `LedSceneDeletePage`
   - 啟用條件：`isConnected && !controller.isBusy`

3. **添加場景按鈕** (FloatingActionButton 和靜態場景標題旁的 IconButton)
   - 功能：進入 `LedSceneAddPage`
   - 啟用條件：`isConnected && !controller.isBusy`

4. **場景卡片點擊** (`onTap`)
   - 功能：進入 `LedSceneEditPage`，傳遞 `sceneId`
   - 啟用條件：`isConnected && !controller.isBusy`

5. **播放按鈕** (`onApply`)
   - 功能：調用 `controller.applyScene(scene.id)`
   - 啟用條件：`isConnected && !controller.isBusy && scene.isEnabled && !scene.isActive`

6. **喜愛按鈕** (`toggleFavoriteScene`)
   - 功能：調用 `controller.toggleFavoriteScene(scene.id)`
   - 啟用條件：`isConnected && !controller.isBusy`

**對照狀態**：

| 功能 | reef-b-app | koralcore | 狀態 |
|------|-----------|-----------|------|
| **返回** | finish() | AppBar 自動 | ✅ |
| **編輯** | 進入 LedSceneDeleteActivity | 進入 LedSceneDeletePage | ✅ |
| **添加場景（FAB）** | ❌ 無 | ✅ FloatingActionButton | ⚠️ |
| **添加場景（靜態場景標題旁）** | btn_add_scene (24×24dp) | IconButton(Icons.add) | ✅ |
| **場景卡片點擊** | 進入 LedSceneEditActivity | 進入 LedSceneEditPage | ✅ |
| **播放按鈕** | clickSceneBtnPlay() | applyScene() | ✅ |
| **喜愛按鈕** | favoriteScene() | toggleFavoriteScene() | ✅ |

---

## 六、差異分析

### 1. koralcore 特有功能

1. **RefreshIndicator**：下拉刷新功能（reef-b-app 沒有）
2. **副標題**：`ledScenesListSubtitle`（reef-b-app 沒有）
3. **頻譜圖表**：`LedSpectrumChart`（reef-b-app 沒有）
4. **BLE 連接提示**：`BleGuardBanner`（reef-b-app 沒有）
5. **FloatingActionButton**：添加場景的浮動按鈕（reef-b-app 沒有）

### 2. 圖標差異

- koralcore 使用 Material Icons 作為 fallback，但嘗試加載自定義圖標
- reef-b-app 使用自定義 drawable 資源

### 3. Layout 差異

- reef-b-app 使用 ConstraintLayout，有明確的 x, y 軸約束
- koralcore 使用 ListView + Column/Row，主要是垂直排列

### 4. 功能差異

- koralcore 的場景卡片可以點擊進入編輯頁面（reef-b-app 沒有）
- koralcore 有 FloatingActionButton 用於添加場景（reef-b-app 沒有）

---

## 七、需要修復的問題

### 1. 移除 koralcore 特有功能（如果需要完全對照）

- [ ] 移除 RefreshIndicator（如果不需要）
- [ ] 移除副標題（如果不需要）
- [ ] 移除頻譜圖表（如果不需要）
- [ ] 移除 BLE 連接提示（如果不需要）
- [ ] 移除 FloatingActionButton（如果不需要）

### 2. 對照圖標資源

- [ ] 確認所有自定義圖標資源是否存在
- [ ] 如果不存在，需要添加或使用正確的 Material Icons

### 3. 對照 Layout 位置

- [ ] 確保靜態場景標題和添加按鈕在同一行（x 軸對齊）
- [ ] 確保所有組件的 margin/padding 完全對照

### 4. 對照功能啟用條件

- [ ] 確認編輯按鈕的啟用條件是否與 reef-b-app 一致
- [ ] 確認添加場景按鈕的啟用條件是否與 reef-b-app 一致

---

## 八、總結

### ✅ 已對照

1. 基本 layout 結構（動態場景、靜態場景）
2. 場景卡片的基本結構和樣式
3. 基本功能（編輯、添加、播放、喜愛）

### ⚠️ 部分對照

1. 圖標資源（使用 Material Icons 作為 fallback）
2. Layout 位置（使用 ListView 而非 ConstraintLayout）
3. 功能啟用條件（可能不完全一致）

### ❌ 未對照（koralcore 特有）

1. RefreshIndicator
2. 副標題
3. 頻譜圖表
4. BLE 連接提示
5. FloatingActionButton

---

## 九、建議

1. **確認是否需要移除 koralcore 特有功能**：根據用戶需求決定是否保留
2. **對照圖標資源**：確認所有自定義圖標是否存在，如果不存在則使用 Material Icons
3. **對照 Layout 位置**：如果需要完全對照，考慮使用 Stack + Positioned 來實現 ConstraintLayout 的約束關係
4. **對照功能啟用條件**：檢查 reef-b-app 的 ViewModel 邏輯，確保啟用條件一致

