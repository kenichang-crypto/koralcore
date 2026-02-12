import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../domain/sink/sink.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/widgets/edit_text_bottom_sheet.dart';
import '../controllers/sink_manager_controller.dart';

class SinkManagerPage extends StatelessWidget {
  const SinkManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final sinkRepository = appContext.sinkRepository;

    return ChangeNotifierProvider<SinkManagerController>(
      create: (_) => SinkManagerController(sinkRepository: sinkRepository),
      child: const _SinkManagerView(),
    );
  }
}

Future<void> _showAddSinkBottomSheet(
  BuildContext context,
  SinkManagerController controller,
) async {
  final result = await EditTextBottomSheet.show(
    context,
    type: EditTextBottomSheetType.addSink,
  );
  if (context.mounted && result != null && result.trim().isNotEmpty) {
    final success = await controller.addSink(result.trim());
    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).sinkAddSuccess)),
      );
    } else if (context.mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).sinkNameExists)),
      );
    }
  }
}

Future<void> _showEditSinkBottomSheet(
  BuildContext context,
  SinkManagerController controller,
  Sink sink,
) async {
  final result = await EditTextBottomSheet.show(
    context,
    type: EditTextBottomSheetType.editSink,
    initialValue: sink.name,
  );
  if (context.mounted && result != null && result.trim().isNotEmpty) {
    final success = await controller.editSink(sink.id, result.trim());
    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).sinkEditSuccess)),
      );
    } else if (context.mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).sinkNameExists)),
      );
    }
  }
}

Future<void> _showDeleteSinkDialog(
  BuildContext context,
  SinkManagerController controller,
  Sink sink,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.sinkDeleteTitle),
      content: Text(l10n.sinkDeleteMessage),
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
    await controller.deleteSink(sink.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sinkDeleteSuccess)),
      );
    }
  }
}

