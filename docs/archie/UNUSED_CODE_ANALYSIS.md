# 無效/無用程式碼分析報告

## 🔍 檢查結果

### 1. 舊目錄結構殘留

#### ❌ `lib/ui/` 目錄
**狀態**: 可能包含舊文件，需要檢查

**位置**: `lib/ui/`

**理由**:
- 架構重構後，所有文件應該移到新結構
- `lib/ui/` 是舊架構的殘留
- 如果仍有文件，可能是重複或未遷移的內容

**建議**: 
- 檢查 `lib/ui/` 中的文件
- 確認是否已被新架構替代
- 如果已替代，可以刪除

---

### 2. 舊類名引用

#### ❌ `ReefColors`, `ReefSpacing`, `ReefRadius`, `ReefTextStyles`, `ReefTheme`
**狀態**: 需要檢查是否仍有引用

**理由**:
- 架構重構後，這些類已重命名為 `AppColors`, `AppSpacing`, `AppRadius`, `AppTextStyles`, `AppTheme`
- 如果仍有舊類名引用，會導致編譯錯誤

**建議**:
- 搜索所有文件，確認是否仍有舊類名引用
- 如果有，需要更新為新類名

---

### 3. 舊 import 路徑

#### ❌ `import.*ui/theme/reef`
**狀態**: 需要檢查

**理由**:
- 舊路徑：`lib/ui/theme/reef_*.dart`
- 新路徑：`lib/shared/theme/app_*.dart`
- 如果仍有舊路徑引用，會導致編譯錯誤

**建議**:
- 搜索所有文件，確認是否仍有舊 import 路徑
- 如果有，需要更新為新路徑

---

### 4. 空目錄

#### ❌ 空的 `widgets/` 或 `components/` 目錄
**狀態**: 需要檢查

**理由**:
- 架構重構後，這些目錄可能已清空
- 空目錄沒有用處，可以刪除

**建議**:
- 檢查是否有空目錄
- 如果有，可以刪除

---

### 5. 重複文件

#### ❌ `lib/ui/features/` vs `lib/features/`
**狀態**: 需要檢查

**理由**:
- 如果 `lib/ui/features/` 和 `lib/features/` 都存在，可能有重複
- 應該只保留 `lib/features/` 中的文件

**建議**:
- 比較兩個目錄的內容
- 確認是否有重複
- 如果有，刪除 `lib/ui/features/` 中的文件

---

### 6. 未使用的 Helper 或 Assets

#### ❌ `lib/ui/assets/` 中的文件
**狀態**: 需要檢查

**理由**:
- 如果 `lib/ui/assets/` 中的文件仍在使用，需要保留
- 如果未被使用，可以刪除或移動

**建議**:
- 檢查 `lib/ui/assets/` 中的文件是否仍被引用
- 如果仍在使用，考慮移動到 `lib/shared/assets/` 或保留
- 如果未被使用，可以刪除

---

## 📋 待檢查項目清單

### 高優先級（可能導致編譯錯誤）

1. ✅ **舊類名引用** - `ReefColors`, `ReefSpacing`, `ReefRadius`, `ReefTextStyles`, `ReefTheme`
2. ✅ **舊 import 路徑** - `import.*ui/theme/reef`
3. ✅ **舊 import 路徑** - `import.*ui/components`
4. ✅ **舊 import 路徑** - `import.*ui/widgets`

### 中優先級（可能導致混淆）

5. ✅ **舊目錄結構** - `lib/ui/features/`
6. ✅ **舊目錄結構** - `lib/ui/components/`
7. ✅ **舊目錄結構** - `lib/ui/widgets/`
8. ✅ **舊目錄結構** - `lib/ui/theme/`

### 低優先級（清理工作）

9. ✅ **空目錄** - 檢查是否有空目錄
10. ✅ **未使用的文件** - 檢查是否有未使用的文件

---

## 🔧 建議的清理步驟

### 步驟 1: 檢查舊類名和 import
```bash
# 搜索舊類名
grep -r "ReefColors\|ReefSpacing\|ReefRadius\|ReefTextStyles\|ReefTheme" lib/

# 搜索舊 import 路徑
grep -r "import.*ui/theme\|import.*ui/components\|import.*ui/widgets" lib/
```

### 步驟 2: 檢查舊目錄
```bash
# 檢查 lib/ui/ 目錄
find lib/ui -type f -name "*.dart"

# 檢查是否有重複
diff -r lib/ui/features lib/features
```

### 步驟 3: 檢查空目錄
```bash
# 查找空目錄
find lib -type d -empty
```

### 步驟 4: 確認後刪除
- 確認舊文件已被新文件替代
- 確認沒有引用舊路徑
- 確認沒有編譯錯誤
- 然後刪除舊目錄和文件

---

**狀態**: 待檢查

**下一步**: 執行檢查命令，列出具體的無效/無用內容

