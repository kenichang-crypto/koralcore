# Phase 5: 細節調整和優化計劃

## 概述

Phase 5 專注於 UI 的細節優化和用戶體驗提升，包括動畫、交互細節、狀態顯示等。這些優化不是功能必需的，但能顯著提升應用的專業度和用戶體驗。

**優先級**: 低（可選，但建議完成）

**預計工作量**: 1-2 週

---

## 一、動畫和過渡效果

### 1.1 頁面轉場動畫

**目標**: 確保頁面切換時有流暢的過渡動畫

**需要檢查的頁面**:
- [ ] 主要頁面之間的導航（Home → Device, Home → LED, Home → Dosing）
- [ ] 設置頁面的進入和退出
- [ ] 表單頁面的打開和關閉

**實現方式**:
```dart
// 使用 Flutter 的標準頁面轉場
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => TargetPage(),
    // 使用默認動畫即可，Flutter 已經提供了流暢的動畫
  ),
)
```

**當前狀態**: Flutter 默認已提供 Material Design 標準頁面轉場動畫

---

### 1.2 列表動畫

**目標**: 列表項目的插入、刪除、更新時有平滑的動畫

**需要檢查的列表**:
- [ ] 設備列表（Device Page）
- [ ] LED 場景列表（LED Scene List）
- [ ] Dosing 排程列表（Dosing Schedule List）
- [ ] Warning 列表

**實現方式**:
```dart
// 使用 AnimatedList 或 ListView.builder 的內建動畫
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    // Flutter 的 ListView 已經有默認的動畫
    return YourListItem(item: items[index]);
  },
)
```

**建議優化**:
- 如果列表項需要自定義動畫，可以使用 `AnimatedList`
- 對於簡單的列表，Flutter 的默認動畫已經足夠

---

### 1.3 按鈕點擊反饋

**目標**: 按鈕點擊時有視覺反饋

**需要檢查的按鈕**:
- [ ] 主要操作按鈕（Apply, Save, Delete）
- [ ] Icon 按鈕
- [ ] 卡片點擊

**實現方式**:
```dart
// Material 3 的按鈕已經有內建的 ripple 效果
FilledButton(
  onPressed: () {},
  child: Text('Button'),
)

// 如果需要自定義，可以使用 InkWell
InkWell(
  onTap: () {},
  borderRadius: BorderRadius.circular(ReefRadius.lg),
  child: Container(...),
)
```

**當前狀態**: Material 3 組件已經提供標準的觸摸反饋

---

### 1.4 加載動畫

**目標**: 數據加載時顯示適當的加載指示器

**需要檢查的頁面**:
- [ ] 設備掃描時（Bluetooth Page）
- [ ] 數據加載時（各列表頁面）
- [ ] 表單提交時

**實現方式**:
```dart
// 使用 CircularProgressIndicator 或 LinearProgressIndicator
if (isLoading)
  Center(child: CircularProgressIndicator())
else
  YourContent()

// 或使用線性進度條
if (isLoading)
  LinearProgressIndicator()
```

**建議優化**:
- 確保所有加載狀態都有適當的視覺反饋
- 對於長時間加載，考慮添加進度百分比或說明文字

---

## 二、交互細節

### 2.1 滑動手勢

**目標**: 支持常見的滑動手勢（如下拉刷新、滑動刪除）

**需要實現的手勢**:
- [ ] 下拉刷新（Pull to Refresh）- ✅ 已在多個頁面實現
- [ ] 滑動刪除（Swipe to Delete）- ⚠️ 待檢查

**實現方式**:
```dart
// 下拉刷新
RefreshIndicator(
  onRefresh: () async {
    await controller.refresh();
  },
  child: ListView(...),
)

// 滑動刪除（使用 Dismissible）
Dismissible(
  key: Key(item.id),
  direction: DismissDirection.endToStart,
  onDismissed: (direction) {
    controller.deleteItem(item.id);
  },
  background: Container(
    color: ReefColors.danger,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: ReefSpacing.md),
    child: Icon(Icons.delete, color: ReefColors.onError),
  ),
  child: ListItem(...),
)
```

