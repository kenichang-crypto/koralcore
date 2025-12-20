import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_session.dart';
import '../../../../theme/dimensions.dart';
import '../../../components/ble_guard.dart';
import '../models/pump_head_summary.dart';
import 'manual_dosing_page.dart';
import 'pump_head_detail_page.dart';
import 'package:koralcore/l10n/app_localizations.dart';

class DosingMainPage extends StatelessWidget {
  const DosingMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final l10n = AppLocalizations.of(context);
    final bool isConnected = session.isBleConnected;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dosingHeader)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        children: [
          Text(
            l10n.dosingSubHeader,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          if (!isConnected) ...[
            const BleGuardBanner(),
            const SizedBox(height: AppDimensions.spacingXL),
          ],
          Text(
            l10n.dosingPumpHeadsHeader,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            l10n.dosingPumpHeadsSubheader,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          _PumpHeadGrid(
            isConnected: isConnected,
            onHeadTap: (headId) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PumpHeadDetailPage(headId: headId),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingXL),
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
    );
  }
}

class _PumpHeadGrid extends StatelessWidget {
  final bool isConnected;
  final ValueChanged<String> onHeadTap;

  const _PumpHeadGrid({required this.isConnected, required this.onHeadTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Wrap(
      spacing: AppDimensions.spacingL,
      runSpacing: AppDimensions.spacingL,
      children: _headOrder.map((headId) {
        final summary = PumpHeadSummary.demo(headId);
        return SizedBox(
          width: 200,
          child: Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              onTap: isConnected ? () => onHeadTap(headId) : null,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            summary.displayName,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      summary.additiveName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      '${summary.dailyTargetMl.toStringAsFixed(1)} ml/day',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Chip(
                      label: Text(
                        isConnected
                            ? l10n.dosingPumpHeadStatusReady
                            : l10n.dosingPumpHeadStatus,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

const List<String> _headOrder = ['A', 'B', 'C', 'D'];

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
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: ListTile(
        enabled: enabled,
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
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
      ),
    );
  }
}
