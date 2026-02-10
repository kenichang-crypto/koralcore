
import 'device_product.dart';

/// Resolves DeviceProduct from product identity string.
///
/// PARITY: Matches Android DeviceProfileRegistry logic.
/// - Model identity is authoritative.
/// - Capabilities are NOT used for product resolution.
/// - Unknown models return DeviceProduct.unknown.
class DeviceProductResolver {
  const DeviceProductResolver();

  DeviceProduct resolve(String? modelIdentity) {
    if (modelIdentity == null) return DeviceProduct.unknown;

    // Normalize: lowercase and remove spaces (Android logic)
    final normalized = modelIdentity.trim().toLowerCase().replaceAll(' ', '');

    if (normalized.isEmpty) return DeviceProduct.unknown;

    // Android: normalized.contains("dose") && normalized.contains("4h") && !normalized.contains("4r")
    if (normalized.contains('dose') &&
        normalized.contains('4h') &&
        !normalized.contains('4r')) {
      return DeviceProduct.doser4k; // Assuming 4H maps to doser4k
    }

    // Android: normalized.contains("dose") && normalized.contains("4r") && !normalized.contains("4h")
    if (normalized.contains('dose') &&
        normalized.contains('4r') &&
        !normalized.contains('4h')) {
      return DeviceProduct.doser; // Assuming 4R maps to standard doser
    }

    // LED check (Added for Flutter parity, assuming Android handles this similarly or via exact match)
    if (normalized.contains('led')) {
      return DeviceProduct.ledController;
    }

    // Default to unknown if no match found
    // Android: Returns DEFAULT_PROFILE (which implies unknown behavior)
    return DeviceProduct.unknown;
  }
}
