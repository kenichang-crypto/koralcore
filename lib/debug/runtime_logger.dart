import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

const String _sessionId = '74d5f5';

Future<void> appendRuntimeLog({
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, dynamic>? data,
}) async {
  final record = {
    'sessionId': _sessionId,
    'runId': 'debug',
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data ?? {},
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };
  try {
    final Directory dir = Directory.systemTemp;
    await dir.create(recursive: true);
    final File file = File('${dir.path}/debug-ble.log');
    await file.writeAsString('${jsonEncode(record)}\n', mode: FileMode.append);
  } catch (e, stack) {
    debugPrint('RuntimeLog error: $e\n$stack');
  }
}
