# Spectrum Domain Parity Spec

## 1. 概觀 (Overview)

本文件定義 Spectrum (光譜) 功能的純領域邏輯 (Domain Logic) 對照規格。
目標是確保 Flutter 端的計算邏輯、數據結構與物理意義完全對齊 Android 原始實作，不涉及任何 UI 層實作。

**原始碼來源**:
- `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/util/spectrum/Spectrum.kt`
- `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/util/spectrum/SpectrumUtil.kt`
- `android/ReefB_Android/app/src/main/java/tw/com/crownelectronics/reefb/util/spectrum/SpectrumString.kt`

---

## 2. 資料結構與語意 (Data Structures & Semantics)

### 2.1 Android Data Class Analysis

Android 端使用 Gson 解析 JSON 字串為物件。

#### `rawSpectrum`
- **用途**: JSON 根物件容器
- **欄位**:
  - `list: List<Spectrum>`: 包含該 Channel 所有波長的強度數據

#### `Spectrum`
- **用途**: 單一波長的強度定義點
- **欄位**:
  - `wave: Int`: 波長 (nm)，範圍通常為 380 - 700
  - `strength25: Double`: 當 Channel 強度設為 25% 時的該波長強度值
  - `strength50: Double`: 當 Channel 強度設為 50% 時的該波長強度值
  - `strength75: Double`: 當 Channel 強度設為 75% 時的該波長強度值
  - `strength100: Double`: 當 Channel 強度設為 100% 時的該波長強度值

### 2.2 Channel Semantics

Android 端定義了 8 個獨立的 LED Channel，每個 Channel 都有獨立的光譜數據源 (JSON String)。

| Channel ID (Logical) | Android Source Method | 物理意義 |
|---|---|---|
| **UV** | `getUVString()` | 紫外線波段 |
| **Purple** | `getPurpleString()` | 紫色波段 |
| **Blue** | `getBlueString()` | 藍色波段 |
| **RoyalBlue** | `getRoyalBlueString()` | 寶藍色波段 |
| **Green** | `getGreenString()` | 綠色波段 |
| **Red** | `getRedString()` | 紅色波段 |
| **ColdWhite** | `getColdWhiteString()` | 冷白光 |
| **MoonLight** | `getMoonLightString()` | 月光/暖白光 |

---

## 3. 計算邏輯 (Calculation Logic)

### 3.1 核心公式：分段線性插值 (Piecewise Linear Interpolation)

Android `SpectrumUtil.getInterpolation` 與 `getChartValues` 實作了基於 4 個錨點 (25%, 50%, 75%, 100%) 的分段線性插值。

**公式**:
對於給定 Channel 強度 `S` (0-100) 和某波長的數據點 `P`：

- **若 S = 0**: 強度 = 0
- **若 0 < S < 25**: 插值區間 [0, 25]
  - $Val = 0 + \frac{S - 0}{25 - 0} \times (P_{25} - 0)$
- **若 25 ≤ S < 50**: 插值區間 [25, 50]
  - $Val = P_{25} + \frac{S - 25}{50 - 25} \times (P_{50} - P_{25})$
- **若 50 ≤ S < 75**: 插值區間 [50, 75]
  - $Val = P_{50} + \frac{S - 50}{75 - 50} \times (P_{75} - P_{50})$
- **若 75 ≤ S < 100**: 插值區間 [75, 100]
  - $Val = P_{75} + \frac{S - 75}{100 - 75} \times (P_{100} - P_{75})$
- **若 S = 100**: 強度 = $P_{100}$

**通用插值函數**:
```kotlin
fun getInterpolation(x1, y1, x3, y3, x2):
    return y1 + (x2 - x1) / (x3 - x1) * (y3 - y1)
```

### 3.2 光譜合成 (Spectrum Synthesis)

總光譜是所有 Channel 在特定波長下的強度總和。

**計算步驟**:
1. 定義波長範圍：`380` 到 `700` (含 380, 不含 700? Android 寫 `380 until 700` 即 `[380, 699]`)。
2. 對於每個波長 `w`：
   - 計算每個 Channel `c` 在強度 `Level_c` 下的插值強度 `I_c(w)`。
   - 總強度 `Total(w) = Σ I_c(w)` (加總所有 8 個 Channel)。

---

## 4. Android → Flutter Domain Mapping

| Android Element | Android Type | Proposed Dart Element | Dart Type |
|---|---|---|---|
| `rawSpectrum` | Data Class | `SpectrumDataConfig` | Class |
| `Spectrum` | Data Class | `SpectrumWavePoint` | Class |
| `SpectrumUtil` | Class | `SpectrumCalculator` | Class (Service) |
| `SpectrumString` | Kotlin File | `SpectrumDataSource` | Class (Static/Const) |
| `getInterpolation` | Method | `calculateIntensity` | Method |
| `calculateSpectrum` | Method | `synthesizeSpectrum` | Method |

---

## 5. 必須實作的 Dart 類別清單 (Required Implementation)

以下類別必須在 `lib/features/led/domain/spectrum/` 或 `lib/features/led/data/spectrum/` 下實作，**嚴禁包含任何 UI 代碼**。

### 5.1 Models (`lib/features/led/domain/models/spectrum/`)

#### `SpectrumWavePoint`
- 映射 Android `Spectrum`
- 欄位：
  - `final int waveLength;`
  - `final double strength25;`
  - `final double strength50;`
  - `final double strength75;`
  - `final double strength100;`

#### `SpectrumChannelData`
- 封裝單一 Channel 的完整光譜數據
- 欄位：
  - `final List<SpectrumWavePoint> points;`
  - 方法：`double getIntensityAt(int waveLength, int level);`

### 5.2 Data (`lib/features/led/data/spectrum/`)

#### `SpectrumDataSource`
- 存放從 `SpectrumString.kt` 移植的原始 JSON 數據或預解析的物件。
- 提供各 Channel 的數據存取方法 (e.g., `static List<SpectrumWavePoint> get uv;`)。

### 5.3 Service (`lib/features/led/domain/services/`)

#### `SpectrumCalculator`
- 純邏輯服務類別。
- **輸入**: 8 個 Channel 的強度值 (0-100)。
- **輸出**: 光譜分佈數據 (List of Point: `{wave, totalIntensity}`)。
- **職責**:
  1. 執行分段線性插值。
  2. 執行波長強度疊加。
  3. 提供 380nm - 700nm 的完整數據點。

---

## 6. 審核標準 (Gate Criteria)

1. **數據完整性**: Dart 端的數據源必須包含 `SpectrumString.kt` 中所有 Channel 的完整數據點。
2. **公式準確性**: 插值邏輯必須通過單元測試，驗證 0, 25, 50, 75, 100 及中間值的計算結果與手算/Android 邏輯一致。
3. **無 UI 依賴**: 所有上述類別不得 import `package:flutter/material.dart` 或任何 UI 相關庫。
