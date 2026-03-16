# Entity 和 Extension 補齊/修正計畫

本文件列出需要補齊或修正的 Entity 和 Extension 項目，並提供分段修正計畫。

生成時間：2025-01-XX

---

## 一、需要補齊/修正的項目

### Entity 修正項目

#### 高優先級（功能完整性）

1. **DropHead.maxDrop 字段**
   - **問題**：`reef-b-app` 的 `DropHead` 有 `maxDrop` 字段，`koralcore` 的 `PumpHead` 沒有對應字段
   - **影響**：可能影響最大滴液量限制功能
   - **修正**：確認是否需要添加 `maxDrop` 字段，或確認 `dailyTargetMl` 是否已涵蓋此功能

2. **SinkWithDevices 數據類**
   - **問題**：`reef-b-app` 有專門的 `SinkWithDevices` 數據類，`koralcore` 只有查詢方法
   - **影響**：代碼可讀性和類型安全
   - **修正**：創建 `SinkWithDevices` domain 模型

#### 中優先級（類型一致性）

3. **Warning.id 類型**
   - **問題**：`reef-b-app` 使用 `Int`，`koralcore` 使用 `int`（實際檢查後發現也是 int）
   - **影響**：類型一致性
   - **修正**：確認當前實現是否正確（需要檢查實際代碼）

4. **Warning.time 類型**
   - **問題**：`reef-b-app` 使用 `String`，`koralcore` 使用 `DateTime`
   - **影響**：序列化/反序列化時可能需要轉換
   - **修正**：確認是否需要支持 String 格式的 time

#### 低優先級（架構差異）

5. **Device 相關數據類**
   - **問題**：`reef-b-app` 有多個數據類（DeviceReset, DeviceFavorite, DeviceDelayTime, etc.），`koralcore` 使用 Repository 方法
   - **影響**：無（架構差異，不需要修正）
   - **修正**：不需要修正，這是設計選擇

---

### Extension 補齊項目

#### 高優先級（BLE 處理必需）

1. **ByteArray.toHexString()**
   - **問題**：`reef-b-app` 有 `ByteArray.toHexString()`，`koralcore` 只有 `_toHex()` 單字節轉換
   - **影響**：BLE 調試和日誌記錄
   - **修正**：創建 `Uint8List` 和 `List<int>` 的 `toHexString()` extension

2. **Int.toBoolean() / Byte.toBoolean()**
   - **問題**：`reef-b-app` 有 `Int.toBoolean()` 和 `Byte.toBoolean()`，`koralcore` 沒有
   - **影響**：BLE 數據解析時需要頻繁轉換
   - **修正**：創建 `int.toBoolean()` extension

3. **Boolean.toByte() / Boolean.toInt()**
   - **問題**：`reef-b-app` 有 `Boolean.toByte()`，`koralcore` 沒有
   - **影響**：BLE 命令構建時需要轉換
   - **修正**：創建 `bool.toInt()` extension

#### 中優先級（便利性）

4. **DateTime.format()**
   - **問題**：`reef-b-app` 有 `Calendar.format()`，`koralcore` 使用 `DateFormat`
   - **影響**：日期格式化便利性
   - **修正**：創建 `DateTime.format()` extension（可選）

#### 低優先級（UI 特定）

5. **輸入驗證 Extension**
   - **問題**：`reef-b-app` 有 `autoTrim()` 和 `InputFilterMinMax`，`koralcore` 使用 Flutter 機制
   - **影響**：UI 輸入驗證
   - **修正**：創建 Flutter 對應的輸入驗證工具（可選）

---

## 二、分段修正計畫

### Phase 1: Extension 工具類（高優先級）

**目標**：補齊 BLE 處理必需的 extension 方法

**任務**：
1. 創建 `lib/core/extensions/byte_array_extensions.dart`
   - `Uint8List.toHexString()` - 將字節數組轉換為十六進制字符串
   - `List<int>.toHexString()` - 將整數列表轉換為十六進制字符串

2. 創建 `lib/core/extensions/int_extensions.dart`
   - `int.toBoolean()` - 將整數轉換為布爾值（0=false, 1=true, 其他=false）

3. 創建 `lib/core/extensions/bool_extensions.dart`
   - `bool.toInt()` - 將布爾值轉換為整數（true=1, false=0）

**預估時間**：1-2 小時

**驗證**：
- 在 BLE 命令構建和解析中使用這些 extension
- 確保與 `reef-b-app` 的行為一致

---

### Phase 2: Entity 字段補齊（高優先級）

**目標**：補齊缺失的 Entity 字段

**任務**：
1. **確認 DropHead.maxDrop 需求**
   - 檢查 `reef-b-app` 中 `maxDrop` 的實際用途
   - 確認是否對應 `dailyTargetMl` 或需要單獨字段
   - 如果需要，在 `PumpHead` 或相關模型中添加 `maxDrop` 字段

