# 批量 Import 更新進度

## 更新策略

由於文件數量較多（71個），採用分批更新策略：

1. **優先更新關鍵文件**（home, device, splash）
2. **批量更新主題和類名引用**
3. **更新剩餘 features**

---

## 已更新文件

### ✅ 已完成

1. **lib/features/home/presentation/pages/home_page.dart**
   - ✅ 更新主題 import
   - ✅ 更新 widgets import
   - ✅ 更新 components import
   - ✅ 更新 features 之間的 import
   - ✅ 更新類名引用（ReefColors → AppColors 等）

2. **lib/features/device/presentation/pages/device_page.dart**
   - ✅ 更新 BLE import
   - ✅ 更新主題 import
   - ✅ 更新 widgets import
   - ✅ 更新 components import
   - ✅ 更新 features 之間的 import
   - ✅ 更新類名引用

---

## 待更新文件

### 需要更新的文件類型

1. **主題相關** (~20 個文件)
   - 需要更新：`import '../../theme/reef_*.dart'` → `import '../../../../shared/theme/app_*.dart'`
   - 需要更新類名：`ReefColors` → `AppColors` 等

2. **Widget 相關** (~15 個文件)
   - 需要更新：`import '../../widgets/...'` → `import '../../../../shared/widgets/...'`

3. **Components 相關** (~10 個文件)
   - 需要更新：`import '../../components/...'` → `import '../../../../shared/widgets/...'` 或 `import '../../../../core/ble/...'`

4. **Features 之間的 import** (~30 個文件)
   - 需要調整相對路徑

5. **Assets 相關** (~5 個文件)
   - 需要確認：`lib/ui/assets/` 是否應該移動到 `lib/shared/assets/` 或保持原樣

---

## 更新規則總結

### Import 路徑更新

| 舊路徑 | 新路徑 | 相對路徑調整 |
|--------|--------|-------------|
| `../../theme/reef_colors.dart` | `../../../../shared/theme/app_colors.dart` | +2 層級 |
| `../../widgets/...` | `../../../../shared/widgets/...` | +2 層級 |
| `../../components/...` | `../../../../shared/widgets/...` 或 `../../../../core/ble/...` | +2 層級 |
| `../led/pages/...` | `../../led/presentation/pages/...` | 調整結構 |
| `../device/controllers/...` | `../../device/presentation/controllers/...` | 調整結構 |

### 類名更新

| 舊類名 | 新類名 |
|--------|--------|
| `ReefColors` | `AppColors` |
| `ReefSpacing` | `AppSpacing` |
| `ReefRadius` | `AppRadius` |
| `ReefTextStyles` | `AppTextStyles` |
| `ReefTheme` | `AppTheme` |

---

## 下一步

1. 繼續更新剩餘的 features 文件
2. 處理 assets 路徑問題
3. 測試編譯

---

**進度**: 2/71 文件已更新 (~3%)

