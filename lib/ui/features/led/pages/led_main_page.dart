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
import '../../../../domain/led_lighting/led_schedule_overview.dart';
import '../../../components/ble_guard.dart';
import '../../../components/app_error_presenter.dart';
import '../controllers/led_scene_list_controller.dart';
import '../controllers/led_schedule_summary_controller.dart';
import '../models/led_scene_summary.dart';
import 'led_control_page.dart';
import 'led_schedule_edit_page.dart';
import 'led_scene_list_page.dart';
import 'led_schedule_list_page.dart';

class LedMainPage extends StatelessWidget {
  const LedMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final appContext = context.read<AppContext>();
    final l10n = AppLocalizations.of(context);
    final deviceName = session.activeDeviceName ?? l10n.ledDetailUnknownDevice;
    final isConnected = session.isBleConnected;

    return Scaffold(
      backgroundColor: ReefColors.primaryStrong,
      appBar: AppBar(
        backgroundColor: ReefColors.primary,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        titleTextStyle: ReefTextStyles.title2.copyWith(
          color: ReefColors.onPrimary,
        ),
        title: Text(l10n.ledHeader),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(ReefSpacing.xl),
          children: [
            Text(
              l10n.ledSubHeader,
              style: ReefTextStyles.body.copyWith(color: ReefColors.surface),
            ),
            const SizedBox(height: ReefSpacing.lg),
            if (!isConnected) ...[
              const BleGuardBanner(),
              const SizedBox(height: ReefSpacing.xl),
            ],
            _DeviceHeaderCard(
              deviceName: deviceName,
              isConnected: isConnected,
              l10n: l10n,
            ),
            const SizedBox(height: ReefSpacing.xl),
            ChangeNotifierProvider<LedSceneListController>(
              create: (_) => LedSceneListController(
                session: session,
                readLedScenesUseCase: appContext.readLedScenesUseCase,
              )..refresh(),
              child: _SceneCarousel(isConnected: isConnected, l10n: l10n),
            ),
            const SizedBox(height: ReefSpacing.xl),
            ChangeNotifierProvider<LedScheduleSummaryController>(
              create: (_) => LedScheduleSummaryController(
                session: session,
                readLedScheduleSummaryUseCase:
                    appContext.readLedScheduleSummaryUseCase,
              )..refresh(),
              child: _LedScheduleSummarySection(
                l10n: l10n,
                isConnected: isConnected,
              ),
            ),
            const SizedBox(height: ReefSpacing.xl),
            _EntryTile(
              title: l10n.ledEntryIntensity,
              subtitle: l10n.ledIntensityEntrySubtitle,
              enabled: isConnected,
              onTapWhenEnabled: () {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(context)
                    .push<bool>(
                      MaterialPageRoute(builder: (_) => const LedControlPage()),
                    )
                    .then((result) {
                      if (result != true) {
                        return;
                      }
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.ledControlApplySuccess)),
                      );
                    });
              },
            ),
            _EntryTile(
              title: l10n.ledEntryScenes,
              subtitle: l10n.ledScenesListSubtitle,
              enabled: isConnected,
              onTapWhenEnabled: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LedSceneListPage()),
                );
              },
            ),
            _EntryTile(
              title: l10n.ledEntrySchedule,
              subtitle: l10n.ledScheduleListSubtitle,
              enabled: isConnected,
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
        : ReefColors.textSecondary.withOpacity(0.6);

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceName,
                        style: ReefTextStyles.title1.copyWith(
                          color: ReefColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: ReefSpacing.sm),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: ReefSpacing.sm),
                          Text(
                            statusText,
                            style: ReefTextStyles.body.copyWith(
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showComingSoon(context, l10n),
                  tooltip: l10n.ledDetailFavoriteTooltip,
                  icon: const Icon(Icons.star_border),
                ),
              ],
            ),
            const SizedBox(height: ReefSpacing.md),
            Text(
              l10n.ledDetailHeaderHint,
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

class _SceneCarousel extends StatelessWidget {
  final bool isConnected;
  final AppLocalizations l10n;

  const _SceneCarousel({required this.isConnected, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.ledScenesPlaceholderTitle,
          subtitle: l10n.ledScenesPlaceholderSubtitle,
        ),
        const SizedBox(height: ReefSpacing.md),
        SizedBox(
          height: 190,
          child: Consumer<LedSceneListController>(
            builder: (context, controller, _) {
              _maybeShowSceneError(context, controller);

              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final scenes = controller.scenes.take(5).toList();
              if (scenes.isEmpty) {
                return _SceneCarouselEmptyCard(l10n: l10n);
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: scenes.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: ReefSpacing.md),
                itemBuilder: (context, index) {
                  final scene = scenes[index];
                  return SizedBox(
                    width: 220,
                    child: _ScenePreviewCard(
                      scene: scene,
                      l10n: l10n,
                      isConnected: isConnected,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
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

class _ScenePreviewCard extends StatelessWidget {
  final LedSceneSummary scene;
  final AppLocalizations l10n;
  final bool isConnected;

  const _ScenePreviewCard({
    required this.scene,
    required this.l10n,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = scene.isEnabled
        ? l10n.ledSceneStatusEnabled
        : l10n.ledSceneStatusDisabled;
    final statusColor = scene.isEnabled ? Colors.white : Colors.white70;
    return Card(
      color: ReefColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ReefRadius.md),
      ),
      child: InkWell(
        onTap: isConnected
            ? () => _showComingSoon(context, l10n)
            : () => showBleGuardDialog(context),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: scene.palette,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(ReefSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      scene.name,
                      style: ReefTextStyles.subheaderAccent.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    statusLabel,
                    style: ReefTextStyles.caption1.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                scene.description,
                style: ReefTextStyles.caption1.copyWith(color: Colors.white70),
              ),
            ],
          ),
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

void _maybeShowScheduleSummaryError(
  BuildContext context,
  LedScheduleSummaryController controller,
) {
  final code = controller.lastErrorCode;
  if (code == null) {
    return;
  }

  _showAppError(context, code);
  controller.clearError();
}

String _ledSummaryModeLabel(LedScheduleMode mode, AppLocalizations l10n) {
  switch (mode) {
    case LedScheduleMode.dailyProgram:
      return l10n.ledScheduleTypeDaily;
    case LedScheduleMode.customWindow:
      return l10n.ledScheduleTypeCustom;
    case LedScheduleMode.sceneBased:
      return l10n.ledScheduleTypeScene;
    case LedScheduleMode.none:
      return l10n.ledScheduleSummaryEmpty;
  }
}

void _showAppError(BuildContext context, AppErrorCode code) {
  final message = describeAppError(AppLocalizations.of(context), code);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String _formatWindow(
  MaterialLocalizations localizations,
  TimeOfDay start,
  TimeOfDay end,
  bool use24HourFormat,
) {
  final startLabel = localizations.formatTimeOfDay(
    start,
    alwaysUse24HourFormat: use24HourFormat,
  );
  final endLabel = localizations.formatTimeOfDay(
    end,
    alwaysUse24HourFormat: use24HourFormat,
  );
  return '$startLabel – $endLabel';
}

class _LedScheduleSummaryCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _LedScheduleSummaryCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final bool use24h =
        MediaQuery.maybeOf(context)?.alwaysUse24HourFormat ?? false;
    final materialLocalizations = MaterialLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.ledScheduleSummaryTitle,
          subtitle: l10n.ledScheduleListSubtitle,
        ),
        const SizedBox(height: ReefSpacing.md),
        Card(
          color: ReefColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReefRadius.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ReefSpacing.lg),
            child: Consumer<LedScheduleSummaryController>(
              builder: (context, controller, _) {
                _maybeShowScheduleSummaryError(context, controller);

                if (controller.isLoading) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final summary = controller.summary;
                if (summary == null || !summary.hasSchedule) {
                  return Text(
                    l10n.ledScheduleSummaryEmpty,
                    style: ReefTextStyles.body.copyWith(
                      color: ReefColors.textSecondary,
                    ),
                  );
                }

                final String modeLabel = _ledSummaryModeLabel(
                  summary.mode,
                  l10n,
                );
                final String? windowLabel = _resolveWindowLabel(
                  summary,
                  materialLocalizations,
                  use24h,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ReefSpacing.md,
                            vertical: ReefSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: ReefColors.info.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(ReefRadius.md),
                          ),
                          child: Text(
                            modeLabel,
                            style: ReefTextStyles.caption1Accent.copyWith(
                              color: ReefColors.info,
                            ),
                          ),
                        ),
                        const SizedBox(width: ReefSpacing.sm),
                        Text(
                          summary.isEnabled
                              ? l10n.ledScheduleStatusEnabled
                              : l10n.ledScheduleStatusDisabled,
                          style: ReefTextStyles.caption1.copyWith(
                            color: summary.isEnabled
                                ? ReefColors.success
                                : ReefColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ReefSpacing.lg),
                    if ((summary.label ?? '').isNotEmpty) ...[
                      Text(
                        l10n.ledScheduleSummaryLabel,
                        style: ReefTextStyles.caption1.copyWith(
                          color: ReefColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: ReefSpacing.xs),
                      Text(
                        summary.label!,
                        style: ReefTextStyles.subheaderAccent.copyWith(
                          color: ReefColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: ReefSpacing.lg),
                    ],
                    if (windowLabel != null) ...[
                      Text(
                        l10n.ledScheduleSummaryWindowLabel,
                        style: ReefTextStyles.caption1.copyWith(
                          color: ReefColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: ReefSpacing.xs),
                      Text(
                        windowLabel,
                        style: ReefTextStyles.subheaderAccent.copyWith(
                          color: ReefColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  String? _resolveWindowLabel(
    LedScheduleOverview summary,
    MaterialLocalizations localizations,
    bool use24HourFormat,
  ) {
    if (summary.startMinute == null || summary.endMinute == null) {
      return null;
    }
    final TimeOfDay start = _minutesToTime(summary.startMinute!);
    final TimeOfDay end = _minutesToTime(summary.endMinute!);
    return _formatWindow(localizations, start, end, use24HourFormat);
  }

  TimeOfDay _minutesToTime(int minutes) {
    final normalized = minutes.clamp(0, 23 * 60 + 59);
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

class _LedScheduleSummarySection extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isConnected;

  const _LedScheduleSummarySection({
    required this.l10n,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LedScheduleSummaryCard(l10n: l10n),
        const SizedBox(height: ReefSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: isConnected
                ? () => _openEditor(context)
                : () => showBleGuardDialog(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.ledScheduleAddButton),
          ),
        ),
      ],
    );
  }

  Future<void> _openEditor(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LedScheduleEditPage()),
    );
    if (result != true) {
      return;
    }

    final LedScheduleSummaryController controller = context
        .read<LedScheduleSummaryController>();
    await controller.refresh();
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.ledScheduleEditSuccess)),
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
    final l10n = AppLocalizations.of(context);
    final Color titleColor = enabled
        ? ReefColors.textPrimary
        : ReefColors.textSecondary;
    final Color subtitleColor = enabled
        ? ReefColors.textSecondary
        : ReefColors.textSecondary.withOpacity(0.6);

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
        onTap: enabled
            ? (onTapWhenEnabled ?? () => _showComingSoon(context, l10n))
            : () => showBleGuardDialog(context),
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
            color: ReefColors.surface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

void _showComingSoon(BuildContext context, AppLocalizations l10n) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
}
