import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../domain/sink/sink.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../widgets/reef_backgrounds.dart';
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
          appBar: AppBar(
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

    return ListView.builder(
      padding: const EdgeInsets.all(ReefSpacing.xl),
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
    return Card(
      margin: const EdgeInsets.only(bottom: ReefSpacing.sm),
      child: ListTile(
        leading: Icon(
          Icons.water_drop,
          color: sink.type == SinkType.defaultSink
              ? ReefColors.primary
              : ReefColors.textSecondary,
        ),
        title: Text(sink.name),
        subtitle: Text(
          l10n.sinkDeviceCount(sink.deviceIds.length),
        ),
        trailing: sink.type == SinkType.defaultSink
            ? Chip(
                label: Text(l10n.sinkTypeDefault),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              )
            : const Icon(Icons.chevron_right),
        onTap: sink.type == SinkType.defaultSink ? null : onTap,
        onLongPress: sink.type == SinkType.defaultSink ? null : onLongPress,
      ),
    );
  }
}

