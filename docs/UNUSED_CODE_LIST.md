# 無效/無用程式碼清單

## 📋 可刪除的內容

### 🔴 高優先級 - 舊目錄結構（完全重複）

#### 1. `lib/ui/` 整個目錄
**狀態**: ❌ 可刪除

**理由**:
- 架構重構後，所有文件已移到新結構
- `lib/ui/` 是舊架構的殘留
- 包含 95 個文件，與新架構重複

**包含的子目錄**:
- `lib/ui/app/` → 已移到 `lib/app/`
- `lib/ui/features/` → 已移到 `lib/features/`
- `lib/ui/widgets/` → 已移到 `lib/shared/widgets/`
- `lib/ui/components/` → 已移到 `lib/shared/widgets/` 或 `lib/core/ble/`
- `lib/ui/theme/` → 已移到 `lib/shared/theme/`
- `lib/ui/assets/` → 需要檢查是否仍在使用
- `lib/ui/previews/` → 預覽文件，可刪除

**影響**: 
- 刪除後不會影響新架構
- 新架構已完全替代舊架構

---

#### 2. `lib/ui/features/` 目錄
**狀態**: ❌ 可刪除

**理由**:
- 所有文件已移到 `lib/features/{feature}/presentation/`
- 與新架構完全重複

**包含的文件**:
- `lib/ui/features/home/` → `lib/features/home/presentation/`
- `lib/ui/features/device/` → `lib/features/device/presentation/`
- `lib/ui/features/led/` → `lib/features/led/presentation/`
- `lib/ui/features/dosing/` → `lib/features/dosing/presentation/`
- `lib/ui/features/bluetooth/` → `lib/features/bluetooth/presentation/`
- `lib/ui/features/splash/` → `lib/features/splash/presentation/`
- `lib/ui/features/sink/` → `lib/features/sink/presentation/`
- `lib/ui/features/warning/` → `lib/features/warning/presentation/`

---

#### 3. `lib/ui/widgets/` 目錄
**狀態**: ❌ 可刪除

**理由**:
- 所有文件已移到 `lib/shared/widgets/`
- 與新架構完全重複

**重複的文件**:
- `lib/ui/widgets/reef_app_bar.dart` → `lib/shared/widgets/reef_app_bar.dart`
- `lib/ui/widgets/reef_device_card.dart` → `lib/shared/widgets/reef_device_card.dart`
- `lib/ui/widgets/reef_backgrounds.dart` → `lib/shared/widgets/reef_backgrounds.dart`
- `lib/ui/widgets/reef_gradients.dart` → `lib/shared/widgets/reef_gradients.dart`

---

#### 4. `lib/ui/theme/` 目錄
**狀態**: ❌ 可刪除

**理由**:
- 所有文件已移到 `lib/shared/theme/`
- 使用舊類名（`ReefColors`, `ReefSpacing` 等）
- 新架構使用新類名（`AppColors`, `AppSpacing` 等）

**包含的文件**:
- `lib/ui/theme/reef_colors.dart` → `lib/shared/theme/app_colors.dart`
- `lib/ui/theme/reef_spacing.dart` → `lib/shared/theme/app_spacing.dart`
- `lib/ui/theme/reef_radius.dart` → `lib/shared/theme/app_radius.dart`
- `lib/ui/theme/reef_text.dart` → `lib/shared/theme/app_text_styles.dart`
- `lib/ui/theme/reef_theme.dart` → `lib/shared/theme/app_theme.dart`

---

#### 5. `lib/ui/components/` 目錄
**狀態**: ❌ 可刪除

**理由**:
- 架構重構後，components 已移到：
  - `lib/shared/widgets/` (UI 組件)
  - `lib/core/ble/` (BLE 相關組件，如 `ble_guard.dart`)

**包含的文件**:
- `lib/ui/components/ble_guard.dart` → `lib/core/ble/ble_guard.dart`
- `lib/ui/components/app_error_presenter.dart` → 可能已移到 `lib/shared/widgets/`

---

#### 6. `lib/ui/app/` 目錄
**狀態**: ❌ 可刪除

**理由**:
- 所有文件已移到 `lib/app/`

**包含的文件**:
- `lib/ui/app/main_scaffold.dart` → `lib/app/main_scaffold.dart`
- `lib/ui/app/navigation_controller.dart` → `lib/app/navigation_controller.dart`

---

#### 7. `lib/ui/previews/` 目錄
**狀態**: ❌ 可刪除

**理由**:
- 預覽文件，用於開發時預覽
- 不影響生產代碼
- 可以安全刪除

**包含的文件**:
- `lib/ui/previews/reef_device_card_preview.dart`

---

#### 8. `lib/theme/` 目錄（如果存在）
**狀態**: ❌ 可刪除

**理由**:
- 舊的主題目錄
- 已移到 `lib/shared/theme/`

