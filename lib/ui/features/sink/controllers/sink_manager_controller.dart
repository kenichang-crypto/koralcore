import 'package:flutter/foundation.dart';

import '../../../../application/common/app_error_code.dart';
import '../../../../domain/sink/sink.dart';
import '../../../../platform/contracts/sink_repository.dart';

/// Controller for managing sink list and operations.
class SinkManagerController extends ChangeNotifier {
  final SinkRepository sinkRepository;

  SinkManagerController({required this.sinkRepository}) {
    _initialize();
  }

  List<Sink> _sinks = <Sink>[];
  bool _isLoading = false;
  String? _errorMessage;
  AppErrorCode? _errorCode;

  List<Sink> get sinks => List.unmodifiable(_sinks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AppErrorCode? get errorCode => _errorCode;
  bool get isEmpty => _sinks.isEmpty;

  void _initialize() {
    _loadSinks();
    sinkRepository.observeSinks().listen((sinks) {
      _sinks = sinks;
      notifyListeners();
    });
  }

  // Make _loadSinks accessible for retry
  void reload() {
    _loadSinks();
  }

  Future<void> _loadSinks() async {
    _isLoading = true;
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();

    try {
      _sinks = sinkRepository.getCurrentSinks();
    } catch (e) {
      _errorCode = AppErrorCode.unknownError;
      _errorMessage = null; // Will be localized in UI using errorCode
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSink(String name) async {
    if (name.trim().isEmpty) {
      _errorMessage = 'Sink name cannot be empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if name already exists
      final existingSink = _sinks.firstWhere(
        (sink) => sink.name == name.trim(),
        orElse: () => const Sink(
          id: '',
          name: '',
          type: SinkType.custom,
          deviceIds: [],
        ),
      );

      if (existingSink.id.isNotEmpty) {
        _errorMessage = 'Sink name already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final newSink = Sink(
        id: 'sink-${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        type: SinkType.custom,
        deviceIds: const [],
      );

      sinkRepository.upsertSink(newSink);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorCode = AppErrorCode.unknownError;
      _errorMessage = null; // Will be localized in UI using errorCode
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> editSink(SinkId sinkId, String name) async {
    if (name.trim().isEmpty) {
      _errorMessage = 'Sink name cannot be empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sink = _sinks.firstWhere(
        (s) => s.id == sinkId,
        orElse: () => throw Exception('Sink not found'),
      );

      // Check if name already exists (excluding current sink)
      final existingSink = _sinks.firstWhere(
        (s) => s.name == name.trim() && s.id != sinkId,
        orElse: () => const Sink(
          id: '',
          name: '',
          type: SinkType.custom,
          deviceIds: [],
        ),
      );

      if (existingSink.id.isNotEmpty) {
        _errorMessage = 'Sink name already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final updatedSink = sink.copyWith(name: name.trim());
      sinkRepository.upsertSink(updatedSink);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorCode = AppErrorCode.unknownError;
      _errorMessage = null; // Will be localized in UI using errorCode
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSink(SinkId sinkId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sink = _sinks.firstWhere(
        (s) => s.id == sinkId,
        orElse: () => throw Exception('Sink not found'),
      );

      // Prevent deletion of default sink
      if (sink.type == SinkType.defaultSink) {
        _errorMessage = 'Cannot delete default sink';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      sinkRepository.removeSink(sinkId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorCode = AppErrorCode.unknownError;
      _errorMessage = null; // Will be localized in UI using errorCode
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    _errorCode = null;
    notifyListeners();
  }
}

