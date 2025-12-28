# Entity 和 Extension 對照檢查報告

本文件檢查 `reef-b-app` 中的 `entity` 和 `extension` 在 `koralcore` 中的對照狀況。

生成時間：2025-01-XX

---

## 一、Entity 對照狀況

### 1. Device.kt

**reef-b-app 定義**：
```kotlin
data class Device(
    val id: Int = 0,
    val macAddress: String,
    val name: String,
    val type: DeviceType,   // LED/DROP
    val sinkId: Int? = null,
    val group: LedGroup? = null,
    val favorite: Boolean = false,
    val master: Boolean? = null,
    val isConnect: Boolean = false,
    val delayTime: Int? = null,
)
```

**koralcore 對照狀況**：
- ✅ **已實現**：通過 `DeviceRepository` 和 `_DeviceRecord` 內部類管理
- ✅ **字段對齊**：
  - `id` → `_DeviceRecord.id` (String)
  - `macAddress` → `_DeviceRecord.macAddress` (String?)
  - `name` → `_DeviceRecord.name` (String)
  - `type` → `_DeviceRecord.type` (String? - 'LED'/'DROP')
  - `sinkId` → `_DeviceRecord.sinkId` (String?)
  - `group` → `_DeviceRecord.deviceGroup` (String? - 'A'/'B'/'C'/'D'/'E')
  - `favorite` → `_DeviceRecord.isFavorite` (bool)
  - `master` → `_DeviceRecord.isMaster` (bool)
  - `isConnect` → `_DeviceRecord.state` (String - 'connected'/'disconnected')
  - `delayTime` → `_DeviceRecord.delayTime` (int?)
- ⚠️ **差異**：
  - `id` 類型不同（Int vs String）
  - `isConnect` 使用 `state` 字符串而非布爾值

**相關數據類**：
- `DeviceReset` → ❌ 未實現（可能不需要，koralcore 使用不同的更新機制）
- `DeviceFavorite` → ❌ 未實現（使用 `toggleFavoriteDevice` 方法）
- `DeviceDelayTime` → ❌ 未實現（直接更新設備記錄）
- `DeviceEdit` → ❌ 未實現（使用 `updateDeviceName` 等方法）
- `DeviceChangeMaster` → ❌ 未實現（直接更新設備記錄）
- `DeviceMoveGroup` → ❌ 未實現（直接更新設備記錄）

---

### 2. Scene.kt

**reef-b-app 定義**：
```kotlin
data class Scene(
    val id: Int = 0,
    val name: String,
    val favorite: Boolean = false,
    val icon: Int,  // 圖示編號 0-10
    val sceneId: Byte? = null,   // null=自訂，其他=預設
    val isDynamic: Boolean = false,
    val uv: Int? = null,
    val purple: Int? = null,
    val blue: Int? = null,
    val royalBlue: Int? = null,
    val green: Int? = null,
    val red: Int? = null,
    val coldWhite: Int? = null,
    val warmWhite: Int? = null,
    val moon: Int? = null,
)
```

**koralcore 對照狀況**：
- ✅ **已實現**：通過 `LedStateScene` domain 模型和 `SceneCatalog`
- ✅ **字段對齊**：
  - `id` → `LedStateScene.sceneId` (String) 或通過 `SceneCatalog` 管理
  - `name` → `LedStateScene.name` (String)
  - `favorite` → 通過 `FavoriteSceneRepository` 管理（不在 Scene 模型中）
  - `icon` → `LedStateScene.iconKey` (String?) - 使用 iconKey 而非 icon 編號
  - `sceneId` → `LedStateScene.presetCode` (int?) - null=自訂，其他=預設
  - `isDynamic` → ✅ `LedStateScene.isDynamic` (bool)
  - 所有通道值（uv, purple, blue, etc.）→ `LedStateScene.channelLevels` (Map<String, int>)
- ⚠️ **差異**：
  - `icon` 使用 `iconKey` (String) 而非 `icon` (Int)
  - `sceneId` 使用 `presetCode` (int?) 而非 `sceneId` (Byte?)
  - 通道值使用 Map 而非直接字段
  - `favorite` 不在 Scene 模型中，通過 Repository 管理

**相關數據類**：
- `SceneFavorite` → ✅ 通過 `FavoriteSceneRepository` 實現
- `SceneEdit` → ❌ 未實現（使用 `updateScene` 方法）

