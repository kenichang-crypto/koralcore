import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/drop_type/drop_type.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../controllers/drop_type_controller.dart';

/// Drop type management page.
///
/// PARITY: Mirrors reef-b-app's DropTypeActivity.
class DropTypePage extends StatelessWidget {
  final int? initialDropTypeId;

  const DropTypePage({
    super.key,
    this.initialDropTypeId,
  });

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<DropTypeController>(
      create: (_) => DropTypeController(
        dropTypeRepository: appContext.dropTypeRepository,
        pumpHeadRepository: appContext.pumpHeadRepository,
      )..initialize(),
      child: _DropTypeView(initialDropTypeId: initialDropTypeId),
    );
  }
}

class _DropTypeView extends StatefulWidget {
  final int? initialDropTypeId;

  const _DropTypeView({this.initialDropTypeId});

  @override
  State<_DropTypeView> createState() => _DropTypeViewState();
}

class _DropTypeViewState extends State<_DropTypeView> {
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialDropTypeId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<DropTypeController>();
    final isConnected = session.isBleConnected;

    _maybeShowError(context, controller.lastErrorCode);

    return Scaffold(
      backgroundColor: ReefColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: ReefColors.primary,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        titleTextStyle: ReefTextStyles.title2.copyWith(
          color: ReefColors.onPrimary,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.dropTypeTitle ?? 'Drop Type'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_selectedId ?? 0);
            },
            child: Text(
              l10n.actionDone ?? 'Done',
              style: TextStyle(color: ReefColors.onPrimary),
            ),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!isConnected) ...[
                  const BleGuardBanner(),
                ],
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(ReefSpacing.lg),
                    children: [
                      // Add "No" option
                      _buildDropTypeTile(
                        context,
                        controller,
                        null,
                        l10n.dropTypeNo ?? 'No',
                        l10n,
                      ),
                      const Divider(),
                      // Drop types list
                      ...controller.dropTypes.map((dropType) =>
                          _buildDropTypeTile(
                            context,
                            controller,
                            dropType,
                            dropType.name,
                            l10n,
                          )),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDropTypeDialog(context, controller, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDropTypeTile(
    BuildContext context,
    DropTypeController controller,
    DropType? dropType,
    String name,
    AppLocalizations l10n,
  ) {
    final int id = dropType?.id ?? 0;
    final bool isSelected = _selectedId == id;

    return ListTile(
      title: Text(name),
      selected: isSelected,
      selectedTileColor: ReefColors.primary.withOpacity(0.1),
      trailing: dropType != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDropTypeDialog(
                    context,
                    controller,
                    dropType,
                    l10n,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteDropTypeDialog(
                    context,
                    controller,
                    dropType,
                    l10n,
                  ),
                ),
              ],
            )
          : null,
      onTap: () {
        setState(() {
          _selectedId = id;
        });
      },
      onLongPress: dropType != null
          ? () => _showDeleteDropTypeDialog(
                context,
                controller,
                dropType,
                l10n,
              )
          : null,
    );
  }

  Future<void> _showAddDropTypeDialog(
    BuildContext context,
    DropTypeController controller,
    AppLocalizations l10n,
  ) async {
    final textController = TextEditingController();
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.dropTypeAddTitle ?? 'Add Drop Type'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: l10n.dropTypeNameLabel ?? 'Name',
            hintText: l10n.dropTypeNameHint ?? 'Enter drop type name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.actionAdd ?? 'Add'),
          ),
        ],
      ),
    );

    if (result == true && textController.text.trim().isNotEmpty) {
      final bool success = await controller.addDropType(textController.text);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.dropTypeAddSuccess ?? 'Drop type added successfully',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.dropTypeNameExists ?? 'Drop type name already exists',
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditDropTypeDialog(
    BuildContext context,
    DropTypeController controller,
    DropType dropType,
    AppLocalizations l10n,
  ) async {
    final textController = TextEditingController(text: dropType.name);
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.dropTypeEditTitle ?? 'Edit Drop Type'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: l10n.dropTypeNameLabel ?? 'Name',
            hintText: l10n.dropTypeNameHint ?? 'Enter drop type name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.actionSave ?? 'Save'),
          ),
        ],
      ),
    );

    if (result == true && textController.text.trim().isNotEmpty) {
      final bool success =
          await controller.editDropType(dropType.id, textController.text);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.dropTypeEditSuccess ?? 'Drop type updated successfully',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.dropTypeNameExists ?? 'Drop type name already exists',
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _showDeleteDropTypeDialog(
    BuildContext context,
    DropTypeController controller,
    DropType dropType,
    AppLocalizations l10n,
  ) async {
    final bool isUsed = await controller.isDropTypeUsed(dropType.id);
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isUsed
              ? (l10n.dropTypeDeleteUsedTitle ??
                  'Drop Type is in Use')
              : (l10n.dropTypeDeleteTitle ?? 'Delete Drop Type'),
        ),
        content: Text(
          isUsed
              ? (l10n.dropTypeDeleteUsedContent ??
                  'This drop type is currently used by pump heads. Do you want to delete it anyway?')
              : (l10n.dropTypeDeleteContent ??
                  'Are you sure you want to delete "${dropType.name}"?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: ReefColors.error,
            ),
            child: Text(l10n.actionDelete ?? 'Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      final bool success = await controller.deleteDropType(dropType.id);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.dropTypeDeleteSuccess ?? 'Drop type deleted successfully',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.dropTypeDeleteFailed ?? 'Failed to delete drop type',
              ),
            ),
          );
        }
      }
    }
  }

  void _maybeShowError(BuildContext context, AppErrorCode? code) {
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<DropTypeController>();
      final l10n = AppLocalizations.of(context);
      final message = describeAppError(l10n, code);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }
}

