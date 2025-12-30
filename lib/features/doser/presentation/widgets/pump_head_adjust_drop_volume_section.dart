import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koralcore/l10n/app_localizations.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../controllers/pump_head_adjust_controller.dart';

/// Drop volume input section for pump head adjustment page.
///
/// PARITY: Mirrors reef-b-app's tv_adjust_drop_volume_title and layout_adjust_drop_volume.
class PumpHeadAdjustDropVolumeSection extends StatelessWidget {
  final PumpHeadAdjustController controller;
  final bool isConnected;
  final AppLocalizations l10n;

  const PumpHeadAdjustDropVolumeSection({
    super.key,
    required this.controller,
    required this.isConnected,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PARITY: tv_adjust_drop_volume_title - marginTop 16dp, caption1
        Text(
          l10n.dosingDropVolume,
          style: AppTextStyles.caption1.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        // PARITY: layout_adjust_drop_volume - marginTop 4dp, TextInputLayout style
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller.volumeController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          inputFormatters: [
            // PARITY: InputFilter - 0.1 to 500.9, max 1 decimal place
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d{0,3}(\.\d{0,1})?$'),
            ),
            _VolumeInputFormatter(),
          ],
          decoration: InputDecoration(
            // PARITY: TextInputLayout style - bg_aaa, 4dp cornerRadius
            filled: true,
            fillColor: AppColors.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              borderSide: BorderSide.none,
            ),
            hintText: l10n.dosingAdjustVolumeHint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
          ),
          enabled: !controller.isCalibrating && isConnected,
        ),
      ],
    );
  }
}

/// Input formatter for volume (0.1 to 500.9, max 1 decimal place)
class _VolumeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    try {
      final double value = double.parse(newValue.text);
      // PARITY: InputFilter - 0.1 to 500.9
      if (value < 0.1 || value > 500.9) {
        return oldValue;
      }
      // Check decimal places
      final parts = newValue.text.split('.');
      if (parts.length > 1 && parts[1].length > 1) {
        return oldValue;
      }
    } catch (e) {
      return oldValue;
    }

    return newValue;
  }
}

