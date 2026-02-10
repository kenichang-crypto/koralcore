# L3 Icon 違規修正 - 決策建議

## 🚨 當前狀況

- **已完成**: 階段 1（新增 5 個 CommonIconHelper 方法）+ 部分階段 2（2/31 處替換）
- **剩餘**: 29 處 Material Icons 違規
- **預估時間**: 手動替換需 2-3 小時

---

## 🎯 三種修正方案

### 方案 A：批量腳本替換（最快）⚡

**優點**:
- ✅ 10 分鐘內完成所有替換
- ✅ 一致性高
- ✅ 可重複執行

**缺點**:
- ⚠️ 需手動調整部分參數（size, color）
- ⚠️ 需逐一驗證

**執行方式**:
```bash
# 創建替換腳本
cat > fix_icons.sh << 'EOF'
#!/bin/bash
cd /Users/Kaylen/Documents/GitHub/koralcore

# 替換所有明確對應的 Material Icons
find lib/features -name "*.dart" -type f -exec sed -i '' \
  -e 's/Icon(Icons\.arrow_back/Icon(CommonIconHelper.getBackIcon()/g' \
  -e 's/Icon(Icons\.calendar_today/Icon(CommonIconHelper.getCalendarIcon()/g' \
  -e 's/Icon(Icons\.navigate_next/Icon(CommonIconHelper.getNextIcon()/g' \
  -e 's/Icon(Icons\.arrow_drop_down/Icon(CommonIconHelper.getDownIcon()/g' \
  -e 's/Icon(Icons\.add,/Icon(CommonIconHelper.getAddIcon(),/g' \
  -e 's/Icon(Icons\.remove/Icon(CommonIconHelper.getMinusIcon()/g' \
  -e 's/Icon(Icons\.play_arrow/Icon(CommonIconHelper.getPlayIcon()/g' \
  -e 's/Icon(Icons\.add_circle_outline/Icon(CommonIconHelper.getAddBtnIcon()/g' \
  -e 's/Icon(Icons\.more_horiz/Icon(CommonIconHelper.getMoreEnableIcon()/g' \
  -e 's/Icon(Icons\.check,/Icon(CommonIconHelper.getCheckIcon(),/g' \
  -e 's/Icon(Icons\.water_drop/Icon(CommonIconHelper.getDropIcon()/g' \
  -e 's/Icon(Icons\.nightlight_round/Icon(CommonIconHelper.getMoonRoundIcon()/g' \
  -e 's/Icon(Icons\.lightbulb/Icon(CommonIconHelper.getLedIcon()/g' \
  {} \;

echo "✅ 替換完成！請執行 flutter analyze 檢查"
EOF

chmod +x fix_icons.sh
./fix_icons.sh
```

---

### 方案 B：分批手動替換（穩妥）🔧

**優點**:
- ✅ 精確控制每一處
- ✅ 確保參數正確
- ✅ 易於回滾

**缺點**:
- ❌ 耗時 2-3 小時
- ❌ 容易疲勞出錯

**執行方式**:
按模組分批處理：
1. Dosing 模組（6 處）- 30 分鐘
2. LED 模組（23 處）- 2 小時
3. Device 模組（2 處）- 10 分鐘

---

### 方案 C：先標註 TODO，暫緩替換（延後）📋

**優點**:
- ✅ 不阻塞其他 L0-L2 層工作
- ✅ 可在後續 PR 中處理

**缺點**:
- ❌ L3 層評分維持在 78%
- ❌ 技術債累積

**執行方式**:
```dart
// 在所有 Material Icons 上方標註
// TODO(L3): Replace with CommonIconHelper.getXxxIcon()
// VIOLATION: Material Icons not allowed (L3 Rule)
Icon(Icons.calendar_today, size: 24)
```

---

## 🎯 推薦方案

### 推薦：**方案 A（批量腳本替換）**

**理由**:
1. ✅ 效率最高（10 分鐘 vs 2-3 小時）
2. ✅ 18/31 處可直接替換（已有對應方法）
3. ✅ 剩餘 13 處需查證的可先標註 TODO
4. ✅ 可立即將 L3 評分從 78% 提升至 90%+

**執行步驟**:
1. **立即執行**: 批量替換 18 處可立即修正的
2. **後續處理**: 查證 Android 並處理剩餘 13 處
3. **驗證**: `flutter analyze` + 手動檢查參數

---

## 📊 方案對比

| 方案 | 時間 | L3 評分 | 風險 | 推薦度 |
|------|------|---------|------|--------|
| **A. 批量腳本** | 10 分鐘 | 90%+ | 低（需驗證） | ⭐⭐⭐⭐⭐ |
| **B. 手動替換** | 2-3 小時 | 100% | 極低 | ⭐⭐⭐ |
| **C. 標註 TODO** | 5 分鐘 | 78% | 無 | ⭐⭐ |

---

## ✅ 最終建議

**採用方案 A + 部分方案 C**:

1. **立即執行方案 A**: 批量替換 18 處可立即修正的 Material Icons
2. **標註 TODO**: 對剩餘 13 處需查證的 Material Icons 標註 `TODO(L3)`
3. **產出報告**: 更新 L3 評分至 90%+，標註剩餘待辦項目

**預期成果**:
- ⏱️ 總耗時: **15 分鐘**
- 📊 L3 評分: **78% → 90%+**
- ✅ 18/31 處完全合規
- 📋 13/31 處標註 TODO（待後續處理）

---

**請問您選擇哪個方案？**
- **A**: 批量腳本替換（推薦）
- **B**: 手動逐一替換
- **C**: 標註 TODO 暫緩

或是我直接執行**方案 A + 部分方案 C**？