**當前狀態**: 
- ✅ 下拉刷新已在多個頁面實現
- ⚠️ 滑動刪除需要檢查並實現

---

### 2.2 長按操作

**目標**: 支持長按顯示上下文菜單或快捷操作

**需要實現的場景**:
- [ ] 設備卡片長按（顯示快捷菜單：編輯、刪除、設為最愛）
- [ ] 場景卡片長按（顯示快捷操作）
- [ ] 列表項長按（顯示更多選項）

**實現方式**:
```dart
// 使用 GestureDetector
GestureDetector(
  onLongPress: () {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildContextMenu(),
    );
  },
  child: YourCard(),
)
```

**當前狀態**: ⚠️ 需要檢查並實現

---

### 2.3 拖拽排序

**目標**: 支持拖拽重新排序（如果適用）

**需要實現的場景**:
- [ ] Sink 列表排序（如果需要）
- [ ] 場景順序調整（如果需要）
- [ ] 排程順序調整（如果需要）

**實現方式**:
```dart
// 使用 ReorderableListView
ReorderableListView(
  onReorder: (oldIndex, newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
    });
  },
  children: items.map((item) => YourListItem(key: Key(item.id), item: item)).toList(),
)
```

**當前狀態**: ⚠️ 需要確認是否需要此功能

---

### 2.4 鍵盤交互

**目標**: 優化鍵盤交互（自動聚焦、完成按鈕、鍵盤類型）

**需要檢查的表單**:
- [ ] 設備名稱輸入
- [ ] 數值輸入（Dosing 體積、LED 強度等）
- [ ] 時間選擇

**實現方式**:
```dart
TextField(
  autofocus: true, // 自動聚焦
  keyboardType: TextInputType.number, // 數字鍵盤
  textInputAction: TextInputAction.done, // 完成按鈕
  onSubmitted: (_) => _handleSubmit(), // 完成按鈕操作
)
```

**當前狀態**: ⚠️ 需要檢查並優化

---

## 三、空狀態和錯誤狀態

### 3.1 空狀態顯示

**目標**: 所有列表頁面在沒有數據時顯示友好的空狀態

**需要檢查的頁面**:
- [x] 設備列表（Device Page）- ✅ 已有空狀態
- [x] LED 場景列表 - ✅ 已有空狀態
- [x] Dosing 排程列表 - ✅ 已有空狀態
- [x] Warning 列表 - ✅ 已有空狀態
- [ ] 其他列表頁面

**實現方式**:
```dart
if (items.isEmpty)
  _EmptyState(
    icon: Icons.device_unknown,
    title: l10n.emptyStateTitle,
    subtitle: l10n.emptyStateSubtitle,
  )
else
  ListView(...)
```

**當前狀態**: ✅ 大部分頁面已有空狀態，需要檢查是否完整

---

### 3.2 錯誤狀態顯示

**目標**: 錯誤發生時顯示清晰的錯誤信息

**需要檢查的場景**:
- [ ] 網絡錯誤（BLE 連接失敗）
- [ ] 數據加載錯誤
- [ ] 表單驗證錯誤
- [ ] 操作失敗（保存、刪除等）

**實現方式**:
```dart
// 使用 SnackBar 顯示錯誤
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(l10n.errorMessage),
    backgroundColor: ReefColors.danger,
    action: SnackBarAction(
      label: l10n.actionRetry,
      onPressed: () => _retry(),
    ),
  ),
)

// 或在頁面中顯示錯誤卡片
if (hasError)
  Card(
    color: ReefColors.danger.withOpacity(0.1),
    child: Padding(
      padding: EdgeInsets.all(ReefSpacing.md),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: ReefColors.danger),
          SizedBox(width: ReefSpacing.sm),
          Expanded(child: Text(l10n.errorMessage)),
        ],
      ),
    ),
  )
```

**當前狀態**: ⚠️ 需要檢查錯誤處理的完整性

---

### 3.3 加載狀態優化

**目標**: 優化加載狀態的顯示方式