**包含的文件**:
- `lib/theme/colors.dart` → `lib/shared/theme/app_colors.dart`
- `lib/theme/dimensions.dart` → `lib/shared/theme/app_spacing.dart`

---

### 🟡 中優先級 - 需要檢查的內容

#### 9. `lib/ui/assets/` 目錄
**狀態**: ⚠️ 需要檢查

**理由**:
- 包含 `common_icon_helper.dart` 和 `reef_icons.dart`
- 可能仍被新架構引用
- 需要確認是否仍在使用

**建議**:
- 檢查是否有文件引用 `lib/ui/assets/`
- 如果有，考慮移動到 `lib/shared/assets/` 或保留
- 如果沒有，可以刪除

**包含的文件**:
- `lib/ui/assets/common_icon_helper.dart` - 可能仍在使用
- `lib/ui/assets/reef_icons.dart` - 可能仍在使用
- `lib/ui/assets/reef_material_icons.dart` - 需要檢查

---

### 🟢 低優先級 - 空目錄

#### 10. 空目錄
**狀態**: ✅ 可刪除

**理由**:
- 空目錄沒有用處
- 不會影響編譯

**找到的空目錄**:
- `lib/core/platform/` (如果為空)
- `lib/core/utils/` (如果為空)
- `lib/core/error/` (如果為空)
- `lib/features/home/presentation/helpers/` (如果為空)
- `lib/features/home/presentation/widgets/` (如果為空)
- `lib/features/splash/presentation/controllers/` (如果為空)
- `lib/features/splash/presentation/helpers/` (如果為空)
- `lib/features/splash/presentation/widgets/` (如果為空)
- `lib/features/sink/presentation/helpers/` (如果為空)
- `lib/features/sink/presentation/widgets/` (如果為空)
- `lib/features/warning/presentation/helpers/` (如果為空)
- `lib/features/warning/presentation/widgets/` (如果為空)
- `lib/features/bluetooth/presentation/controllers/` (如果為空)
- `lib/features/bluetooth/presentation/helpers/` (如果為空)
- `lib/features/bluetooth/presentation/widgets/` (如果為空)
- `lib/features/device/presentation/helpers/` (如果為空)
- `lib/features/dosing/presentation/helpers/` (如果為空)
- `lib/features/dosing/presentation/widgets/` (如果為空)

---

## 📊 統計

### 可刪除的文件數量
- **lib/ui/** 目錄: ~95 個文件
- **lib/theme/** 目錄: ~2 個文件（如果存在）
- **總計**: ~97 個文件

### 可刪除的目錄數量
- **lib/ui/** 及其所有子目錄: ~30+ 個目錄
- **lib/theme/**: 1 個目錄（如果存在）
- **空目錄**: ~17 個目錄

---

## ⚠️ 注意事項

### 刪除前必須確認

1. ✅ **檢查 import 引用**
   - 確認沒有文件引用 `lib/ui/` 路徑
   - 確認沒有文件引用 `lib/theme/` 路徑

2. ✅ **檢查 assets**
   - 確認 `lib/ui/assets/` 中的文件是否仍在使用
   - 如果使用，先移動到新位置

3. ✅ **測試編譯**
   - 刪除前運行 `flutter analyze`
   - 刪除後運行 `flutter analyze` 確認無錯誤

4. ✅ **備份**
   - 建議先備份或提交到 git
   - 以便必要時恢復

---

## 🔧 建議的刪除順序

### 步驟 1: 檢查引用
```bash
# 檢查是否有文件引用 lib/ui/
grep -r "import.*ui/" lib/ --exclude-dir=ui

# 檢查是否有文件引用 lib/theme/
grep -r "import.*theme/" lib/ --exclude-dir=ui --exclude-dir=shared
```

### 步驟 2: 處理 assets
```bash
# 檢查 lib/ui/assets/ 是否仍在使用
grep -r "ui/assets" lib/ --exclude-dir=ui

# 如果仍在使用，先移動到 lib/shared/assets/
```

### 步驟 3: 刪除舊目錄
```bash
# 刪除 lib/ui/ 目錄（除了 assets，如果仍在使用）
rm -rf lib/ui/features/
rm -rf lib/ui/widgets/
rm -rf lib/ui/components/
rm -rf lib/ui/theme/
rm -rf lib/ui/app/
rm -rf lib/ui/previews/

# 刪除 lib/theme/ 目錄（如果存在）
rm -rf lib/theme/
```

### 步驟 4: 刪除空目錄
```bash
# 刪除所有空目錄
find lib -type d -empty -delete
```

### 步驟 5: 驗證
```bash
# 運行分析確認無錯誤
flutter analyze
```

---

**狀態**: 待確認和執行

**風險**: 低（新架構已完全替代舊架構）

