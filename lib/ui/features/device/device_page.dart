import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/common/app_error_code.dart';
import '../../../application/system/ble_readiness_controller.dart';
import '../../../theme/dimensions.dart';
import '../../components/app_error_presenter.dart';
import '../../components/ble_guard.dart';
import 'controllers/device_list_controller.dart';
import 'widgets/device_card.dart';
import 'package:koralcore/l10n/app_localizations.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DeviceListController>().refresh());
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DeviceListController>();
    _maybeShowError(controller.lastErrorCode);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingXL,
                  AppDimensions.spacingXL,
                  AppDimensions.spacingXL,
                  AppDimensions.spacingM,
                ),
                child: Text(
                  l10n.deviceHeader,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer<BleReadinessController>(
                builder: (context, bleController, _) {
                  if (bleController.snapshot.isReady) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.spacingXL,
                      0,
                      AppDimensions.spacingXL,
                      AppDimensions.spacingL,
                    ),
                    child: const BleGuardBanner(),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXL,
                ),
                child: _ActionsBar(controller: controller, l10n: l10n),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.spacingL),
            ),
            if (controller.devices.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  l10n: l10n,
                  onScan: () => controller.refresh(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXL,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppDimensions.spacingXL,
                    crossAxisSpacing: AppDimensions.spacingXL,
                    childAspectRatio: .85,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final device = controller.devices[index];
                    final isSelected = controller.selectedIds.contains(
                      device.id,
                    );
                    return DeviceCard(
                      device: device,
                      selectionMode: controller.selectionMode,
                      isSelected: isSelected,
                      onSelect: () => controller.toggleSelection(device.id),
                      onConnect: () => controller.connect(device.id),
                      onDisconnect: () => controller.disconnect(device.id),
                    );
                  }, childCount: controller.devices.length),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.spacingXXL),
            ),
          ],
        ),
      ),
    );
  }

  void _maybeShowError(AppErrorCode? code) {
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<DeviceListController>();
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(describeAppError(l10n, code))));
      controller.clearError();
    });
  }
}

class _ActionsBar extends StatelessWidget {
  final DeviceListController controller;
  final AppLocalizations l10n;

  const _ActionsBar({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilledButton.icon(
          onPressed: controller.isScanning
              ? null
              : () {
                  controller.refresh();
                },
          icon: controller.isScanning
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync),
          label: Text(
            controller.isScanning
                ? l10n.bluetoothScanning
                : l10n.bluetoothScanCta,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        if (!controller.selectionMode) ...[
          OutlinedButton(
            onPressed: controller.devices.isEmpty
                ? null
                : controller.enterSelectionMode,
            child: Text(l10n.deviceSelectMode),
          ),
        ] else ...[
          Expanded(
            child: Text(
              l10n.deviceSelectionCount(controller.selectedIds.length),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: controller.exitSelectionMode,
            child: Text(l10n.actionCancel),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          FilledButton.tonal(
            onPressed: controller.selectedIds.isEmpty
                ? null
                : () => _confirmDelete(context),
            child: Text(l10n.deviceActionDelete),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deviceDeleteConfirmTitle),
          content: Text(l10n.deviceDeleteConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.deviceDeleteConfirmSecondary),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deviceDeleteConfirmPrimary),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await controller.removeSelected();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.snackbarDeviceRemoved)));
    }
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final Future<void> Function() onScan;

  const _EmptyState({required this.l10n, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.deviceEmptyTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Text(
          l10n.deviceEmptySubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingXL),
        FilledButton(
          onPressed: () {
            onScan();
          },
          child: Text(l10n.bluetoothScanCta),
        ),
      ],
    );
  }
}
