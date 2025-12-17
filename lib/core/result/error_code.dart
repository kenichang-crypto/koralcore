/// Stable platform error codes.
/// NEVER reuse or change meaning once published.
enum ErrorCode {
  unknown,

  invalidInput,
  notSupported,
  timeout,
  disconnected,

  permissionDenied,
  deviceBusy,

  internalError,
}
