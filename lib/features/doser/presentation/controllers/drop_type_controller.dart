import 'package:flutter/foundation.dart';

import '../../../../app/common/app_error_code.dart';
import '../../../../domain/drop_type/drop_type.dart';
import '../../../../platform/contracts/drop_type_repository.dart';
import '../../../../platform/contracts/pump_head_repository.dart';

/// Controller for drop type management page.
///
/// PARITY: Mirrors reef-b-app's DropTypeViewModel.
class DropTypeController extends ChangeNotifier {
  final DropTypeRepository dropTypeRepository;
  final PumpHeadRepository pumpHeadRepository;

  DropTypeController({
    required this.dropTypeRepository,
    required this.pumpHeadRepository,
  });

  // State
  bool _isLoading = false;
  List<DropType> _dropTypes = [];
  int? _selectedDropTypeId;
  AppErrorCode? _lastErrorCode;

  // Getters
  bool get isLoading => _isLoading;
  List<DropType> get dropTypes => List.unmodifiable(_dropTypes);
  int? get selectedDropTypeId => _selectedDropTypeId;
  AppErrorCode? get lastErrorCode => _lastErrorCode;

  /// Initialize controller and load drop types.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dropTypes = await dropTypeRepository.getAllDropTypes();
      _clearError();
    } catch (e) {
      _setError(AppErrorCode.unknownError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set selected drop type.
  void setSelectedDropTypeId(int? id) {
    _selectedDropTypeId = id;
    notifyListeners();
  }

  /// Add new drop type.
  Future<bool> addDropType(String name) async {
    if (name.trim().isEmpty) {
      _setError(AppErrorCode.invalidParam);
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Check if name already exists
      final existing = _dropTypes
          .where((dt) => dt.name == name.trim())
          .toList();
      if (existing.isNotEmpty) {
        _setError(AppErrorCode.invalidParam);
        return false;
      }

      final DropType newType = DropType.create(name: name.trim());
      await dropTypeRepository.addDropType(newType);

      // Reload
      await initialize();

      _clearError();
      return true;
    } catch (e) {
      _setError(AppErrorCode.unknownError);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Edit drop type.
  Future<bool> editDropType(int id, String name) async {
    if (name.trim().isEmpty) {
      _setError(AppErrorCode.invalidParam);
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Check if name already exists (excluding current)
      final existing = _dropTypes
          .where((dt) => dt.name == name.trim() && dt.id != id)
          .toList();
      if (existing.isNotEmpty) {
        _setError(AppErrorCode.invalidParam);
        return false;
      }

      final DropType current = _dropTypes.firstWhere(
        (dt) => dt.id == id,
        orElse: () => throw Exception('DropType not found'),
      );

      final DropType updated = current.copyWith(name: name.trim());
      await dropTypeRepository.updateDropType(updated);

      // Reload
      await initialize();

      _clearError();
      return true;
    } catch (e) {
      _setError(AppErrorCode.unknownError);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete drop type.
  Future<bool> deleteDropType(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if drop type is used
      final bool isUsed = await dropTypeRepository.isDropTypeUsed(id);
      if (isUsed) {
        // Clear drop type from pump heads that use it
        // TODO: Implement clearing drop type from pump heads
        // For now, we'll still delete it
      }

      await dropTypeRepository.deleteDropType(id);

      // Reload
      await initialize();

      _clearError();
      return true;
    } catch (e) {
      _setError(AppErrorCode.unknownError);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if drop type is used.
  Future<bool> isDropTypeUsed(int id) async {
    try {
      return await dropTypeRepository.isDropTypeUsed(id);
    } catch (e) {
      return false;
    }
  }

  void _setError(AppErrorCode code) {
    _lastErrorCode = code;
  }

  void _clearError() {
    _lastErrorCode = null;
  }
}
