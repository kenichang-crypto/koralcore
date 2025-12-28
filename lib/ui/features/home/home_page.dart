import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../application/common/app_session.dart';
import '../../../application/device/device_snapshot.dart';
import '../../app/navigation_controller.dart';
import '../../components/ble_guard.dart';
import '../../theme/reef_colors.dart';
import '../../theme/reef_radius.dart';
import '../../theme/reef_spacing.dart';
import '../../theme/reef_text.dart';
import '../device/controllers/device_list_controller.dart';
import '../dosing/pages/dosing_main_page.dart';
import '../led/pages/led_main_page.dart';
import '../warning/pages/warning_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final devices = context.watch<DeviceListController>().savedDevices;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ReefColors.primaryStrong,
      appBar: AppBar(
        backgroundColor: ReefColors.primaryStrong,
        elevation: 0,
        title: Text(
          l10n.tabHome,
          style: ReefTextStyles.title2.copyWith(
            color: ReefColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning, color: ReefColors.onPrimary),
            tooltip: l10n.warningTitle ?? 'Warnings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WarningPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ReefSpacing.xl),
          children: [
            _SinkHeaderCard(
              deviceCount: devices.length,
              isConnected: session.isBleConnected,
              activeDeviceName: session.activeDeviceName,
              onConnectTap: () =>
                  context.read<NavigationController>().select(2),
              l10n: l10n,
            ),
            if (!session.isBleConnected) ...[
              const SizedBox(height: ReefSpacing.md),
              const BleGuardBanner(),
            ],
            const SizedBox(height: ReefSpacing.xl),
            _DeviceSection(devices: devices, l10n: l10n),
            const SizedBox(height: ReefSpacing.xl),
            _FeatureActionCard(
              title: l10n.sectionLedTitle,
              subtitle: l10n.ledSubHeader,
              asset: 'assets/icons/home/home_led.png',
              onTap: () => _openGuarded(
                context,
                session.isBleConnected,
                const LedMainPage(),
              ),
            ),
            const SizedBox(height: ReefSpacing.md),
            _FeatureActionCard(
              title: l10n.sectionDosingTitle,
              subtitle: l10n.dosingSubHeader,
              asset: 'assets/icons/home/home_dosing.png',
              onTap: () => _openGuarded(
                context,
                session.isBleConnected,
                const DosingMainPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGuarded(BuildContext context, bool isConnected, Widget page) {
    if (!isConnected) {
      showBleGuardDialog(context);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _SinkHeaderCard extends StatelessWidget {
  final int deviceCount;
  final bool isConnected;
  final String? activeDeviceName;
  final VoidCallback onConnectTap;
  final AppLocalizations l10n;

  const _SinkHeaderCard({
    required this.deviceCount,
    required this.isConnected,
    required this.activeDeviceName,
    required this.onConnectTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ReefColors.surface.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ReefColors.surface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(ReefRadius.lg),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/home/home_header.png',
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            const SizedBox(width: ReefSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'My Reef',
                    style: ReefTextStyles.title2.copyWith(
                      color: ReefColors.surface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: ReefSpacing.xs),
                  Text(
                    '$deviceCount devices',
                    style: ReefTextStyles.body.copyWith(
                      color: ReefColors.surface,
                    ),
                  ),
                  if (isConnected) ...[
                    const SizedBox(height: ReefSpacing.xs),
                    Text(
                      l10n.homeStatusConnected(
                        activeDeviceName ?? l10n.deviceHeader,
                      ),
                      style: ReefTextStyles.caption1.copyWith(
                        color: ReefColors.surface,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isConnected)
              FilledButton(
                onPressed: onConnectTap,
                style: FilledButton.styleFrom(
                  backgroundColor: ReefColors.surface,
                  foregroundColor: ReefColors.primaryStrong,
                ),
                child: Text(l10n.homeConnectCta),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeviceSection extends StatelessWidget {
  final List<DeviceSnapshot> devices;
  final AppLocalizations l10n;

  const _DeviceSection({required this.devices, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deviceHeader,
          style: ReefTextStyles.title2.copyWith(color: ReefColors.surface),
        ),
        const SizedBox(height: ReefSpacing.md),
        if (devices.isEmpty)
          Card(
            color: ReefColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ReefRadius.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(ReefSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.deviceEmptyTitle,
                    style: ReefTextStyles.subheaderAccent.copyWith(
                      color: ReefColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: ReefSpacing.xs),
                  Text(
                    l10n.deviceEmptySubtitle,
                    style: ReefTextStyles.caption1.copyWith(
                      color: ReefColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          for (int i = 0; i < devices.length; i++) ...[
            _HomeDeviceTile(device: devices[i], l10n: l10n),
            if (i != devices.length - 1) const SizedBox(height: ReefSpacing.md),
          ],
        ],
      ],
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

class _FeatureActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String asset;
  final VoidCallback onTap;

  const _FeatureActionCard({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ReefRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(ReefSpacing.xl),
        decoration: BoxDecoration(
          color: ReefColors.surface.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(ReefRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: ReefColors.surface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(ReefRadius.md),
              ),
              child: Center(child: Image.asset(asset, width: 28, height: 28)),
            ),
            const SizedBox(width: ReefSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ReefTextStyles.subheaderAccent.copyWith(
                      color: ReefColors.surface,
                    ),
                  ),
                  const SizedBox(height: ReefSpacing.xs),
                  Text(
                    subtitle,
                    style: ReefTextStyles.caption1.copyWith(
                      color: ReefColors.surface,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: ReefColors.surface,
              size: 16,
            ),
          ],
        ),
      ),
    );
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
