/// FirmwareVersion
///
/// Lightweight immutable wrapper representing the firmware version string.
class FirmwareVersion {
  final String value;

  const FirmwareVersion(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirmwareVersion && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'FirmwareVersion($value)';
}