**需要優化的場景**:
- [ ] 初始加載（顯示骨架屏或加載動畫）
- [ ] 增量加載（顯示進度條或指示器）
- [ ] 背景刷新（不阻塞 UI）

**實現方式**:
```dart
// 骨架屏（可選，使用 shimmer 包）
if (isLoading)
  Shimmer(
    child: SkeletonList(),
  )
else
  YourContent()

// 或使用簡單的加載指示器
if (isLoading)
  Center(child: CircularProgressIndicator())
else
  YourContent()
```

**當前狀態**: ⚠️ 需要檢查並優化

---

## 四、視覺細節

### 4.1 圖標和插圖

**目標**: 確保所有圖標和插圖符合設計規範

**需要檢查的圖標**:
- [ ] 功能圖標（LED, Dosing, Device 等）
- [ ] 狀態圖標（連接、斷開、錯誤等）
- [ ] 操作圖標（編輯、刪除、添加等）

**當前狀態**: ⚠️ 需要檢查圖標的一致性

---

### 4.2 陰影和層次

**目標**: 使用適當的陰影和層次來區分 UI 元素

**需要檢查的元素**:
- [ ] 卡片陰影（Card elevation）
- [ ] 按鈕陰影
- [ ] AppBar 陰影（elevation: 0 已設置）
- [ ] 浮動操作按鈕（如果有）

**實現方式**:
```dart
// Material 3 使用 elevation 控制陰影
Card(
  elevation: 0, // 或適當的值
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(ReefRadius.lg),
  ),
)
```

**當前狀態**: ✅ 已統一設置 elevation: 0，符合 Material 3 設計

---

### 4.3 圓角和邊框

**目標**: 統一圓角和邊框樣式

**需要檢查的元素**:
- [x] 卡片圓角 - ✅ 已統一使用 ReefRadius
- [x] 按鈕圓角 - ✅ 已統一使用 ReefRadius
- [x] 輸入框圓角 - ✅ 已統一使用 ReefRadius
- [ ] 其他容器圓角

**當前狀態**: ✅ 已基本統一，需要最終檢查

---

### 4.4 顏色對比度

**目標**: 確保所有文字和圖標在背景上有足夠的對比度

**需要檢查的組合**:
- [ ] 主要文字在淺色背景上（✅ 已設置 textPrimary）
- [ ] 次要文字在淺色背景上（✅ 已設置 textSecondary）
- [ ] 按鈕文字在按鈕背景上（✅ 已設置 onPrimary）
- [ ] 圖標顏色

**當前狀態**: ✅ 已基本統一，建議進行可訪問性測試

---

## 五、性能優化

### 5.1 列表性能

**目標**: 優化長列表的滾動性能

**實現方式**:
```dart
// 使用 ListView.builder 而不是 ListView
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListItem(item: items[index]);
  },
)

// 如果需要，可以設置 cacheExtent
ListView.builder(
  cacheExtent: 500, // 預緩存的像素
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListItem(item: items[index]);
  },
)
```

**當前狀態**: ✅ 大部分列表已使用 ListView.builder

---

### 5.2 圖片加載

**目標**: 優化圖片加載和緩存

**需要檢查的圖片**:
- [ ] 場景圖標
- [ ] 設備圖標
- [ ] 其他資源圖片

**實現方式**:
```dart
// 使用 Image.asset 並設置適當的寬高
Image.asset(
  'assets/icons/scene.png',
  width: 32,
  height: 32,
  cacheWidth: 64, // 緩存寬度（2x）
)
```

**當前狀態**: ⚠️ 需要檢查圖片加載優化

---

### 5.3 狀態更新優化

**目標**: 避免不必要的重建

**實現方式**:
```dart
// 使用 Consumer 或 Selector 只監聽需要的狀態
Consumer<YourController>(
  builder: (context, controller, child) {
    return YourWidget(data: controller.data);
  },
)

// 或使用 Selector 只監聽特定屬性
Selector<YourController, String>(
  selector: (_, controller) => controller.name,
  builder: (context, name, child) {
    return Text(name);
  },
)
```

