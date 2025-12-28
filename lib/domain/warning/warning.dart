/// Warning
///
/// Domain model representing a device warning.
///
/// PARITY: Based on reef-b-app entity Warning.kt.
/// 
/// Note on field differences:
/// - `id`: int (matches reef-b-app)
/// - `deviceId`: String (reef-b-app uses `deviceMacAddress`, but koralcore uses deviceId for consistency)
/// - `time`: DateTime (reef-b-app uses String, but koralcore uses DateTime for type safety)
///   Use `fromJson`/`toJson` for serialization compatibility.
class Warning {
  /// Database primary key (auto-generated)
  final int id;

  /// Warning identifier from device
  final int warningId;

  /// Device identifier (MAC address in reef-b-app, but deviceId in koralcore)
  final String deviceId;

  /// Warning timestamp
  final DateTime time;

  const Warning({
    required this.id,
    required this.warningId,
    required this.deviceId,
    required this.time,
  });

  /// Creates a Warning from JSON map.
  /// 
  /// PARITY: Compatible with reef-b-app's Warning entity JSON format.
  /// Handles both String and DateTime formats for time field.
  factory Warning.fromJson(Map<String, dynamic> json) {
    final timeValue = json['time'];
    DateTime time = DateTime.now(); // Default initialization
    if (timeValue is String) {
      // Try parsing as ISO 8601 or common formats
      try {
        time = DateTime.parse(timeValue);
      } catch (e) {
        // Fallback: try common formats
        // Format: "yyyy-MM-dd HH:mm:ss" or "yyyy-MM-dd HH:mm"
        final formats = [
          'yyyy-MM-dd HH:mm:ss',
          'yyyy-MM-dd HH:mm',
          'yyyy/MM/dd HH:mm:ss',
          'yyyy/MM/dd HH:mm',
        ];
        bool parsed = false;
        // ignore: unused_local_variable
        for (final format in formats) {
          try {
            // Note: Simple date parsing - for production, use intl package
            final parts = timeValue.split(' ');
            if (parts.length == 2) {
              final dateParts = parts[0].split(RegExp(r'[-/]'));
              final timeParts = parts[1].split(':');
              if (dateParts.length == 3 && timeParts.length >= 2) {
                time = DateTime(
                  int.parse(dateParts[0]),
                  int.parse(dateParts[1]),
                  int.parse(dateParts[2]),
                  int.parse(timeParts[0]),
                  int.parse(timeParts[1]),
                  timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
                );
                parsed = true;
                break;
              }
            }
          } catch (_) {
            continue;
          }
        }
        if (!parsed) {
          // Last resort: use current time
          time = DateTime.now();
        }
      }
    } else if (timeValue is int) {
      // Unix timestamp in milliseconds
      time = DateTime.fromMillisecondsSinceEpoch(timeValue);
    } else if (timeValue is DateTime) {
      time = timeValue;
    } else {
      // Default to current time
      time = DateTime.now();
    }

    return Warning(
      id: json['id'] as int? ?? 0,
      warningId: json['warning_id'] as int? ?? json['warningId'] as int? ?? 0,
      deviceId: json['device_mac_address'] as String? ?? json['deviceId'] as String? ?? '',
      time: time,
    );
  }

  /// Converts Warning to JSON map.
  /// 
  /// PARITY: Compatible with reef-b-app's Warning entity JSON format.
  /// Converts DateTime to String for compatibility.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warning_id': warningId,
      'device_mac_address': deviceId, // Use reef-b-app field name for compatibility
      'time': _formatTime(time), // Convert DateTime to String
    };
  }

  /// Formats DateTime to String in reef-b-app format.
  /// 
  /// Format: "yyyy-MM-dd HH:mm:ss"
  String _formatTime(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  /// Creates a copy with updated fields.
  Warning copyWith({
    int? id,
    int? warningId,
    String? deviceId,
    DateTime? time,
  }) {
    return Warning(
      id: id ?? this.id,
      warningId: warningId ?? this.warningId,
      deviceId: deviceId ?? this.deviceId,
      time: time ?? this.time,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Warning &&
          other.id == id &&
          other.warningId == warningId &&
          other.deviceId == deviceId &&
          other.time == time;

  @override
  int get hashCode => Object.hash(id, warningId, deviceId, time);

  @override
  String toString() =>
      'Warning(id: $id, warningId: $warningId, deviceId: $deviceId, time: $time)';
}

