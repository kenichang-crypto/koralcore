library;

/// Extension for converting integers to booleans.
/// 
/// PARITY: Matches reef-b-app's IntExtension.kt
extension IntExtensions on int {
  /// Converts an integer to a boolean.
  /// 
  /// - 0 -> false
  /// - 1 -> true
  /// - other -> false
  /// 
  /// PARITY: Matches reef-b-app's Int.toBoolean()
  bool toBoolean() {
    return this == 1;
  }
}

