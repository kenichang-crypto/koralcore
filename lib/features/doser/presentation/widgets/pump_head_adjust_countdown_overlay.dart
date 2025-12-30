import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Countdown overlay for pump head adjustment calibration.
///
/// PARITY: Mirrors reef-b-app's loading dialog with countdown timer.
class PumpHeadAdjustCountdownOverlay extends StatelessWidget {
  final int remainingSeconds;
  final AppLocalizations l10n;

  const PumpHeadAdjustCountdownOverlay({
    super.key,
    required this.remainingSeconds,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${l10n.dosingAdjusting} $remainingSeconds s',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

