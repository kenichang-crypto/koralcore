import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../domain/sink/sink.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../widgets/reef_backgrounds.dart';
import '../../../widgets/reef_app_bar.dart';
import '../../../components/error_state_widget.dart';
import '../../../components/loading_state_widget.dart';
import '../../../components/empty_state_widget.dart';
import '../controllers/sink_manager_controller.dart';

class SinkManagerPage extends StatelessWidget {
  const SinkManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final sinkRepository = appContext.sinkRepository;

    return ChangeNotifierProvider<SinkManagerController>(
      create: (_) => SinkManagerController(
        sinkRepository: sinkRepository,
      ),
      child: const _SinkManagerView(),
    );
  }
}

class _SinkManagerView extends StatelessWidget {
  const _SinkManagerView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<SinkManagerController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: ReefAppBar(
            title: Text(l10n.sinkManagerTitle),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddSinkDialog(context, controller),
            child: const Icon(Icons.add),
          ),
          body: ReefMainBackground(
            child: _buildBody(context, controller, l10n),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    SinkManagerController controller,
    AppLocalizations l10n,
  ) {
    if (controller.isLoading) {
      return const LoadingStateWidget.center();
    }

    if (controller.errorCode != null || controller.errorMessage != null) {
      return ErrorStateWidget(
        errorCode: controller.errorCode,
        customMessage: controller.errorMessage,
        onRetry: () {
          controller.clearError();
          controller.reload();
        },
      );
    }

    if (controller.isEmpty) {
      return EmptyStateWidget(
        title: l10n.sinkEmptyStateTitle,
        subtitle: l10n.sinkEmptyStateSubtitle,
        icon: Icons.water_drop_outlined,
      );
    }

    // PARITY: activity_sink_manager.xml rv_sink_manager
    // RecyclerView with marginTop 13dp, no padding (padding is handled by adapter items)
    return ListView.builder(
      padding: EdgeInsets.zero, // No padding - adapter items handle their own spacing
      itemCount: controller.sinks.length,
      itemBuilder: (context, index) {
        final sink = controller.sinks[index];
        return _SinkCard(
          sink: sink,
          onTap: () => _showEditSinkDialog(context, controller, sink),
          onLongPress: () => _showDeleteSinkDialog(
            context,
            controller,
            sink,
            l10n,
          ),
        );
      },
    );
  }

  void _showAddSinkDialog(
    BuildContext context,
    SinkManagerController controller,
  ) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).sinkAddTitle),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).sinkNameLabel,
            hintText: AppLocalizations.of(context).sinkNameHint,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                final success = await controller.addSink(name);
                if (success && dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              }
            },
            child: Text(AppLocalizations.of(context).add),
          ),
        ],
      ),
    );
  }

  void _showEditSinkDialog(
    BuildContext context,
    SinkManagerController controller,
    Sink sink,
  ) {
    final textController = TextEditingController(text: sink.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).sinkEditTitle),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).sinkNameLabel,
            hintText: AppLocalizations.of(context).sinkNameHint,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                final success = await controller.editSink(sink.id, name);
                if (success && dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              }
            },
            child: Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
    );
  }

  void _showDeleteSinkDialog(
    BuildContext context,
    SinkManagerController controller,
    Sink sink,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sinkDeleteTitle),
        content: Text(
          l10n.sinkDeleteMessage.replaceAll('{name}', sink.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              // ignore: unused_local_variable
              final success = await controller.deleteSink(sink.id);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: ReefColors.danger,
            ),
            child: Text(l10n.delete),
          ),
        ],
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

  const _SinkCard({
    required this.sink,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String deviceCount = l10n.sinkDeviceCount(sink.deviceIds.length);

    // PARITY: adapter_sink.xml structure
    return InkWell(
      onTap: sink.type == SinkType.defaultSink ? null : onTap,
      onLongPress: sink.type == SinkType.defaultSink ? null : onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Inner container (white background)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: ReefSpacing.md, // dp_16 paddingStart
              top: ReefSpacing.xs, // dp_8 paddingTop
              right: ReefSpacing.md, // dp_16 paddingEnd
              bottom: ReefSpacing.xs, // dp_8 paddingBottom
            ),
            decoration: BoxDecoration(
              color: ReefColors.surface, // white
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
                        style: ReefTextStyles.caption1Accent.copyWith(
                          color: ReefColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: ReefSpacing.xs), // dp_8 marginTop (implicit)
                      // Device amount (tv_device_amount) - caption1, text_aa
                      Text(
                        deviceCount,
                        style: ReefTextStyles.caption1.copyWith(
                          color: ReefColors.textSecondary, // text_aa
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ReefSpacing.xs), // dp_4 marginEnd
                // Edit button (btn_edit) - 24×24dp
                if (sink.type != SinkType.defaultSink)
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
                    onPressed: onTap,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
              ],
            ),
          ),
          // First divider (bg_aaa, full width)
          Divider(
            height: 1, // dp_1
            thickness: 1, // dp_1
            color: ReefColors.surfaceMuted, // bg_aaa
          ),
          // Second divider (bg_press, with 16dp margin)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ReefSpacing.md), // dp_16 marginStart/End
            child: Divider(
              height: 1, // dp_1
              thickness: 1, // dp_1
              color: ReefColors.surfacePressed, // bg_press
            ),
          ),
        ],
      ),
    );
  }
}

