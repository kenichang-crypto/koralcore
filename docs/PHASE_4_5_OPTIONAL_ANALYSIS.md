# Phase 4-5 可選性分析

本文檔說明為什麼 Phase 4（DateTime.format()）和 Phase 5（UI 輸入驗證）是可選的，以及 Flutter 是否已經有現成的解決方案。

生成時間：2025-01-XX

---

## 一、Phase 4: DateTime.format() Extension

### reef-b-app 的實現

```kotlin
// CalendarExtension.kt
fun Calendar.format(pattern: String): String {
    return SimpleDateFormat(pattern).format(this.time)
}
```

### Flutter/Dart 的現有解決方案

#### 1. **intl 包（已包含在 koralcore）**

`koralcore` 的 `pubspec.yaml` 已經包含 `intl: ^0.20.2`，可以直接使用：

```dart
import 'package:intl/intl.dart';

// 直接使用 DateFormat
final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
String formatted = formatter.format(DateTime.now());
```

#### 2. **koralcore 中的實際使用**

在 `Warning` 類中已經有手動實現的格式化方法：

```dart
// lib/domain/warning/warning.dart
String _formatTime(DateTime dt) {
  return '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';
}
```

### 為什麼是可選的？

1. **Flutter 已有標準解決方案**：
   - `DateFormat` 類功能完整，支持多種格式
   - 已經包含在 `intl` 包中，無需額外依賴

2. **使用方式已經很簡單**：
   ```dart
   // 現有方式（已經很簡潔）
   DateFormat('yyyy-MM-dd').format(dateTime)
   
   // Extension 方式（只是稍微簡化）
   dateTime.format('yyyy-MM-dd')
   ```

3. **不是功能必需**：
   - 只是語法糖，不影響功能
   - 現有代碼已經可以正常工作

### 建議

**可以不做**，因為：
- ✅ Flutter 已經有 `DateFormat` 類
- ✅ 使用方式已經很簡單
- ✅ 不是功能必需，只是便利性

**如果要做**，好處是：
- 與 `reef-b-app` 的 API 更一致
- 語法稍微簡潔一些

---

## 二、Phase 5: UI 輸入驗證工具

### reef-b-app 的實現

#### 1. autoTrim() - 禁止輸入空格

```kotlin
// EdittextExtension.kt
fun autoTrim(editText: EditText) {
    editText.addTextChangedListener(object : TextWatcher {
        override fun onTextChanged(p0: CharSequence?, ...) {
            if (p0.toString().contains(" ")) {
                // 移除空格
            }
        }
    })
}
```

#### 2. InputFilterMinMax - 限制輸入範圍

```kotlin
// InputFilterMinMax.kt
class InputFilterMinMax : InputFilter {
    override fun filter(...): CharSequence? {
        val input = (dest.toString() + source.toString()).toInt()
        if (isInRange(min, max, input)) return null
        return ""
    }
}
```

### Flutter/Dart 的現有解決方案

#### 1. **TextInputFormatter（Flutter 內建）**

Flutter 提供了 `TextInputFormatter` 類來實現輸入過濾：

```dart
import 'package:flutter/services.dart';

// 禁止空格
TextInputFormatter.withFunction((oldValue, newValue) {
  if (newValue.text.contains(' ')) {
    return oldValue; // 拒絕包含空格的輸入
  }
  return newValue;
})

// 或使用 FilteringTextInputFormatter
FilteringTextInputFormatter.deny(RegExp(r'\s')) // 禁止空格
```

#### 2. **範圍限制**

```dart
// 限制數字範圍
TextInputFormatter.withFunction((oldValue, newValue) {
  final value = int.tryParse(newValue.text);
  if (value != null && value >= min && value <= max) {
    return newValue;
  }
  return oldValue;
})
```

#### 3. **koralcore 中的實際使用**

檢查代碼發現，koralcore 的 UI 頁面已經在使用 `TextEditingController`：

```dart
// 在 UI 頁面中
final TextEditingController _controller = TextEditingController();

TextField(
  controller: _controller,
  inputFormatters: [
    // 可以在這裡添加過濾器
  ],
)
```

### 為什麼是可選的？

