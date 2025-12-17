/// 滴液計算 / 驗證的輸入資料模型
///
/// ⚠️ Domain 層規則：
/// - 不依賴 Flutter
/// - 不包含 UI / BLE / 儲存邏輯
class DosingInput {
  /// 韌體格式
  /// 0x7A = 舊韌體（整數 ml）
  /// 0x7E = 新韌體（0.1 ml 精度）
  final FirmwareType firmware;

  /// 模式
  /// daily24h = 24 小時均分
  /// custom = 自訂次數
  final DosingMode mode;

  /// 每日總劑量（ml）
  /// - 24h 模式必填
  final double? dailyDose;

  /// 單次區間總劑量（ml）
  /// - custom 模式必填
  final double? intervalDose;

  /// 每區間次數
  /// - custom 模式必填
  final int? times;

  const DosingInput({
    required this.firmware,
    required this.mode,
    this.dailyDose,
    this.intervalDose,
    this.times,
  });
}

/// 韌體格式定義
enum FirmwareType {
  /// 舊韌體：0x7A
  /// - 單次最小 1.0 ml
  /// - 整數 ml
  legacy7A,

  /// 新韌體：0x7E
  /// - 單次最小 0.4 ml
  /// - 0.1 ml 精度
  modern7E,
}

/// 排程模式
enum DosingMode {
  /// 24 小時均分
  daily24h,

  /// 自訂模式
  custom,
}