2. **創建 SinkWithDevices 數據類**
   - 創建 `lib/domain/sink/sink_with_devices.dart`
   - 包含 `Sink` 和 `List<Device>` 字段
   - 更新 `SinkRepository` 返回此類型

**預估時間**：2-3 小時

**驗證**：
- 確保所有使用 `SinkWithDevices` 的地方都能正常工作
- 確保數據庫查詢正確返回此類型

---

### Phase 3: Entity 類型一致性（中優先級）

**目標**：統一 Entity 類型，確保序列化/反序列化正確

**任務**：
1. **檢查 Warning 實現**
   - 確認 `Warning.id` 類型（應該是 int，不是 String）
   - 確認 `Warning.time` 是否需要支持 String 格式
   - 如果需要，添加 `fromJson`/`toJson` 方法處理類型轉換

2. **統一 ID 類型文檔**
   - 在相關 Entity 的文檔中說明 ID 類型選擇的原因
   - 確保所有 Entity 的 ID 類型使用一致

**預估時間**：1-2 小時

**驗證**：
- 確保 Warning 的序列化/反序列化正確
- 確保所有 Entity 的 ID 類型文檔完整

---

### Phase 4: 便利性 Extension（中優先級）

**目標**：添加便利性 extension 方法

**任務**：
1. **創建 DateTime.format() extension**
   - 創建 `lib/core/extensions/datetime_extensions.dart`
   - 提供 `DateTime.format(String pattern)` 方法
   - 內部使用 `DateFormat` 實現

**預估時間**：0.5-1 小時

**驗證**：
- 確保格式化結果與 `reef-b-app` 的 `Calendar.format()` 一致

---

### Phase 5: UI 輸入驗證（低優先級，可選）

**目標**：實現 Flutter 對應的輸入驗證工具

**任務**：
1. **創建輸入過濾工具**
   - 創建 `lib/ui/utils/input_filters.dart`
   - 實現類似 `autoTrim` 的輸入過濾
   - 實現類似 `InputFilterMinMax` 的範圍限制

**預估時間**：1-2 小時

**驗證**：
- 在相關 UI 頁面中使用這些工具
- 確保輸入驗證行為正確

---

## 三、詳細修正步驟

### Phase 1 詳細步驟

#### 步驟 1.1: 創建 ByteArray Extensions

**文件**：`lib/core/extensions/byte_array_extensions.dart`

```dart
library;

import 'dart:typed_data';

/// Extension for converting byte arrays to hex strings.
/// 
/// PARITY: Matches reef-b-app's ByteArrayExtension.kt
extension ByteArrayExtensions on List<int> {
  /// Converts a list of bytes to a hex string.
  /// 
  /// Format: "0xXX 0xYY 0xZZ"
  /// PARITY: Matches reef-b-app's ByteArray.toHexString()
  String toHexString() {
    if (isEmpty) {
      return '0x';
    }
    return map((byte) => '0x${(byte & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase()}').join(' ');
  }
}

/// Extension for Uint8List.
extension Uint8ListExtensions on Uint8List {
  /// Converts a Uint8List to a hex string.
  String toHexString() {
    return this.toList().toHexString();
  }
}
```

#### 步驟 1.2: 創建 Int Extensions

**文件**：`lib/core/extensions/int_extensions.dart`

```dart
library;

/// Extension for converting integers to booleans.
/// 
/// PARITY: Matches reef-b-app's IntExtension.kt
extension IntExtensions on int {
  /// Converts an integer to a boolean.
  /// 
  /// - 0 -> false
  /// - 1 -> true
  /// - other -> false
  /// 
  /// PARITY: Matches reef-b-app's Int.toBoolean()
  bool toBoolean() {
    return this == 1;
  }
}
```

#### 步驟 1.3: 創建 Bool Extensions

**文件**：`lib/core/extensions/bool_extensions.dart`

```dart
library;

/// Extension for converting booleans to integers.
/// 
/// PARITY: Matches reef-b-app's BooleanExtension.kt
extension BoolExtensions on bool {
  /// Converts a boolean to an integer.
  /// 
  /// - true -> 1
  /// - false -> 0
  /// 
  /// PARITY: Matches reef-b-app's Boolean.toByte() (returns 0x01 or 0x00)
  int toInt() {
    return this ? 1 : 0;
  }
  
  /// Converts a boolean to a byte value.
  /// 
  /// - true -> 0x01
  /// - false -> 0x00
  int toByte() {
    return toInt();
  }
}
```

---

### Phase 2 詳細步驟

#### 步驟 2.1: 添加 maxDrop 字段

**確認需求**：
- `reef-b-app` 中 `maxDrop` 用於：
  1. UI 顯示最大滴液量（`DropHeadMainActivity`）
  2. 驗證滴液量是否超過最大限制（`DropHeadRecordSettingViewModel`）
