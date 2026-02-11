import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../../../core/ble/ble_guard.dart';
import '../controllers/led_control_controller.dart';

class LedControlPage extends StatelessWidget {
  const LedControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();

    return ChangeNotifierProvider<LedControlController>(
      create: (_) => LedControlController(
        session: session,
        readLightingStateUseCase: appContext.readLightingStateUseCase,
        setChannelIntensityUseCase: appContext.setChannelIntensityUseCase,
      )..refresh(),
      child: const _LedControlView(),
    );
  }
}

class _LedControlView extends StatelessWidget {
  const _LedControlView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer2<AppSession, LedControlController>(
      builder: (context, session, controller, _) {
        _maybeShowError(context, controller);
        final theme = Theme.of(context);
        final bool isConnected = session.isBleConnected;

        return Scaffold(
          appBar: ReefAppBar(title: Text(l10n.ledControlTitle)),
          body: controller.isLoading
              ? const LoadingStateWidget.center()
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    Text(
                      l10n.ledControlSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (!isConnected) ...[
                      const BleGuardBanner(),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    Text(
                      l10n.ledControlChannelsSection,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (controller.channels.isEmpty)
                      _LedControlEmptyState(message: l10n.ledControlEmptyState)
                    else
                      ...controller.channels.map(
                        (channel) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _ChannelSliderCard(
                            key: ValueKey(channel.id),
                            channel: channel,
                            enabled: session.isReady && !controller.isApplying,
                          ),
                        ),
                      ),
                  ],
                ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton(
                          onPressed: controller.isApplying
                              ? null
                              : () {
                                  controller.resetEdits();
                                  Navigator.of(context).pop();
                                },
                          child: Text(l10n.actionCancel),
                        ),
                        const SizedBox(height: AppSpacing.xxxs),
                        Text(
                          'Discard local changes',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          !session.isReady ||
                              controller.isApplying ||
                              !controller.hasChanges
                          ? null
                          : () => _handleApply(context),
                      child: controller.isApplying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.actionApply),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleApply(BuildContext context) async {
    final controller = context.read<LedControlController>();
    final l10n = AppLocalizations.of(context);
    final bool success = await controller.applyChanges();

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      final AppErrorCode code =
          controller.lastErrorCode ?? AppErrorCode.unknownError;
      final messenger = ScaffoldMessenger.of(context);
      final message = describeAppError(l10n, code);
      messenger.showSnackBar(SnackBar(content: Text(message)));
      controller.clearError();
    }
  }
}

class _ChannelSliderCard extends StatelessWidget {
  final LedChannelEditState channel;
  final bool enabled;

  const _ChannelSliderCard({
    super.key,
    required this.channel,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final controller = context.read<LedControlController>();
    final bool hasChanged = controller.didChannelChange(channel.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(channel.label, style: theme.textTheme.titleSmall),
                ),
                Text(
                  l10n.ledControlValueLabel(channel.value),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Slider(
              value: channel.value.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: l10n.ledControlValueLabel(channel.value),
              onChanged: enabled
                  ? (value) => controller.updateChannel(channel.id, value)
                  : null,
            ),
            if (hasChanged) ...[
              const SizedBox(height: AppSpacing.xxxs),
              Text(
                'Changes apply after tapping Apply',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LedControlEmptyState extends StatelessWidget {
  final String message;

  const _LedControlEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

void _maybeShowError(BuildContext context, LedControlController controller) {
  final AppErrorCode? code = controller.lastErrorCode;
  if (code == null) {
    return;
  }

  showErrorSnackBar(context, code);
  controller.clearError();
}
