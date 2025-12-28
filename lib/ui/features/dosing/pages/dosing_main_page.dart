import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/doser_dosing/pump_head.dart';
import '../../../components/ble_guard.dart';
import '../../../components/error_state_widget.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../widgets/reef_backgrounds.dart';
import '../models/pump_head_summary.dart';
import 'dosing_main_page_helpers.dart'
    show confirmDeleteDevice, confirmResetDevice, handlePlayDosing, handleConnect, handleDisconnect;
import 'manual_dosing_page.dart';
import 'pump_head_detail_page.dart';
import 'pump_head_schedule_page.dart';
import 'pump_head_calibration_page.dart';
import '../../device/pages/device_settings_page.dart';
import 'package:koralcore/l10n/app_localizations.dart';

const _dosingIconAsset = 'assets/icons/dosing/dosing_main.png';

class DosingMainPage extends StatelessWidget {
  const DosingMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final appContext = context.read<AppContext>();
    final l10n = AppLocalizations.of(context);
    final bool isConnected = session.isBleConnected;
    final deviceName = session.activeDeviceName ?? l10n.dosingHeader;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ReefColors.primary,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ReefColors.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          deviceName,
          style: ReefTextStyles.title2.copyWith(
            color: ReefColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // Favorite button
          FutureBuilder<bool>(
            future: session.activeDeviceId != null
                ? appContext.deviceRepository.isDeviceFavorite(session.activeDeviceId!)
                : Future.value(false),
            builder: (context, snapshot) {
              final isFavorite = snapshot.data ?? false;
              final deviceId = session.activeDeviceId;
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? ReefColors.error
                      : ReefColors.onPrimary.withValues(alpha: 0.7),
                ),
                tooltip: isFavorite ? l10n.deviceActionUnfavorite : l10n.deviceActionFavorite,
                onPressed: isConnected && deviceId != null
                    ? () async {
                        try {
                          await appContext.toggleFavoriteDeviceUseCase.execute(
                            deviceId: deviceId,
                          );
                          if (context.mounted) {
                            final l10n = AppLocalizations.of(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFavorite
                                      ? l10n.deviceUnfavorited
                                      : l10n.deviceFavorited,
                                ),
                              ),
                            );
                          }
                        } catch (error) {
                          if (context.mounted) {
                                showErrorSnackBar(
                                  context,
                                  AppErrorCode.unknownError,
                                );
                          }
                        }
                      }
                    : null,
              );
            },
          ),
          // Menu button
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: ReefColors.onPrimary),
            enabled: isConnected,
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DeviceSettingsPage(),
                    ),
                  );
                  break;
                case 'delete':
                  confirmDeleteDevice(context, session, appContext);
                  break;
                case 'reset':
                  if (isConnected) {
                    confirmResetDevice(context, session, appContext);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.deviceStateDisconnected)),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 20),
                    const SizedBox(width: ReefSpacing.sm),
                    Text(l10n.deviceActionEdit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 20, color: ReefColors.error),
                    const SizedBox(width: ReefSpacing.sm),
                    Text(
                      l10n.deviceActionDelete,
                      style: const TextStyle(color: ReefColors.error),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, size: 20),
                    const SizedBox(width: ReefSpacing.sm),
                    Text(l10n.dosingResetDevice),
                  ],
                ),
              ),
            ],
          ),
          // BLE connection button
          IconButton(
            icon: Icon(
              isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: ReefColors.onPrimary,
            ),
            tooltip: isConnected ? l10n.deviceActionDisconnect : l10n.deviceActionConnect,
            onPressed: isConnected
                ? () => handleDisconnect(context, session, appContext)
                : () => handleConnect(context, session, appContext),
          ),
        ],
      ),
      body: ReefMainBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(ReefSpacing.xl),
            children: [
            Text(
              l10n.dosingSubHeader,
              style: ReefTextStyles.body.copyWith(color: ReefColors.textPrimary),
            ),
            const SizedBox(height: ReefSpacing.md),
            if (!isConnected) ...[
              const BleGuardBanner(),
              const SizedBox(height: ReefSpacing.md),
            ],
            const SizedBox(height: ReefSpacing.md),
            Text(
              l10n.dosingPumpHeadsHeader,
              style: ReefTextStyles.title2.copyWith(color: ReefColors.textPrimary),
            ),
            const SizedBox(height: ReefSpacing.sm),
            Text(
              l10n.dosingPumpHeadsSubheader,
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.textPrimary,
              ),
            ),
            const SizedBox(height: ReefSpacing.lg),
            _PumpHeadList(
              isConnected: isConnected,
              appContext: appContext,
              session: session,
              onHeadTap: (headId) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PumpHeadDetailPage(headId: headId),
                  ),
                );
              },
              onHeadPlay: isConnected
                  ? (headId) => handlePlayDosing(context, session, appContext, headId)
                  : null,
            ),
            const SizedBox(height: ReefSpacing.xl),
            _EntryTile(
              title: l10n.dosingEntrySchedule,
              subtitle: l10n.dosingScheduleOverviewSubtitle,
              enabled: isConnected,
              onTapWhenEnabled: () {
                // Navigate to first pump head's schedule page
                final firstHeadId = _getFirstPumpHeadId(session);
                if (firstHeadId != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PumpHeadSchedulePage(headId: firstHeadId),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.dosingNoPumpHeads)),
                  );
                }
              },
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
              subtitle: l10n.dosingCalibrationHistorySubtitle,
              enabled: isConnected,
              onTapWhenEnabled: () {
                // Navigate to first pump head's calibration page
                final firstHeadId = _getFirstPumpHeadId(session);
                if (firstHeadId != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PumpHeadCalibrationPage(headId: firstHeadId),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.dosingNoPumpHeads)),
                  );
                }
              },
            ),
            _EntryTile(
              title: l10n.dosingEntryHistory,
              subtitle: l10n.dosingHistorySubtitle,
              enabled: isConnected,
              onTapWhenEnabled: () {
                // Navigate to first pump head's detail page (which shows record history)
                final firstHeadId = _getFirstPumpHeadId(session);
                if (firstHeadId != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PumpHeadDetailPage(headId: firstHeadId),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.dosingNoPumpHeads)),
                  );
                }
              },
            ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get the first available pump head ID
  String? _getFirstPumpHeadId(AppSession session) {
    final pumpHeads = session.pumpHeads;
    if (pumpHeads.isEmpty) {
      return null;
    }
    // Return the first pump head's headId (e.g., 'A', 'B', 'C', 'D')
    return pumpHeads.first.headId;
  }
}

class _PumpHeadList extends StatelessWidget {
  final bool isConnected;
  final AppContext appContext;
  final AppSession session;
  final ValueChanged<String> onHeadTap;
  final ValueChanged<String>? onHeadPlay;

  const _PumpHeadList({
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
        _DropHeadCard(
          summary: summary,
          isConnected: isConnected,
          l10n: l10n,
          onTap: isConnected ? () => onHeadTap(headId) : null,
          onPlay: isConnected && onHeadPlay != null
              ? () => onHeadPlay!(headId)
              : null,
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
  final VoidCallback? onPlay;

  const _DropHeadCard({
    required this.summary,
    required this.isConnected,
    required this.l10n,
    this.onTap,
    this.onPlay,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onPlay != null)
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        color: ReefColors.primary,
                        tooltip: l10n.actionPlay,
                        onPressed: onPlay,
                      ),
                    const Icon(
                      Icons.chevron_right,
                      color: ReefColors.textSecondary,
                    ),
                  ],
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
