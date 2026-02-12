import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../controllers/sink_manager_controller.dart';
import 'sink_manager_page.dart';

/// Sink position selection page.
///
/// PARITY: Mirrors reef-b-app's SinkPositionActivity.
class SinkPositionPage extends StatelessWidget {
  final String? initialSinkId;

  const SinkPositionPage({super.key, this.initialSinkId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final sinkRepository = appContext.sinkRepository;

    return ChangeNotifierProvider<SinkManagerController>(
      // UI parity only: do not trigger reload / side-effects here
      create: (_) => SinkManagerController(sinkRepository: sinkRepository),
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

    // PARITY: activity_sink_position.xml
    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _ToolbarTwoAction(
                  title: l10n.sinkPositionTitle,
                  rightText: l10n.actionConfirm,
                  onBack: () => Navigator.of(context).pop(),
                  onConfirm: () => Navigator.of(context).pop(_selectedSinkId),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: controller.sinks.length,
                    itemBuilder: (context, index) {
                      final sink = controller.sinks[index];
                      return _SinkSelectTile(
                        name: sink.name,
                        isSelected:
                            _selectedSinkId != null && _selectedSinkId == sink.id,
                        onTap: () => setState(() => _selectedSinkId = sink.id),
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
                onPressed: () {
                  // PARITY: fab_add_sink - navigate to add sink (SinkManagerPage handles add)
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SinkManagerPage(),
                    ),
                  ).then((_) {
                    if (context.mounted) controller.reload();
                  });
                },
                backgroundColor: AppColors.primary,
                child: CommonIconHelper.getAddWhiteIcon(size: 24),
              ),
            ),
            if (controller.isLoading) const _ProgressOverlay(),
          ],
        ),
      ),
    );
  }
}

class _ToolbarTwoAction extends StatelessWidget {
  final String title;
  final String rightText;
  final VoidCallback? onBack;
  final VoidCallback? onConfirm;

  const _ToolbarTwoAction({
    required this.title,
    required this.rightText,
    this.onBack,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Column(
        children: [
          SizedBox(
            height: kToolbarHeight,
            width: double.infinity,
            child: Row(
              children: [
                InkWell(
                  onTap: onBack,
                  child: SizedBox(
                    width: 56,
                    height: 44,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: CommonIconHelper.getBackIcon(
                        size: 24,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TextButton(
                    onPressed: onConfirm,
                    child: Text(
                      rightText,
                      style: AppTextStyles.caption1.copyWith(
                        color: AppColors.primaryStrong,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 2, color: AppColors.surfacePressed),
        ],
      ),
    );
  }
}

class _SinkSelectTile extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SinkSelectTile({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // PARITY: adapter_sink_select.xml
    // - paddingStart/End 16dp
    // - RadioButton not clickable in Android
    // - Divider bg_press
    return InkWell(
      // UI parity only: no onTap behavior
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IgnorePointer(
                  ignoring: true,
                  child: Radio<bool>(
                    value: true,
                    groupValue: isSelected,
                    onChanged: null,
                  ),
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
              ],
            ),
          ),
          const Divider(
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
  const _ProgressOverlay();

  @override
  Widget build(BuildContext context) {
    // PARITY: progress.xml (full overlay + centered ProgressBar)
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
