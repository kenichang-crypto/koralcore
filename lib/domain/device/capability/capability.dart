import 'capability_id.dart';

/// Minimal capability descriptor used by the registry snapshots.
class Capability {
  final CapabilityId id;
  final String name;
  final bool isEnabled;

  const Capability({
    required this.id,
    required this.name,
    this.isEnabled = true,
  });
}