---

### 3. DropHead.kt

**reef-b-app 定義**：
```kotlin
data class DropHead(
    val id: Int = 0,
    val deviceId: Int,   // 滴液泵資料庫編號
    val headId: Int,      // 幾號泵頭
    val dropTypeId: Int? = null,
    val maxDrop: Int? = null,
    val rotatingSpeed: Int = 2,  // 1-低速 2-中速 3-高速
)
```

**koralcore 對照狀況**：
- ✅ **已實現**：通過 `PumpHead` domain 模型和 `PumpHeadRepository`
- ✅ **字段對齊**：
  - `id` → `PumpHead` 沒有 id（使用 headId 作為標識）
  - `deviceId` → `PumpHead.deviceId` (String) - 在 Repository 層管理
  - `headId` → `PumpHead.headId` (String - 'A'/'B'/'C'/'D')
  - `dropTypeId` → `PumpHead.dropTypeId` (int?) - 在 Repository 層管理
  - `maxDrop` → ❌ 未實現（可能對應 `dailyTargetMl`，但用途不同）
  - `rotatingSpeed` → `PumpHeadMode.rotatingSpeed` (在 DosingState 中)
- ⚠️ **差異**：
  - `headId` 類型不同（Int vs String）
  - `maxDrop` 字段缺失（`dailyTargetMl` 是每日目標，不是最大滴液量）
  - `rotatingSpeed` 在 `PumpHeadMode` 中，不在 `PumpHead` 中
  - `PumpHead` 包含更多運行時狀態（todayDispensedMl, flowRateMlPerMin, status）

**相關數據類**：
- `DropHeadEdit` → ❌ 未實現（使用 `updatePumpHead` 方法）
- `DropHeadDropType` → ❌ 未實現（直接更新 `dropTypeId`）
- `DropHeadRotatingSpeed` → ❌ 未實現（直接更新 `rotatingSpeed`）
- `DropHeadReset` → ❌ 未實現（使用 `resetToDefault` 方法）

---

### 4. Sink.kt

**reef-b-app 定義**：
```kotlin
data class Sink(
    val id: Int = 0,
    var name: String,
)
```

**koralcore 對照狀況**：
- ✅ **已實現**：`lib/domain/sink/sink.dart`
- ✅ **字段對齊**：
  - `id` → `Sink.id` (String)
  - `name` → `Sink.name` (String)
- ⚠️ **差異**：
  - `id` 類型不同（Int vs String）
  - `Sink` 還有 `type` 字段（`SinkType` enum）

---

### 5. DropType.kt

**reef-b-app 定義**：
```kotlin
data class DropType(
    val id: Int = 0,
    var name: String,
    val isPreset: Boolean = false,
)
```

**koralcore 對照狀況**：
- ✅ **已實現**：`lib/domain/drop_type/drop_type.dart`
- ✅ **字段對齊**：
  - `id` → `DropType.id` (int)
  - `name` → `DropType.name` (String)
  - `isPreset` → `DropType.isPreset` (bool)
- ✅ **完全對齊**

---

### 6. LedRecord.kt

**reef-b-app 定義**：
```kotlin
data class LedRecord(
    val hour: Int,
    val minute: Int,
    val totalMinute: Int,
    var coldWhite: Int? = null,
    var royalBlue: Int? = null,
    var blue: Int? = null,
    var red: Int? = null,
    var green: Int? = null,
    var purple: Int? = null,
    var uv: Int? = null,
    var warmWhite: Int? = null,
    var moonLight: Int? = null,
)
```

**koralcore 對照狀況**：
- ✅ **已實現**：`lib/domain/led_lighting/led_record.dart`
- ✅ **字段對齊**：
  - `hour` → `LedRecord.hour` (int)
  - `minute` → `LedRecord.minute` (int)
  - `totalMinute` → `LedRecord.totalMinute` (int)
  - 所有通道值 → `LedRecord` 的對應字段
- ✅ **完全對齊**

---

### 7. Warning.kt

**reef-b-app 定義**：
```kotlin
data class Warning(
    val id: Int = 0,
    var warningId: Int,
    var deviceMacAddress: String,
    var time: String,
)
```

