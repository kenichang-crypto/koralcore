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
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../controllers/led_record_setting_controller.dart';
import 'led_record_page.dart';

/// LED record setting page.
///
/// PARITY: Mirrors reef-b-app's LedRecordSettingActivity.
class LedRecordSettingPage extends StatelessWidget {
  const LedRecordSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<LedRecordSettingController>(
      create: (_) => LedRecordSettingController(
        session: session,
        ledRecordRepository: appContext.ledRecordRepository,
        startLedRecordUseCase: appContext.startLedRecordUseCase,
      ),
      child: const _LedRecordSettingView(),
    );
  }
}

class _LedRecordSettingView extends StatelessWidget {
  const _LedRecordSettingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<LedRecordSettingController>();
    final isConnected = session.isBleConnected;

    _maybeShowError(context, controller.lastErrorCode);

    return Scaffold(
      backgroundColor: ReefColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: ReefColors.primary,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        titleTextStyle: ReefTextStyles.title2.copyWith(
          color: ReefColors.onPrimary,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.ledRecordSettingTitle ?? 'LED Record Settings'),
        actions: [
          TextButton(
            onPressed: controller.isLoading || !isConnected
                ? null
                : () => _handleSave(context, controller, l10n),
            child: Text(
              l10n.actionSave ?? 'Save',
              style: TextStyle(color: ReefColors.onPrimary),
            ),
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(ReefSpacing.lg),
              children: [
                if (!isConnected) ...[
                  const BleGuardBanner(),
                  const SizedBox(height: ReefSpacing.lg),
                ],
                _buildInitStrengthSection(context, controller, l10n),
                const SizedBox(height: ReefSpacing.lg),
                _buildSunriseSection(context, controller, l10n),
                const SizedBox(height: ReefSpacing.lg),
                _buildSunsetSection(context, controller, l10n),
                const SizedBox(height: ReefSpacing.lg),
                _buildSlowStartSection(context, controller, l10n),
                const SizedBox(height: ReefSpacing.lg),
                _buildMoonlightSection(context, controller, l10n),
              ],
            ),
    );
  }

  Widget _buildInitStrengthSection(
    BuildContext context,
    LedRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.ledRecordSettingInitStrength ?? 'Initial Strength',
                  style: ReefTextStyles.title3,
                ),
                Text(
                  '${controller.initStrength}%',
                  style: ReefTextStyles.title2,
                ),
              ],
            ),
            const SizedBox(height: ReefSpacing.sm),
            Slider(
              value: controller.initStrength.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: '${controller.initStrength}%',
              onChanged: (value) {
                controller.setInitStrength(value.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunriseSection(
    BuildContext context,
    LedRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.ledRecordSettingSunrise ?? 'Sunrise Time',
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.sm),
            OutlinedButton(
              onPressed: () => _selectTime(
                context,
                controller.sunriseHour,
                controller.sunriseMinute,
                (hour, minute) => controller.setSunrise(hour, minute),
              ),
              child: Text(
                '${controller.sunriseHour.toString().padLeft(2, '0')}:${controller.sunriseMinute.toString().padLeft(2, '0')}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunsetSection(
    BuildContext context,
    LedRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.ledRecordSettingSunset ?? 'Sunset Time',
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.sm),
            OutlinedButton(
              onPressed: () => _selectTime(
                context,
                controller.sunsetHour,
                controller.sunsetMinute,
                (hour, minute) => controller.setSunset(hour, minute),
              ),
              child: Text(
                '${controller.sunsetHour.toString().padLeft(2, '0')}:${controller.sunsetMinute.toString().padLeft(2, '0')}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlowStartSection(
    BuildContext context,
    LedRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.ledRecordSettingSlowStart ?? 'Slow Start',
                  style: ReefTextStyles.title3,
                ),
                Text(
                  '${controller.slowStart} ${l10n.minute ?? 'min'}',
                  style: ReefTextStyles.title2,
                ),
              ],
            ),
            const SizedBox(height: ReefSpacing.sm),
            Slider(
              value: controller.slowStart.toDouble(),
              min: 0,
              max: 120,
              divisions: 120,
              label: '${controller.slowStart} min',
              onChanged: (value) {
                controller.setSlowStart(value.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoonlightSection(
    BuildContext context,
    LedRecordSettingController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.ledRecordSettingMoonlight ?? 'Moonlight',
                  style: ReefTextStyles.title3,
                ),
                Text(
                  '${controller.moonlight}%',
                  style: ReefTextStyles.title2,
                ),
              ],
            ),
            const SizedBox(height: ReefSpacing.sm),
            Slider(
              value: controller.moonlight.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: '${controller.moonlight}%',
              onChanged: (value) {
                controller.setMoonlight(value.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    int initialHour,
    int initialMinute,
    void Function(int, int) onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );
    if (picked != null) {
      onTimeSelected(picked.hour, picked.minute);
    }
  }

  Future<void> _handleSave(
    BuildContext context,
    LedRecordSettingController controller,
    AppLocalizations l10n,
  ) async {
    final bool success = await controller.saveLedRecord(
      onTimeError: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.ledRecordSettingErrorSunTime ??
                  'Sunrise must be before sunset',
            ),
          ),
        );
      },
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ledRecordSettingSuccess ?? 'Settings saved'),
        ),
      );
      // Navigate to record page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LedRecordPage(),
        ),
      );
    }
  }

  void _maybeShowError(BuildContext context, AppErrorCode? code) {
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<LedRecordSettingController>();
      final l10n = AppLocalizations.of(context);
      final message = describeAppError(l10n, code);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }
}