1. **Flutter 已有標準解決方案**：
   - `TextInputFormatter` 類功能完整
   - `FilteringTextInputFormatter` 提供常用過濾器
   - 無需額外依賴

2. **使用方式已經很簡單**：
   ```dart
   // 現有方式（已經很簡潔）
   TextField(
     inputFormatters: [
       FilteringTextInputFormatter.deny(RegExp(r'\s')), // 禁止空格
     ],
   )
   ```

3. **不是功能必需**：
   - 只是便利性工具
   - 現有代碼已經可以正常工作

### 建議

**可以不做**，因為：
- ✅ Flutter 已經有 `TextInputFormatter` 類
- ✅ `FilteringTextInputFormatter` 提供常用過濾器
- ✅ 使用方式已經很簡單
- ✅ 不是功能必需，只是便利性

**如果要做**，好處是：
- 與 `reef-b-app` 的 API 更一致
- 可以封裝常用模式為工具類
- 代碼更統一

---

## 三、總結對照表

| 項目 | reef-b-app | Flutter 現有方案 | koralcore 狀態 | 是否必需 |
|------|------------|------------------|----------------|----------|
| DateTime.format() | Calendar.format() | DateFormat.format() | ✅ 已使用 DateFormat | ❌ 可選 |
| autoTrim() | EditText extension | FilteringTextInputFormatter | ⚠️ 未統一使用 | ❌ 可選 |
| InputFilterMinMax | InputFilter 類 | TextInputFormatter | ⚠️ 未統一使用 | ❌ 可選 |

---

## 四、建議決策

### 選項 1：不做（推薦）

**理由**：
1. Flutter 已經有標準解決方案
2. 使用方式已經很簡單
3. 不是功能必需
4. 減少代碼維護成本

**適用場景**：
- 項目時間緊迫
- 現有代碼已經可以正常工作
- 不需要與 `reef-b-app` 的 API 完全一致

### 選項 2：做（可選）

**理由**：
1. 與 `reef-b-app` 的 API 更一致
2. 可以封裝常用模式為工具類
3. 代碼更統一

**適用場景**：
- 需要與 `reef-b-app` 保持高度一致
- 有額外時間進行優化
- 希望代碼更統一

---

## 五、如果選擇做的話

### Phase 4: DateTime Extension

```dart
// lib/core/extensions/datetime_extensions.dart
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String format(String pattern) {
    return DateFormat(pattern).format(this);
  }
}
```

**使用**：
```dart
DateTime.now().format('yyyy-MM-dd HH:mm:ss');
```

### Phase 5: 輸入驗證工具

```dart
// lib/ui/utils/input_formatters.dart
import 'package:flutter/services.dart';

class InputFormatters {
  /// 禁止輸入空格
  static TextInputFormatter autoTrim() {
    return FilteringTextInputFormatter.deny(RegExp(r'\s'));
  }
  
  /// 限制數字範圍
  static TextInputFormatter minMax(int min, int max) {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final value = int.tryParse(newValue.text);
      if (value != null && value >= min && value <= max) {
        return newValue;
      }
      return oldValue;
    });
  }
}
```

**使用**：
```dart
TextField(
  inputFormatters: [
    InputFormatters.autoTrim(),
    InputFormatters.minMax(1, 500),
  ],
)
```

---

## 六、最終建議

**建議：可以不做**

原因：
1. ✅ Flutter 已經有完整的解決方案
2. ✅ 使用方式已經很簡單
3. ✅ 不是功能必需
4. ✅ 減少代碼維護成本

**如果未來需要**：
- 可以在需要時再實現
- 不會影響現有功能
- 可以逐步遷移

---

## 七、與 reef-b-app 的對照

| 功能 | reef-b-app | Flutter 對應 | 是否需要實現 |
|------|------------|--------------|--------------|
| Calendar.format() | ✅ Extension | ✅ DateFormat | ❌ 不需要 |
| autoTrim() | ✅ Extension | ✅ FilteringTextInputFormatter | ❌ 不需要 |
| InputFilterMinMax | ✅ 類 | ✅ TextInputFormatter | ❌ 不需要 |

**結論**：Flutter 已經有對應的標準解決方案，不需要額外實現。

