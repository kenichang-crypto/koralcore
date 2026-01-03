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
import '../controllers/add_device_controller.dart';

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
                  title: l10n.addDeviceTitle, // @string/add_device
                  // TODO(android @string/skip): 若此 locale 缺少翻譯，需補齊 ARB（本任務禁止修改 ARB）
                  leftText: l10n.actionSkip,
                  rightText: l10n.actionDone, // @string/complete
                ),
                Expanded(
                  // PARITY: layout_add_device paddings 16/12/16/12
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _DeviceNameSection(),
                        _SinkPositionSection(),
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

  const _ToolbarTwoAction({
    required this.title,
    required this.leftText,
    required this.rightText,
  });

  @override
  Widget build(BuildContext context) {
    // PARITY: toolbar_two_action.xml
    // - White toolbar background
    // - Left/Right text buttons (visible in AddDeviceActivity)
    // - Center title
    // - 2dp bottom divider (bg_press)
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
                    // UI parity only: no onPressed behavior
                    onPressed: null,
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
                      color: AppColors.textPrimary, // text_aaaa
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
                    // UI parity only: no onPressed behavior
                    onPressed: null,
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

class _DeviceNameSection extends StatelessWidget {
  const _DeviceNameSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // PARITY: tv_device_name_title + layout_name (TextInputLayout)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deviceName, // @string/device_name
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4), // dp_4 marginTop
        TextField(
          // UI parity only: no onChanged behavior
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
  const _SinkPositionSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // PARITY: tv_sink_position_title (marginTop 16dp) + layout_sink_position (TextInputLayout) + view_sink_position overlay
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16), // dp_16 marginTop
        Text(
          l10n.sinkPosition, // @string/sink_position
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4), // dp_4 marginTop
        Stack(
          children: [
            TextField(
              enabled: false, // edt_sink_position enabled="false"
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
                // PARITY: endIconDrawable="@drawable/ic_next", endIconTint="@color/text_aaa"
                suffixIcon: CommonIconHelper.getNextIcon(
                  size: 20,
                  color: AppColors.textSecondary, // text_aaa
                ),
              ),
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              maxLines: 1,
            ),
            // PARITY: view_sink_position - selectableItemBackground overlay
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  // UI parity only: no onTap behavior
                  onTap: null,
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
