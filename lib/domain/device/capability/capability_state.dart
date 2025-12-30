/// 能力狀態（不是設備狀態）
///
/// 舉例：
/// - dosing capability 可能存在，但目前被鎖定
/// - scheduling capability 可能存在，但 device offline
enum CapabilityState {
  /// 能力可正常使用
  available,

  /// 能力暫時不可用（例如 device busy）
  unavailable,

  /// 能力被鎖定（例如排程執行中）
  locked,

  /// 能力不支援（profile 不符合）
  unsupported,
}
