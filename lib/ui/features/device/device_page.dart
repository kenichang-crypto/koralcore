import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:koralcore/ui/assets/reef_icons.dart';
import 'package:provider/provider.dart';

import '../../../application/common/app_error_code.dart';
import '../../../application/system/ble_readiness_controller.dart';
import '../../components/ble_guard.dart';
import '../../components/error_state_widget.dart';
import '../../components/empty_state_widget.dart';
import '../../theme/reef_colors.dart';
import '../../theme/reef_radius.dart';
import '../../theme/reef_spacing.dart';
import '../../theme/reef_text.dart';
import '../../widgets/reef_backgrounds.dart';
import 'controllers/device_list_controller.dart';
import 'widgets/device_card.dart';
import 'pages/add_device_page.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DeviceListController>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DeviceListController>();
    _maybeShowError(controller.lastErrorCode);
    final l10n = AppLocalizations.of(context);

    final bool selectionMode = controller.selectionMode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ReefColors.primary,
        foregroundColor: ReefColors.onPrimary,
        elevation: 0,
        leading: selectionMode
            ? IconButton(
                icon: const Icon(Icons.close, color: ReefColors.surface),
                onPressed: controller.exitSelectionMode,
              )
            : null,
        titleSpacing: ReefSpacing.lg,
        title: Text(
          selectionMode
              ? l10n.deviceSelectionCount(controller.selectedIds.length)
              : l10n.deviceHeader,
          style: ReefTextStyles.title2.copyWith(
            color: ReefColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: selectionMode
            ? [
                TextButton(
                  onPressed: controller.selectedIds.isEmpty
                      ? null
                      : () => _confirmDelete(context, controller),
                  child: Text(
                    l10n.deviceActionDelete,
                    style: ReefTextStyles.bodyAccent.copyWith(
                      color: ReefColors.onPrimary,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: ReefMainBackground(
        child: SafeArea(
          child: RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Consumer<BleReadinessController>(
                  builder: (context, bleController, _) {
                    if (bleController.snapshot.isReady) {
                      return const SizedBox.shrink();
                    }
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(
                        ReefSpacing.xl,
                        ReefSpacing.lg,
                        ReefSpacing.xl,
                        ReefSpacing.lg,
                      ),
                      child: BleGuardBanner(),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: ReefSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: _ActionsBar(controller: controller, l10n: l10n),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: ReefSpacing.lg)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: ReefSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: _SectionHeader(title: l10n.deviceHeader),
                ),
              ),
              if (controller.savedDevices.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ReefSpacing.xl,
                    ),
                    child: _EmptyState(
                      l10n: l10n,
                      onScan: () => controller.refresh(),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReefSpacing.xl,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: ReefSpacing.lg,
                          crossAxisSpacing: ReefSpacing.lg,
                          childAspectRatio: .95,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final device = controller.savedDevices[index];
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
                    }, childCount: controller.savedDevices.length),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: ReefSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: _SectionHeader(title: l10n.bluetoothHeader),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: ReefSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: controller.discoveredDevices.length,
                    (context, index) {
                      final device = controller.discoveredDevices[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: ReefSpacing.md),
                        child: DeviceCard(
                          device: device,
                          selectionMode: false,
                          isSelected: false,
                          onSelect: null,
                          onConnect: () => controller.connect(device.id),
                          onDisconnect: () => controller.disconnect(device.id),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (controller.discoveredDevices.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ReefSpacing.xl,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: ReefSpacing.xxl),
                      child: Container(
                        padding: const EdgeInsets.all(ReefSpacing.lg),
                        decoration: BoxDecoration(
                          color: ReefColors.surface.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(ReefRadius.lg),
                        ),
                        child: Row(
                          children: [
                            Image.asset(kBluetoothIcon, width: 32, height: 32),
                            const SizedBox(width: ReefSpacing.md),
                            Expanded(
                              child: Text(
                                l10n.bluetoothEmptyState,
                                style: ReefTextStyles.body.copyWith(
                                  color: ReefColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: ReefSpacing.xxl),
              ),
            ],
          ),
        ),
          ),
        ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddDevicePage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.deviceActionAdd),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DeviceListController controller,
  ) async {
    final l10n = AppLocalizations.of(context);
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

  void _maybeShowError(AppErrorCode? code) {
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = context.read<DeviceListController>();
      showErrorSnackBar(context, code);
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
          style: FilledButton.styleFrom(
            backgroundColor: ReefColors.surface,
            foregroundColor: ReefColors.primaryStrong,
          ),
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
        const SizedBox(width: ReefSpacing.md),
        if (!controller.selectionMode)
          OutlinedButton(
            onPressed: controller.savedDevices.isEmpty
                ? null
                : controller.enterSelectionMode,
            child: Text(l10n.deviceSelectMode),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  final Future<void> Function() onScan;

  const _EmptyState({required this.l10n, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: l10n.deviceEmptyTitle,
      subtitle: l10n.deviceEmptySubtitle,
      imageAsset: kDeviceEmptyIcon,
      iconSize: 48,
      useCard: true,
      action: FilledButton(
        onPressed: onScan,
        child: Text(l10n.bluetoothScanCta),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: ReefSpacing.xl,
        bottom: ReefSpacing.md,
      ),
      child: Text(
        title,
        style: ReefTextStyles.subheaderAccent.copyWith(
          color: ReefColors.textPrimary,
        ),
      ),
    );
  }
}
