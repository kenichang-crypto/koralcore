# Domain 層 Parity 分析（Dosing）

## 一、reef-b-app Android 的 Domain 結構

### DropInformation（狀態管理）
```kotlin
class DropInformation {
    private var mode = arrayListOf(
        DropHeadMode(),  // 4個泵頭
        DropHeadMode(),
        DropHeadMode(),
        DropHeadMode()
    )
    
    private val adjustHistory = arrayListOf<Pair<Int, ArrayList<DropAdjustHistory>>?>(
        null,  // 4個泵頭的校正歷史
        null,
        null,
        null,
    )
    
    // 方法：
    - setMode(no: Int, mode: DropHeadMode)
    - getMode(no: Int): DropHeadMode
    - setDetail(no: Int, detail: DropHeadRecordDetail)
    - setDropVolume(headId: Int, nonRecord: Float, record: Float)
    - initAdjustHistory(no: Int, size: Int)
    - setHistory(no: Int, data: DropAdjustHistory): Boolean
    - clearInformation()
}
```

### DropHeadMode（泵頭模式）
```kotlin
data class DropHeadMode(
    val mode: DropRecordType = DropRecordType.NONE,
    val runDay: List<Boolean>? = null,  // 執行星期（星期一～星期日）
    val timeString: String? = null,     // 時間字串（用於範圍或單次）
    var recrodDrop: Float = 0f,         // 今日排程滴液量
    var otherDrop: Float? = null,       // 今日非排程滴液量
    var totalDrop: Int? = null,         // 每日滴液總量
    val rotatingSpeed: Int = 2,         // 泵頭轉速：1-低速 2-中速 3-高速
    val recordDetail: ArrayList<DropHeadRecordDetail> = arrayListOf(),  // 客製化排程細項
)
```

### DropHeadRecordDetail（客製化排程細項）
```kotlin
data class DropHeadRecordDetail(
    val timeString: String? = null,  // 時間範圍字串（如 "08:00 ~ 10:00"）
    val dropTime: Int,               // 滴液次數
    val totalDrop: Int,              // 滴液總量
    val rotatingSpeed: Int = 2,      // 泵頭轉速
)
```

### DropAdjustHistory（校正歷史）
```kotlin
data class DropAdjustHistory(
    val timeString: String,  // 時間字串（如 "2025-01-15 14:30:00"）
    val vloume: Int,          // 體積（注意拼寫錯誤）
    val rotatingSpeed: Int,   // 轉速
)
```

### DropRecordType（排程類型）
```kotlin
enum class DropRecordType {
    NONE,      // 無排程
    _24HR,     // 24小時均等滴液
    SINGLE,    // 單次滴液（定時）
    CUSTOM,    // 客製化排程
}
```

---

## 二、koralcore Domain 層現狀

### PumpHead（泵頭基本資訊）
```dart
class PumpHead {
  final String headId;
  final int pumpId;
  final String additiveName;
  final double dailyTargetMl;
  final double todayDispensedMl;
  final double flowRateMlPerMin;
  final DateTime? lastDoseAt;
  final String statusKey;
  final PumpHeadStatus status;
}
```

**問題**：
- ❌ **沒有排程模式資訊**（`DropRecordType`）
- ❌ **沒有執行星期資訊**（`runDay`）
- ❌ **沒有時間字串資訊**（`timeString`）
- ❌ **沒有排程細項**（`recordDetail`）
- ❌ **沒有轉速資訊**（`rotatingSpeed`）
- ❌ **沒有區分排程/非排程滴液量**（只有 `todayDispensedMl`）

### DoserSchedule（排程定義）
```dart
class DoserSchedule {
  final int pumpId;
  final DoserScheduleType type;  // h24, custom, oneshotSchedule
  // ... 其他排程定義相關欄位
}
```

**問題**：
- ❌ **這是「排程定義」，不是「當前狀態」**
- ❌ **與 reef-b-app 的 `DropHeadMode` 結構完全不同**
- ❌ **reef-b-app 的 `DropHeadMode` 是從 BLE sync 取得的「當前狀態」**

### DosingScheduleSummary（排程摘要）
```dart
class DosingScheduleSummary {
  final DosingScheduleMode mode;  // none, dailyAverage, customWindow
  final double? totalMlPerDay;
  final int? windowCount;
  final int? slotCount;
}
```

**問題**：
- ❌ **這是摘要資訊，不是完整狀態**
- ❌ **沒有對應到 reef-b-app 的 `DropHeadMode` 結構**

---

## 三、Parity 差異分析

### 缺失的 Domain 模型

1. **DropHeadMode 對應模型**
   - ❌ koralcore **沒有**對應 `DropHeadMode` 的 Domain 模型
   - ❌ koralcore **沒有**對應 `DropRecordType` 的 enum
   - 目前 `BleDosingRepositoryImpl` 使用內部 `_DropHeadMode`，但這不是 Domain 層模型

2. **DropHeadRecordDetail 對應模型**
   - ❌ koralcore **沒有**對應 `DropHeadRecordDetail` 的 Domain 模型
   - 目前 `BleDosingRepositoryImpl` 使用內部 `_DropHeadRecordDetail`

3. **DropAdjustHistory 對應模型**
   - ❌ koralcore **沒有**對應 `DropAdjustHistory` 的 Domain 模型
   - 目前 `BleDosingRepositoryImpl` 使用內部 `_DropAdjustHistory`

4. **DosingState 對應模型**
   - ❌ koralcore **沒有**對應 `DropInformation` 的 Domain 狀態模型
   - 類似 LED 的 `LedState`，應該有一個 `DosingState` 來管理所有泵頭的狀態

---

