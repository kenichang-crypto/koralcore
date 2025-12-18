import '../ble_adapter.dart';

/// Sends prebuilt schedule payloads over BLE without interpreting them.
class ScheduleSender {
  final BleAdapter bleAdapter;

  const ScheduleSender({required this.bleAdapter});

  Future<void> send(List<int> payload) async {
    // TODO: Provide service UUID once BLE spec is finalized.
    final String serviceUuid = '';

    // TODO: Provide characteristic UUID for schedule writes.
    final String characteristicUuid = '';

    await bleAdapter.write(
      serviceUuid: serviceUuid,
      characteristicUuid: characteristicUuid,
      payload: payload,
    );
  }
}
