library;

import 'dart:typed_data';

/// Extension for converting byte arrays to hex strings.
/// 
/// PARITY: Matches reef-b-app's ByteArrayExtension.kt
extension ByteArrayExtensions on List<int> {
  /// Converts a list of bytes to a hex string.
  /// 
  /// Format: "0xXX 0xYY 0xZZ"
  /// PARITY: Matches reef-b-app's ByteArray.toHexString()
  String toHexString() {
    if (isEmpty) {
      return '0x';
    }
    return map((byte) => '0x${(byte & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase()}').join(' ');
  }
}

/// Extension for Uint8List.
extension Uint8ListExtensions on Uint8List {
  /// Converts a Uint8List to a hex string.
  /// 
  /// Format: "0xXX 0xYY 0xZZ"
  /// PARITY: Matches reef-b-app's ByteArray.toHexString()
  String toHexString() {
    return this.toList().toHexString();
  }
}

