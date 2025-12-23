import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_session.dart';
import '../../../components/ble_guard.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../models/pump_head_summary.dart';
import 'manual_dosing_page.dart';
import 'pump_head_detail_page.dart';
import 'package:koralcore/l10n/app_localizations.dart';

const _dosingIconAsset = 'assets/icons/dosing/dosing_main.png';

class DosingMainPage extends StatelessWidget {
  const DosingMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final l10n = AppLocalizations.of(context);
    final bool isConnected = session.isBleConnected;

    return Scaffold(
      backgroundColor: ReefColors.primaryStrong,
      appBar: AppBar(
        backgroundColor: ReefColors.primaryStrong,
        elevation: 0,
        title: Text(
          l10n.dosingHeader,
          style: ReefTextStyles.title2.copyWith(
            color: ReefColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ReefSpacing.xl),
          children: [
            Text(
              l10n.dosingSubHeader,
              style: ReefTextStyles.body.copyWith(color: ReefColors.surface),
            ),
            const SizedBox(height: ReefSpacing.md),
            if (!isConnected) ...[
              const BleGuardBanner(),
              const SizedBox(height: ReefSpacing.md),
            ],
            const SizedBox(height: ReefSpacing.md),
            Text(
              l10n.dosingPumpHeadsHeader,
              style: ReefTextStyles.title2.copyWith(color: ReefColors.surface),
            ),
            const SizedBox(height: ReefSpacing.sm),
            Text(
              l10n.dosingPumpHeadsSubheader,
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.surface,
              ),
            ),
            const SizedBox(height: ReefSpacing.lg),
            _PumpHeadList(
              isConnected: isConnected,
              onHeadTap: (headId) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PumpHeadDetailPage(headId: headId),
                  ),
                );
              },
            ),
            const SizedBox(height: ReefSpacing.xl),
            _EntryTile(
              title: l10n.dosingEntrySchedule,
              subtitle: l10n.comingSoon,
              enabled: isConnected,
            ),
            _EntryTile(
              title: l10n.dosingEntryManual,
              subtitle: l10n.dosingManualPageSubtitle,
              enabled: isConnected,
              onTapWhenEnabled: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManualDosingPage()),
                );
              },
            ),
            _EntryTile(
              title: l10n.dosingEntryCalibration,
              subtitle: l10n.comingSoon,
              enabled: isConnected,
            ),
            _EntryTile(
              title: l10n.dosingEntryHistory,
              subtitle: l10n.comingSoon,
              enabled: isConnected,
            ),
          ],
        ),
      ),
    );
  }
}

class _PumpHeadList extends StatelessWidget {
  final bool isConnected;
  final ValueChanged<String> onHeadTap;

  const _PumpHeadList({required this.isConnected, required this.onHeadTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<Widget> cards = <Widget>[];
    for (final String headId in _headOrder) {
      final summary = PumpHeadSummary.demo(headId);
      cards.add(
        _DropHeadCard(
          summary: summary,
          isConnected: isConnected,
          l10n: l10n,
          onTap: isConnected ? () => onHeadTap(headId) : null,
        ),
      );
      cards.add(const SizedBox(height: ReefSpacing.md));
    }
    if (cards.isNotEmpty) {
      cards.removeLast();
    }
    return Column(children: cards);
  }
}

const List<String> _headOrder = ['A', 'B', 'C', 'D'];

class _DropHeadCard extends StatelessWidget {
  final PumpHeadSummary summary;
  final bool isConnected;
  final AppLocalizations l10n;
  final VoidCallback? onTap;

  const _DropHeadCard({
    required this.summary,
    required this.isConnected,
    required this.l10n,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ReefRadius.lg),
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(
          horizontal: ReefSpacing.lg,
          vertical: ReefSpacing.md,
        ),
        decoration: BoxDecoration(
          color: ReefColors.surface,
          borderRadius: BorderRadius.circular(ReefRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: ReefColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(ReefRadius.pill),
              ),
              child: Center(
                child: Image.asset(_dosingIconAsset, width: 32, height: 32),
              ),
            ),
            const SizedBox(width: ReefSpacing.lg),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.displayName,
                    style: ReefTextStyles.subheaderAccent.copyWith(
                      color: ReefColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: ReefSpacing.xs),
                  Text(
                    l10n.dosingPumpHeadDailyTarget,
                    style: ReefTextStyles.caption1.copyWith(
                      color: ReefColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: ReefSpacing.xs),
                  Text(
                    '${summary.dailyTargetMl.toStringAsFixed(1)} ml',
                    style: ReefTextStyles.bodyAccent.copyWith(
                      color: ReefColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isConnected
                      ? l10n.dosingPumpHeadStatusReady
                      : l10n.dosingPumpHeadStatus,
                  style: ReefTextStyles.caption1.copyWith(
                    color: ReefColors.textSecondary,
                  ),
                ),
                const SizedBox(height: ReefSpacing.sm),
                const Icon(
                  Icons.chevron_right,
                  color: ReefColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTapWhenEnabled;

  const _EntryTile({
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.onTapWhenEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ReefSpacing.md),
      child: InkWell(
        onTap: enabled
            ? () {
                if (onTapWhenEnabled != null) {
                  onTapWhenEnabled!();
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(subtitle)));
                }
              }
            : () {
                showBleGuardDialog(context);
              },
        borderRadius: BorderRadius.circular(ReefRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(ReefSpacing.lg),
          decoration: BoxDecoration(
            color: ReefColors.surface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ReefRadius.lg),
          ),
          child: Row(
            children: [
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
      ),
    );
  }
}
