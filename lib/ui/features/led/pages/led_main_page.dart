import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../../domain/led_lighting/led_state.dart';
import '../../../components/ble_guard.dart';
import '../../../components/app_error_presenter.dart';
import '../controllers/led_scene_list_controller.dart';
import '../models/led_scene_summary.dart';
import '../support/scene_channel_helper.dart';
import '../support/scene_display_text.dart';
import '../widgets/led_spectrum_chart.dart';
import 'led_control_page.dart';
import 'led_record_page.dart';
import 'led_scene_list_page.dart';
import 'led_schedule_list_page.dart';

const _ledIconAsset = 'assets/icons/led/led_main.png';

class LedMainPage extends StatelessWidget {
  const LedMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

    return ChangeNotifierProvider<LedSceneListController>(
      create: (_) => LedSceneListController(
        session: session,
        readLedScenesUseCase: appContext.readLedScenesUseCase,
        applySceneUseCase: appContext.applySceneUseCase,
        observeLedStateUseCase: appContext.observeLedStateUseCase,
        readLedStateUseCase: appContext.readLedStateUseCase,
        stopLedPreviewUseCase: appContext.stopLedPreviewUseCase,
      )..initialize(),
      child: const _LedMainScaffold(),
    );
  }
}

class _LedMainScaffold extends StatelessWidget {
  const _LedMainScaffold();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final l10n = AppLocalizations.of(context);
    final deviceName = session.activeDeviceName ?? l10n.ledDetailUnknownDevice;

