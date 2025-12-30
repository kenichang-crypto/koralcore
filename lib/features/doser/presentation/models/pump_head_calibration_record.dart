class PumpHeadCalibrationRecord {
  final String id;
  final String speedProfile;
  final double flowRateMlPerMin;
  final DateTime performedAt;
  final String? note;

  const PumpHeadCalibrationRecord({
    required this.id,
    required this.speedProfile,
    required this.flowRateMlPerMin,
    required this.performedAt,
    this.note,
  });
}
