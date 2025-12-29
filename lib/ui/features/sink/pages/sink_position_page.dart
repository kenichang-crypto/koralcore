import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../controllers/sink_manager_controller.dart';

/// Sink position selection page.
///
/// PARITY: Mirrors reef-b-app's SinkPositionActivity.
class SinkPositionPage extends StatelessWidget {
  final String? initialSinkId;

  const SinkPositionPage({
    super.key,
    this.initialSinkId,
  });

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final sinkRepository = appContext.sinkRepository;

    return ChangeNotifierProvider<SinkManagerController>(
      create: (_) => SinkManagerController(
        sinkRepository: sinkRepository,
      )..reload(),
      child: _SinkPositionView(initialSinkId: initialSinkId),
    );
  }
}

class _SinkPositionView extends StatefulWidget {
  final String? initialSinkId;

  const _SinkPositionView({this.initialSinkId});

  @override
  State<_SinkPositionView> createState() => _SinkPositionViewState();
}

class _SinkPositionViewState extends State<_SinkPositionView> {
  String? _selectedSinkId;

  @override
  void initState() {
    super.initState();
    _selectedSinkId = widget.initialSinkId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<SinkManagerController>();

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
        title: Text(l10n.sinkPositionTitle),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_selectedSinkId ?? '');
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
          : ListView(
              padding: const EdgeInsets.all(ReefSpacing.lg),
              children: [
                // "No" option
                ListTile(
                  title: Text(l10n.sinkPositionNotSet),
                  selected: _selectedSinkId == null || _selectedSinkId == '',
                  selectedTileColor: ReefColors.primary.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      _selectedSinkId = '';
                    });
                  },
                ),
                const Divider(),
                // Sink list
                ...controller.sinks.map((sink) => ListTile(
                      title: Text(sink.name),
                      selected: _selectedSinkId == sink.id,
                      selectedTileColor: ReefColors.primary.withOpacity(0.1),
                      onTap: () {
                        setState(() {
                          _selectedSinkId = sink.id;
                        });
                      },
                    )),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSinkDialog(context, controller, l10n),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddSinkDialog(
    BuildContext context,
    SinkManagerController controller,
    AppLocalizations l10n,
  ) async {
    final textController = TextEditingController();
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sinkAddTitle),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: l10n.sinkNameLabel,
            hintText: l10n.sinkNameHint,
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
      final bool success = await controller.addSink(textController.text);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.sinkAddSuccess,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.sinkNameExists,
              ),
            ),
          );
        }
      }
    }
  }
}

