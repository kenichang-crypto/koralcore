# 架構差異說明

## 🔍 發現的問題

### 問題 1: `lib/presentation/` 目錄不應該存在

**實際情況**:
- ✅ `lib/features/led/presentation/` - 正確
- ✅ `lib/features/sink/presentation/` - 正確
- ✅ `lib/features/warning/presentation/` - 正確
- ❌ `lib/presentation/` - **不應該存在**

**原因**:
- 正規架構應該是 `lib/features/{feature}/presentation/`
- `lib/presentation/` 是舊架構的殘留
- 只包含一個 `placeholder.dart` 文件，沒有實際用途

**解決方案**:
- 刪除 `lib/presentation/` 目錄

---

## 📋 實際架構 vs 預期架構

### ✅ 正確的部分

所有 features 的結構都是正確的：
```
lib/features/
├─ home/
│  └─ presentation/
├─ device/
│  └─ presentation/
├─ led/
│  └─ presentation/
├─ doser/
│  └─ presentation/
├─ bluetooth/
│  └─ presentation/
├─ splash/
│  └─ presentation/
├─ sink/
│  └─ presentation/
└─ warning/
   └─ presentation/
```

### ❌ 需要修正的部分

```
lib/
└─ presentation/  ← 這個不應該存在
   └─ placeholder.dart
```

---

## 🎯 IDE 顯示紅色的可能原因

1. **`lib/presentation/` 目錄存在** - 這不符合正規架構
2. **IDE 可能檢測到結構不一致** - 有些 features 有完整的子目錄，有些沒有
3. **可能缺少某些文件** - 導致 IDE 標記為錯誤

---

## 🔧 建議的修正

### 步驟 1: 刪除 `lib/presentation/`
```bash
rm -rf lib/presentation/
```

### 步驟 2: 確認所有 features 結構一致
- 檢查每個 feature 是否有 `presentation/` 目錄
- 確認 `presentation/` 下有正確的子目錄（pages, controllers, widgets, helpers, models）

---

**狀態**: 發現問題，需要修正

**影響**: 低（`lib/presentation/` 只包含 placeholder，不影響功能）

