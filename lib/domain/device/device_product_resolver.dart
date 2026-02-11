import 'device_product.dart';

/// Resolves DeviceProduct from a product identity string (e.g., model name).
///
/// ## KC-A-FINAL: Semantic Sealing
/// This resolver's purpose is strictly to map a known `modelIdentity` to a
/// concrete `DeviceProduct`. It is NOT an "intelligent" or "auto-detecting"
/// mechanism.
///
/// ### Heuristic Logic: Legacy Compatibility
/// The `heuristic` logic (e.g., `contains('dose')`) exists purely for legacy
/// compatibility with older device firmwares that may not provide a clean,
/// exact model name. This is a fallback and should not be treated as a reliable
/// source of truth for future devices.
///
/// ### Unknown is a Valid State
/// Returning `DeviceProduct.unknown` is an expected and valid outcome. It
/// signifies that the provided `modelIdentity` does not map to a known product
/// in this version of the app. It is NOT an error state. Downstream logic
/// MUST handle `unknown` gracefully (e.g., by disabling product-specific features).
///
/// PARITY: Matches Android DeviceProfileRegistry logic.
/// - Model identity is the authoritative source.
/// - Capabilities are NEVER used for product resolution.
class DeviceProductResolver {
  const DeviceProductResolver();

  DeviceProduct resolve(String? modelIdentity) {
    if (modelIdentity == null) return DeviceProduct.unknown;

    // Normalize: lowercase and remove spaces (Android logic)
    final normalized = modelIdentity.trim().toLowerCase().replaceAll(' ', '');

    if (normalized.isEmpty) return DeviceProduct.unknown;

    // Heuristic: Legacy doser check (4H vs 4R)
    // Android: normalized.contains("dose") && normalized.contains("4h") && !normalized.contains("4r")
    if (normalized.contains('dose') &&
        normalized.contains('4h') &&
        !normalized.contains('4r')) {
      return DeviceProduct.doser4k;
    }

    // Heuristic: Legacy doser check (4R vs 4H)
    // Android: normalized.contains("dose") && normalized.contains("4r") && !normalized.contains("4h")
    if (normalized.contains('dose') &&
        normalized.contains('4r') &&
        !normalized.contains('4h')) {
      return DeviceProduct.doser;
    }

    // Heuristic: Legacy LED check
    if (normalized.contains('led')) {
      return DeviceProduct.ledController;
    }

    // FINAL-1: Fallback to Unknown (Non-authoritative identity)
    // When no heuristic matches, returning 'unknown' is the correct behavior.
    // The 'modelIdentity' (often from device_name) is not a guaranteed
    // authoritative source.
    return DeviceProduct.unknown;
  }
}
