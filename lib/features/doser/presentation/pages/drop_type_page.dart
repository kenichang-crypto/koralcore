// PARITY: 100% Android activity_drop_type.xml
// android/ReefB_Android/app/src/main/res/layout/activity_drop_type.xml
//
// PARITY: reef DropTypeActivity - back->finish, right->setResult+finish, FAB->add,
// tap->edit, longPress->delete (with isUsed check)

import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/widgets/edit_text_bottom_sheet.dart';
import '../controllers/drop_type_controller.dart';

class _DropTypeListItem {
  final int id;
  final String name;
  final bool isPreset;

  _DropTypeListItem({
    required this.id,
    required this.name,
    required this.isPreset,
  });
}

/// DropTypePage - PARITY with reef DropTypeActivity
///
/// reef: back->finish, right->setResult(drop_type_id)+finish, FAB->add,
/// tap->edit, longPress->delete
class DropTypePage extends StatelessWidget {
  /// Initial drop type id when opened as selector (e.g. from pump head settings).
  final int? initialDropTypeId;

  const DropTypePage({super.key, this.initialDropTypeId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();

    return ChangeNotifierProvider<DropTypeController>(
      create: (_) => DropTypeController(
        dropTypeRepository: appContext.dropTypeRepository,
        pumpHeadRepository: appContext.pumpHeadRepository,
        initialDropTypeId: initialDropTypeId,
      )..initialize(),
      child: const _DropTypePageContent(),
    );
  }
}

class _DropTypePageContent extends StatelessWidget {
  const _DropTypePageContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<DropTypeController>(
      builder: (context, controller, _) {
        // reef: prepend DropType(0, "No")
        final List<_DropTypeListItem> items = [
          _DropTypeListItem(id: 0, name: l10n.generalNone, isPreset: true),
          ...controller.dropTypes.map((dt) => _DropTypeListItem(
                id: dt.id,
                name: dt.name,
                isPreset: dt.isPreset,
              )),
        ];
        final selectedId = controller.selectedDropTypeId ?? 0;

        return Scaffold(
          backgroundColor: AppColors.surfaceMuted,
          body: Stack(
            children: [
              Column(
                children: [
                  _ToolbarTwoAction(
                    l10n: l10n,
                    onBack: () => Navigator.of(context).pop(),
                    onConfirm: () => Navigator.of(context).pop(selectedId),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isNo = item.id == 0;
                        return _DropTypeItem(
                          id: item.id,
                          name: item.name,
                          selectedId: selectedId,
                          onTap: () =>
                              controller.setSelectedDropTypeId(item.id),
                          onEditPressed: isNo
                              ? null
                              : () => _showEditDropTypeBottomSheet(
                                    context,
                                    controller,
                                    item.id,
                                    item.name,
                                  ),
                          onLongPress: isNo
                              ? null
                              : () => _showDeleteDropTypeDialog(
                                    context,
                                    controller,
                                    item.id,
                                  ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () =>
                      _showAddDropTypeBottomSheet(context, controller),
                  child: CommonIconHelper.getAddIcon(
                    size: 24,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
              _ProgressOverlay(visible: controller.isLoading),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _showAddDropTypeBottomSheet(
  BuildContext context,
  DropTypeController controller,
) async {
  final result = await EditTextBottomSheet.show(
    context,
    type: EditTextBottomSheetType.addDropType,
  );
  if (context.mounted && result != null && result.trim().isNotEmpty) {
    final success = await controller.addDropType(result.trim());
    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).dropTypeAddSuccess),
        ),
      );
    } else if (context.mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).dropTypeNameExists),
        ),
      );
    }
  }
}

Future<void> _showEditDropTypeBottomSheet(
  BuildContext context,
  DropTypeController controller,
  int id,
  String currentName,
) async {
  final result = await EditTextBottomSheet.show(
    context,
    type: EditTextBottomSheetType.editDropType,
    initialValue: currentName,
  );
  if (context.mounted && result != null && result.trim().isNotEmpty) {
    final success = await controller.editDropType(id, result.trim());
    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).dropTypeEditSuccess),
        ),
      );
    } else if (context.mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).dropTypeNameExists),
        ),
      );
    }
  }
}

Future<void> _showDeleteDropTypeDialog(
  BuildContext context,
  DropTypeController controller,
  int id,
) async {
  final l10n = AppLocalizations.of(context);
  final isUsed = await controller.isDropTypeUsed(id);
  if (!context.mounted) return;

  if (isUsed) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dropTypeDeleteUsedTitle),
        content: Text(l10n.dropTypeDeleteUsedContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (context.mounted && confirmed == true) {
      await controller.deleteDropType(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.dropTypeDeleteSuccess)),
        );
      }
    }
  } else {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dropTypeDeleteTitle),
        content: Text(l10n.dropTypeDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (context.mounted && confirmed == true) {
      await controller.deleteDropType(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.dropTypeDeleteSuccess)),
        );
      }
    }
  }
}

class _ToolbarTwoAction extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  const _ToolbarTwoAction({
    required this.l10n,
    required this.onBack,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(top: 40, bottom: 8),
      child: Row(
        children: [
          IconButton(
            icon: CommonIconHelper.getCloseIcon(
              size: 24,
              color: AppColors.onPrimary,
            ),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              l10n.dosingTypeTitle,
              style: AppTextStyles.title2.copyWith(color: AppColors.onPrimary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onConfirm,
            child: Text(
              l10n.actionConfirm,
              style: AppTextStyles.body.copyWith(color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropTypeItem extends StatelessWidget {
  final int id;
  final String name;
  final int selectedId;
  final VoidCallback? onTap;
  final VoidCallback? onEditPressed;
  final VoidCallback? onLongPress;

  const _DropTypeItem({
    required this.id,
    required this.name,
    required this.selectedId,
    this.onTap,
    this.onEditPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Radio<int>(
                  value: id,
                  groupValue: selectedId,
                  onChanged: onTap != null ? (_) => onTap!() : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onEditPressed != null) ...[
                  const SizedBox(width: 16),
                  IconButton(
                    icon: CommonIconHelper.getEditIcon(
                      size: 24,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: onEditPressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.surfacePressed,
          ),
        ],
      ),
    );
  }
}

class _ProgressOverlay extends StatelessWidget {
  final bool visible;

  const _ProgressOverlay({required this.visible});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
