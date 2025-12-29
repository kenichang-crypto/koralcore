import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../widgets/reef_app_bar.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../../../assets/common_icon_helper.dart';
import '../controllers/led_master_setting_controller.dart';

/// LED master setting page.
///
/// PARITY: Mirrors reef-b-app's LedMasterSettingActivity.
class LedMasterSettingPage extends StatelessWidget {
  final String sinkId;

  const LedMasterSettingPage({super.key, required this.sinkId});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    return ChangeNotifierProvider<LedMasterSettingController>(
      create: (_) => LedMasterSettingController(
        sinkId: sinkId,
        deviceRepository: appContext.deviceRepository,
        sinkRepository: appContext.sinkRepository,
      )..initialize(),
      child: _LedMasterSettingView(sinkId: sinkId),
    );
  }
}

class _LedMasterSettingView extends StatelessWidget {
  final String sinkId;

  const _LedMasterSettingView({required this.sinkId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<LedMasterSettingController>();
    final isConnected = session.isBleConnected;

    _maybeShowError(context, controller.lastErrorCode);

    return Scaffold(
      backgroundColor: ReefColors.surfaceMuted,
      appBar: ReefAppBar(
        backgroundColor: ReefColors.primary,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: CommonIconHelper.getCloseIcon(size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.ledMasterSettingTitle,
          style: ReefTextStyles.title2.copyWith(
            color: ReefColors.onPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
              // PARITY: activity_led_master_setting.xml ScrollView + ConstraintLayout
              // layout_title has padding 16/8/16, RecyclerView has no padding
              padding: EdgeInsets.zero,
              children: [
                if (!isConnected) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: ReefSpacing.md),
                    child: const BleGuardBanner(),
                  ),
                  const SizedBox(height: ReefSpacing.lg),
                ],
                // PARITY: layout_title padding 16/8/16, marginTop 12dp
                Padding(
                  padding: EdgeInsets.only(
                    left: ReefSpacing.md, // dp_16 paddingStart
                    top: ReefSpacing.sm, // dp_12 marginTop
                    right: ReefSpacing.md, // dp_16 paddingEnd
                    bottom: ReefSpacing.xs, // dp_8 paddingTop (from layout_title)
                  ),
                  child: _buildTitleSection(l10n),
                ),
                // PARITY: RecyclerView with no padding (adapter items handle spacing)
                ...controller.groups.map(
                  (group) => _buildGroupSection(
                    context,
                    controller,
                    group.id,
                    group.devices,
                    l10n,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTitleSection(AppLocalizations l10n) {
    // PARITY: layout_title structure with tv_group_title, tv_name_title, tv_master_title
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10), // dp_10 paddingStart
          child: Text(
            l10n.group, // PARITY: @string/group
            style: ReefTextStyles.caption1.copyWith(
              color: ReefColors.textSecondary, // text_aaa
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 10), // dp_10 paddingStart
            child: Text(
              l10n.led, // PARITY: @string/led
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.textSecondary, // text_aaa
              ),
            ),
          ),
        ),
        Text(
          l10n.masterSlave, // PARITY: @string/master_slave
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.textSecondary, // text_aaa
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGroupSection(
    BuildContext context,
    LedMasterSettingController controller,
    String groupId,
    List<Map<String, dynamic>> devices,
    AppLocalizations l10n,
  ) {
    if (devices.isEmpty) {
      return const SizedBox.shrink();
    }

    // PARITY: RecyclerView with no padding (adapter items handle spacing)
    // First group has no marginTop, subsequent groups have marginTop 16dp
    return Column(
      children: [
        if (groupId != controller.groups.first.id)
          SizedBox(height: ReefSpacing.md), // dp_16 marginTop for subsequent groups
        ...devices.map(
          (device) =>
              _buildDeviceTile(context, controller, device, groupId, l10n),
        ),
      ],
    );
  }

  /// Device tile matching adapter_master_setting.xml layout.
  ///
  /// PARITY: Mirrors reef-b-app's adapter_master_setting.xml structure:
  /// - ConstraintLayout: white background, padding 16/8/16/8dp
  /// - tv_group: body, text_aaa, marginStart 8dp
  /// - tv_name: body, text_aaaa, marginStart 45dp
  /// - img_master: 20×20dp, marginStart 45dp (ic_master_big)
  /// - btn_more: 24×24dp, marginStart 45dp (ic_menu)
  Widget _buildDeviceTile(
    BuildContext context,
    LedMasterSettingController controller,
    Map<String, dynamic> device,
    String groupId,
    AppLocalizations l10n,
  ) {
    final String deviceId = device['id'] as String;
    final String name = device['name'] as String? ?? 'Unknown';
    final bool isMaster = (device['is_master'] as int? ?? 0) != 0;
    final session = context.watch<AppSession>();
    final isConnected = session.isBleConnected;

    // PARITY: adapter_master_setting.xml structure
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: ReefSpacing.md, // dp_16 paddingStart
        top: ReefSpacing.xs, // dp_8 paddingTop
        right: ReefSpacing.md, // dp_16 paddingEnd
        bottom: ReefSpacing.xs, // dp_8 paddingBottom
      ),
      decoration: BoxDecoration(
        color: ReefColors.surface, // white background
      ),
      child: Row(
        children: [
          // Group (tv_group) - body, text_aaa, marginStart 8dp
          Padding(
            padding: EdgeInsets.only(left: ReefSpacing.xs), // dp_8 marginStart
            child: Text(
              groupId,
              style: ReefTextStyles.body.copyWith(
                color: ReefColors.textTertiary, // text_aaa
              ),
            ),
          ),
          SizedBox(width: 45), // dp_45 marginStart
          // Name (tv_name) - body, text_aaaa
          Expanded(
            child: Text(
              name,
              style: ReefTextStyles.body.copyWith(
                color: ReefColors.textPrimary, // text_aaaa
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 45), // dp_45 marginStart
          // Master icon (img_master) - 20×20dp
          if (isMaster)
            Image.asset(
              'assets/icons/ic_master_big.png', // TODO: Add icon asset
              width: 20, // dp_20
              height: 20, // dp_20
              errorBuilder: (context, error, stackTrace) => CommonIconHelper.getMasterIcon(
                size: 20,
                color: ReefColors.primary,
              ),
            ),
          SizedBox(width: 45), // dp_45 marginStart
          // More button (btn_more) - 24×24dp
          IconButton(
            icon: Image.asset(
              'assets/icons/ic_menu.png', // TODO: Add icon asset
              width: 24, // dp_24
              height: 24, // dp_24
              errorBuilder: (context, error, stackTrace) => CommonIconHelper.getMenuIcon(
                size: 24,
                color: ReefColors.textPrimary,
              ),
            ),
            onPressed: () => _showDeviceMenu(context, controller, deviceId, groupId, isMaster, isConnected, l10n),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeviceMenu(
    BuildContext context,
    LedMasterSettingController controller,
    String deviceId,
    String groupId,
    bool isMaster,
    bool isConnected,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMaster && isConnected)
            ListTile(
              leading: CommonIconHelper.getMasterIcon(size: 24),
              title: Text(l10n.ledMasterSettingSetMaster),
              onTap: () async {
                Navigator.pop(context);
                final success = await controller.setMaster(deviceId, groupId);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.ledMasterSettingSetMasterSuccess,
                      ),
                    ),
                  );
                }
              },
            ),
          if (isConnected)
            ListTile(
              leading: CommonIconHelper.getResetIcon(size: 24), // Using reset icon as placeholder for swap
              title: Text(l10n.ledMasterSettingMoveGroup),
              onTap: () {
                Navigator.pop(context);
                _showMoveGroupDialog(context, controller, deviceId, l10n);
              },
            ),
        ],
      ),
    );
  }

  /// Group selection dialog matching adapter_choose_group.xml layout.
  ///
  /// PARITY: Mirrors reef-b-app's adapter_choose_group.xml structure:
  /// - ConstraintLayout: selectableItemBackground, padding 4/0/4/0dp
  /// - tv_group_name: body, text_aaaa (visibility gone by default)
  /// - layout_state: check icon (24×24dp, invisible) or "群組已滿" text (body, text_aa, gone)
  Future<void> _showMoveGroupDialog(
    BuildContext context,
    LedMasterSettingController controller,
    String deviceId,
    AppLocalizations l10n,
  ) async {
    final String? selectedGroup = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.ledMasterSettingSelectGroup),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['A', 'B', 'C', 'D', 'E'].map((group) {
            final sizes = controller.getGroupSizes();
            final int index = ['A', 'B', 'C', 'D', 'E'].indexOf(group);
            final bool isFull = index < sizes.length && sizes[index] >= 4;
            // PARITY: adapter_choose_group.xml structure
            return InkWell(
              onTap: isFull ? null : () => Navigator.of(context).pop(group),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 4, // dp_4 paddingTop/Bottom
                ),
                child: Row(
                  children: [
                    // Group name (tv_group_name) - body, text_aaaa (visibility gone by default, but we show it)
                    Expanded(
                      child: Text(
                        '${l10n.ledMasterSettingGroup} $group',
                        style: ReefTextStyles.body.copyWith(
                          color: ReefColors.textPrimary, // text_aaaa
                        ),
                      ),
                    ),
                    // State layout (layout_state)
                    if (isFull)
                      // "群組已滿" text (tv_is_full) - body, text_aa
                      Text(
                        l10n.ledMasterSettingGroupFull,
                        style: ReefTextStyles.body.copyWith(
                          color: ReefColors.textSecondary, // text_aa
                        ),
                      )
                    else
                      // Check icon (img_check) - 24×24dp, invisible by default
                      SizedBox(
                        width: 24, // dp_24
                        height: 24, // dp_24
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    if (selectedGroup != null) {
      final success = await controller.moveGroup(deviceId, selectedGroup);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.ledMasterSettingMoveGroupSuccess,
            ),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.ledMasterSettingMoveGroupFailed,
            ),
          ),
        );
      }
    }
  }

  void _maybeShowError(BuildContext context, AppErrorCode? code) {
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context);
      final message = describeAppError(l10n, code);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }
}
