import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/common/app_session.dart';
import '../../../theme/dimensions.dart';
import '../../app/navigation_controller.dart';
import '../../components/ble_guard.dart';
import '../../components/feature_entry_card.dart';
import '../dosing/pages/dosing_main_page.dart';
import '../led/pages/led_main_page.dart';
import 'package:koralcore/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        children: [
          _ConnectionCard(session: session),
          if (!session.isBleConnected) ...[
            const SizedBox(height: AppDimensions.spacingL),
            const BleGuardBanner(),
          ],
          const SizedBox(height: AppDimensions.spacingXXL),
          Text(
            l10n.sectionDosingTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          FeatureEntryCard(
            title: l10n.dosingEntrySchedule,
            subtitle: l10n.dosingSubHeader,
            asset: 'assets/icons/icon_dosing.svg',
            enabled: session.isBleConnected,
            onTap: () => _openGuarded(
              context,
              session.isBleConnected,
              const DosingMainPage(),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            l10n.sectionLedTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          FeatureEntryCard(
            title: l10n.ledEntryIntensity,
            subtitle: l10n.ledSubHeader,
            asset: 'assets/icons/icon_led.svg',
            enabled: session.isBleConnected,
            onTap: () => _openGuarded(
              context,
              session.isBleConnected,
              const LedMainPage(),
            ),
          ),
        ],
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

class _ConnectionCard extends StatelessWidget {
  final AppSession session;

  const _ConnectionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isConnected = session.isBleConnected;
    final title = isConnected
        ? l10n.homeStatusConnected(session.activeDeviceName ?? 'Device')
        : l10n.homeStatusDisconnected;
    final subtitle = isConnected
        ? l10n.homeConnectedCopy
        : l10n.homeNoDeviceCopy;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            FilledButton(
              onPressed: () {
                context.read<NavigationController>().select(2);
              },
              child: Text(l10n.homeConnectCta),
            ),
          ],
        ),
      ),
    );
  }
}
