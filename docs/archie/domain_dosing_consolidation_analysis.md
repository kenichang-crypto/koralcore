# Domain Dosing 模型合併評估報告

## 當前結構

### 1. `domain/doser/` (僅 encoder 工具)
- `encoder/single_dose_encoding_utils.dart` - BLE 編碼工具
- `encoder/timed_single_dose_encoder.dart` - 定時滴液編碼器
- **用途**: 純工具類，用於 BLE 命令編碼
- **狀態**: ✅ 保持獨立（工具類不應合併）

### 2. `domain/doser_dosing/` (核心 Dosing Domain)
**主要模型**:
- `dosing_state.dart` - **核心狀態模型**，對應 `reef-b-app` 的 `DropInformation`
- `pump_head.dart` - 泵頭模型
- `pump_head_mode.dart` - 泵頭模式
- `schedule.dart` - 排程模型（舊設計）
- `doser_schedule.dart` - 排程類型定義
- `single_dose_immediate.dart` - 立即單次滴液
- `single_dose_timed.dart` - 定時單次滴液
- 其他輔助模型（`pump_speed.dart`, `time_of_day.dart`, `weekday.dart` 等）

**使用情況**:
- ✅ 被廣泛使用（`DosingState`, `PumpHead`, `PumpHeadMode` 等）
- ✅ 對應 `reef-b-app` 的 `DropInformation` 結構
- ✅ 是當前運行時的主要狀態模型

### 3. `domain/doser_schedule/` (新排程架構設計)
**主要模型**:
- `dosing_schedule_summary.dart` - 排程摘要（**唯一被 UI 使用**）
- `single_dose_plan.dart` - 單次滴液計劃
- `scheduled_dose_trigger.dart` - 排程觸發器
- `daily_average_schedule_definition.dart` - 24h 平均排程定義
- `custom_window_schedule_definition.dart` - 自定義窗口排程定義
- `schedule_weekday.dart` - 排程星期

**使用情況**:
- ⚠️ 只有 `dosing_schedule_summary.dart` 被 UI 使用
- ⚠️ 其他模型似乎是**探索性設計**（根據 `doser_schedule_architecture.md`）
- ⚠️ 狀態標記為 "exploratory design; no runtime behavior changed"

## 合併建議

### ✅ 建議合併：`doser_schedule/` → `doser_dosing/`

**理由**:

1. **概念一致性**
   - 兩者都是 dosing 相關的 domain 模型
   - `doser_schedule/` 中的模型本質上是 `doser_dosing/` 的擴展
   - 沒有明確的邊界區分

2. **使用情況**
   - `doser_dosing/` 是核心，被廣泛使用
   - `doser_schedule/` 只有一個文件被使用
   - 合併後可以統一管理所有 dosing 相關模型

3. **對照 `reef-b-app`**
   - `reef-b-app` 的 `DropInformation` 是一個統一的類
   - 包含所有 dosing 相關狀態（mode, schedule, history 等）
   - 合併後更符合 `reef-b-app` 的架構

4. **減少混淆**
   - 當前結構容易讓人困惑（為什麼有兩個 dosing 目錄？）
   - 合併後結構更清晰

### ❌ 不建議合併：`doser/` (encoder 工具)

**理由**:
- 工具類應該保持獨立
- 不屬於 domain 模型，屬於 infrastructure/encoding 層
- 保持現狀即可

## 合併方案

### 方案 1: 完全合併（推薦）

**步驟**:
1. 將 `doser_schedule/` 中的所有文件移動到 `doser_dosing/`
2. 更新所有 import 路徑
3. 刪除 `doser_schedule/` 目錄

**優點**:
- 結構最清晰
- 所有 dosing 相關模型在一個地方
- 符合 `reef-b-app` 的架構

**缺點**:
- 需要更新多個文件的 import
- 如果 `doser_schedule/` 中的某些模型是實驗性的，可能需要重新評估

### 方案 2: 部分合併（保守）

**步驟**:
1. 只移動已使用的模型（`dosing_schedule_summary.dart`）
2. 保留實驗性模型在 `doser_schedule/` 中，但標記為 `@experimental`

**優點**:
- 風險較低
- 可以逐步遷移

**缺點**:
- 結構仍然分散
- 需要維護兩個目錄

## 建議

**推薦方案 1（完全合併）**，因為：
1. `doser_schedule/` 中的模型都是 dosing 相關，應該屬於 `doser_dosing/`
2. 當前只有一個文件被使用，合併成本低
3. 即使有實驗性設計，也可以放在 `doser_dosing/` 中，用註釋標記
4. 更符合 `reef-b-app` 的統一架構

## 執行計劃

如果採用方案 1：

1. **移動文件**
   ```bash
   mv lib/domain/doser_schedule/* lib/domain/doser_dosing/
   ```

2. **更新 import 路徑**
   - 搜索所有 `import.*doser_schedule` 的引用
   - 替換為 `import.*doser_dosing`

3. **驗證**
   - 運行 linter 檢查
   - 確保所有引用正確

4. **清理**
   - 刪除 `doser_schedule/` 目錄

## 結論

**建議合併 `doser_schedule/` 到 `doser_dosing/`**，因為：
- ✅ 概念一致（都是 dosing domain）
- ✅ 結構更清晰
- ✅ 符合 `reef-b-app` 架構
- ✅ 合併成本低（只有一個文件被使用）

**不建議合併 `doser/`**，因為它是工具類，應該保持獨立。

