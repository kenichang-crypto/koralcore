library;

/// Extension for converting booleans to integers.
/// 
/// PARITY: Matches reef-b-app's BooleanExtension.kt
extension BoolExtensions on bool {
  /// Converts a boolean to an integer.
  /// 
  /// - true -> 1
  /// - false -> 0
  /// 
  /// PARITY: Matches reef-b-app's Boolean.toByte() (returns 0x01 or 0x00)
  int toInt() {
    return this ? 1 : 0;
  }
  
  /// Converts a boolean to a byte value.
  /// 
  /// - true -> 0x01
  /// - false -> 0x00
  int toByte() {
    return toInt();
  }
}

