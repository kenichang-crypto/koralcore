import 'dose_value.dart';

/// 滴液 Domain 規則定義
///
/// ❗ 本檔案只負責：
/// - 規格數值
/// - 純計算公式
/// ❌ 不做驗證
/// ❌ 不丟錯誤
abstract class DosingRules {
  /// 每區間最大次數
  static const int maxTimesPerInterval = 5;

  /// 舊韌體（0x7A）
  /// 單次最小滴液量（ml）
  static const double legacyMinSingleDose = 1.0;

  /// 新韌體（0x7E）
  /// 單次最小滴液量（ml）
  static const double modernMinSingleDose = 0.4;

  /// 取得對應韌體的最小單次滴液量
  static double minSingleDose(FirmwareType firmware) {
    switch (firmware) {
      case FirmwareType.legacy7A:
        return legacyMinSingleDose;
      case FirmwareType.modern7E:
        return modernMinSingleDose;
    }
  }

  /// 24 小時模式：計算單次滴液量
  ///
  /// singleDose = dailyDose / 24
  static double calcDailySingleDose(double dailyDose) {
    return dailyDose / 24.0;
  }

  /// Custom 模式：計算單次滴液量
  ///
  /// singleDose = intervalDose / times
  static double calcCustomSingleDose({
    required double intervalDose,
    required int times,
  }) {
    return intervalDose / times;
  }
}
