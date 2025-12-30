import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_error_code.dart';
import '../../../../app/common/app_session.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/reef_app_bar.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../../shared/widgets/app_error_presenter.dart';
import '../../../../core/ble/ble_guard.dart';
import '../controllers/manual_dosing_controller.dart';
import '../models/pump_head_summary.dart';
import 'package:koralcore/l10n/app_localizations.dart';

class ManualDosingPage extends StatelessWidget {
  const ManualDosingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<AppSession>();
    final appContext = context.read<AppContext>();
    return ChangeNotifierProvider<ManualDosingController>(
      create: (_) => ManualDosingController(
        session: session,
        singleDoseImmediateUseCase: appContext.singleDoseImmediateUseCase,
      ),
      child: const _ManualDosingView(),
    );
  }
}

class _ManualDosingView extends StatefulWidget {
  const _ManualDosingView();

  @override
  State<_ManualDosingView> createState() => _ManualDosingViewState();
}

class _ManualDosingViewState extends State<_ManualDosingView> {
  static const List<String> _headIds = ['A', 'B', 'C', 'D'];
  static const double _stepAmount = 0.5;

  late TextEditingController _doseController;
  String _selectedHead = _headIds.first;
  String? _doseError;

  @override
  void initState() {
    super.initState();
    _doseController = TextEditingController(text: '1.0');
  }

  @override
  void dispose() {
    _doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer2<AppSession, ManualDosingController>(
      builder: (context, session, controller, _) {
        final theme = Theme.of(context);
        final bool isConnected = session.isBleConnected;
        final PumpHeadSummary summary = PumpHeadSummary.demo(_selectedHead);

        return Scaffold(
          appBar: ReefAppBar(title: Text(l10n.dosingEntryManual)),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  // PARITY: General settings page layout - padding 16/12/16/40dp
                  padding: EdgeInsets.only(
                    left: AppSpacing.md, // dp_16 paddingStart
                    top: AppSpacing.sm, // dp_12 paddingTop
                    right: AppSpacing.md, // dp_16 paddingEnd
                    bottom: 40, // dp_40 paddingBottom
                  ),
                  children: [
                    Text(
                      l10n.dosingManualPageSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildHeadCard(theme, l10n, summary),
                    const SizedBox(height: AppSpacing.md),
                    if (!isConnected) ...[
                      const BleGuardBanner(),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    _buildDoseCard(theme, l10n),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text(l10n.actionCancel),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FilledButton(
                          onPressed: !isConnected || controller.isSubmitting
                              ? null
                              : () => _handleSubmit(context),
                          child: controller.isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.dosingPumpHeadManualDose),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeadCard(
    ThemeData theme,
    AppLocalizations l10n,
    PumpHeadSummary summary,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedHead,
              decoration: InputDecoration(
                labelText: l10n.dosingPumpHeadsHeader,
                labelStyle: theme.textTheme.titleSmall,
              ),
              items: _headIds
                  .map(
                    (head) => DropdownMenuItem(
                      value: head,
                      child: Text(l10n.dosingPumpHeadSummaryTitle(head)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedHead = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              summary.additiveName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Chip(
                  label: Text(l10n.dosingPumpHeadStatusReady),
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${summary.dailyTargetMl.toStringAsFixed(1)} ml/day',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dosingManualDoseInputLabel,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                IconButton(
                  onPressed: _decrementDose,
                  icon: CommonIconHelper.getMinusIcon(size: 24),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: TextField(
                    controller: _doseController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.dosingManualDoseInputHint,
                      errorText: _doseError,
                      suffixText: 'ml',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      if (_doseError != null) {
                        setState(() {
                          _doseError = null;
                        });
                      }
                    },
                    onSubmitted: (_) => _handleSubmit(context),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  onPressed: _incrementDose,
                  icon: CommonIconHelper.getAddIcon(size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _incrementDose() {
    final double current = _parseDose() ?? 0;
    final double next = (current + _stepAmount).clamp(0, 500);
    _setDose(next);
  }

  void _decrementDose() {
    final double current = _parseDose() ?? 0;
    final double next = (current - _stepAmount).clamp(0, 500);
    if (next <= 0) {
      _setDose(0);
    } else {
      _setDose(next);
    }
  }

  void _setDose(double value) {
    final double sanitized = double.parse(value.toStringAsFixed(1));
    final String text = sanitized == sanitized.truncateToDouble()
        ? sanitized.toStringAsFixed(0)
        : sanitized.toString();
    _doseController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    setState(() {
      _doseError = null;
    });
  }

  double? _parseDose() {
    final value = double.tryParse(_doseController.text.trim());
    if (value == null || value.isNaN || value.isInfinite) {
      return null;
    }
    return value;
  }

  Future<void> _handleSubmit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context);
    final double? dose = _parseDose();
    if (dose == null || dose <= 0) {
      setState(() {
        _doseError = l10n.dosingManualInvalidDose;
      });
      return;
    }

    final bool confirmed = await _showConfirmDialog(context, l10n);
    if (!confirmed || !mounted) {
      return;
    }

    final controller = context.read<ManualDosingController>();
    final bool success = await controller.submit(
      headId: _selectedHead,
      doseMl: dose,
    );
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    if (success) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.dosingPumpHeadManualDoseSuccess)),
      );
    } else {
      final message = describeAppError(
        l10n,
        controller.lastErrorCode ?? AppErrorCode.unknownError,
      );
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<bool> _showConfirmDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.dosingManualConfirmTitle),
          content: Text(l10n.dosingManualConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.actionConfirm),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
