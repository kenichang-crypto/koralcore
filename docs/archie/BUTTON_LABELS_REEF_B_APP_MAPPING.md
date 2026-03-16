# 按鈕標籤 reef-b-app 對照映射表

## 審計日期
2024-12-28

## 對照原則
所有按鈕標籤必須與 reef-b-app 保持一致，使用相同的字符串資源。

---

## reef-b-app 中的字符串資源

### 1. 連接相關
- `toast_connect_successful`: "Connection successful."
- `toast_disconnect`: "Device disconnected"
- 注意：reef-b-app 中沒有專門的 "Connect" / "Disconnect" 按鈕文本，只有 toast 消息

### 2. 收藏相關
- `favorite`: "Favorite devices" (用於菜單)
- `favorite_device`: "Favorite Devices" (用於下拉選項)
- `menu_favorite`: 引用 `@string/favorite`
- **注意**：reef-b-app 中**沒有** "Favorite" / "Unfavorite" 作為工具提示的字符串資源
- **注意**：reef-b-app 中**沒有** "Device favorited" / "Device unfavorited" 的 toast 消息

### 3. 記錄相關
- `continue_record`: "Resume execution." (對應 "Continue Record" 工具提示)
- `record_pause`: "The schedule is paused."

### 4. 通用動作
- `run`: "Run" (可能用於 Play 按鈕)

---

## koralcore 中發現的硬編碼 vs reef-b-app 對照

### 1. Connect/Disconnect 工具提示
- **koralcore**: `'Connect'` / `'Disconnect'`
- **reef-b-app**: 無對應的字符串資源（只有 toast 消息）
- **koralcore 已有鍵**: `deviceActionConnect` = "Connect", `deviceActionDisconnect` = "Disconnect"
- **決定**: ✅ 使用已有的本地化鍵（因為這些是標準操作，不依賴於 reef-b-app 是否有對應）

### 2. Favorite/Unfavorite 工具提示
- **koralcore**: `'Favorite'` / `'Unfavorite'`
- **reef-b-app**: ❌ 無對應的字符串資源
- **koralcore 已有鍵**: `ledScenesActionFavorite` = "Add Favorite", `ledScenesActionUnfavorite` = "Remove Favorite"
- **決定**: ⚠️ 需要判斷是否應該使用場景的 "Add Favorite" / "Remove Favorite"，還是創建新的簡短版本

### 3. Device Favorited/Unfavorited SnackBar
- **koralcore**: `'Device favorited'` / `'Device unfavorited'`
- **reef-b-app**: ❌ 無對應的字符串資源
- **決定**: ⚠️ 需要添加新的本地化鍵（因為這是用戶操作反饋，應該有明確的消息）

### 4. Portrait/Landscape 工具提示
- **koralcore**: `'Portrait'` / `'Landscape'`
- **reef-b-app**: ❌ 無對應的字符串資源
- **決定**: ⚠️ 需要添加新的本地化鍵

### 5. Favorite Scenes 標題/副標題
- **koralcore**: `'Favorite Scenes'` / `'Your favorite scenes'`
- **reef-b-app**: ❌ 無對應的字符串資源（但可能有類似的場景相關字符串）
- **決定**: ⚠️ 需要添加新的本地化鍵或查找類似的場景相關字符串

### 6. Continue Record 工具提示
- **koralcore**: `'Continue Record'`
- **reef-b-app**: `continue_record` = "Resume execution."
- **決定**: ✅ 使用 `continue_record` 的文本（但鍵名可能需要調整）

### 7. Play 工具提示
- **koralcore**: `'Play'`
- **reef-b-app**: `run` = "Run"
- **決定**: ⚠️ 需要確認 reef-b-app 中 Play 按鈕實際使用什麼文本

---

## 修復策略

### 策略 1：完全對照 reef-b-app
- 只使用 reef-b-app 中存在的字符串資源
- 對於 reef-b-app 中沒有的，不顯示或使用圖標替代

### 策略 2：擴展但保持一致
- 對於標準操作（Connect/Disconnect），使用通用本地化鍵
- 對於 reef-b-app 中沒有的，添加新的本地化鍵，但文本要與 reef-b-app 的風格一致

### 策略 3：智能映射
- 對於有直接對應的，使用對應的字符串
- 對於沒有直接對應的，使用最接近的字符串或創建新的鍵

---

## 建議的修復方案

### 方案 A：使用已有鍵（優先）
1. **Connect/Disconnect**: 使用 `deviceActionConnect` / `deviceActionDisconnect` ✅
2. **Favorite/Unfavorite**: 使用 `ledScenesActionFavorite` / `ledScenesActionUnfavorite`（雖然是場景相關，但語義相同）

### 方案 B：添加新鍵（當沒有合適的已有鍵時）
1. **Device Favorited/Unfavorited**: 添加 `deviceFavorited` / `deviceUnfavorited`
2. **Portrait/Landscape**: 添加 `ledOrientationPortrait` / `ledOrientationLandscape`
3. **Favorite Scenes**: 添加 `ledFavoriteScenesTitle` / `ledFavoriteScenesSubtitle`
4. **Continue Record**: 使用 `continue_record` 文本（但需要檢查實際使用）

### 方案 C：參考 reef-b-app 但創建新鍵
- 對於所有沒有直接對應的，創建新的本地化鍵，文本風格與 reef-b-app 保持一致

---

## 下一步行動

1. ⏳ **確認 reef-b-app 中實際使用的文本** - 查看實際代碼實現，確認工具提示和按鈕標籤的實際文本
2. ⏳ **決定修復策略** - 選擇方案 A、B 或 C
3. ⏳ **添加缺失的本地化鍵** - 根據選擇的策略添加必要的鍵
4. ⏳ **修復所有硬編碼** - 替換所有硬編碼字符串

