import 'capability/capability_id.dart';

/// Immutable collection wrapper around device capability identifiers.
class CapabilitySet {
  final Set<CapabilityId> _values;

  const CapabilitySet._(this._values);

  factory CapabilitySet.fromRaw(Map<String, dynamic> raw) {
    final resolved = <CapabilityId>{};

    void addByKey(String? key) {
      if (key == null) return;
      final CapabilityId? id = _capabilityKeyMap[key];
      if (id != null) {
        resolved.add(id);
      }
    }

    final dynamic ids = raw['capabilities'] ?? raw['ids'];
    if (ids is Iterable) {
      for (final item in ids) {
        addByKey(item?.toString());
      }
    }

    raw.forEach((key, value) {
      if (value is bool) {
        if (value) {
          addByKey(key);
        }
        return;
      }

      if (value != null) {
        addByKey(key);
      }
    });

    return CapabilitySet._(Set.unmodifiable(resolved));
  }

  const CapabilitySet.empty() : _values = const <CapabilityId>{};

  bool supports(CapabilityId id) => _values.contains(id);

  Set<CapabilityId> get values => _values;
}

const Map<String, CapabilityId> _capabilityKeyMap = {
  'ledPower': CapabilityId.ledPower,
  'led_power': CapabilityId.ledPower,
  'ledIntensity': CapabilityId.ledIntensity,
  'led_intensity': CapabilityId.ledIntensity,
  'led.schedule.daily': CapabilityId.ledScheduleDaily,
  'led.schedule.custom': CapabilityId.ledScheduleCustom,
  'led.schedule.scene': CapabilityId.ledScheduleScene,
  'ledScheduleDaily': CapabilityId.ledScheduleDaily,
  'ledScheduleCustom': CapabilityId.ledScheduleCustom,
  'ledScheduleScene': CapabilityId.ledScheduleScene,
  'dosing': CapabilityId.dosing,
  'schedule': CapabilityId.scheduling,
  'scheduling': CapabilityId.scheduling,
  'doser.decimal_ml': CapabilityId.doserDecimalMl,
  'doserDecimalMl': CapabilityId.doserDecimalMl,
  'doser.schedule.oneshot': CapabilityId.doserOneshotSchedule,
  'doserOneshotSchedule': CapabilityId.doserOneshotSchedule,
};
