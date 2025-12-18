import '../../core/capability/capability_id.dart';
import 'capability_set.dart';
import 'device_product.dart';
import 'firmware_version.dart';

/// Immutable snapshot describing the currently connected device.
class DeviceContext {
  final String deviceId;
  final DeviceProduct product;
  final FirmwareVersion firmware;
  final CapabilitySet capabilities;

  const DeviceContext({
    required this.deviceId,
    required this.product,
    required this.firmware,
    required this.capabilities,
  });

  bool get supportsDecimalMl =>
      capabilities.supports(CapabilityId.doserDecimalMl);

  bool get supportsOneshotSchedule =>
      capabilities.supports(CapabilityId.doserOneshotSchedule);
}
