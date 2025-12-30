import 'package:flutter/foundation.dart';

import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/warning/warning.dart';
import '../../../../platform/contracts/warning_repository.dart';

/// Controller for warning list page.
///
/// PARITY: Mirrors reef-b-app's WarningViewModel.
class WarningController extends ChangeNotifier {
  final AppSession session;
  final WarningRepository warningRepository;

  WarningController({
    required this.session,
    required this.warningRepository,
  });

  // State
  bool _isLoading = false;
  List<Warning> _warnings = [];
  AppErrorCode? _lastErrorCode;

  // Getters
  bool get isLoading => _isLoading;
  List<Warning> get warnings => List.unmodifiable(_warnings);
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  /// Initialize controller and load warnings.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _warnings = await warningRepository.getAllWarnings();
      // Sort by time (newest first)
      _warnings.sort((a, b) => b.time.compareTo(a.time));
      _clearError();
    } catch (e) {
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh warnings list.
  Future<void> refresh() async {
    await initialize();
  }

  /// Delete a warning.
  Future<void> deleteWarning(int warningId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await warningRepository.deleteWarning(warningId);
      // Reload
      await initialize();
      _clearError();
    } catch (e) {
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all warnings.
  Future<void> clearAllWarnings() async {
    _isLoading = true;
    notifyListeners();

    try {
      await warningRepository.clearAllWarnings();
      // Reload
      await initialize();
      _clearError();
    } catch (e) {
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  void _clearError() {
    _lastErrorCode = null;
  }
}