class _SinkManagerView extends StatelessWidget {
  const _SinkManagerView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<SinkManagerController>(
      builder: (context, controller, _) {
        // PARITY: activity_sink_manager.xml
        // - Root background: @color/bg_aaa
        // - include toolbar_two_action + 2dp divider
        // - rv_sink_manager (marginTop 13dp) OR layout_no_sink
        // - fab_add_sink (bottom-end, margin 16dp)
        // - include progress overlay (gone by default)
        return Scaffold(
          backgroundColor: AppColors.surfaceMuted, // bg_aaa
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _ToolbarTwoAction(onBack: () => Navigator.of(context).pop()),
                    Expanded(
                      child: _SinkManagerContent(
                        controller: controller,
                        l10n: l10n,
                      ),
                    ),
                  ],
                ),
                // PARITY: fab_add_sink (ic_add_white), reef: ModalBottomSheetEdittext ADD_SINK
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    onPressed: () => _showAddSinkBottomSheet(context, controller),
                    backgroundColor: AppColors.primary,
                    child: CommonIconHelper.getAddWhiteIcon(size: 24),
                  ),
                ),
                // PARITY: include @layout/progress (full-screen, clickable overlay)
                if (controller.isLoading) const _ProgressOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToolbarTwoAction extends StatelessWidget {
  final VoidCallback onBack;

  const _ToolbarTwoAction({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // PARITY: docs/reef_b_app_res/layout/toolbar_two_action.xml
    // reef: btnBack.setOnClickListener { finish() }
    return Material(
      color: AppColors.surface, // white
      child: Column(
        children: [
          SizedBox(
            height: kToolbarHeight,
            width: double.infinity,
            child: Row(
              children: [
                // Left: btn_back (56x44dp) - reef: finish()
                IconButton(
                  onPressed: onBack,
                  icon: CommonIconHelper.getBackIcon(
                    size: 24,
                    color: AppColors.textPrimary,
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  constraints: const BoxConstraints(
                    minWidth: 56,
                    minHeight: 44,
                  ),
                ),
                // Center: toolbar_title
                Expanded(
                  child: Text(
                    l10n.sinkManagerTitle,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary, // text_aaaa
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Right placeholder (reserve space similar to end controls)
                const SizedBox(width: 56, height: 44),
              ],
            ),
          ),
          Container(height: 2, color: AppColors.surfacePressed),
        ],
      ),
    );
  }
}

class _SinkManagerContent extends StatelessWidget {
  final SinkManagerController controller;
  final AppLocalizations l10n;

  const _SinkManagerContent({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    // PARITY: activity_sink_manager.xml
    // - rv_sink_manager is gone by default, layout_no_sink shown when empty
    if (controller.isEmpty) {
      return _NoSinkState(l10n: l10n);
    }

    // PARITY: rv_sink_manager, reef: onClickSink->edit, onLongClickSink->delete
    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: controller.sinks.length,
        itemBuilder: (context, index) {
          final sink = controller.sinks[index];
          return _SinkCard(
            sink: sink,
            onTap: sink.type != SinkType.defaultSink
                ? () => _showEditSinkBottomSheet(context, controller, sink)
                : null,
            onLongPress: sink.type != SinkType.defaultSink
                ? () => _showDeleteSinkDialog(context, controller, sink)
                : null,
          );
        },
      ),
    );
  }
}

class _NoSinkState extends StatelessWidget {
  final AppLocalizations l10n;

  const _NoSinkState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    // PARITY: activity_sink_manager.xml - layout_no_sink
    // - text_no_sink_title (subheader_accent)
    // - text_no_sink_content (body, text_aaa), marginTop 8dp
    //
    // TODO(android @string/text_no_sink_title, @string/text_no_sink_content):
    // 目前 ARB 未發現對應 key；暫用既有 sinkEmptyStateTitle/Subtitle（文字需後續對齊 Android）。
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.sinkEmptyStateTitle,
            style: AppTextStyles.subheaderAccent.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.sinkEmptyStateSubtitle,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary, // text_aaa
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay();

  @override
  Widget build(BuildContext context) {
    // PARITY: docs/reef_b_app_res/layout/progress.xml
    // - Full screen overlay, background #4D000000, centered ProgressBar
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: Container(
          color: const Color(0x4D000000),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

/// Sink card matching adapter_sink.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_sink.xml structure:
/// - ConstraintLayout: selectableItemBackground
/// - Inner: white background, padding 16/8/16/8dp
/// - tv_sink_name: caption1_accent
/// - tv_device_amount: caption1, text_aa
/// - btn_edit: 24×24dp
/// - Two dividers: bg_aaa (full width) and bg_press (with 16dp margin)
class _SinkCard extends StatelessWidget {
  final Sink sink;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _SinkCard({required this.sink, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String deviceCount = l10n.sinkDeviceCount(sink.deviceIds.length);

    // PARITY: adapter_sink.xml, reef: onClickSink->edit, onLongClickSink->delete
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Inner container (white background)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: AppSpacing.md, // dp_16 paddingStart
              top: AppSpacing.xs, // dp_8 paddingTop
              right: AppSpacing.md, // dp_16 paddingEnd
              bottom: AppSpacing.xs, // dp_8 paddingBottom
            ),
            decoration: BoxDecoration(
              color: AppColors.surface, // white
            ),
            child: Row(
              children: [
                // Sink name (tv_sink_name) - caption1_accent
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sink.name,
                        style: AppTextStyles.caption1Accent.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: AppSpacing.xs,
                      ), // dp_8 marginTop (implicit)
                      // Device amount (tv_device_amount) - caption1, text_aa
                      Text(
                        deviceCount,
                        style: AppTextStyles.caption1.copyWith(
                          color: AppColors.textSecondary, // text_aa
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.xs), // dp_4 marginEnd
                // Edit button (btn_edit) - 24×24dp
                // PARITY: Using CommonIconHelper.getEditIcon() for 100% parity
                if (sink.type != SinkType.defaultSink)
                  IconButton(
                    icon: CommonIconHelper.getEditIcon(
                      size: 24,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: onTap,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
              ],
            ),
          ),
          // First divider (bg_aaa, full width)
          Divider(
            height: 1, // dp_1
            thickness: 1, // dp_1
            color: AppColors.surfaceMuted, // bg_aaa
          ),
          // Second divider (bg_press, with 16dp margin)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ), // dp_16 marginStart/End
            child: Divider(
              height: 1, // dp_1
              thickness: 1, // dp_1
              color: AppColors.surfacePressed, // bg_press
            ),
          ),
        ],
      ),
    );
  }
}
