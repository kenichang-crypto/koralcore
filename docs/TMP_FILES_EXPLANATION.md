# .tmp 文件說明

## 什麼是 .tmp 文件？

`.tmp` 文件是 **Flutter 本地化生成過程中的臨時文件**。

### 生成過程

當運行 `flutter gen-l10n` 時，Flutter 工具會：

1. **讀取 ARB 文件**（`intl_*.arb`）
2. **生成臨時文件**（`app_localizations_*.dart.tmp`）
3. **驗證和處理**
4. **重命名為最終文件**（`app_localizations_*.dart`）

### 為什麼會有 .tmp 文件？

- **原子性操作**：確保生成過程不會產生不完整的文件
- **錯誤恢復**：如果生成失敗，不會破壞現有文件
- **並發安全**：多個生成過程可以安全並行運行

---

## 是否可以刪除？

### ✅ 可以安全刪除

`.tmp` 文件是**臨時文件**，可以安全刪除：

1. **不會影響功能**：最終使用的是 `.dart` 文件，不是 `.tmp` 文件
2. **會自動重新生成**：下次運行 `flutter gen-l10n` 時會重新創建
3. **不應該提交到 Git**：這些是生成過程的副產品

---

## 已執行的操作

### ✅ 1. 刪除所有 .tmp 文件

已刪除以下臨時文件：
- `app_localizations_ar.dart.tmp`
- `app_localizations_de.dart.tmp`
- `app_localizations_es.dart.tmp`
- `app_localizations_id.dart.tmp`
- `app_localizations_ja.dart.tmp`
- `app_localizations_ko.dart.tmp`
- `app_localizations_pt.dart.tmp`
- `app_localizations_ru.dart.tmp`
- `app_localizations_th.dart.tmp`
- `app_localizations_vi.dart.tmp`

### ✅ 2. 更新 .gitignore

已將 `*.tmp` 加入 `.gitignore`，確保這些臨時文件不會被提交到版本控制。

---

## 建議

### ✅ 最佳實踐

1. **刪除 .tmp 文件**：定期清理，或使用腳本自動清理
2. **加入 .gitignore**：避免提交臨時文件到版本控制
3. **不需要手動管理**：Flutter 工具會自動處理

### 📝 清理腳本（可選）

如果需要定期清理，可以創建一個腳本：

```bash
#!/bin/bash
# clean_tmp.sh
find lib/l10n -name "*.tmp" -type f -delete
echo "已清理所有 .tmp 文件"
```

---

## 總結

- ✅ **.tmp 文件可以安全刪除**
- ✅ **已刪除所有 .tmp 文件**
- ✅ **已加入 .gitignore**
- ✅ **不會影響功能**

這些文件是生成過程的臨時產物，不需要保留。