- 這是一個配置字段，用於限制每日最大滴液量
- 與 `dailyTargetMl` 不同：`dailyTargetMl` 是目標值，`maxDrop` 是上限值

**修正步驟**：
1. 在 `drop_head` 表中添加 `max_drop` 字段（INTEGER，可為 null）
   - 更新 `DatabaseHelper` 的 migration（version 7）
   - 更新 `_onCreate` 方法
2. 在 `PumpHeadRepositoryImpl` 中添加 `maxDrop` 字段的讀寫
   - 更新 `_pumpHeadFromMap` 方法
   - 更新 `_savePumpHeadToDatabase` 方法
3. 在 `PumpHead` domain 模型中添加 `maxDrop` 字段
   - 添加 `maxDrop` (int?) 字段
   - 更新 `copyWith` 方法
   - 更新 `_createDefaultHead` 方法（如果需要默認值）

#### 步驟 2.2: 創建 SinkWithDevices

**文件**：`lib/domain/sink/sink_with_devices.dart`

```dart
library;

import 'device/device.dart';  // 需要確認 Device domain 模型
import 'sink.dart';

/// Represents a Sink with its associated devices.
/// 
/// PARITY: Matches reef-b-app's SinkWithDevices.kt
class SinkWithDevices {
  final Sink sink;
  final List<Device> devices;

  const SinkWithDevices({
    required this.sink,
    required this.devices,
  });
}
```

**需要確認**：
- `Device` domain 模型是否存在
- 如果不存在，需要創建或使用現有的設備表示方式

---

### Phase 3 詳細步驟

#### 步驟 3.1: 檢查 Warning 實現

**需要檢查**：
- `Warning.id` 的實際類型（應該是 int）
- `Warning.time` 是否需要支持 String 格式的序列化

**如果需要修正**：
- 更新 `Warning` 類的 `fromJson`/`toJson` 方法
- 確保與 `reef-b-app` 的序列化格式兼容

---

### Phase 4 詳細步驟

#### 步驟 4.1: 創建 DateTime Extensions

**文件**：`lib/core/extensions/datetime_extensions.dart`

```dart
library;

import 'package:intl/intl.dart';

/// Extension for formatting DateTime.
/// 
/// PARITY: Matches reef-b-app's CalendarExtension.kt
extension DateTimeExtensions on DateTime {
  /// Formats the DateTime using the given pattern.
  /// 
  /// PARITY: Matches reef-b-app's Calendar.format(pattern)
  String format(String pattern) {
    return DateFormat(pattern).format(this);
  }
}
```

---

## 四、執行順序建議

### 第一階段（立即執行）
1. ✅ Phase 1: Extension 工具類（高優先級）
   - 這些是 BLE 處理的基礎工具，使用頻繁

### 第二階段（短期內執行）
2. ✅ Phase 2: Entity 字段補齊（高優先級）
   - 確保功能完整性

### 第三階段（中期執行）
3. ⚠️ Phase 3: Entity 類型一致性（中優先級）
   - 確保數據一致性

### 第四階段（可選）
4. ⚠️ Phase 4: 便利性 Extension（中優先級）
5. ⚠️ Phase 5: UI 輸入驗證（低優先級）

---

## 五、驗證標準

### Extension 驗證
- ✅ 所有 extension 方法都通過單元測試
- ✅ 與 `reef-b-app` 的行為完全一致
- ✅ 在現有代碼中替換手動轉換邏輯

### Entity 驗證
- ✅ 所有 Entity 字段都正確映射
- ✅ 數據庫持久化正確
- ✅ 序列化/反序列化正確
- ✅ 與 `reef-b-app` 的數據格式兼容

---

## 六、注意事項

1. **ID 類型差異**：
   - `reef-b-app` 使用 `Int`，`koralcore` 使用 `String`
   - 這是設計選擇，不需要統一
   - 但需要在文檔中說明

2. **架構差異**：
   - `reef-b-app` 使用數據類，`koralcore` 使用 Repository 模式
   - 不需要強制對齊，保持現有架構

3. **平台差異**：
   - Flutter 和 Android 的某些功能（如 Toast、EditText）無法直接對應
   - 需要實現 Flutter 對應的機制

---

## 七、優先級總結

| 階段 | 優先級 | 預估時間 | 必要性 |
|------|--------|----------|--------|
| Phase 1: Extension 工具類 | 🔴 高 | 1-2 小時 | 必需 |
| Phase 2: Entity 字段補齊 | 🔴 高 | 2-3 小時 | 必需 |
| Phase 3: Entity 類型一致性 | 🟡 中 | 1-2 小時 | 建議 |
| Phase 4: 便利性 Extension | 🟡 中 | 0.5-1 小時 | 可選 |
| Phase 5: UI 輸入驗證 | 🟢 低 | 1-2 小時 | 可選 |

**總預估時間**：5.5-10 小時

