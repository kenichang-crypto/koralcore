import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimensions.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
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
          appBar: AppBar(title: Text(l10n.ledControlTitle)),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(AppDimensions.spacingXL),
                  children: [
                    Text(
                      l10n.ledControlSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                    if (!isConnected) ...[
                      const BleGuardBanner(),
                      const SizedBox(height: AppDimensions.spacingL),
                    ],
                    Text(
                      l10n.ledControlChannelsSection,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    if (controller.channels.isEmpty)
                      _LedControlEmptyState(message: l10n.ledControlEmptyState)
                    else
                      ...controller.channels
                          .map(
                            (channel) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDimensions.spacingM,
                              ),
                              child: _ChannelSliderCard(
                                key: ValueKey(channel.id),
                                channel: channel,
                                enabled: isConnected && !controller.isApplying,
                              ),
                            ),
                          )
                          .toList(),
                  ],
                ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingXL),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.isApplying
                          ? null
                          : () {
                              controller.resetEdits();
                              Navigator.of(context).pop();
                            },
                      child: Text(l10n.actionCancel),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          !isConnected ||
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
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
            const SizedBox(height: AppDimensions.spacingS),
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
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.grey700),
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

  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(SnackBar(content: Text(describeAppError(l10n, code))));
  controller.clearError();
}
