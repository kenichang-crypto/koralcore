import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../controllers/add_device_controller.dart';
import '../../../sink/presentation/pages/sink_position_page.dart';

/// Add device page.
///
/// PARITY: Mirrors reef-b-app's AddDeviceActivity.
class AddDevicePage extends StatelessWidget {
  const AddDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<AddDeviceController>(
      create: (_) => AddDeviceController(
        session: session,
        deviceRepository: appContext.deviceRepository,
        pumpHeadRepository: appContext.pumpHeadRepository,
        sinkRepository: appContext.sinkRepository,
        disconnectDeviceUseCase: appContext.disconnectDeviceUseCase,
      ),
      child: const _AddDeviceView(),
    );
  }
}

class _AddDeviceView extends StatelessWidget {
  const _AddDeviceView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<AddDeviceController>();
    return Scaffold(
      // PARITY: activity_add_device.xml - root has no explicit background
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _ToolbarTwoAction(
                  title: l10n.addDeviceTitle,
                  leftText: l10n.actionSkip,
                  rightText: l10n.actionDone,
                  onLeftPressed: controller.isLoading
                      ? null
                      : () async {
                          final ok = await controller.skip();
                          if (ok && context.mounted) {
                            Navigator.of(context).pop();
                          } else if (context.mounted && controller.lastErrorCode != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  describeAppError(l10n, controller.lastErrorCode!),
                                ),
                              ),
                            );
                          }
                        },
                  onRightPressed: controller.isLoading
                      ? null
                      : () async {
                          final ok = await controller.addDevice();
                          if (ok && context.mounted) {
                            Navigator.of(context).pop();
                          } else if (context.mounted && controller.lastErrorCode != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  describeAppError(l10n, controller.lastErrorCode!),
                                ),
                              ),
                            );
                          }
                        },
                ),
                Expanded(
                  // PARITY: layout_add_device paddings 16/12/16/12
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DeviceNameSection(controller: controller),
                        _SinkPositionSection(controller: controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // PARITY: include @layout/progress (gone by default)
            if (controller.isLoading) const _ProgressOverlay(),
          ],
        ),
      ),
    );
  }
}

class _ToolbarTwoAction extends StatelessWidget {
  final String title;
  final String leftText;
  final String rightText;
  final VoidCallback? onLeftPressed;
  final VoidCallback? onRightPressed;

  const _ToolbarTwoAction({
    required this.title,
    required this.leftText,
    required this.rightText,
    this.onLeftPressed,
    this.onRightPressed,
  });

  @override
  Widget build(BuildContext context) {
    // PARITY: toolbar_two_action.xml (Skip/Done wired per UX Parity P4)
    return Material(
      color: AppColors.surface,
      child: Column(
        children: [
          SizedBox(
            height: kToolbarHeight,
            width: double.infinity,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: TextButton(
                    onPressed: onLeftPressed,
                    child: Text(
                      leftText,
                      style: AppTextStyles.bodyAccent.copyWith(
                        color: AppColors.primaryStrong,
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
                    onPressed: onRightPressed,
                    child: Text(
                      rightText,
                      style: AppTextStyles.bodyAccent.copyWith(
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

class _DeviceNameSection extends StatefulWidget {
  final AddDeviceController controller;

  const _DeviceNameSection({required this.controller});

  @override
  State<_DeviceNameSection> createState() => _DeviceNameSectionState();
}

class _DeviceNameSectionState extends State<_DeviceNameSection> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final initial = widget.controller.deviceName.isEmpty
        ? (widget.controller.connectedDeviceName ?? '')
        : widget.controller.deviceName;
    _textController = TextEditingController(text: initial);
    if (initial.isNotEmpty) widget.controller.setDeviceName(initial);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // PARITY: tv_device_name_title + layout_name (TextInputLayout)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deviceName,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _textController,
          onChanged: widget.controller.setDeviceName,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceMuted, // TextInputLayout bg_aaa
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs), // dp_4
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          maxLines: 1,
        ),
      ],
    );
  }
}

class _SinkPositionSection extends StatelessWidget {
  final AddDeviceController controller;

  const _SinkPositionSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = controller.selectedSinkName ?? l10n.sinkPositionNotSet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          l10n.sinkPosition,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            InputDecorator(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                suffixIcon: CommonIconHelper.getNextIcon(
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
              child: Text(
                text,
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.of(context).push<String?>(
                      MaterialPageRoute(
                        builder: (_) => SinkPositionPage(
                          initialSinkId: controller.selectedSinkId,
                        ),
                      ),
                    );
                    if (result != null) {
                      await controller.setSelectedSinkId(result);
                    }
                  },
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay();

  @override
  Widget build(BuildContext context) {
    // PARITY: progress.xml
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
