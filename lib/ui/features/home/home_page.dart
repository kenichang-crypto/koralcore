import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../application/common/app_session.dart';
import '../../app/navigation_controller.dart';
import '../../components/ble_guard.dart';
import '../../theme/reef_colors.dart';
import '../../theme/reef_radius.dart';
import '../../theme/reef_spacing.dart';
import '../../theme/reef_text.dart';
import '../dosing/pages/dosing_main_page.dart';
import '../led/pages/led_main_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final l10n = AppLocalizations.of(context);

    return ColoredBox(
      color: ReefColors.primaryStrong,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ReefSpacing.xl),
          children: [
            _ConnectionCard(session: session),
            if (!session.isBleConnected) ...[
              const SizedBox(height: ReefSpacing.lg),
              const BleGuardBanner(),
            ],
            const SizedBox(height: ReefSpacing.xxl),
            Text(
              l10n.sectionDosingTitle,
              style: ReefTextStyles.title2.copyWith(color: ReefColors.surface),
            ),
            const SizedBox(height: ReefSpacing.md),
            _FeatureEntryCard(
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
            const SizedBox(height: ReefSpacing.lg),
            Text(
              l10n.sectionLedTitle,
              style: ReefTextStyles.title2.copyWith(color: ReefColors.surface),
            ),
            const SizedBox(height: ReefSpacing.md),
            _FeatureEntryCard(
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
              title,
              style: ReefTextStyles.title2.copyWith(
                color: ReefColors.textPrimary,
              ),
            ),
            const SizedBox(height: ReefSpacing.sm),
            Text(
              subtitle,
              style: ReefTextStyles.body.copyWith(
                color: ReefColors.textSecondary,
              ),
            ),
            const SizedBox(height: ReefSpacing.lg),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: ReefColors.primary,
                foregroundColor: ReefColors.onPrimary,
                textStyle: ReefTextStyles.bodyAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: ReefSpacing.lg,
                  vertical: ReefSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ReefRadius.lg),
                ),
              ),
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

class _FeatureEntryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String asset;
  final VoidCallback? onTap;
  final bool enabled;

  const _FeatureEntryCard({
    required this.title,
    required this.subtitle,
    required this.asset,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Card(
        color: ReefColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ReefRadius.lg),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(ReefRadius.lg),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(ReefSpacing.xl),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ReefColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(ReefRadius.md),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      asset,
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        ReefColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ReefSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: ReefTextStyles.subheaderAccent.copyWith(
                          color: ReefColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: ReefSpacing.sm),
                      Text(
                        subtitle,
                        style: ReefTextStyles.caption1.copyWith(
                          color: ReefColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: ReefColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
