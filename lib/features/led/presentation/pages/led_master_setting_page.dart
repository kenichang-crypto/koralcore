import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';

/// LedMasterSettingPage
///
/// Parity with reef-b-app LedMasterSettingActivity (activity_led_master_setting.xml)
/// Correction Mode: UI structure only, no behavior
class LedMasterSettingPage extends StatelessWidget {
  const LedMasterSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LedMasterSettingView();
  }
}

class _LedMasterSettingView extends StatelessWidget {
  const _LedMasterSettingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        Column(
          children: [
            // A. Toolbar (fixed) ↔ toolbar_two_action.xml
            _ToolbarTwoAction(l10n: l10n),

            // B. ScrollView content (scrollable) ↔ layout_led_master_setting
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // B1. Header section (layout_title)
                  _HeaderSection(l10n: l10n),

                  _GroupASection(l10n: l10n),
                  _GroupBSection(l10n: l10n),
                  _GroupCSection(l10n: l10n),
                  _GroupDSection(),
                  _GroupESection(),
                ],
              ),
            ),
          ],
        ),

        // C. Progress overlay ↔ progress.xml
        // PARITY: visibility="gone" by default, controlled by loading state
        // In Correction Mode, never show (no controller)
        // if (controller.isLoading) const _ProgressOverlay(),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// A. Toolbar (fixed) ↔ toolbar_two_action.xml
// ────────────────────────────────────────────────────────────────────────────