**koralcore 對照狀況**：
- ✅ **已實現**：`lib/domain/warning/warning.dart`
- ✅ **字段對齊**：
  - `id` → `Warning.id` (String)
  - `warningId` → `Warning.warningId` (int)
  - `deviceMacAddress` → `Warning.deviceId` (String)
  - `time` → `Warning.time` (DateTime)
- ⚠️ **差異**：
  - `id` 類型不同（Int vs String）
  - `deviceMacAddress` 字段名不同（deviceId vs deviceMacAddress）
  - `time` 類型不同（String vs DateTime）

---

### 8. DeviceFavoriteScene.kt

**reef-b-app 定義**：
```kotlin
data class DeviceFavoriteScene(
    val id: Int = 0,
    val deviceId: Int,
    val sceneId: Int,
    val createdAt: Long = System.currentTimeMillis(),
)
```

**koralcore 對照狀況**：
- ✅ **已實現**：通過 `FavoriteSceneRepository` 管理
- ✅ **字段對齊**：
  - `id` → 內部管理（不暴露）
  - `deviceId` → 通過方法參數傳遞（String）
  - `sceneId` → 通過方法參數傳遞（String）
  - `createdAt` → 內部管理（不暴露）
- ⚠️ **差異**：
  - 使用 Repository 模式，不直接暴露數據類

---

### 9. SinkWithDevices.kt

**reef-b-app 定義**：
```kotlin
data class SinkWithDevices(
    @Embedded val sink: Sink,
    @Relation(parentColumn = "id", entityColumn = "sinkId") 
    var devices: List<Device>
)
```

**koralcore 對照狀況**：
- ⚠️ **部分實現**：通過 `SinkRepository.getSinkWithDevices()` 方法
- ⚠️ **差異**：
  - 沒有專門的數據類
  - 使用查詢方法返回組合數據

---

## 二、Extension 對照狀況

### 1. ByteArrayExtension.kt

**reef-b-app 定義**：
```kotlin
fun ByteArray.toHexString(): String =
    joinToString(separator = " 0x", prefix = "0x") { String.format("%02X", it) }
```

**koralcore 對照狀況**：
- ⚠️ **部分實現**：在 `BleGoldenCapture._toHex()` 中有類似的轉換邏輯
- ❌ **未找到對應的 extension**：沒有統一的 `Uint8List` 或 `List<int>` 的 hex 轉換工具
- 💡 **建議**：創建 `lib/core/extensions/byte_array_extensions.dart` 提供 `toHexString()` 方法
- 📝 **現有實現**：`BleGoldenCapture._toHex()` 提供單字節轉換，但沒有完整的 `ByteArray.toHexString()` 對應

---

### 2. ByteExtension.kt

**reef-b-app 定義**：
```kotlin
fun Byte.toBoolean(): Boolean = when (this) {
    (0x00).toByte() -> false
    (0x01).toByte() -> true
    else -> false
}
```

**koralcore 對照狀況**：
- ⚠️ **部分實現**：在 BLE 處理中可能有類似的轉換邏輯（如 `data[2] & 0xFF == 0x01`）
- ❌ **未找到對應的 extension**：需要檢查是否有 `int` 到 `bool` 的轉換工具
- 💡 **建議**：創建 `lib/core/extensions/int_extensions.dart` 提供 `toBoolean()` 方法

---

### 3. BooleanExtension.kt

**reef-b-app 定義**：
```kotlin
fun Boolean.toByte(): Byte = when (this) {
    true -> 0x01
    false -> 0x00
}
```

**koralcore 對照狀況**：
- ⚠️ **部分實現**：在 BLE 命令構建中可能有類似的轉換邏輯（如 `value ? 0x01 : 0x00`）
- ❌ **未找到對應的 extension**：需要檢查是否有 `bool` 到 `int` 的轉換工具
- 💡 **建議**：創建 `lib/core/extensions/bool_extensions.dart` 提供 `toInt()` 方法

---

### 4. IntExtension.kt

**reef-b-app 定義**：
```kotlin
fun Int.toast(context: Context, duration: Int = Toast.LENGTH_SHORT) =
    Toast.makeText(context, this, duration).show()

fun Int.toBoolean(): Boolean = when (this) {
    0 -> false
    1 -> true
    else -> false
}
```

