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
import '../../../widgets/reef_app_bar.dart';
import '../models/pump_head_summary.dart';
import 'dosing_main_page_helpers.dart'
    show confirmDeleteDevice, confirmResetDevice, handlePlayDosing, handleConnect, handleDisconnect;
import 'manual_dosing_page.dart';
import 'pump_head_detail_page.dart';
import 'pump_head_schedule_page.dart';
import 'pump_head_calibration_page.dart';
import '../../device/pages/device_settings_page.dart';
import 'package:koralcore/l10n/app_localizations.dart';


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
      appBar: ReefAppBar(
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
            // PARITY: Entry tiles (Schedule, Manual, Calibration, History)
            // These are not in the XML, but are part of the Flutter implementation
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ReefSpacing.md),
              child: Column(
                children: [
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

/// Drop head card matching adapter_drop_head.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_drop_head.xml structure:
/// - MaterialCardView: margin 16/5/16/5dp, cornerRadius 8dp, elevation 10dp
/// - Title area: grey background, padding 8dp, pump head icon (80×20dp), drop type name
/// - Main area: white background, padding 8/8/12/12dp, play button (60×60dp), mode, schedule info, progress bar
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
    // Calculate progress (todayDispensedMl / dailyTargetMl)
    final double progress = summary.dailyTargetMl > 0
        ? (summary.todayDispensedMl / summary.dailyTargetMl).clamp(0.0, 1.0)
        : 0.0;
    final String volumeText = '${summary.todayDispensedMl.toStringAsFixed(0)} / ${summary.dailyTargetMl.toStringAsFixed(0)} ml';
    
    // Mode name (simplified - TODO: Get from PumpHeadMode)
    final String modeName = _getModeName(summary, l10n);
    
    // Time string (simplified - TODO: Get from PumpHeadMode.timeString)
    final String? timeString = null; // TODO: Get from schedule
    
    // Weekday selection (simplified - TODO: Get from PumpHeadMode.runDay)
    final List<bool> weekDays = [false, false, false, false, false, false, false]; // TODO: Get from schedule

    // PARITY: adapter_drop_head.xml structure
    return Card(
      margin: EdgeInsets.only(
        left: ReefSpacing.md, // dp_16 marginStart
        top: 5, // dp_5 marginTop
        right: ReefSpacing.md, // dp_16 marginEnd
        bottom: 5, // dp_5 marginBottom
      ),
      elevation: 10, // dp_10
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.sm), // dp_8 cornerRadius
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ReefRadius.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title area (layout_drop_head_title) - grey background
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ReefSpacing.xs), // dp_8 padding
              decoration: BoxDecoration(
                color: ReefColors.grey, // grey background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ReefRadius.sm),
                  topRight: Radius.circular(ReefRadius.sm),
                ),
              ),
              child: Row(
                children: [
                  // Pump head icon (img_drop_head) - 80×20dp
                  Image.asset(
                    'assets/icons/dosing/img_drop_head_${summary.headId.toLowerCase()}.png', // TODO: Add icon asset
                    width: 80, // dp_80
                    height: 20, // dp_20
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 20,
                      color: ReefColors.surfaceMuted,
                    ),
                  ),
                  SizedBox(width: 32), // dp_32 marginStart
                  // Drop type name (tv_drop_type_name) - body_accent
                  Expanded(
                    child: Text(
                      summary.additiveName.isNotEmpty
                          ? summary.additiveName
                          : l10n.dosingPumpHeadNoType,
                      style: ReefTextStyles.bodyAccent.copyWith(
                        color: ReefColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Main area (layout_drop_head_main) - white background
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: ReefSpacing.xs, // dp_8 paddingStart
                top: ReefSpacing.xs, // dp_8 paddingTop
                right: ReefSpacing.md + ReefSpacing.xs, // dp_12 paddingEnd
                bottom: ReefSpacing.md + ReefSpacing.xs, // dp_12 paddingBottom
              ),
              decoration: BoxDecoration(
                color: ReefColors.surface, // white background
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(ReefRadius.sm),
                  bottomRight: Radius.circular(ReefRadius.sm),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Play button (btn_play) - 60×60dp
                  if (onPlay != null)
                    IconButton(
                      icon: Image.asset(
                        'assets/icons/ic_play_enabled.png', // TODO: Add icon asset
                        width: 60, // dp_60
                        height: 60, // dp_60
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.play_arrow,
                          size: 60,
                          color: ReefColors.primary,
                        ),
                      ),
                      onPressed: onPlay,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: 60,
                        minHeight: 60,
                      ),
                    )
                  else
                    SizedBox(width: 60, height: 60),
                  SizedBox(width: ReefSpacing.md), // dp_12 marginStart
                  // Mode and schedule info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mode (tv_mode) - caption1, bg_secondary color
                        Text(
                          modeName,
                          style: ReefTextStyles.caption1.copyWith(
                            color: ReefColors.textSecondary, // bg_secondary (using textSecondary as fallback)
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ReefSpacing.xs), // dp_8 marginTop
                        // Schedule info (layout_mode)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Weekday icons (layout_weekday)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(7, (index) {
                                final bool isSelected = weekDays[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: index == 0 ? 0 : ReefSpacing.xs, // dp_4 marginStart (except first)
                                    right: index < 6 ? ReefSpacing.xs : 0, // dp_4 marginEnd (except last)
                                  ),
                                  child: Image.asset(
                                    _getWeekdayIconAsset(index, isSelected),
                                    width: 20, // dp_20
                                    height: 20, // dp_20
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.circle_outlined,
                                      size: 20,
                                      color: isSelected
                                          ? ReefColors.primary
                                          : ReefColors.textDisabled,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            // Time string (tv_time) - caption1_accent, text_aaaa
                            if (timeString != null) ...[
                              SizedBox(height: ReefSpacing.xs), // dp_8 marginTop
                              Text(
                                timeString,
                                style: ReefTextStyles.caption1Accent.copyWith(
                                  color: ReefColors.textPrimary, // text_aaaa
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            // Progress bar and volume (pb_volume, tv_volume)
                            SizedBox(height: ReefSpacing.xs), // dp_4 marginTop
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Progress bar
                                LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 20, // dp_20 trackThickness
                                  backgroundColor: ReefColors.surfacePressed, // bg_press trackColor
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ReefColors.grey, // grey indicatorColor
                                  ),
                                  borderRadius: BorderRadius.circular(10), // dp_10 trackCornerRadius
                                ),
                                // Volume text (tv_volume) - caption1, text_aaaa
                                Text(
                                  volumeText,
                                  style: ReefTextStyles.caption1.copyWith(
                                    color: ReefColors.textPrimary, // text_aaaa
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getModeName(PumpHeadSummary summary, AppLocalizations l10n) {
    // TODO: Get actual mode from PumpHeadMode
    // For now, return a default mode name
    if (summary.dailyTargetMl > 0) {
      return l10n.dosingPumpHeadModeScheduled;
    }
    return l10n.dosingPumpHeadModeFree;
  }

  String _getWeekdayIconAsset(int index, bool isSelected) {
    // Index: 0=Sunday, 1=Monday, ..., 6=Saturday
    final List<String> weekdayNames = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    final String state = isSelected ? 'select' : 'unselect';
    return 'assets/icons/ic_${weekdayNames[index]}_$state.png';
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
