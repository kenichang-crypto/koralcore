# PumpHeadDetailPage 轉換計劃

**日期**: 2026-01-03  
**狀態**: 執行中  
**從**: Parity Mode (StatelessWidget, 475 行)  
**到**: Feature Mode (StatefulWidget with Controller)  

---

## 🎯 轉換清單

### 1. 基礎結構轉換 ✓
- [ ] 添加必要的 imports (Provider, Controller, AppContext)
- [ ] StatelessWidget → StatefulWidget
- [ ] 添加 ChangeNotifierProvider wrapper
- [ ] 添加 initState 和 dispose

### 2. Toolbar 連接 ✓
- [ ] onBack: `Navigator.of(context).pop()`
- [ ] onMenu: 顯示 PopupMenu (Settings/Record/Adjust)
- [ ] title: 從 session/controller 獲取設備名稱

### 3. Drop Head Info Card 連接 ✓
- [ ] 顯示實際的 Drop Type (從 controller)
- [ ] 根據連線狀態顯示/隱藏

### 4. Record Section 連接 ✓
- [ ] onMorePressed: 導航到 Record Settings 頁面
- [ ] 顯示 Today Record Volume (從 controller.todayDoseSummary)
- [ ] 顯示 Record Type (從 controller.dosingScheduleSummary)
- [ ] 根據連線狀態顯示不同UI

### 5. Adjust Section 連接 ✓
- [ ] onMorePressed: 導航到 Adjust List 頁面
- [ ] 顯示校正歷史 (從 controller - 如有實現)
- [ ] 根據連線狀態顯示不同UI

### 6. Loading & Error 狀態 ✓
- [ ] 連接 controller.isLoading → _ProgressOverlay
- [ ] 處理 controller.lastErrorCode → SnackBar

### 7. RefreshIndicator ✓
- [ ] 添加下拉刷新功能
- [ ] 連接到 controller.refresh()

### 8. Manual Dose & Timed Dose ✓
- [ ] 添加 Action Buttons (可能在 FAB 或底部)
- [ ] 連接到 controller.sendManualDose()
- [ ] 連接到 controller.scheduleTimedDose()

---

## 📝 修改策略

### 方案 A: 完全重寫文件 ❌
- 風險高
- 可能失去 Parity 註解

### 方案 B: 逐步修改現有文件 ✅ 推薦
- 保留所有 Parity 註解
- 逐步添加功能
- 風險低

---

## 🔧 實施步驟

### Step 1: 基礎結構 (10 分鐘)
```dart
// 1. 添加 imports
import 'package:provider/provider.dart';
import '../../../../app/common/app_context.dart';
import '../controllers/pump_head_detail_controller.dart';

// 2. 創建 wrapper class
class PumpHeadDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PumpHeadDetailController(...),
      child: _PumpHeadDetailPageContent(headId: headId),
    );
  }
}

// 3. 轉換原有 class 為 StatefulWidget
class _PumpHeadDetailPageContent extends StatefulWidget {
  @override
  State<_PumpHeadDetailPageContent> createState() => ...
}
```

### Step 2: 連接狀態 (15 分鐘)
```dart
// 1. initState - 初始化 controller
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<PumpHeadDetailController>().refresh();
  });
}

// 2. 使用 Consumer/context.watch 連接狀態
final controller = context.watch<PumpHeadDetailController>();
```

### Step 3: 連接 UI 互動 (20 分鐘)
```dart
// 1. Toolbar
_ToolbarDevice(
  title: _buildTitle(controller, session),
  onBack: () => Navigator.of(context).pop(),
  onMenu: () => _showPopupMenu(context, controller),
)

// 2. Section Headers
_SectionHeader(
  title: 'Record',
  onMorePressed: () => _navigateToRecordSettings(context),
)

// 3. 其他互動...
```

### Step 4: 實現 Helper 方法 (15 分鐘)
```dart
void _showPopupMenu(BuildContext context, PumpHeadDetailController controller) {
  // PopupMenu logic
}

void _navigateToRecordSettings(BuildContext context) {
  // Navigation logic
}

String _buildTitle(PumpHeadDetailController controller, AppSession session) {
  // Title logic
}
```

---

## ⏱️ 預計時間分配

| 步驟 | 時間 | 累計 |
|------|------|------|
| Step 1: 基礎結構 | 10 min | 10 min |
| Step 2: 連接狀態 | 15 min | 25 min |
| Step 3: 連接 UI | 20 min | 45 min |
| Step 4: Helper 方法 | 15 min | 60 min |
| **總計** | **60 min** | **1 小時** |

---

**開始時間**: 2026-01-03  
**預計完成**: 1 小時後

