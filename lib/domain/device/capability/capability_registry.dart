import 'capability.dart';
import 'capability_id.dart';
import 'capability_snapshot.dart';

/// CapabilityRegistry 是平台層的「能力管理者」
///
/// 職責：
/// - 註冊能力（來自 device / profile / adapter）
/// - 提供能力快照給 UI / UseCase
///
/// 不做：
/// - 不執行命令
/// - 不知道 BLE
/// - 不知道 firmware
class CapabilityRegistry {
  final Map<CapabilityId, Capability> _capabilities = {};

  /// 註冊或更新一項能力
  void register(Capability capability) {
    _capabilities[capability.id] = capability;
  }

  /// 取得單一能力
  Capability? get(CapabilityId id) => _capabilities[id];

  /// 取得整體快照（給 UI）
  CapabilitySnapshot snapshot() {
    return CapabilitySnapshot(_capabilities.values.toList());
  }
}
