import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/drop_type/drop_type.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../widgets/reef_app_bar.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../controllers/drop_type_controller.dart';

/// Drop type management page.
///
/// PARITY: Mirrors reef-b-app's DropTypeActivity.
class DropTypePage extends StatelessWidget {
  final int? initialDropTypeId;

  const DropTypePage({super.key, this.initialDropTypeId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
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
      appBar: ReefAppBar(
        backgroundColor: ReefColors.primary,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.dropTypeTitle,
          style: ReefTextStyles.title2.copyWith(
            color: ReefColors.onPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_selectedId ?? 0);
            },
            child: Text(
              l10n.actionDone,
              style: TextStyle(color: ReefColors.onPrimary),
            ),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!isConnected) ...[const BleGuardBanner()],
                Expanded(
                  child: ListView(
                    // PARITY: activity_drop_type.xml rv_drop_type
                    // RecyclerView with no padding (adapter items handle their own spacing)
                    padding: EdgeInsets.zero,
                    children: [
                      // Add "No" option
                      _buildDropTypeTile(
                        context,
                        controller,
                        null,
                        l10n.dropTypeNo,
                        l10n,
                      ),
                      const Divider(),
                      // Drop types list
                      ...controller.dropTypes.map(
                        (dropType) => _buildDropTypeTile(
                          context,
                          controller,
                          dropType,
                          dropType.name,
                          l10n,
                        ),
                      ),
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

  /// Drop type tile matching adapter_drop_type.xml layout.
  ///
  /// PARITY: Mirrors reef-b-app's adapter_drop_type.xml structure:
  /// - ConstraintLayout: padding 16/0/16/0dp
  /// - RadioButton
  /// - tv_name: body, text_aaaa
  /// - btn_edit: 24×24dp (optional)
  /// - Divider: bg_press
  Widget _buildDropTypeTile(
    BuildContext context,
    DropTypeController controller,
    DropType? dropType,
    String name,
    AppLocalizations l10n,
  ) {
    final int id = dropType?.id ?? 0;

    // PARITY: adapter_drop_type.xml structure
    return InkWell(
      onTap: () {
        setState(() {
          _selectedId = id;
        });
      },
      onLongPress: dropType != null
          ? () => _showDeleteDropTypeDialog(context, controller, dropType, l10n)
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: ReefSpacing.md, // dp_16 paddingStart/End
            ),
            child: Row(
              children: [
                // RadioButton
                Radio<int>(
                  value: id,
                  groupValue: _selectedId,
                  onChanged: (value) {
                    setState(() {
                      _selectedId = value;
                    });
                  },
                ),
                SizedBox(width: ReefSpacing.md), // dp_16 marginEnd
                // Name (tv_name) - body, text_aaaa
                Expanded(
                  child: Text(
                    name,
                    style: ReefTextStyles.body.copyWith(
                      color: ReefColors.textPrimary, // text_aaaa
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Edit button (btn_edit) - 24×24dp (optional)
                if (dropType != null) ...[
                  SizedBox(width: ReefSpacing.md), // dp_16 marginEnd
                  IconButton(
                    icon: Image.asset(
                      'assets/icons/ic_edit.png', // TODO: Add icon asset
                      width: 24, // dp_24
                      height: 24, // dp_24
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.edit,
                        size: 24,
                        color: ReefColors.textPrimary,
                      ),
                    ),
                    onPressed: () => _showEditDropTypeDialog(
                      context,
                      controller,
                      dropType,
                      l10n,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Divider (bg_press)
          Divider(
            height: 1, // dp_1
            thickness: 1, // dp_1
            color: ReefColors.surfacePressed, // bg_press
          ),
        ],
      ),
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
        title: Text(l10n.dropTypeAddTitle),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: l10n.dropTypeNameHint,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.actionAdd),
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
                l10n.dropTypeAddSuccess,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.dropTypeNameExists,
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
        title: Text(l10n.dropTypeEditTitle),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: l10n.dropTypeNameHint,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );

    if (result == true && textController.text.trim().isNotEmpty) {
      final bool success = await controller.editDropType(
        dropType.id,
        textController.text,
      );
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.dropTypeEditSuccess,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.dropTypeNameExists,
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
              ? (l10n.dropTypeDeleteUsedTitle)
              : (l10n.dropTypeDeleteTitle),
        ),
        content: Text(
          isUsed
              ? l10n.dropTypeDeleteUsedContent
              : l10n.dropTypeDeleteContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: ReefColors.error),
            child: Text(l10n.actionDelete),
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
                l10n.dropTypeDeleteSuccess,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.dropTypeDeleteFailed,
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
      final l10n = AppLocalizations.of(context);
      final message = describeAppError(l10n, code);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }
}
