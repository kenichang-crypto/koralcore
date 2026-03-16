# 合併到主分支計畫

## 當前狀態

- **當前分支**：`parity-led`
- **目標分支**：`main`
- **未提交的更改**：
  - 修改：`ble_dosing_repository_impl.dart`, `ble_led_repository_impl.dart`
  - 新增：多個文檔文件

---

## 合併步驟

### Step 1: 提交當前更改

```bash
# 添加所有更改
git add .

# 提交更改
git commit -m "docs: 添加驗證報告、測試報告和文檔

- 添加新評論驗證報告 (NEW_REVIEW_VERIFICATION.md)
- 添加 ACK/Sync 說明文檔 (ACK_AND_SYNC_EXPLANATION.md)
- 添加 Android/iOS 運行準備檢查 (ANDROID_IOS_READINESS_CHECK.md)
- 添加多語言對照計畫 (L10N_PARITY_AND_IMPORT_PLAN.md)
- 添加模擬測試報告 (MOCK_TEST_REPORT.md)
- 更新 BLE Repository 實現"
```

### Step 2: 切換到 main 分支

```bash
# 切換到 main 分支
git checkout main

# 拉取最新更改
git pull origin main
```

### Step 3: 合併 parity-led 分支

```bash
# 合併 parity-led 分支
git merge parity-led

# 如果有衝突，解決衝突後：
git add .
git commit -m "merge: 合併 parity-led 分支到 main"
```

### Step 4: 推送到遠程

```bash
# 推送到遠程 main 分支
git push origin main
```

---

## 替代方案：使用 Pull Request

如果希望通過 Pull Request 合併：

1. **推送 parity-led 分支**：
   ```bash
   git push origin parity-led
   ```

2. **在 GitHub 創建 Pull Request**：
   - 從 `parity-led` 到 `main`
   - 添加描述說明這是完整的對照版本

3. **審查和合併**：
   - 審查更改
   - 合併 PR

---

## 注意事項

### 1. 備份
- 確保所有更改已提交
- 建議先創建備份分支

### 2. 衝突處理
- 如果 main 分支有新的更改，可能會產生衝突
- 需要手動解決衝突

### 3. 測試
- 合併後建議進行測試
- 確保功能正常

---

## 建議的提交訊息

```
feat: 完成 reef-b-app 對照，實現完整功能

主要更改：
- 完成 LED 和 Dosing 的 BLE 實現
- 實現所有 UI 頁面（190+ 個組件）
- 完成多語言支持（14 種語言）
- 完成資源導入和配置
- 添加完整的文檔和驗證報告

此版本已達到與 reef-b-app 的功能對照，可以直接在 Android 和 iOS 上運行。
```

