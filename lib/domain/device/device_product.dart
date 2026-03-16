/// DeviceProduct
///
/// Minimal classification for supported device families. This enum intentionally
/// avoids hardware-specific details and only captures high-level capabilities.
enum DeviceProduct { unknown, ledController, doser, doser4k }

extension DeviceProductDoseProfile on DeviceProduct {
  double get doseRawToMlFactor {
    switch (this) {
      case DeviceProduct.doser:
        return 0.1;
      case DeviceProduct.doser4k:
      case DeviceProduct.ledController:
      case DeviceProduct.unknown:
      default:
        return 1.0;
    }
  }
}
