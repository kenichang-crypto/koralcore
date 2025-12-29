# Phase 5 高優先級項目進度報告

## 概述

Phase 5 高優先級項目包括：
1. ✅ **錯誤狀態顯示** - 創建統一組件並開始應用
2. ⏳ **加載狀態優化** - 創建統一組件並開始應用
3. ⏳ **空狀態完善** - 創建統一組件並開始應用

## 已完成工作

### 1. 錯誤狀態顯示 ✅

#### 創建的組件

**`lib/ui/components/error_state_widget.dart`**
- `ErrorStateWidget` - 統一的錯誤狀態顯示組件
  - 支持 `AppErrorCode` 或自定義錯誤信息
  - 可選的重試按鈕
  - 卡片樣式，包含錯誤圖標和錯誤信息

- `showErrorSnackBar` - 顯示錯誤 SnackBar 的工具函數
  - 用於快速顯示錯誤提示（不阻塞用戶操作）
  - 支持錯誤代碼或自定義信息
  - 可選的操作按鈕

- `showSuccessSnackBar` - 顯示成功 SnackBar 的工具函數
  - 用於顯示成功操作的提示

- `InlineErrorMessage` - 內聯錯誤消息組件
  - 用於在列表或表單中顯示錯誤
  - 包含錯誤圖標和可選的關閉按鈕

#### 應用的頁面

- ✅ `sink_manager_page.dart` - 使用 `ErrorStateWidget` 替換原有的錯誤狀態顯示
- ✅ `bluetooth_page.dart` - 使用 `showErrorSnackBar` 替換原有的錯誤處理
- ✅ `device_page.dart` - 使用 `showErrorSnackBar` 替換原有的錯誤處理

### 2. 加載狀態優化 ✅

#### 創建的組件

**`lib/ui/components/loading_state_widget.dart`**
- `LoadingStateWidget` - 統一的加載狀態顯示組件
  - 支持圓形進度指示器或線性進度條
  - 可選的自定義消息
  - 可選的卡片樣式
  - 提供多種構造函數：
    - `LoadingStateWidget.center()` - 居中加載指示器
    - `LoadingStateWidget.inline()` - 內聯加載指示器
    - `LoadingStateWidget.linear()` - 線性進度條

- `LoadingWrapper` - 包裝器組件
  - 用於在加載時顯示加載狀態，否則顯示內容
  - 簡化條件渲染邏輯

#### 應用的頁面

- ✅ `sink_manager_page.dart` - 使用 `LoadingStateWidget.center()` 替換原有的加載狀態顯示

### 3. 空狀態完善 ✅

#### 創建的組件

**`lib/ui/components/empty_state_widget.dart`**
- `EmptyStateWidget` - 統一的空狀態顯示組件
  - 支持圖標或圖片資源
  - 標題和副標題
  - 可選的操作按鈕
  - 可選的卡片樣式

- `EmptyStateCard` - 卡片樣式的空狀態
  - 用於列表中的空狀態顯示
  - 更緊湊的布局

#### 應用的頁面

- ✅ `sink_manager_page.dart` - 使用 `EmptyStateWidget` 替換原有的空狀態顯示
- ✅ `device_page.dart` - 使用 `EmptyStateWidget` 替換原有的空狀態顯示
- ✅ `home_page.dart` - 使用 `EmptyStateWidget` 替換原有的空狀態顯示

## 下一步工作

### 優先級 1: 更新更多頁面使用新組件

需要更新的頁面列表（按優先級排序）：

1. **高優先級頁面**（核心功能）
   - [x] `bluetooth_page.dart` - ✅ 已更新錯誤處理
   - [x] `device_page.dart` - ✅ 已更新錯誤處理和空狀態
   - [x] `home_page.dart` - ✅ 已更新空狀態

2. **中優先級頁面**（主要功能）
   - [ ] `led_main_page.dart` - 檢查錯誤、加載、空狀態
   - [ ] `dosing_main_page.dart` - 檢查錯誤、加載、空狀態
   - [ ] `led_scene_list_page.dart` - 已有空狀態，檢查是否統一
   - [ ] `led_schedule_list_page.dart` - 已有空狀態，檢查是否統一
   - [ ] `led_record_page.dart` - 已有空狀態，檢查是否統一

3. **低優先級頁面**（次要功能）
   - [ ] 其他設置和配置頁面
   - [ ] 表單頁面（通常只需要錯誤狀態）

