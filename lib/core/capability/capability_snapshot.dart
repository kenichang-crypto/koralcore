import 'capability.dart';

/// CapabilitySnapshot 表示
/// 👉「此刻，平台認知到的能力狀態集合」
///
/// 它是 immutable（不可變）
/// 常用於：
/// - UI render
/// - State diff
/// - log / debug
class CapabilitySnapshot {
  final List<Capability> capabilities;

  const CapabilitySnapshot(this.capabilities);

  Capability? find(CapabilityId id) {
    return capabilities.where((c) => c.id == id).firstOrNull;
  }
}
