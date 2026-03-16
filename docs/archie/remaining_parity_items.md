# 剩餘需要對照的項目

## 一、命令構建器（Command Builder）

### reef-b-app Android 的命令構建方法

reef-b-app Android 的 `CommandManager.kt` 提供了以下 Dosing 命令構建方法：

1. **getDropTimeCorrectionCommand()** - 0x60
2. **getDropSyncInformationCommand()** - 0x65
3. **getDropSetDelayTimeCommand(second: Int)** - 0x61
4. **getDropSetRotatingSpeedCommand(no: Int, speed: Int)** - 0x62
5. **getDropManualDropStartCommand(no: Int)** - 0x63
6. **getDropManualDropEndCommand(no: Int)** - 0x64
7. **getDropSingleImmediatelyCommand(no: Int, volume: Int, speed: Int)** - 0x6E
8. **getDropSingleTimelyCommand(no, year, month, day, hour, minute, volume, speed)** - 0x6F
9. **getDrop24WeeklyCommand(no, monday, ..., sunday, volume, speed)** - 0x70
10. **getDrop24RangeCommand(no, startYear, ..., endDay, volume, speed)** - 0x71
11. **getDropCustomWeeklyCommand(no, monday, ..., sunday, count)** - 0x72
12. **getDropCustomRangeCommand(no, startYear, ..., endDay, count)** - 0x73
13. **getDropCustomDetailCommand(no, startHour, startMinute, endHour, endMinute, times, volume, speed)** - 0x74
14. **getDropStartAdjustCommand(no: Int, speed: Int)** - 0x75
15. **getDropAdjustResultCommand(no: Int, speed: Int, volume: Int)** - 0x76
16. **getDropGetAdjustHistoryCommand(no: Int)** - 0x77
17. **getDropClearDropCommand(no: Int)** - 0x79
18. **getDropGetTotalDropCommand(no: Int)** - 0x7A
19. **getDropGetTotalDropDecimalCommand(no: Int)** - 0x7E
20. **getDropResetCommand()** - 0x7D

### koralcore 現狀

- ❌ **沒有 `DosingCommandBuilder`**
- ✅ 有 `ImmediateSingleDoseEncoder`（0x6E）
- ✅ 有 `TimedSingleDoseEncoder`（0x6F）
- ✅ 有 `DailyAverageScheduleEncoder`（0x70）
- ✅ 有 `CustomScheduleEncoder0x72/0x73/0x74`（0x72-0x74）
- ❌ **缺少其他命令構建器**（0x60-0x65, 0x61-0x64, 0x75-0x77, 0x79, 0x7A, 0x7D, 0x7E）

### Checksum 算法

**reef-b-app Android**：
- LED 命令：使用 `dataSum`（簡單求和，從 index 2 開始到最後，然後取最後一個 byte 作為 checksum）
- Dosing 命令：使用 **XOR checksum**（所有 byte 的 XOR）

**koralcore**：
- LED 命令：使用 `_checksum`（簡單求和）
- Dosing 命令：❌ **未確認**，需要檢查現有的 encoder 使用什麼算法

---

## 二、Repository Interface

### reef-b-app Android

reef-b-app Android 沒有明確的 Repository 接口，而是：
- `DropInformation` 直接儲存狀態
- ViewModel 直接讀取 `DropInformation` 的狀態
- `CommandManager.parseCommand()` 更新 `DropInformation`

### koralcore 現狀

- ✅ 有 `DosingPort`（只讀接口，用於讀取今日總量）
- ❌ **沒有 `DosingRepository` 接口**（類似 `LedRepository`）
- ❌ **沒有 `observeDosingState()` 方法**
- ❌ **沒有 `getDosingState()` 方法**

**需要創建**：
```dart
abstract class DosingRepository {
  Stream<DosingState> observeDosingState(String deviceId);
  Future<DosingState?> getDosingState(String deviceId);
  // ... 其他方法
}
```

---

## 三、Application 層整合

### reef-b-app Android

ViewModel 直接使用 `DropInformation`：
```kotlin
dropInformation.getModes()  // 取得所有泵頭模式
dropInformation.getMode(headNo)  // 取得特定泵頭模式
dropInformation.getHistory(headNo)  // 取得校正歷史
```

### koralcore 現狀

- ❌ Application 層沒有使用 `DosingState`
- ❌ 沒有對應的 UseCase 來觀察 Dosing 狀態
- ❌ `AppContext` 沒有 `DosingRepository`

---

## 四、狀態發送機制

### reef-b-app Android

- ViewModel 在 sync END 時讀取 `DropInformation` 的完整狀態
- 更新 LiveData，通知 UI

### koralcore 現狀

- ❌ `BleDosingRepositoryImpl` 沒有狀態發送機制（Stream/Controller）
- ❌ 沒有 `observeDosingState()` 方法
- ❌ 沒有在 sync END 時發送狀態

---

## 五、命令構建器的 Checksum 差異

### reef-b-app Android

**LED 命令**（`dataSum`）：
```kotlin
fun dataSum(array: ByteArray): Byte {
    val data = array.copyOfRange(2, array.size)
    return data.sum().toByte()
}
```

**Dosing 命令**（XOR checksum）：
```kotlin
private fun checksum(bytes: ByteArray): Byte {
    var sum = 0
    for (b in bytes) {
        sum = sum xor (b.toInt() and 0xFF)
    }
    return (sum and 0xFF).toByte()
}
```

### koralcore 現狀

- ✅ LED 命令使用簡單求和（與 reef-b-app 一致）
- ❌ **Dosing 命令的 checksum 算法未確認**
- 需要檢查現有的 encoder 是否使用 XOR checksum

---

## 六、總結：需要對照的項目

### 高優先級（必須對照）

1. **創建 `DosingRepository` 接口**
   - 對應 `LedRepository`
   - 提供 `observeDosingState()` 和 `getDosingState()` 方法

2. **實現狀態發送機制**
   - 在 `BleDosingRepositoryImpl` 中添加 Stream/Controller
   - 在 sync END 時發送狀態

3. **確認 Dosing 命令的 checksum 算法**
   - 檢查現有 encoder 是否使用 XOR checksum
   - 如果沒有，需要更新為 XOR checksum

### 中優先級（建議對照）

4. **創建 `DosingCommandBuilder`**
   - 對應 `LedCommandBuilder`
   - 實現所有 Dosing 命令構建方法（0x60-0x7E，除了 0x7B, 0x7C）

5. **Application 層整合**
   - 在 `AppContext` 中添加 `DosingRepository`
   - 創建對應的 UseCase（如 `ObserveDosingStateUseCase`）

### 低優先級（可選）

6. **完善 ACK 處理邏輯**
   - 目前所有 ACK handler 都是 TODO
   - 需要根據業務需求完善

---

## 七、檢查清單

### 必須對照（高優先級）
- [ ] 創建 `DosingRepository` 接口
- [ ] 實現狀態發送機制（Stream/Controller）
- [ ] 確認 Dosing 命令的 checksum 算法（XOR）

### 建議對照（中優先級）
- [ ] 創建 `DosingCommandBuilder`
- [ ] Application 層整合（AppContext, UseCase）

### 可選（低優先級）
- [ ] 完善 ACK 處理邏輯

