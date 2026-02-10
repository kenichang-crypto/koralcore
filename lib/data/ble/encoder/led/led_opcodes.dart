/// LED opcode definitions aligned with reef-b-app.
class LedOpcodes {
  /// Feature flag to enable New 5-channel encoders (0x81/0x82/0x83).
  ///
  /// ARCHIVED for v1.0: This path is currently disabled to enforce parity with
  /// the Android legacy behavior. Do NOT enable unless the firmware and app
  /// are ready to migrate to the new protocol.
  static const bool enableNew5ChannelEncoders = false;

  // Legacy 9-channel opcodes (v1.0 default)
  static const int setRecord = 0x27;
  static const int usePresetScene = 0x28;
  static const int useCustomScene = 0x29;
  static const int dimming = 0x33;

  // New 5-channel opcodes (Archived / Disabled)
  static const int dailySchedule = 0x81;
  static const int customWindow = 0x82;
  static const int sceneWindow = 0x83;

  const LedOpcodes._();
}
