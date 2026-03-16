import '../doser_dosing/dosing_state.dart';
import '../led_lighting/led_state.dart';
import 'capability/capability_id.dart';
import 'capability_set.dart';
import 'device_product.dart';
import 'firmware_version.dart';

/// Immutable snapshot describing the currently connected device.
class DeviceContext {
  final String deviceId;
  final DeviceProduct product;
  final FirmwareVersion firmware;
  final CapabilitySet capabilities;
  final DeviceRuntimeState runtimeState;

  const DeviceContext({
    required this.deviceId,
    required this.product,
    required this.firmware,
    required this.capabilities,
    this.runtimeState = const DeviceRuntimeState(),
  });

  DeviceContext copyWith({
    String? deviceId,
    DeviceProduct? product,
    FirmwareVersion? firmware,
    CapabilitySet? capabilities,
    DeviceRuntimeState? runtimeState,
  }) {
    return DeviceContext(
      deviceId: deviceId ?? this.deviceId,
      product: product ?? this.product,
      firmware: firmware ?? this.firmware,
      capabilities: capabilities ?? this.capabilities,
      runtimeState: runtimeState ?? this.runtimeState,
    );
  }

  bool get supportsDecimalMl =>
      capabilities.supports(CapabilityId.doserDecimalMl);

  bool get supportsOneshotSchedule =>
      capabilities.supports(CapabilityId.doserOneshotSchedule);

  bool get supportsLedScheduleDaily =>
      capabilities.supports(CapabilityId.ledScheduleDaily);

  bool get supportsLedScheduleCustom =>
      capabilities.supports(CapabilityId.ledScheduleCustom);

  bool get supportsLedScheduleScene =>
      capabilities.supports(CapabilityId.ledScheduleScene);
}

class DeviceRuntimeState {
  final bool isSyncing;
  final double todayDoseMl;
  final LedState? ledState;
  final DosingState? dosingState;

  const DeviceRuntimeState({
    this.isSyncing = false,
    this.todayDoseMl = 0.0,
    this.ledState,
    this.dosingState,
  });

  DeviceRuntimeState copyWith({
    bool? isSyncing,
    double? todayDoseMl,
    LedState? ledState,
    DosingState? dosingState,
  }) {
    return DeviceRuntimeState(
      isSyncing: isSyncing ?? this.isSyncing,
      todayDoseMl: todayDoseMl ?? this.todayDoseMl,
      ledState: ledState ?? this.ledState,
      dosingState: dosingState ?? this.dosingState,
    );
  }
}
