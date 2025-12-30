import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/doser_dosing/pump_head.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../models/pump_head_summary.dart';
import 'dosing_main_pump_head_card.dart';

/// Pump head list widget for dosing main page.
///
/// PARITY: Mirrors reef-b-app's rv_drop_head RecyclerView.
class DosingMainPumpHeadList extends StatelessWidget {
  final bool isConnected;
  final AppContext appContext;
  final AppSession session;
  final ValueChanged<String> onHeadTap;
  final ValueChanged<String>? onHeadPlay;

  const DosingMainPumpHeadList({
    super.key,
    required this.isConnected,
    required this.appContext,
    required this.session,
    required this.onHeadTap,
    this.onHeadPlay,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final l10n = AppLocalizations.of(context);

    // Get real pump heads from session, or use empty placeholders
    final List<PumpHead> pumpHeads = session.pumpHeads;
    final Map<String, PumpHead> headMap = {
      for (final PumpHead head in pumpHeads) head.headId.toUpperCase(): head,
    };

    final List<Widget> cards = <Widget>[];
    for (final String headId in _headOrder) {
      final PumpHead? head = headMap[headId.toUpperCase()];
      final PumpHeadSummary summary = head != null
          ? PumpHeadSummary.fromPumpHead(head)
          : PumpHeadSummary.empty(headId);

      cards.add(
        DosingMainPumpHeadCard(
          summary: summary,
          isConnected: isConnected,
          l10n: l10n,
          onTap: isConnected ? () => onHeadTap(headId) : null,
          onPlay: isConnected && onHeadPlay != null
              ? () => onHeadPlay!(headId)
              : null,
        ),
      );
      cards.add(const SizedBox(height: AppSpacing.md));
    }
    if (cards.isNotEmpty) {
      cards.removeLast();
    }
    return Column(children: cards);
  }
}

const List<String> _headOrder = ['A', 'B', 'C', 'D'];