## 四、建議的 Domain 層結構

### 1. 創建 DosingState（對應 DropInformation）

```dart
class DosingState {
  final String deviceId;
  final List<PumpHeadMode> pumpHeadModes;  // 4個泵頭
  final List<PumpHeadAdjustHistory?> adjustHistory;  // 4個泵頭的校正歷史
  final int? delayTime;  // 延遲時間（從 0x66 取得）
  
  const DosingState({
    required this.deviceId,
    required this.pumpHeadModes,
    required this.adjustHistory,
    this.delayTime,
  });
}
```

### 2. 創建 PumpHeadMode（對應 DropHeadMode）

```dart
class PumpHeadMode {
  final PumpHeadRecordType mode;
  final List<bool>? runDay;  // 執行星期（星期一～星期日）
  final String? timeString;  // 時間字串
  final double recordDrop;  // 今日排程滴液量
  final double? otherDrop;  // 今日非排程滴液量
  final int? totalDrop;  // 每日滴液總量
  final int rotatingSpeed;  // 泵頭轉速：1-低速 2-中速 3-高速
  final List<PumpHeadRecordDetail> recordDetail;  // 客製化排程細項
  
  const PumpHeadMode({
    this.mode = PumpHeadRecordType.none,
    this.runDay,
    this.timeString,
    this.recordDrop = 0.0,
    this.otherDrop,
    this.totalDrop,
    this.rotatingSpeed = 2,
    List<PumpHeadRecordDetail>? recordDetail,
  }) : recordDetail = recordDetail ?? const [];
}
```

### 3. 創建 PumpHeadRecordType（對應 DropRecordType）

```dart
enum PumpHeadRecordType {
  none,    // 無排程
  h24,     // 24小時均等滴液
  single,  // 單次滴液（定時）
  custom,  // 客製化排程
}
```

### 4. 創建 PumpHeadRecordDetail（對應 DropHeadRecordDetail）

```dart
class PumpHeadRecordDetail {
  final String? timeString;  // 時間範圍字串
  final int dropTime;  // 滴液次數
  final int totalDrop;  // 滴液總量
  final int rotatingSpeed;  // 泵頭轉速
  
  const PumpHeadRecordDetail({
    this.timeString,
    required this.dropTime,
    required this.totalDrop,
    this.rotatingSpeed = 2,
  });
}
```

### 5. 創建 PumpHeadAdjustHistory（對應 DropAdjustHistory）

```dart
class PumpHeadAdjustHistory {
  final String timeString;  // 時間字串
  final int volume;  // 體積
  final int rotatingSpeed;  // 轉速
  
  const PumpHeadAdjustHistory({
    required this.timeString,
    required this.volume,
    required this.rotatingSpeed,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PumpHeadAdjustHistory &&
        other.timeString == timeString &&
        other.volume == volume &&
        other.rotatingSpeed == rotatingSpeed;
  }
  
  @override
  int get hashCode => Object.hash(timeString, volume, rotatingSpeed);
}
```

---

## 五、Parity 問題總結

### 嚴重缺失（必須創建）

1. ❌ **沒有 `DosingState` Domain 模型**
   - 需要對應 `DropInformation`
   - 管理 4 個泵頭的狀態

2. ❌ **沒有 `PumpHeadMode` Domain 模型**
   - 需要對應 `DropHeadMode`
   - 包含排程模式、執行時間、滴液量等資訊

3. ❌ **沒有 `PumpHeadRecordType` enum**
   - 需要對應 `DropRecordType`
   - 定義排程類型（none, h24, single, custom）

4. ❌ **沒有 `PumpHeadRecordDetail` Domain 模型**
   - 需要對應 `DropHeadRecordDetail`
   - 用於客製化排程細項

5. ❌ **沒有 `PumpHeadAdjustHistory` Domain 模型**
   - 需要對應 `DropAdjustHistory`
   - 用於校正歷史

### 現有模型不匹配

1. ⚠️ **`PumpHead` 模型不完整**
   - 只有基本資訊，缺少排程狀態
   - 需要擴展或創建新模型

2. ⚠️ **`DoserSchedule` 是排程定義，不是狀態**
   - 這是「要設定的排程」，不是「當前狀態」
   - 與 reef-b-app 的 `DropHeadMode` 用途不同

---

## 六、建議行動

### Phase 0.5: 創建 Domain 層模型（在 Infrastructure 之前）

1. **創建 `PumpHeadRecordType` enum**
   - 對應 `DropRecordType`

2. **創建 `PumpHeadRecordDetail` class**
   - 對應 `DropHeadRecordDetail`

3. **創建 `PumpHeadAdjustHistory` class**
   - 對應 `DropAdjustHistory`

4. **創建 `PumpHeadMode` class**
   - 對應 `DropHeadMode`
   - 包含所有必要欄位

5. **創建 `DosingState` class**
   - 對應 `DropInformation`
   - 管理所有泵頭狀態

6. **更新 `BleDosingRepositoryImpl`**
   - 使用 Domain 層模型，而不是內部 `_DropHeadMode` 等
   - 將 Infrastructure 層的內部模型改為使用 Domain 模型

---

## 七、注意事項

1. **Domain 層規則**：
   - 不依賴 Flutter
   - 不包含 UI / BLE / 儲存邏輯
   - 純 Domain 模型

2. **Parity 要求**：
   - 所有 Domain 模型必須對應 reef-b-app 的結構
   - 欄位名稱和類型必須一致（或合理映射）

3. **架構分層**：
   - Domain 層：純模型，無依賴
   - Infrastructure 層：使用 Domain 模型，處理 BLE 通訊
   - Application 層：使用 Domain 模型，處理業務邏輯

