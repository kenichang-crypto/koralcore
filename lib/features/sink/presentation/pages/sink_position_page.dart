import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/assets/common_icon_helper.dart';
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
      backgroundColor: AppColors.surfaceMuted,
      appBar: ReefAppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: CommonIconHelper.getCloseIcon(size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.sinkPositionTitle,
          style: AppTextStyles.title2.copyWith(
            color: AppColors.onPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_selectedSinkId ?? '');
            },
            child: Text(
              l10n.actionDone,
              style: TextStyle(color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              // PARITY: activity_sink_position.xml rv_sink
              // RecyclerView with no padding (adapter items handle their own spacing)
              padding: EdgeInsets.zero,
              children: [
                // "No" option - PARITY: adapter_sink_select.xml
                _buildSinkSelectTile(
                  context: context,
                  name: l10n.sinkPositionNotSet,
                  isSelected: _selectedSinkId == null || _selectedSinkId == '',
                  onTap: () {
                    setState(() {
                      _selectedSinkId = '';
                    });
                  },
                ),
                // Sink list - PARITY: adapter_sink_select.xml
                ...controller.sinks.map((sink) => _buildSinkSelectTile(
                      context: context,
                      name: sink.name,
                      isSelected: _selectedSinkId == sink.id,
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
        child: CommonIconHelper.getAddIcon(size: 24),
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

  /// Sink select tile matching adapter_sink_select.xml layout.
  ///
  /// PARITY: Mirrors reef-b-app's adapter_sink_select.xml structure:
  /// - ConstraintLayout: padding 16/0/16/0dp
  /// - RadioButton
  /// - tv_name: body, text_aaaa
  /// - Divider: bg_press
  Widget _buildSinkSelectTile({
    required BuildContext context,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md, // dp_16 paddingStart/End
            ),
            child: Row(
              children: [
                // RadioButton
                Radio<bool>(
                  value: true,
                  groupValue: isSelected,
                  onChanged: (_) => onTap(),
                ),
                SizedBox(width: AppSpacing.md), // dp_16 marginEnd
                // Name (tv_name) - body, text_aaaa
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary, // text_aaaa
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Divider (bg_press)
          Divider(
            height: 1, // dp_1
            thickness: 1, // dp_1
            color: AppColors.surfacePressed, // bg_press
          ),
        ],
      ),
    );
  }
}