    return Consumer<LedSceneListController>(
      builder: (context, controller, _) {
        final bool isConnected = session.isBleConnected;
        final bool writeLocked = controller.isWriteLocked;
        final bool featuresEnabled = isConnected && !writeLocked;

        return Scaffold(
          backgroundColor: ReefColors.primaryStrong,
          appBar: AppBar(
            backgroundColor: ReefColors.primaryStrong,
            elevation: 0,
            title: Text(
              l10n.ledHeader,
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
                  l10n.ledSubHeader,
                  style: ReefTextStyles.body.copyWith(
                    color: ReefColors.surface,
                  ),
                ),
                const SizedBox(height: ReefSpacing.md),
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: ReefSpacing.md),
                ],
                const SizedBox(height: ReefSpacing.md),
                _DeviceHeaderCard(
                  deviceName: deviceName,
                  isConnected: isConnected,
                  l10n: l10n,
                ),
                const SizedBox(height: ReefSpacing.xl),
                _RuntimeStatusCard(controller: controller),
                const SizedBox(height: ReefSpacing.xl),
                _SceneListSection(l10n: l10n, controller: controller),
                const SizedBox(height: ReefSpacing.xl),
                _EntryTile(
                  title: l10n.ledEntryIntensity,
                  subtitle: l10n.ledIntensityEntrySubtitle,
                  enabled: featuresEnabled,
                  onTapWhenEnabled: () {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(context)
                        .push<bool>(
                          MaterialPageRoute(
                            builder: (_) => const LedControlPage(),
                          ),
                        )
                        .then((result) {
                          if (result != true) {
                            return;
                          }
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(l10n.ledControlApplySuccess),
                            ),
                          );
                        });
                  },
                ),
                _EntryTile(
                  title: l10n.ledEntryScenes,
                  subtitle: l10n.ledScenesListSubtitle,
                  enabled: featuresEnabled,
                  onTapWhenEnabled: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LedSceneListPage(),
                      ),
                    );
                  },
                ),
                _EntryTile(
                  title: l10n.ledEntryRecords,
                  subtitle: l10n.ledEntryRecordsSubtitle,
                  enabled: featuresEnabled,
                  onTapWhenEnabled: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LedRecordPage()),
                    );
                  },
                ),
                _EntryTile(
                  title: l10n.ledEntrySchedule,
                  subtitle: l10n.ledScheduleListSubtitle,
                  enabled: featuresEnabled,
                  onTapWhenEnabled: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LedScheduleListPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DeviceHeaderCard extends StatelessWidget {
  final String deviceName;
  final bool isConnected;
  final AppLocalizations l10n;

  const _DeviceHeaderCard({
    required this.deviceName,
    required this.isConnected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = isConnected
        ? l10n.deviceStateConnected
        : l10n.deviceStateDisconnected;
    final statusColor = isConnected
        ? ReefColors.success
        : ReefColors.textSecondary.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(ReefSpacing.lg),
      decoration: BoxDecoration(
        color: ReefColors.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ReefRadius.lg),
      ),
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
              child: Image.asset(_ledIconAsset, width: 30, height: 30),
            ),
          ),
          const SizedBox(width: ReefSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  deviceName,
                  style: ReefTextStyles.subheaderAccent.copyWith(
                    color: ReefColors.surface,
                  ),
                ),
                const SizedBox(height: ReefSpacing.xs),
                Text(
                  statusText,
                  style: ReefTextStyles.caption1.copyWith(color: statusColor),
                ),
                const SizedBox(height: ReefSpacing.xs),
                Text(
                  l10n.ledDetailHeaderHint,
                  style: ReefTextStyles.caption1.copyWith(
                    color: ReefColors.surface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RuntimeStatusCard extends StatelessWidget {
  final LedSceneListController controller;

  const _RuntimeStatusCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String statusLabel = _statusLabel(l10n);
    final Color statusColor = _statusColor();
    final LedSceneSummary? activeScene = _activeScene();
    final LedStateSchedule? activeSchedule = controller.activeSchedule;
    final List<Widget> chips = [];

    if (activeScene != null) {
      final String activeName = LedSceneDisplayText.name(activeScene, l10n);
      chips.add(
        _RuntimeInfoChip(
          color: ReefColors.success,
          label: l10n.ledSceneCurrentlyRunning,
          value: activeName,
          detail: _sceneTypeLabel(activeScene, l10n),
        ),
      );
    }
    if (activeSchedule != null) {
      chips.add(
        _RuntimeInfoChip(
          color: ReefColors.info,
          label: l10n.ledRuntimeScheduleActive,
          value: _scheduleTypeLabel(activeSchedule, l10n),
          detail: _scheduleRange(activeSchedule, context),
        ),
      );
    }

    return Card(
      color: ReefColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.ledRuntimeStatus,
              style: ReefTextStyles.subheaderAccent.copyWith(
                color: ReefColors.textPrimary,
              ),
            ),
            const SizedBox(height: ReefSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ReefSpacing.md,
                vertical: ReefSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(ReefRadius.md),
              ),
              child: Text(
                statusLabel,
                style: ReefTextStyles.caption1Accent.copyWith(
                  color: statusColor,
                ),
              ),
            ),
            if (chips.isNotEmpty) ...[
              const SizedBox(height: ReefSpacing.md),
              Wrap(
                spacing: ReefSpacing.sm,
                runSpacing: ReefSpacing.sm,
                children: chips,
              ),
            ],
          ],
        ),
      ),
    );
  }

  LedSceneSummary? _activeScene() {
    for (final scene in controller.scenes) {
      if (scene.isActive) {
        return scene;
      }
    }
    return null;
  }

  String _statusLabel(AppLocalizations l10n) {
    if (controller.ledStatus == LedStatus.applying) {
      return l10n.ledRuntimeApplying;
    }
    if (controller.activeScheduleId != null) {
      return l10n.ledRuntimeScheduleActive;
    }
    if (controller.activeSceneId != null) {
      return l10n.ledRuntimePreview;
    }
    return l10n.ledRuntimeIdle;
  }

  Color _statusColor() {
    if (controller.ledStatus == LedStatus.applying) {
      return ReefColors.warning;
    }
    if (controller.activeScheduleId != null) {
      return ReefColors.success;
    }
    if (controller.activeSceneId != null) {
      return ReefColors.info;
    }
    return ReefColors.textSecondary;
  }

  String _scheduleRange(LedStateSchedule schedule, BuildContext context) {
    final TimeOfDay start = _minutesToTime(
      schedule.window.startMinutesFromMidnight,
    );
    final TimeOfDay end = _minutesToTime(
      schedule.window.endMinutesFromMidnight,
    );
    final materialLocalizations = MaterialLocalizations.of(context);
    return '${materialLocalizations.formatTimeOfDay(start)} – ${materialLocalizations.formatTimeOfDay(end)}';
  }

  String _scheduleTypeLabel(LedStateSchedule schedule, AppLocalizations l10n) {
    final String recurrence = schedule.window.recurrenceLabel.toLowerCase();
    if (recurrence.contains('daily')) {
      return l10n.ledScheduleDaily;
    }
    if (recurrence.contains('window')) {
      return l10n.ledScheduleWindow;
    }

    final int duration =
        schedule.window.endMinutesFromMidnight -
        schedule.window.startMinutesFromMidnight;
    if (duration >= 12 * 60) {
      return l10n.ledScheduleDaily;
    }
    return l10n.ledScheduleWindow;
  }

  String _sceneTypeLabel(LedSceneSummary scene, AppLocalizations l10n) {
    return scene.isPreset ? l10n.ledScenePreset : l10n.ledSceneCustom;
  }

  TimeOfDay _minutesToTime(int minutes) {
    final normalized = minutes.clamp(0, 23 * 60 + 59);
    return TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60);
  }
}

