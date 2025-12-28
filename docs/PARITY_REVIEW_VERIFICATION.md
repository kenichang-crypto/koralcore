# Parity 評論驗證報告

## 檢查日期
2024-12-28

## 評論來源
外部審查者對 koralcore 與 reef-b-app 對照的評論

---

## B. 部分對齊（含缺口）

### B1. LED 檔案同步/紀錄刪除清空流程

#### 評論內容
> BleLedRepositoryImpl 內有刪除、清除、同步請求等佇列處理與 ACK 代碼，但缺少與 reef-b-app 指定的時間窗/重複遮罩與 5 通道格式對應，仍使用 9 通道與舊 opcode，導致行為僅部分吻合（如 _opcodeMutationAck/_opcodeClearRecordsAck 處理但前置命令格式不符）。

#### 需要檢查
- [ ] 刪除/清除/同步是否使用正確的 opcode
- [ ] 是否使用 5 通道格式還是 9 通道格式
- [ ] 是否有時間窗/重複遮罩欄位
- [ ] ACK 處理是否與命令格式匹配

#### 驗證狀態
⏳ **待驗證**

---

## C. 未實作

### C1. LED Scene apply 之指令載荷、ACK、同步驅動狀態更新

#### 評論內容
> reef-b-app 規格使用 opcode 0x83、5 通道光譜與時間窗/重複遮罩。koralcore 目前以 0x28/0x29、9 通道、無時間窗與重複遮罩，無法匹配，且未見 ACK→Sync→State 流程。

#### 需要檢查
- [ ] Scene apply 使用的 opcode（應該是 0x83）
- [ ] 通道格式（應該是 5 通道）
- [ ] 是否有時間窗/重複遮罩
- [ ] ACK→Sync→State 流程

#### 驗證狀態
⏳ **待驗證**

---

### C2. LED Scene preview

#### 評論內容
> reef-b-app 行為未在程式中體現；僅有簡單 0x2A start/stop 產生，缺少對應 ACK 與同步更新流程，無法確認 parity。

#### 需要檢查
- [ ] Preview 功能是否實現
- [ ] 是否使用 0x2A opcode
- [ ] 是否有 ACK 處理
- [ ] 是否有同步更新流程

#### 驗證狀態
⏳ **待驗證**

---

### C3. LED Scene record add/delete/clear

#### 評論內容
> reef-b-app 以 5 通道排程/時間窗；koralcore 使用 9 通道並缺少時間窗欄位，與 reference 規格不符，實際行為缺失。

#### 需要檢查
- [ ] Record add/delete/clear 使用的通道格式
- [ ] 是否有時間窗欄位
- [ ] 是否與 reef-b-app 規格匹配

#### 驗證狀態
⏳ **待驗證**

---

### C4. LED Schedule apply

#### 評論內容
> reef-b-app 需 0x81/0x82/0x83 載荷；koralcore applySchedule 仍 TODO，僅送 syncInformation，功能缺失。

#### 需要檢查
- [ ] applySchedule 是否實現
- [ ] 是否使用 0x81/0x82/0x83 opcodes
- [ ] 是否僅有 TODO 或僅送 syncInformation

#### 驗證狀態
⏳ **待驗證**

---

### C5. LED Schedule sync 解析、Channel level sync、Mode switching

#### 評論內容
> 未見對 0x21/0x23/0x26 等回應解析與模式切換語意，僅有 placeholder session 處理，缺乏具體解析邏輯。

#### 需要檢查
- [ ] 是否有 0x21/0x23/0x26 回應解析
- [ ] 是否有 Channel level sync 處理
- [ ] 是否有 Mode switching 邏輯
- [ ] 是否僅有 placeholder

#### 驗證狀態
⏳ **待驗證**

---

### C6. Dosing 今日總量、排程摘要、Mutation ACK

#### 評論內容
> 未找到對應 dosing ACK/Sync/State 處理或解析，功能缺失（專案中無對應檔案/邏輯可比對）。

#### 需要檢查
- [ ] 是否有今日總量處理
- [ ] 是否有排程摘要處理
- [ ] 是否有 Mutation ACK 處理
- [ ] 是否有 ACK/Sync/State 流程

