/// Capability 層級錯誤
///
/// 與 Result / Failure 不同：
/// - Result 是「操作結果」
/// - CapabilityError 是「能力層限制」
class CapabilityError {
  final CapabilityId capability;
  final String reason;

  const CapabilityError({
    required this.capability,
    required this.reason,
  });
}