**當前狀態**: ⚠️ 需要檢查狀態管理優化

---

## 六、可訪問性

### 6.1 語義標籤

**目標**: 為 UI 元素添加語義標籤，支持屏幕閱讀器

**實現方式**:
```dart
// 使用 Semantics 或組件的 semanticLabel
IconButton(
  icon: Icon(Icons.delete),
  tooltip: l10n.actionDelete,
  onPressed: () {},
  // Material 組件會自動提供語義信息
)

// 對於自定義組件
Semantics(
  label: l10n.deleteButton,
  button: true,
  child: YourCustomButton(),
)
```

**當前狀態**: ⚠️ 需要檢查可訪問性支持

---

### 6.2 字體大小調整

**目標**: 支持系統字體大小設置

**實現方式**:
```dart
// Flutter 默認支持系統字體大小
// 使用 textScaleFactor 調整（如果需要）
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaleFactor: 1.0, // 固定字體大小（如果需要）
  ),
  child: YourText(),
)
```

**當前狀態**: ✅ Flutter 默認支持系統字體大小

---

## 七、實施優先級

### 🔴 高優先級（建議完成）

1. **錯誤狀態顯示** - 用戶需要知道操作是否成功
2. **加載狀態優化** - 提升用戶體驗
3. **空狀態完善** - 確保所有列表都有空狀態

### 🟡 中優先級（建議完成）

4. **滑動刪除** - 提升操作便利性
5. **長按操作** - 提供快捷操作
6. **鍵盤交互優化** - 提升表單體驗
7. **圖片加載優化** - 提升性能

### 🟢 低優先級（可選）

8. **拖拽排序** - 如果功能需要
9. **骨架屏** - 視覺優化
10. **自定義動畫** - 視覺優化
11. **可訪問性優化** - 提升包容性

---

## 八、檢查清單

對每個頁面進行 Phase 5 優化時，使用以下檢查清單：

### 動畫和過渡
- [ ] 頁面轉場流暢
- [ ] 列表動畫適當
- [ ] 按鈕點擊有反饋
- [ ] 加載動畫清晰

### 交互細節
- [ ] 下拉刷新工作正常
- [ ] 滑動刪除（如果適用）
- [ ] 長按操作（如果適用）
- [ ] 鍵盤交互優化

### 狀態顯示
- [ ] 空狀態友好
- [ ] 錯誤狀態清晰
- [ ] 加載狀態適當

### 視覺細節
- [ ] 圖標一致
- [ ] 陰影適當
- [ ] 圓角統一
- [ ] 顏色對比度足夠

### 性能
- [ ] 列表滾動流暢
- [ ] 圖片加載優化
- [ ] 狀態更新優化

---

## 九、實施建議

### 階段 1: 基礎優化（高優先級）

**時間**: 3-5 天

1. 完善錯誤狀態顯示
2. 優化加載狀態
3. 確保所有列表有空狀態
4. 實現滑動刪除（如果適用）

### 階段 2: 交互優化（中優先級）

**時間**: 3-5 天

1. 實現長按操作
2. 優化鍵盤交互
3. 圖片加載優化
4. 狀態更新優化

### 階段 3: 細節優化（低優先級）

**時間**: 2-3 天

1. 可訪問性優化
2. 拖拽排序（如果適用）
3. 骨架屏（如果需要）
4. 最終視覺檢查

---

## 十、總結

Phase 5 是可選的優化階段，主要關注：

1. **用戶體驗提升**: 通過動畫、交互細節提升應用的專業度
2. **狀態管理**: 確保所有狀態（加載、錯誤、空）都有適當的顯示
3. **性能優化**: 確保應用在各種設備上都能流暢運行
4. **可訪問性**: 確保應用對所有用戶都友好

**建議**: 根據項目時間和優先級，至少完成高優先級項目，以確保基本的用戶體驗質量。

---

## 附錄：參考資源

- [Flutter Animation Guide](https://docs.flutter.dev/ui/animations)
- [Material Design 3 Guidelines](https://m3.material.io/)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter Accessibility](https://docs.flutter.dev/ui/accessibility)