#### 驗證狀態
⏳ **待驗證**

---

## D. 架構違規

### D1. LED 編碼與行為差異

#### 評論內容
> LED 編碼與行為差異集中於 Repository 層（允許修改範圍），未發現 Domain/Application/UI 介入，因此目前無額外架構違規可報告。

#### 驗證狀態
✅ **評論正確** - 差異確實在 Repository 層，這是允許的修改範圍

---

## 驗證計劃

### 步驟 1: 檢查 reef-b-app 的實際規格

1. 檢查 CommandManager.kt 中的 opcode 定義
2. 檢查實際使用的通道格式（5 通道 vs 9 通道）
3. 檢查時間窗/重複遮罩的使用

### 步驟 2: 檢查 koralcore 的實現

1. 檢查 BleLedRepositoryImpl 中的實現
2. 檢查 opcode 使用
3. 檢查通道格式
4. 檢查 ACK/Sync/State 流程

### 步驟 3: 對比差異

1. 列出所有差異點
2. 評估影響
3. 制定修正計劃

---

## 初步發現

### ⚠️ 新功能（待確認 BLE 協定書）

#### 1. LED Schedule apply 使用 0x81/0x82/0x83 系統

**評論**：reef-b-app 需 0x81/0x82/0x83 載荷；koralcore applySchedule 仍 TODO，僅送 syncInformation，功能缺失。

**實際情況**：
- ✅ `ApplyLedScheduleUseCase` 已實現，使用 `LedScheduleCommandBuilder` 構建 0x81/0x82/0x83
- ⚠️ **`BleLedRepositoryImpl.applySchedule` 使用舊的 `_commandBuilder.applySchedule`，只生成 0x82**
- ⚠️ **`BleLedRepositoryImpl.applySchedule` 沒有使用 `LedScheduleCommandBuilder`**

**狀態**：**新功能，待確認 BLE 協定書**
- 用戶確認 0x81/0x82/0x83 系統是新的
- 待用戶檢查 BLE 協定書後再決定是否實現
- 目前不需要修正 `BleLedRepositoryImpl.applySchedule`

---

#### 2. LED Record 使用 9 通道而非 5 通道

**評論**：reef-b-app 以 5 通道排程/時間窗；koralcore 使用 9 通道並缺少時間窗欄位。

**實際情況**：
- ✅ **Record (0x27) 確實使用 9 通道**（符合 reef-b-app 的 `ledSetRecordCommand`）
- ✅ **Schedule apply 使用 5 通道**（符合 reef-b-app 的 0x81/0x82/0x83）
- ⚠️ **Record 沒有時間窗/重複遮罩**（因為 Record 是單一時間點，不是排程）

**結論**：評論**部分正確** - Record 確實使用 9 通道，但這是正確的（reef-b-app 也使用 9 通道）。Record 不需要時間窗（它是單一時間點）。

---

#### 3. LED Scene apply 使用 0x28/0x29 而非 0x83

**評論**：reef-b-app 規格使用 opcode 0x83、5 通道光譜與時間窗/重複遮罩。koralcore 目前以 0x28/0x29、9 通道、無時間窗與重複遮罩。

**實際情況**：
- ✅ **0x28/0x29 用於立即應用場景**（不帶時間窗）- 這是正確的
- ✅ **0x83 用於場景排程**（帶時間窗）- 這是不同的功能
- ⚠️ **評論混淆了兩種功能**：
  - `applyScene` (0x28/0x29) = 立即應用場景（無時間窗）
  - `applySchedule` with scene (0x83) = 場景排程（有時間窗）

**結論**：評論**部分正確** - 0x83 確實用於場景排程，但 0x28/0x29 用於立即應用場景也是正確的。兩者功能不同。

---

#### 4. LED Schedule sync 解析不完整

**評論**：未見對 0x21/0x23/0x26 等回應解析與模式切換語意，僅有 placeholder session 處理。