class _RuntimeInfoChip extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String? detail;

  const _RuntimeInfoChip({
    required this.color,
    required this.label,
    required this.value,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ReefSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: ReefTextStyles.caption1Accent.copyWith(color: color),
          ),
          const SizedBox(height: ReefSpacing.xs),
          Text(
            value,
            style: ReefTextStyles.caption1.copyWith(
              color: ReefColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: ReefSpacing.xs),
            Text(
              detail!,
              style: ReefTextStyles.caption2.copyWith(
                color: ReefColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SceneListSection extends StatelessWidget {
  final AppLocalizations l10n;
  final LedSceneListController controller;

  const _SceneListSection({required this.l10n, required this.controller});

  @override
  Widget build(BuildContext context) {
    final List<Widget> content = [];
    final Widget? error = _buildInlineErrorMessage(
      context,
      controller.lastErrorCode,
    );
    if (error != null) {
      content.add(error);
      content.add(const SizedBox(height: ReefSpacing.sm));
      controller.clearError();
    }

    if (controller.currentChannelLevels.isNotEmpty) {
      content.add(
        LedSpectrumChart.fromChannelMap(
          controller.currentChannelLevels,
          height: 80,
          emptyLabel: l10n.ledControlEmptyState,
        ),
      );
      content.add(const SizedBox(height: ReefSpacing.md));
    }

    if (controller.isLoading) {
      content.add(const Center(child: CircularProgressIndicator()));
    } else {
      final scenes = controller.scenes;
      if (scenes.isEmpty) {
        content.add(_SceneCarouselEmptyCard(l10n: l10n));
      } else {
        final int channelCount = controller.currentChannelLevels.length;
        content.add(
          Column(
            children: [
              for (int i = 0; i < scenes.length; i++) ...[
                _SceneListTile(
                  scene: scenes[i],
                  l10n: l10n,
                  channelCount: channelCount,
                ),
                if (i != scenes.length - 1)
                  const SizedBox(height: ReefSpacing.md),
              ],
            ],
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.ledScenesPlaceholderTitle,
          subtitle: l10n.ledScenesPlaceholderSubtitle,
        ),
        const SizedBox(height: ReefSpacing.md),
        ...content,
      ],
    );
  }
}

class _SceneListTile extends StatelessWidget {
  final LedSceneSummary scene;
  final AppLocalizations l10n;
  final int channelCount;

  const _SceneListTile({
    required this.scene,
    required this.l10n,
    required this.channelCount,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = scene.isActive;
    final String sceneName = LedSceneDisplayText.name(scene, l10n);
    final String sceneDescription = LedSceneDisplayText.description(
      scene,
      l10n,
    );
    final String statusLabel;
    final Color statusColor;
    if (isActive) {
      statusLabel = l10n.ledSceneStatusActive;
      statusColor = ReefColors.success;
    } else if (scene.isEnabled) {
      statusLabel = l10n.ledSceneStatusEnabled;
      statusColor = ReefColors.primary;
    } else {
      statusLabel = l10n.ledSceneStatusDisabled;
      statusColor = ReefColors.warning;
    }

    final Color cardColor = isActive
        ? ReefColors.primary.withValues(alpha: 0.2)
        : ReefColors.surface;
    final Color nameColor = isActive
        ? ReefColors.surface
        : ReefColors.textPrimary;
    final Color descriptionColor = isActive
        ? ReefColors.surface.withValues(alpha: 0.85)
        : ReefColors.textSecondary;
    final Color badgeTextColor = isActive ? ReefColors.surface : statusColor;
    final Color badgeBackground = isActive
        ? ReefColors.surface.withValues(alpha: 0.25)
        : statusColor.withValues(alpha: 0.15);
    final String typeLabel = scene.isPreset
        ? l10n.ledScenePreset
        : l10n.ledSceneCustom;
    final String channelLabel = l10n.ledSceneChannelCount(channelCount);
    final List<SceneChannelStat> channelStats = buildSceneChannelStats(
      scene,
      l10n,
    );
    final List<Color> palette = scene.palette.isNotEmpty
        ? scene.palette
        : <Color>[
            ReefColors.primary,
            ReefColors.primary.withValues(alpha: 0.65),
          ];

    return Container(
      padding: const EdgeInsets.all(ReefSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(ReefRadius.lg),
        border: Border.all(
          color: isActive ? ReefColors.primary : ReefColors.surface,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: palette,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ReefRadius.md),
            ),
          ),
          const SizedBox(width: ReefSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sceneName,
                  style: ReefTextStyles.subheaderAccent.copyWith(
                    color: nameColor,
                  ),
                ),
                const SizedBox(height: ReefSpacing.xs),
                Text(
                  sceneDescription,
                  style: ReefTextStyles.caption1.copyWith(
                    color: descriptionColor,
                  ),
                ),
                const SizedBox(height: ReefSpacing.sm),
                Wrap(
                  spacing: ReefSpacing.sm,
                  runSpacing: ReefSpacing.xs,
                  children: [
                    Text(
                      typeLabel,
                      style: ReefTextStyles.caption1.copyWith(
                        color: descriptionColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      channelLabel,
                      style: ReefTextStyles.caption1.copyWith(
                        color: descriptionColor,
                      ),
                    ),
                  ],
                ),
                if (channelStats.isNotEmpty) ...[
                  const SizedBox(height: ReefSpacing.xs),
                  _SceneChannelBadges(
                    stats: channelStats,
                    textColor: descriptionColor,
                    backgroundColor: isActive
                        ? ReefColors.surface.withValues(alpha: 0.2)
                        : ReefColors.surface,
                    borderColor: isActive
                        ? ReefColors.surface.withValues(alpha: 0.4)
                        : ReefColors.greyLight,
                  ),
                ],
                if (isActive) ...[
                  const SizedBox(height: ReefSpacing.sm),
                  Text(
                    l10n.ledSceneCurrentlyRunning,
                    style: ReefTextStyles.caption1.copyWith(
                      color: ReefColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ReefSpacing.md,
              vertical: ReefSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: badgeBackground,
              borderRadius: BorderRadius.circular(ReefRadius.pill),
            ),
            child: Text(
              statusLabel,
              style: ReefTextStyles.caption1.copyWith(color: badgeTextColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneChannelBadges extends StatelessWidget {
  final List<SceneChannelStat> stats;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  const _SceneChannelBadges({
    required this.stats,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: ReefSpacing.sm,
      runSpacing: ReefSpacing.xs,
      children: stats
          .map(
            (stat) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ReefSpacing.sm,
                vertical: ReefSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(ReefRadius.sm),
                border: Border.all(color: borderColor, width: 0.5),
              ),
              child: Text(
                '${stat.label} ${stat.value}%',
                style: ReefTextStyles.caption2.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _SceneCarouselEmptyCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _SceneCarouselEmptyCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ReefColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.ledScenesEmptyTitle,
              style: ReefTextStyles.subheaderAccent.copyWith(
                color: ReefColors.textPrimary,
              ),
            ),
            const SizedBox(height: ReefSpacing.xs),
            Text(
              l10n.ledScenesEmptySubtitle,
              style: ReefTextStyles.caption1.copyWith(
                color: ReefColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _maybeShowSceneError(
  BuildContext context,
  LedSceneListController controller,
) {
  final code = controller.lastErrorCode;
  if (code == null) {
    return;
  }

  _showAppError(context, code);
  controller.clearError();
}

void _showAppError(BuildContext context, AppErrorCode code) {
  final message = describeAppError(AppLocalizations.of(context), code);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
    final Color titleColor = enabled
        ? ReefColors.textPrimary
        : ReefColors.textSecondary;
    final Color subtitleColor = enabled
        ? ReefColors.textSecondary
        : ReefColors.textSecondary.withValues(alpha: 0.6);

    return Card(
      color: ReefColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      margin: const EdgeInsets.only(bottom: ReefSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ReefSpacing.lg,
          vertical: ReefSpacing.md,
        ),
        title: Text(
          title,
          style: ReefTextStyles.subheaderAccent.copyWith(color: titleColor),
        ),
        subtitle: Text(
          subtitle,
          style: ReefTextStyles.caption1.copyWith(color: subtitleColor),
        ),
        trailing: Icon(Icons.chevron_right, color: titleColor),
        onTap: enabled ? onTapWhenEnabled : () => showBleGuardDialog(context),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
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
            color: ReefColors.surface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
