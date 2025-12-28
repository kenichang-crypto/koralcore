import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../../domain/warning/warning.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_radius.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../controllers/warning_controller.dart';

/// Warning list page.
///
/// PARITY: Mirrors reef-b-app's WarningActivity.
/// Note: BLE commands (0x2C, 0x7B) are not implemented in reef-b-app,
/// so this page will show empty state or placeholder data.
class WarningPage extends StatelessWidget {
  const WarningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<WarningController>(
      create: (_) => WarningController(
        session: session,
        warningRepository: appContext.warningRepository,
      )..initialize(),
      child: const _WarningView(),
    );
  }
}

class _WarningView extends StatelessWidget {
  const _WarningView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<WarningController>();
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.warningTitle ?? 'Warnings'),
        actions: [
          if (controller.warnings.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: l10n.warningClearAll ?? 'Clear All',
              onPressed: controller.isLoading
                  ? null
                  : () => _showClearAllDialog(context, controller, l10n),
            ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!isConnected) ...[
                  const BleGuardBanner(),
                ],
                Expanded(
                  child: controller.warnings.isEmpty
                      ? _EmptyState(l10n: l10n)
                      : RefreshIndicator(
                          onRefresh: controller.refresh,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(ReefSpacing.lg),
                            itemCount: controller.warnings.length,
                            itemBuilder: (context, index) {
                              final warning = controller.warnings[index];
                              return _WarningCard(
                                warning: warning,
                                onDelete: () => controller.deleteWarning(
                                  warning.id,
                                ),
                                l10n: l10n,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Future<void> _showClearAllDialog(
    BuildContext context,
    WarningController controller,
    AppLocalizations l10n,
  ) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.warningClearAllTitle ?? 'Clear All Warnings'),
        content: Text(
          l10n.warningClearAllContent ??
              'Are you sure you want to clear all warnings?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: ReefColors.error,
            ),
            child: Text(l10n.actionClear ?? 'Clear'),
          ),
        ],
      ),
    );

    if (result == true) {
      await controller.clearAllWarnings();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.warningClearAllSuccess ?? 'All warnings cleared',
            ),
          ),
        );
      }
    }
  }

  void _maybeShowError(BuildContext context, AppErrorCode? code) {
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<WarningController>();
      final l10n = AppLocalizations.of(context);
      final message = describeAppError(l10n, code);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }
}

class _WarningCard extends StatelessWidget {
  final Warning warning;
  final VoidCallback onDelete;
  final AppLocalizations l10n;

  const _WarningCard({
    required this.warning,
    required this.onDelete,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: ReefSpacing.md),
      child: ListTile(
        leading: Icon(
          Icons.warning,
          color: ReefColors.error,
        ),
        title: Text(
          l10n.warningId(warning.warningId) ??
              'Warning ${warning.warningId}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: ReefSpacing.xs),
            Text(
              DateFormat('yyyy-MM-dd HH:mm:ss').format(warning.time),
              style: ReefTextStyles.body2.copyWith(
                color: ReefColors.grey,
              ),
            ),
            if (warning.deviceId.isNotEmpty) ...[
              const SizedBox(height: ReefSpacing.xs),
              Text(
                'Device: ${warning.deviceId}',
                style: ReefTextStyles.body2.copyWith(
                  color: ReefColors.grey,
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          tooltip: l10n.actionDelete ?? 'Delete',
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: ReefColors.success,
          ),
          const SizedBox(height: ReefSpacing.md),
          Text(
            l10n.warningEmptyTitle ?? 'No Warnings',
            style: ReefTextStyles.title2,
          ),
          const SizedBox(height: ReefSpacing.sm),
          Text(
            l10n.warningEmptySubtitle ??
                'All systems are operating normally',
            style: ReefTextStyles.body1.copyWith(
              color: ReefColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