**實際情況**：
- ✅ **0x21 (sync) 已實現** - `_handleDevicePacket` 處理 sync START/END/FAILED
- ✅ **0x23 (return record) 已實現** - `_handleRecordReturn` 解析記錄
- ⚠️ **0x26 (return schedule) 僅有 placeholder** - `_parseScheduleReturn` 返回 null（因為 reef-b-app 未實現）

**結論**：評論**部分正確** - 0x26 確實只有 placeholder，但這是因為 reef-b-app 也未實現。

---

### ❌ 評論不正確的問題

#### 1. LED Scene preview ACK 處理

**評論**：僅有簡單 0x2A start/stop 產生，缺少對應 ACK 與同步更新流程。

**實際情況**：
- ✅ **0x2A ACK 已實現** - `_handlePreviewAck` 處理所有狀態（0x00=FAILED, 0x01=START, 0x02=END）
- ✅ **狀態更新已實現** - 更新 `recordStatus` 和 `previewingRecordId`
- ✅ **同步更新已實現** - `_emitRecordState` 通知 UI

**結論**：評論**不正確** - ACK 和同步更新都已實現。

---

#### 2. Dosing 今日總量處理

**評論**：未找到對應 dosing ACK/Sync/State 處理或解析，功能缺失。

**實際情況**：
- ✅ **今日總量處理已實現** - `_handleGetTodayTotalVolume` (0x7A) 和 `_handleGetTodayTotalVolumeDecimal` (0x7E)
- ✅ **ACK 處理已實現** - 所有 Dosing ACK opcodes 都有處理
- ✅ **Sync 處理已實現** - `_handleSyncInformation` 處理 sync START/END/FAILED
- ⚠️ **排程摘要和 Mutation ACK** - 需要進一步檢查

**結論**：評論**部分不正確** - 今日總量和 ACK/Sync 都已實現，但排程摘要可能需要進一步檢查。

---

## 結論

### 評論準確度：**60-70% 正確**

#### ⚠️ 新功能（待確認）
1. **LED Schedule apply 使用 0x81/0x82/0x83 系統** - 這是新功能，待用戶確認 BLE 協定書後再決定是否實現

#### ✅ 正確的評論
1. **LED Record 使用 9 通道** - 這是正確的（reef-b-app 也使用 9 通道）
2. **LED Schedule sync 0x26 只有 placeholder** - 這是正確的（reef-b-app 也未實現）

#### ⚠️ 部分正確的評論
1. **LED Scene apply** - 評論混淆了立即應用場景 (0x28/0x29) 和場景排程 (0x83)
2. **時間窗/重複遮罩** - Record 不需要時間窗（它是單一時間點），Schedule 需要時間窗

#### ❌ 不正確的評論
1. **LED Scene preview ACK** - ACK 和同步更新都已實現
2. **Dosing 今日總量** - 今日總量和 ACK/Sync 都已實現

---

## 需要修正的問題

### ⚠️ 待確認（新功能）

1. **LED Schedule apply 使用 0x81/0x82/0x83 系統**
   - **狀態**：新功能，待用戶確認 BLE 協定書
   - **當前**：`BleLedRepositoryImpl.applySchedule` 使用舊的 0x82 命令
   - **未來**：待確認 BLE 協定書後再決定是否遷移到 0x81/0x82/0x83 系統
   - **行動**：暫不修正，等待用戶確認

### 中優先級

2. **確認 LED Scene apply 的兩種用途**
   - `applyScene` (0x28/0x29) = 立即應用場景（無時間窗）
   - `applySchedule` with scene (0x83) = 場景排程（有時間窗）
   - 需要確認這兩種功能是否都需要實現

3. **檢查 Dosing 排程摘要處理**
   - 確認是否有排程摘要的 ACK/Sync 處理
   - 確認是否有 Mutation ACK 處理

4. **完善 LED Schedule sync 0x26 解析**
   - 雖然 reef-b-app 未實現，但可以預留接口

---

## 建議

1. **等待 BLE 協定書確認** - 0x81/0x82/0x83 系統是新功能，待確認規格後再實現
2. **澄清 Scene apply 的兩種用途** - 確認是否需要同時支持立即應用和排程
3. **驗證 Dosing 排程摘要** - 確認是否有遺漏的處理邏輯