class _ToolbarTwoAction extends StatelessWidget {
  const _ToolbarTwoAction({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          height: 56,
          child: Row(
            children: [
              // Left: Cancel (PARITY: btnBack → finish)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.actionCancel,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              // Center: Title
              // TODO(android @string/led_master_setting_title): Confirm exact Android string key
              Text(
                l10n.ledMasterSettingTitle,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Right: Done (PARITY: btnRight → finish)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.actionDone,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Divider (2dp ↔ toolbar_two_action.xml MaterialDivider)
        Container(height: 2, color: AppColors.divider),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B1. Header Section ↔ layout_title
// ────────────────────────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // PARITY: layout_title - ConstraintLayout
    // - marginTop: 12dp
    // - paddingStart/End: 16dp
    // - paddingTop: 8dp
    return Container(
      margin: const EdgeInsets.only(top: 12), // dp_12 marginTop
      padding: const EdgeInsets.only(
        left: 16, // dp_16 paddingStart
        top: 8, // dp_8 paddingTop
        right: 16, // dp_16 paddingEnd
      ),
      child: Stack(
        children: [
          // Invisible layer (actual data row, visibility="invisible")
          // PARITY: Android uses invisible elements to maintain layout structure
          Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Row(
              children: [
                // tv_group (invisible) - marginStart 8dp, body, text_aaa
                Padding(
                  padding: const EdgeInsets.only(left: 8), // dp_8 marginStart
                  child: Text(
                    'A', // Placeholder
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary, // text_aaa
                    ),
                  ),
                ),
                const SizedBox(width: 45), // dp_45 marginStart
                // tv_name (invisible) - marginStart 45dp, body, text_aaaa, SingleLine
                Expanded(
                  child: Text(
                    'Device Name Placeholder',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary, // text_aaaa
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 45), // dp_45 marginStart
                // img_master (invisible) - 20x20dp
                // TODO(android @drawable/ic_master_big)
                CommonIconHelper.getMasterBigIcon(
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 45), // dp_45 marginStart
                // btn_more (invisible) - 24x24dp
                // TODO(android @drawable/ic_menu)
                CommonIconHelper.getMenuIcon(
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),

          // Visible layer (title row)
          Row(
            children: [
              // tv_group_title - paddingStart 10dp, caption1, text_aaa
              Padding(
                padding: const EdgeInsets.only(left: 10), // dp_10 paddingStart
                child: Text(
                  l10n.group, // @string/group
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.textSecondary, // text_aaa
                  ),
                ),
              ),
              const SizedBox(width: 45), // Align with data row
              // tv_name_title - paddingStart 10dp, caption1, text_aaa, SingleLine
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ), // dp_10 paddingStart
                  child: Text(
                    l10n.led, // @string/led
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.textSecondary, // text_aaa
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 45), // Align with data row
              // tv_master_title - caption1, text_aaa, center alignment
              Text(
                l10n.masterSlave, // @string/master_slave
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textSecondary, // text_aaa
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(width: 45), // Align with data row
              const SizedBox(width: 24), // Align with btn_more
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// B2-B6. Group Sections ↔ layout_group_a ~ layout_group_e
// ────────────────────────────────────────────────────────────────────────────

// PARITY: Android defines 5 independent RecyclerViews (rv_group_a ~ rv_group_e)
// Each wrapped in a LinearLayout with specific marginTop

class _GroupASection extends StatelessWidget {
  const _GroupASection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // PARITY: layout_group_a (LinearLayout) + rv_group_a (RecyclerView)
    // No marginTop for first group
    return Column(
      children: [
        _DeviceTile(groupId: 'A', deviceName: 'Device 1', isMaster: true, l10n: l10n),
        _DeviceTile(groupId: 'A', deviceName: 'Device 2', isMaster: false, l10n: l10n),
      ],
    );
  }
}

class _GroupBSection extends StatelessWidget {
  const _GroupBSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // PARITY: layout_group_b (LinearLayout) + rv_group_b (RecyclerView)
    // marginTop: 16dp
    return Column(
      children: [
        const SizedBox(height: 16),
        _DeviceTile(groupId: 'B', deviceName: 'Device 3', isMaster: true, l10n: l10n),
      ],
    );
  }
}

class _GroupCSection extends StatelessWidget {
  const _GroupCSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // PARITY: layout_group_c (LinearLayout) + rv_group_c (RecyclerView)
    // marginTop: 16dp
    return Column(
      children: [
        const SizedBox(height: 16),
        _DeviceTile(groupId: 'C', deviceName: 'Device 4', isMaster: false, l10n: l10n),
      ],
    );
  }
}

class _GroupDSection extends StatelessWidget {
  const _GroupDSection();

  @override
  Widget build(BuildContext context) {
    // PARITY: layout_group_d (LinearLayout) + rv_group_d (RecyclerView)
    // marginTop: 16dp
    return const Column(
      children: [
        SizedBox(height: 16), // dp_16 marginTop
        // Empty group (no items)
      ],
    );
  }
}

class _GroupESection extends StatelessWidget {
  const _GroupESection();

  @override
  Widget build(BuildContext context) {
    // PARITY: layout_group_e (LinearLayout) + rv_group_e (RecyclerView)
    // marginTop: 16dp
    // marginBottom: 12dp (on LinearLayout)
    return const Column(
      children: [
        SizedBox(height: 16), // dp_16 marginTop
        // Empty group (no items)
        SizedBox(height: 12), // dp_12 marginBottom
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Device Tile ↔ adapter_master_setting.xml
// ────────────────────────────────────────────────────────────────────────────

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.groupId,
    required this.deviceName,
    required this.isMaster,
    required this.l10n,
  });

  final String groupId;
  final String deviceName;
  final bool isMaster;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // PARITY: adapter_master_setting.xml
    // - ConstraintLayout: white background, padding 16/8/16/8
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 16, // dp_16 paddingStart
        top: 8, // dp_8 paddingTop
        right: 16, // dp_16 paddingEnd
        bottom: 8, // dp_8 paddingBottom
      ),
      color: Colors.white, // white background
      child: Row(
        children: [
          // tv_group - marginStart 8dp, body, text_aaa
          Padding(
            padding: const EdgeInsets.only(left: 8), // dp_8 marginStart
            child: Text(
              groupId,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary, // text_aaa
              ),
            ),
          ),
          const SizedBox(width: 45), // dp_45 marginStart
          // tv_name - marginStart 45dp, body, text_aaaa, SingleLine
          Expanded(
            child: Text(
              deviceName,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary, // text_aaaa
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 45), // dp_45 marginStart
          // img_master - 20x20dp, marginStart 45dp
          // PARITY: Only show if master, no conditional spacing in Android
          // TODO(android @drawable/ic_master_big)
          if (isMaster)
            CommonIconHelper.getMasterBigIcon(
              size: 20,
              color: AppColors.primary,
            )
          else
            const SizedBox(width: 20, height: 20), // Maintain space

          const SizedBox(width: 45), // dp_45 marginStart
          // btn_more - 24x24dp, marginStart 45dp
          // TODO(android @drawable/ic_menu)
          SizedBox(
            width: 24,
            height: 24,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 160),
              icon: CommonIconHelper.getMenuIcon(
                size: 24,
                color: AppColors.textPrimary,
              ),
              onSelected: (value) {
                // PARITY: reef action_set_master / action_move_group
                // Placeholder - full impl requires sink/device/group data
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.ledMasterSettingMenuPlaceholder)),
                );
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'set_master', child: Text(l10n.ledSetMaster)),
                PopupMenuItem(value: 'move_group', child: Text(l10n.ledMoveGroup)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// C. Progress overlay ↔ progress.xml
// ────────────────────────────────────────────────────────────────────────────

class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