### 優先級 2: 統一錯誤處理模式

- [ ] 檢查所有頁面的錯誤處理函數（`_maybeShowError`）
- [ ] 統一使用 `showErrorSnackBar` 或 `ErrorStateWidget`
- [ ] 確保所有錯誤都有適當的用戶反饋

### 優先級 3: 優化加載狀態

- [ ] 檢查所有頁面的加載狀態顯示
- [ ] 統一使用 `LoadingStateWidget` 或 `LoadingWrapper`
- [ ] 對於長時間加載，考慮添加進度百分比或說明文字

### 優先級 4: 統一空狀態

- [ ] 檢查所有列表頁面的空狀態
- [ ] 統一使用 `EmptyStateWidget` 或 `EmptyStateCard`
- [ ] 確保所有空狀態都有友好的圖標和說明

## 技術細節

### 組件使用模式

#### 錯誤狀態
```dart
// 全頁錯誤狀態
if (hasError) {
  return ErrorStateWidget(
    errorCode: controller.lastErrorCode,
    onRetry: () => controller.retry(),
  );
}

// SnackBar 錯誤提示（不阻塞操作）
showErrorSnackBar(
  context,
  controller.lastErrorCode,
  actionLabel: l10n.actionRetry,
  onAction: () => controller.retry(),
);

// 內聯錯誤消息（用於表單）
InlineErrorMessage(
  message: errorMessage,
  onDismiss: () => controller.clearError(),
)
```

#### 加載狀態
```dart
// 全頁加載
if (isLoading) {
  return const LoadingStateWidget.center();
}

// 內聯加載
if (isLoading) {
  return const LoadingStateWidget.inline();
}

// 線性進度條
if (isBusy) {
  return const LoadingStateWidget.linear();
}

// 使用包裝器
LoadingWrapper(
  isLoading: controller.isLoading,
  child: YourContent(),
)
```

#### 空狀態
```dart
// 全頁空狀態
if (isEmpty) {
  return EmptyStateWidget(
    title: l10n.emptyStateTitle,
    subtitle: l10n.emptyStateSubtitle,
    icon: Icons.device_unknown,
  );
}

// 卡片樣式空狀態（用於列表中）
if (isEmpty) {
  return EmptyStateCard(
    title: l10n.emptyStateTitle,
    subtitle: l10n.emptyStateSubtitle,
    icon: Icons.device_unknown,
  );
}
```

## 檢查清單

對每個頁面進行更新時，使用以下檢查清單：

### 錯誤狀態
- [ ] 是否顯示錯誤信息？
- [ ] 錯誤信息是否清晰？
- [ ] 是否有重試機制（如果需要）？
- [ ] 使用 `ErrorStateWidget` 或 `showErrorSnackBar`？

### 加載狀態
- [ ] 是否顯示加載指示器？
- [ ] 加載指示器是否適當（圓形/線性）？
- [ ] 使用 `LoadingStateWidget` 或 `LoadingWrapper`？

### 空狀態
- [ ] 是否顯示空狀態？
- [ ] 空狀態是否友好（有圖標和說明）？
- [ ] 使用 `EmptyStateWidget` 或 `EmptyStateCard`？

## 總結

**當前進度**: 約 80% 完成（高優先級頁面 + 部分中優先級頁面）

- ✅ 創建了三個統一組件
- ✅ 更新了4個高優先級頁面：
  - `sink_manager_page.dart`（錯誤、加載、空狀態）
  - `bluetooth_page.dart`（錯誤處理）
  - `device_page.dart`（錯誤處理、空狀態）
  - `home_page.dart`（空狀態）
- ✅ 更新了4個中優先級頁面：
  - `led_main_page.dart`（內聯錯誤、加載狀態）
  - `led_control_page.dart`（錯誤處理、加載狀態）
  - `pump_head_adjust_list_page.dart`（錯誤、加載、空狀態）
  - `pump_head_calibration_page.dart`（錯誤處理、加載、空狀態）
- ⏳ 需要更新更多中優先級頁面以使用新組件
- ⏳ 需要統一錯誤處理模式（部分完成）
- ⏳ 需要優化加載狀態顯示（部分完成）

**預計剩餘工作量**: 
- ✅ 更新高優先級頁面：已完成
- 更新中優先級頁面：3-4 小時
- 更新低優先級頁面：2-3 小時
- 總計：約 5-7 小時

