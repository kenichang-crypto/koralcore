import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../app/common/app_session.dart';
import '../../../../domain/doser_dosing/pump_head.dart';
import '../models/pump_head_summary.dart';
import 'dosing_main_pump_head_card.dart';

/// Pump head list widget for dosing main page.
///
/// PARITY: Mirrors reef-b-app's rv_drop_head RecyclerView.
/// android/ReefB_Android/app/src/main/res/layout/activity_drop_main.xml Line 84-97
///
/// - paddingTop: 12dp
/// - paddingBottom: 32dp
/// - clipToPadding: false
/// - overScrollMode: never
/// - itemCount: 4 (tools:itemCount)
/// - listitem: adapter_drop_head.xml
class DosingMainPumpHeadList extends StatelessWidget {
  final bool isConnected;
  final AppSession session;
  final ValueChanged<String>? onHeadTap;
  final ValueChanged<String>? onHeadPlay;

  const DosingMainPumpHeadList({
    super.key,
    required this.isConnected,
    required this.session,
    this.onHeadTap,
    this.onHeadPlay,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Get real pump heads from session, or use empty placeholders
    final List<PumpHead> pumpHeads = session.pumpHeads;
    final Map<String, PumpHead> headMap = {
      for (final PumpHead head in pumpHeads) head.headId.toUpperCase(): head,
    };

    // PARITY: Android paddingTop=12dp, paddingBottom=32dp
    return Padding(
      padding: const EdgeInsets.only(
        top: 12, // dp_12 paddingTop
        bottom: 32, // dp_32 paddingBottom
      ),
      child: Column(
        children: _headOrder.map((headId) {
          final PumpHead? head = headMap[headId.toUpperCase()];
          final PumpHeadSummary summary = head != null
              ? PumpHeadSummary.fromPumpHead(head)
              : PumpHeadSummary.empty(headId);

          return DosingMainPumpHeadCard(
            summary: summary,
            isConnected: isConnected,
            l10n: l10n,
            onTap: onHeadTap != null ? () => onHeadTap!(headId) : null,
            onPlay: onHeadPlay != null ? () => onHeadPlay!(headId) : null,
          );
        }).toList(),
      ),
    );
  }
}

const List<String> _headOrder = ['A', 'B', 'C', 'D'];
