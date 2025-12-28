import '../../domain/drop_type/drop_type.dart';

/// DropTypeRepository
///
/// Repository interface for managing drop types (liquid types for dosing pumps).
///
/// This is a local-only feature, stored in SQLite database.
/// No BLE communication is required.
abstract class DropTypeRepository {
  /// Observes all drop types.
  Stream<List<DropType>> observeDropTypes();

  /// Gets all drop types.
  Future<List<DropType>> getAllDropTypes();

  /// Gets a drop type by ID.
  Future<DropType?> getDropTypeById(int id);

  /// Adds a new drop type.
  /// Returns the ID of the inserted drop type, or -1 if insertion failed.
  Future<int> addDropType(DropType dropType);

  /// Updates an existing drop type.
  /// Returns the number of rows updated (0 if not found).
  Future<int> updateDropType(DropType dropType);

  /// Deletes a drop type by ID.
  Future<void> deleteDropType(int id);

  /// Checks if a drop type is being used by any pump head.
  Future<bool> isDropTypeUsed(int dropTypeId);
}

