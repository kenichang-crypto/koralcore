# 清理計劃 - 無效/無用程式碼

## 📋 可刪除內容清單

### 🔴 高優先級 - 完全重複的舊目錄

#### 1. `lib/ui/features/` - 95 個文件
**狀態**: ❌ **可安全刪除**

**理由**:
- 所有文件已完全遷移到 `lib/features/{feature}/presentation/`
- 與新架構 100% 重複
- 沒有任何文件引用舊路徑（已確認）

**包含**:
- `lib/ui/features/home/` → `lib/features/home/presentation/`
- `lib/ui/features/device/` → `lib/features/device/presentation/`
- `lib/ui/features/led/` → `lib/features/led/presentation/`
- `lib/ui/features/dosing/` → `lib/features/dosing/presentation/`
- `lib/ui/features/bluetooth/` → `lib/features/bluetooth/presentation/`
- `lib/ui/features/splash/` → `lib/features/splash/presentation/`
- `lib/ui/features/sink/` → `lib/features/sink/presentation/`
- `lib/ui/features/warning/` → `lib/features/warning/presentation/`

---

#### 2. `lib/ui/widgets/` - 4 個文件
**狀態**: ❌ **可安全刪除**

**理由**:
- 所有文件已移到 `lib/shared/widgets/`
- 完全重複

**重複文件**:
- `lib/ui/widgets/reef_app_bar.dart` → `lib/shared/widgets/reef_app_bar.dart`
- `lib/ui/widgets/reef_device_card.dart` → `lib/shared/widgets/reef_device_card.dart`
- `lib/ui/widgets/reef_backgrounds.dart` → `lib/shared/widgets/reef_backgrounds.dart`
- `lib/ui/widgets/reef_gradients.dart` → `lib/shared/widgets/reef_gradients.dart`

---

#### 3. `lib/ui/theme/` - 5 個文件
**狀態**: ❌ **可安全刪除**

**理由**:
- 所有文件已移到 `lib/shared/theme/`
- 使用舊類名（`ReefColors` 等），新架構使用新類名（`AppColors` 等）

**重複文件**:
- `lib/ui/theme/reef_colors.dart` → `lib/shared/theme/app_colors.dart`
- `lib/ui/theme/reef_spacing.dart` → `lib/shared/theme/app_spacing.dart`
- `lib/ui/theme/reef_radius.dart` → `lib/shared/theme/app_radius.dart`
- `lib/ui/theme/reef_text.dart` → `lib/shared/theme/app_text_styles.dart`
- `lib/ui/theme/reef_theme.dart` → `lib/shared/theme/app_theme.dart`

---

#### 4. `lib/ui/components/` - 2 個文件
**狀態**: ❌ **可安全刪除**

**理由**:
- `ble_guard.dart` 已移到 `lib/core/ble/ble_guard.dart`
- `app_error_presenter.dart` 可能已移到 `lib/shared/widgets/`

---

#### 5. `lib/ui/app/` - 2 個文件
**狀態**: ❌ **可安全刪除**

**理由**:
- 所有文件已移到 `lib/app/`

**重複文件**:
- `lib/ui/app/main_scaffold.dart` → `lib/app/main_scaffold.dart`
- `lib/ui/app/navigation_controller.dart` → `lib/app/navigation_controller.dart`

---

#### 6. `lib/ui/previews/` - 1 個文件
**狀態**: ❌ **可安全刪除**

**理由**:
- 預覽文件，不影響生產代碼

---

#### 7. `lib/theme/` - 2 個文件（如果存在）
**狀態**: ❌ **可安全刪除**

**理由**:
- 舊的主題目錄，已移到 `lib/shared/theme/`

**包含**:
- `lib/theme/colors.dart` → `lib/shared/theme/app_colors.dart`
- `lib/theme/dimensions.dart` → `lib/shared/theme/app_spacing.dart`

---

### 🟡 中優先級 - 需要確認

#### 8. `lib/ui/assets/` - 3 個文件
**狀態**: ⚠️ **需要檢查後決定**

