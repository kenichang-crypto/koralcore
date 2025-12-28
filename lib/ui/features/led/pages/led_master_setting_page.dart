import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
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
        title: Text(l10n.ledMasterSettingTitle),
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
              padding: const EdgeInsets.all(ReefSpacing.lg),
              children: [
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: ReefSpacing.lg),
                ],
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

    return Card(
      margin: const EdgeInsets.only(bottom: ReefSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.ledMasterSettingGroup} $groupId',
              style: ReefTextStyles.title2,
            ),
            const SizedBox(height: ReefSpacing.sm),
            ...devices.map(
              (device) =>
                  _buildDeviceTile(context, controller, device, groupId, l10n),
            ),
          ],
        ),
      ),
    );
  }

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

    return ListTile(
      title: Text(name),
      subtitle: Text(
        isMaster
            ? l10n.ledMasterSettingMaster
            : l10n.ledMasterSettingSlave,
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (!isConnected) {
            showBleGuardDialog(context);
            return;
          }
          switch (value) {
            case 'set_master':
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
              break;
            case 'move_group':
              _showMoveGroupDialog(context, controller, deviceId, l10n);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'set_master',
            enabled: !isMaster && isConnected,
            child: Text(l10n.ledMasterSettingSetMaster),
          ),
          PopupMenuItem(
            value: 'move_group',
            enabled: isConnected,
            child: Text(l10n.ledMasterSettingMoveGroup),
          ),
        ],
      ),
    );
  }

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
            return ListTile(
              title: Text('${l10n.ledMasterSettingGroup} $group'),
              subtitle: Text(
                isFull
                    ? l10n.ledMasterSettingGroupFull
                    : '${sizes[index]}/4',
              ),
              enabled: !isFull,
              onTap: () => Navigator.of(context).pop(group),
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
