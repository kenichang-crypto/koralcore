# 如何推送到 GitHub

## 前置檢查

### 1. 確認 Git 倉庫狀態

```bash
# 檢查當前狀態
git status

# 查看遠程倉庫
git remote -v

# 查看當前分支
git branch
```

---

## 推送步驟

### 步驟 1: 檢查更改

```bash
# 查看所有更改
git status

# 查看具體更改內容
git diff
```

### 步驟 2: 添加文件到暫存區

#### 添加所有更改
```bash
git add .
```

#### 或選擇性添加
```bash
# 添加特定文件
git add <文件路徑>

# 添加特定目錄
git add lib/ui/features/

# 添加所有 .dart 文件
git add "*.dart"
```

### 步驟 3: 提交更改

```bash
# 提交並添加提交訊息
git commit -m "描述你的更改"

# 例如：
git commit -m "完成 UI 頁面實現和資源導入"
git commit -m "添加 iOS 圖標配置和 XML drawable 轉換"
git commit -m "完成資源連結驗證和測試"
```

#### 詳細提交訊息（推薦）

```bash
git commit -m "完成 UI 頁面實現和資源導入

- 實現所有 34 個 UI 頁面
- 導入所有圖片資源和應用圖標
- 完成 iOS 圖標配置
- 轉換 XML drawable 為 Flutter Widget
- 添加資源連結驗證測試
- 更新文檔"
```

### 步驟 4: 推送到 GitHub

#### 首次推送（如果還沒有遠程倉庫）

```bash
# 添加遠程倉庫
git remote add origin https://github.com/你的用戶名/koralcore.git

# 或使用 SSH
git remote add origin git@github.com:你的用戶名/koralcore.git
```

#### 推送到主分支

```bash
# 推送到 main 分支
git push origin main

# 或推送到 master 分支（如果使用 master）
git push origin master
```

#### 推送到其他分支

```bash
# 創建新分支
git checkout -b feature/ui-pages

# 推送新分支
git push origin feature/ui-pages

# 或設置上游分支
git push -u origin feature/ui-pages
```

---

## 完整流程示例

### 示例 1: 推送所有更改到 main 分支

```bash
# 1. 檢查狀態
git status

# 2. 添加所有更改
git add .

# 3. 提交
git commit -m "完成 UI 頁面實現和資源導入"

# 4. 推送
git push origin main
```

### 示例 2: 分階段提交

```bash
# 1. 只提交文檔更改
git add docs/
git commit -m "更新文檔：添加 UI 頁面概覽和資源連結驗證"

# 2. 提交代碼更改
git add lib/
git commit -m "完成 UI 頁面實現"

# 3. 提交資源文件
git add assets/ ios/android/
git commit -m "導入圖片資源和應用圖標"

# 4. 一次性推送所有提交
git push origin main
```

---

## 常見問題處理

### 問題 1: 遠程倉庫有新的更改

如果遠程倉庫有新的提交，需要先拉取：

```bash
# 拉取遠程更改
git pull origin main

# 如果有衝突，解決衝突後再提交
git add .
git commit -m "解決合併衝突"
git push origin main
```

### 問題 2: 推送被拒絕

```bash
# 強制推送（不推薦，除非確定）
git push -f origin main

# 更好的方式：先拉取再推送
git pull --rebase origin main
git push origin main
```

### 問題 3: 忘記添加文件

```bash
# 如果已經提交但忘記添加文件
git add <遺漏的文件>
git commit --amend --no-edit
git push origin main
```

### 問題 4: 修改最後一次提交

```bash
# 修改最後一次提交訊息
git commit --amend -m "新的提交訊息"

# 如果已經推送，需要強制推送
git push -f origin main
```

---

## 最佳實踐

### 1. 提交前檢查

```bash
# 檢查將要提交的內容
git diff --cached

# 檢查代碼格式
flutter analyze

# 運行測試
flutter test
```

### 2. 有意義的提交訊息

- 使用清晰的描述
- 說明更改的原因和內容
- 遵循約定（如 Conventional Commits）

### 3. 分階段提交

- 相關的更改一起提交
- 不要一次提交太多不相關的更改
- 文檔和代碼可以分開提交

### 4. 定期推送

- 不要累積太多本地提交
- 定期推送到遠程倉庫
- 避免長時間的本地開發

---

## 安全提示

### 1. 不要提交敏感信息

檢查以下文件是否包含敏感信息：
- API 密鑰
- 密碼
- 個人信息
- 配置文件中的敏感數據

### 2. 使用 .gitignore

確保 `.gitignore` 包含：
```
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/

# IDE
.idea/
.vscode/
*.iml

# 環境變量
.env
.env.local

# 系統文件
.DS_Store
Thumbs.db
```

### 3. 檢查提交內容

```bash
# 查看將要提交的文件
git status

# 查看具體更改
git diff
```

---

## 快速命令參考

```bash
# 查看狀態
git status

# 添加所有更改
git add .

# 提交
git commit -m "提交訊息"

# 推送
git push origin main

# 拉取
git pull origin main

# 查看提交歷史
git log --oneline

# 查看遠程倉庫
git remote -v

# 查看分支
git branch -a
```

---

## 推薦工作流程

### 日常開發流程

```bash
# 1. 開始工作前，拉取最新更改
git pull origin main

# 2. 創建功能分支（可選）
git checkout -b feature/新功能

# 3. 進行開發和測試
# ... 編寫代碼 ...

# 4. 檢查更改
git status
git diff

# 5. 添加更改
git add .

# 6. 提交
git commit -m "描述更改"

# 7. 推送
git push origin main
# 或推送分支
git push origin feature/新功能
```

---

## 總結

**最簡單的推送流程**：

```bash
git add .
git commit -m "你的提交訊息"
git push origin main
```

**記住**：
- 推送前先檢查 `git status`
- 使用有意義的提交訊息
- 定期推送，不要累積太多本地提交
- 推送前運行 `flutter analyze` 檢查代碼

