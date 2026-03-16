class BleSyncGuard {
  BleSyncGuard._();

  static final BleSyncGuard shared = BleSyncGuard._();

  final Map<String, _SyncState> _states = {};

  bool tryStartSync(String deviceId) {
    final state = _states.putIfAbsent(deviceId, () => _SyncState());
    if (state.isSyncing) {
      return false;
    }
    state.isSyncing = true;
    return true;
  }

  void finishSync(String deviceId) {
    final state = _states[deviceId];
    if (state != null) {
      state.isSyncing = false;
    }
  }

  void reset(String deviceId) {
    _states.remove(deviceId);
  }
}

class _SyncState {
  bool isSyncing = false;
}
