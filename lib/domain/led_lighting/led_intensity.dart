/// Canonical representation for LED channel intensity bytes.
///
/// reef-b-app transmits intensities as raw PWM bytes (0-255). This value
/// object enforces the valid range up-front so encoders can assume the byte
/// is already sanitized.
class LedIntensity {
  final int value;

  const LedIntensity._(this.value);

  /// Creates an intensity after clamping it to the BLE-valid range.
  factory LedIntensity(int value) {
    if (value < 0 || value > 255) {
      throw RangeError.range(
        value,
        0,
        255,
        'intensity',
        'LED intensities must fit in a single byte (0-255).',
      );
    }
    return LedIntensity._(value);
  }

  static const LedIntensity zero = LedIntensity._(0);

  LedIntensity copyWith(int newValue) => LedIntensity(newValue);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LedIntensity &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'LedIntensity($value)';
}
