import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../domain/sink/sink.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
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
          body: _buildBody(context, controller, l10n),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            ElevatedButton(
              onPressed: () {
                controller.clearError();
                controller.reload();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (controller.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              l10n.sinkEmptyStateTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              l10n.sinkEmptyStateSubtitle,
              style: const TextStyle(
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacingXL),
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
          ElevatedButton(
            onPressed: () async {
              // ignore: unused_local_variable
              final success = await controller.deleteSink(sink.id);
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: ListTile(
        leading: Icon(
          Icons.water_drop,
          color: sink.type == SinkType.defaultSink
              ? AppColors.primary
              : AppColors.grey600,
        ),
        title: Text(sink.name),
        subtitle: Text(
          '${sink.deviceIds.length} ${sink.deviceIds.length == 1 ? 'device' : 'devices'}',
        ),
        trailing: sink.type == SinkType.defaultSink
            ? const Chip(
                label: Text('Default'),
                padding: EdgeInsets.symmetric(horizontal: 8),
              )
            : const Icon(Icons.chevron_right),
        onTap: sink.type == SinkType.defaultSink ? null : onTap,
        onLongPress: sink.type == SinkType.defaultSink ? null : onLongPress,
      ),
    );
  }
}

