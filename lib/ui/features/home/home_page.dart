import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../application/device/device_snapshot.dart';
import '../../theme/reef_colors.dart';
import '../../theme/reef_radius.dart';
import '../../theme/reef_spacing.dart';
import '../../theme/reef_text.dart';
import '../../widgets/reef_backgrounds.dart';
import '../../assets/reef_material_icons.dart';
import '../../components/empty_state_widget.dart';
import '../device/controllers/device_list_controller.dart';
import '../dosing/pages/dosing_main_page.dart';
import '../led/pages/led_main_page.dart';
import '../warning/pages/warning_page.dart';
import '../sink/pages/sink_manager_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<DeviceListController>().savedDevices;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: ReefMainBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 頂部按鈕區域
              _TopButtonBar(
                onWarningTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const WarningPage(),
                    ),
                  );
                },
                l10n: l10n,
              ),
              // Sink 選擇器區域
              _SinkSelectorBar(
                onManagerTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SinkManagerPage(),
                    ),
                  );
                },
                l10n: l10n,
              ),
              // 設備列表區域
              Expanded(
                child: devices.isEmpty
                    ? _EmptyState(l10n: l10n)
                    : ListView(
                        padding: EdgeInsets.only(
                          left: ReefSpacing.sm,
                          right: ReefSpacing.sm,
                          top: ReefSpacing.xs,
                          bottom: ReefSpacing.xl,
                        ),
                        children: [
                          for (int i = 0; i < devices.length; i++) ...[
                            _HomeDeviceTile(device: devices[i], l10n: l10n),
                            if (i != devices.length - 1)
                              const SizedBox(height: ReefSpacing.md),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _TopButtonBar extends StatelessWidget {
  final VoidCallback onWarningTap;
  final AppLocalizations l10n;

  const _TopButtonBar({
    required this.onWarningTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: ReefSpacing.sm,
        bottom: ReefSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              ReefMaterialIcons.warning,
              color: ReefColors.textPrimary,
            ),
            tooltip: l10n.warningTitle,
            onPressed: onWarningTap,
            padding: EdgeInsets.all(ReefSpacing.sm),
            constraints: const BoxConstraints(
              minWidth: 56,
              minHeight: 44,
            ),
          ),
        ],
      ),
    );
  }
}

class _SinkSelectorBar extends StatelessWidget {
  final VoidCallback onManagerTap;
  final AppLocalizations l10n;

  const _SinkSelectorBar({
    required this.onManagerTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: 實現完整的 Sink 選擇器功能
    // 現在先顯示一個臨時的簡單版本
    String selectedSink = 'All Sinks'; // 臨時值

    return Padding(
      padding: EdgeInsets.only(
        left: ReefSpacing.md,
        right: ReefSpacing.md,
        top: ReefSpacing.xs,
        bottom: ReefSpacing.xs,
      ),
      child: Row(
        children: [
          // Sink 選擇器（臨時使用 Text，後續替換為 DropdownButton）
          Text(
            selectedSink,
            style: ReefTextStyles.body.copyWith(
              color: ReefColors.textPrimary,
            ),
          ),
          const SizedBox(width: ReefSpacing.xs),
          Icon(
            ReefMaterialIcons.down,
            size: 24,
            color: ReefColors.textPrimary,
          ),
          const Spacer(),
          // Sink 管理按鈕
          IconButton(
            icon: Icon(
              ReefMaterialIcons.menu,
              color: ReefColors.textPrimary,
              size: 30,
            ),
            onPressed: onManagerTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 30,
              minHeight: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: l10n.deviceEmptyTitle,
      subtitle: l10n.deviceEmptySubtitle,
    );
  }
}


class _HomeDeviceTile extends StatelessWidget {
  final DeviceSnapshot device;
  final AppLocalizations l10n;

  const _HomeDeviceTile({required this.device, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final _DeviceKind kind = _DeviceKindHelper.fromName(device.name);
    final bool isConnected = device.isConnected;
    final bool isConnecting = device.isConnecting;
    final String statusLabel = isConnected
        ? l10n.deviceStateConnected
        : isConnecting
        ? l10n.deviceStateConnecting
        : l10n.deviceStateDisconnected;
    final Color statusColor = isConnected
        ? ReefColors.success
        : isConnecting
        ? ReefColors.warning
        : ReefColors.textSecondary;

    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: ReefColors.surface,
        borderRadius: BorderRadius.circular(ReefRadius.lg),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(ReefRadius.lg),
        onTap: () => _navigate(context, kind),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ReefSpacing.lg,
            vertical: ReefSpacing.md,
          ),
          child: Row(
            children: [
              Image.asset(
                kind == _DeviceKind.led
                    ? 'assets/icons/device/device_led.png'
                    : 'assets/icons/device/device_doser.png',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: ReefSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      device.name,
                      style: ReefTextStyles.subheaderAccent.copyWith(
                        color: ReefColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: ReefSpacing.xs),
                    Text(
                      statusLabel,
                      style: ReefTextStyles.caption1.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: ReefColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, _DeviceKind kind) {
    final Widget page = kind == _DeviceKind.led
        ? const LedMainPage()
        : const DosingMainPage();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}


enum _DeviceKind { led, doser }

class _DeviceKindHelper {
  static _DeviceKind fromName(String name) {
    final String lower = name.toLowerCase();
    if (lower.contains('led')) {
      return _DeviceKind.led;
    }
    return _DeviceKind.doser;
  }
}