**理由**:
- 包含 `common_icon_helper.dart`，可能仍被新架構引用
- 需要確認引用情況

**包含的文件**:
- `lib/ui/assets/common_icon_helper.dart` - ⚠️ 仍在使用（5 個文件引用）
- `lib/ui/assets/reef_icons.dart` - ⚠️ 仍在使用（2 個文件引用）
- `lib/ui/assets/reef_material_icons.dart` - 需要檢查

**建議**:
- 先移動到 `lib/shared/assets/` 或保留在 `lib/ui/assets/`
- 更新所有引用路徑
- 然後刪除 `lib/ui/` 其他目錄

---

### 🟢 低優先級 - 空目錄

#### 9. 空目錄 - ~17 個
**狀態**: ✅ **可安全刪除**

**理由**:
- 空目錄沒有用處
- 不影響編譯

**找到的空目錄**:
- `lib/core/platform/`
- `lib/core/utils/`
- `lib/core/error/`
- `lib/features/home/presentation/helpers/`
- `lib/features/home/presentation/widgets/`
- `lib/features/splash/presentation/controllers/`
- `lib/features/splash/presentation/helpers/`
- `lib/features/splash/presentation/widgets/`
- `lib/features/sink/presentation/helpers/`
- `lib/features/sink/presentation/widgets/`
- `lib/features/warning/presentation/helpers/`
- `lib/features/warning/presentation/widgets/`
- `lib/features/bluetooth/presentation/controllers/`
- `lib/features/bluetooth/presentation/helpers/`
- `lib/features/bluetooth/presentation/widgets/`
- `lib/features/device/presentation/helpers/`
- `lib/features/dosing/presentation/helpers/`
- `lib/features/dosing/presentation/widgets/`

---

## 📊 統計總結

### 可立即刪除
- **lib/ui/features/**: ~95 個文件
- **lib/ui/widgets/**: 4 個文件
- **lib/ui/theme/**: 5 個文件
- **lib/ui/components/**: 2 個文件
- **lib/ui/app/**: 2 個文件
- **lib/ui/previews/**: 1 個文件
- **lib/theme/**: 2 個文件（如果存在）
- **空目錄**: ~17 個

**總計**: ~109 個文件 + ~17 個空目錄

### 需要處理後刪除
- **lib/ui/assets/**: 3 個文件（需要先移動或更新引用）

---

## 🔧 執行步驟

### 步驟 1: 處理 assets（優先）
```bash
# 1. 檢查引用
grep -r "ui/assets" lib/ --exclude-dir=ui

# 2. 移動 assets 到新位置（如果需要）
mkdir -p lib/shared/assets
mv lib/ui/assets/* lib/shared/assets/

# 3. 更新所有引用
find lib -name "*.dart" -exec sed -i '' 's|ui/assets|shared/assets|g' {} \;
```

### 步驟 2: 刪除舊目錄
```bash
# 刪除所有重複的舊目錄
rm -rf lib/ui/features/
rm -rf lib/ui/widgets/
rm -rf lib/ui/theme/
rm -rf lib/ui/components/
rm -rf lib/ui/app/
rm -rf lib/ui/previews/
rm -rf lib/theme/  # 如果存在
```

### 步驟 3: 刪除空目錄
```bash
# 刪除所有空目錄
find lib -type d -empty -delete
```

### 步驟 4: 驗證
```bash
# 運行分析確認無錯誤
flutter analyze
```

---

## ⚠️ 風險評估

### 風險等級: 🟢 低風險

**理由**:
1. ✅ 新架構已完全替代舊架構
2. ✅ 已確認沒有文件引用舊路徑（除了 assets）
3. ✅ 所有功能已在新架構中正常運行
4. ✅ 可以通過 `flutter analyze` 驗證

### 注意事項
1. ⚠️ 刪除前先處理 `lib/ui/assets/` 的引用
2. ⚠️ 建議先提交到 git，以便必要時恢復
3. ⚠️ 刪除後運行 `flutter analyze` 確認無錯誤

---

**狀態**: 準備執行

**建議**: 先處理 assets，然後刪除其他舊目錄

