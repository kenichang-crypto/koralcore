library;

import 'dart:async';

import '../common/app_error.dart';
import '../common/app_error_code.dart';
import 'lighting_state_store.dart';

export 'lighting_state_store.dart'
    show LightingStateSnapshot, LightingChannelSnapshot;

/// Reads the current lighting state snapshot from the in-memory store.
class ReadLightingStateUseCase {
  final LightingStateMemoryStore store;

  const ReadLightingStateUseCase({required this.store});

  Future<LightingStateSnapshot> execute({required String deviceId}) async {
    if (deviceId.isEmpty) {
      throw const AppError(
        code: AppErrorCode.noActiveDevice,
        message: 'Lighting state requires an active device id.',
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 150));
    return store.read(deviceId: deviceId);
  }
}