**koralcore 對照狀況**：
- ❌ **未實現**：
  - `Int.toast()` → Flutter 使用不同的 toast 機制
  - `Int.toBoolean()` → 未找到對應的 extension

---

### 5. CalendarExtension.kt

**reef-b-app 定義**：
```kotlin
fun Calendar.format(pattern: String): String {
    return SimpleDateFormat(pattern).format(this.time)
}
```

**koralcore 對照狀況**：
- ⚠️ **部分實現**：Flutter 使用 `DateTime` 和 `DateFormat`，不是 `Calendar`
- ❌ **未找到對應的 extension**：但 Flutter 有類似的格式化功能

---

### 6. EdittextExtension.kt

**reef-b-app 定義**：
```kotlin
fun autoTrim(editText: EditText) {
    // 禁止輸入空格
}
```

**koralcore 對照狀況**：
- ❌ **未實現**：Flutter 使用 `TextEditingController`，不是 `EditText`
- ⚠️ **可能需要**：在 Flutter 中實現類似的輸入過濾邏輯

---

### 7. InputFilterMinMax.kt

**reef-b-app 定義**：
```kotlin
class InputFilterMinMax : InputFilter {
    // 限制輸入範圍
}
```

**koralcore 對照狀況**：
- ❌ **未實現**：Flutter 使用不同的輸入驗證機制
- ⚠️ **可能需要**：在 Flutter 中實現類似的輸入範圍限制

---

## 三、總結

### Entity 對照總結

| Entity | 狀態 | 完成度 | 備註 |
|--------|------|--------|------|
| Device | ✅ 已實現 | 90% | id 類型不同，使用 state 而非 isConnect |
| Scene | ✅ 已實現 | 95% | icon 使用 iconKey，sceneId 使用 presetCode |
| DropHead | ✅ 已實現 | 80% | 字段映射不完整，缺少 maxDrop |
| Sink | ✅ 已實現 | 95% | id 類型不同，多了 type 字段 |
| DropType | ✅ 已實現 | 100% | 完全對齊 |
| LedRecord | ✅ 已實現 | 100% | 完全對齊 |
| Warning | ✅ 已實現 | 90% | id 和 time 類型不同 |
| DeviceFavoriteScene | ✅ 已實現 | 90% | 使用 Repository 模式 |
| SinkWithDevices | ⚠️ 部分實現 | 70% | 沒有專門的數據類 |

### Extension 對照總結

| Extension | 狀態 | 完成度 | 備註 |
|-----------|------|--------|------|
| ByteArray.toHexString() | ⚠️ 部分實現 | 50% | 有 `_toHex()` 但沒有完整的 extension |
| Byte.toBoolean() | ⚠️ 部分實現 | 50% | 需要確認是否有對應工具 |
| Boolean.toByte() | ⚠️ 部分實現 | 50% | 需要確認是否有對應工具 |
| Int.toast() | ❌ 未實現 | 0% | Flutter 使用不同機制 |
| Int.toBoolean() | ❌ 未實現 | 0% | 需要實現 |
| Calendar.format() | ⚠️ 部分實現 | 70% | Flutter 使用 DateTime |
| autoTrim() | ❌ 未實現 | 0% | Flutter 使用不同機制 |
| InputFilterMinMax | ❌ 未實現 | 0% | Flutter 使用不同機制 |

---

## 四、建議

### 高優先級

1. **創建 Extension 工具類**：
   - `Uint8List.toHexString()` 或 `List<int>.toHexString()`
   - `int.toBoolean()` 和 `bool.toInt()`
   - 這些在 BLE 處理中經常使用

2. **完善 Entity 字段映射**：
   - 確認 `Device` 的 `isConnect` 映射是否正確
   - 確認 `DropHead` 的 `maxDrop` 映射
   - 確認 `Scene` 是否需要 `isDynamic` 字段

### 中優先級

3. **實現 Flutter 對應的輸入驗證**：
   - 實現類似 `autoTrim` 的輸入過濾
   - 實現類似 `InputFilterMinMax` 的範圍限制

### 低優先級

4. **統一 ID 類型**：
   - 考慮是否統一使用 String 或 Int
   - 或明確文檔說明類型差異的原因

---

## 五、詳細對照表

### Entity 詳細對照

詳見上方各 Entity 的對照狀況。

### Extension 詳細對照

詳見上方各 Extension 的對照狀況。

