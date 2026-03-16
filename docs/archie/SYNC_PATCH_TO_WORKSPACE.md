# 同步 ready_gate patch 到 /workspace/koralcore

若你執行環境在 `/workspace/koralcore` 且無法連 GitHub，可手動建立 patch 檔：

## 方法一：git pull（若有網路）

```bash
cd /workspace/koralcore
git pull origin main
# patch 會在 docs/ready_gate_0dc6ddf.patch
```

## 方法二：curl 下載 Raw（若有網路）

```bash
cd /workspace/koralcore
curl -L -o docs/ready_gate_0dc6ddf.patch \
  "https://raw.githubusercontent.com/kenichang-crypto/koralcore/main/docs/ready_gate_0dc6ddf.patch"
```

## 方法三：從本機複製

若 `/Users/Kaylen/Documents/GitHub/koralcore` 與 `/workspace/koralcore` 有同步：
- 本機檔案：`docs/ready_gate_0dc6ddf.patch`
- 等待同步後在 `/workspace/koralcore` 執行 apply 流程

## 方法四：在 Cursor 開啟 /workspace/koralcore

若你在 Cursor 開啟的專案路徑是 `/workspace/koralcore`，本對話的寫入會直接進入該 workspace。請用 **File > Open Folder** 開啟 `/workspace/koralcore`，再請 AI 建立 `docs/ready_gate_0dc6ddf.patch`。

## 套用流程（在 /workspace/koralcore 執行）

```bash
cd /workspace/koralcore

# 確認 patch 存在
test -f docs/ready_gate_0dc6ddf.patch && echo "OK" || echo "缺少 patch"

# 套用（base 須為 224e2ac 或相容狀態）
git apply docs/ready_gate_0dc6ddf.patch
# 或遇衝突時：
git apply --3way docs/ready_gate_0dc6ddf.patch

# 驗證
rg "session\.isReady" lib/features/led/presentation/pages/led_control_page.dart

# 提交
git add -A && git status
git commit -m "feat: ready gate for UI handlers (AUDIT-4/5)"
```
