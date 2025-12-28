import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../application/common/app_context.dart';
import '../../../../application/common/app_error_code.dart';
import '../../../../application/common/app_session.dart';
import '../../../theme/reef_colors.dart';
import '../../../theme/reef_spacing.dart';
import '../../../theme/reef_text.dart';
import '../../../components/app_error_presenter.dart';
import '../../../components/ble_guard.dart';
import '../../sink/pages/sink_position_page.dart';
import '../controllers/add_device_controller.dart';

/// Add device page.
///
/// PARITY: Mirrors reef-b-app's AddDeviceActivity.
class AddDevicePage extends StatelessWidget {
  const AddDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();
    final session = context.read<AppSession>();
    return ChangeNotifierProvider<AddDeviceController>(
      create: (_) => AddDeviceController(
        session: session,
        deviceRepository: appContext.deviceRepository,
        pumpHeadRepository: appContext.pumpHeadRepository,
        sinkRepository: appContext.sinkRepository,
      ),
      child: const _AddDeviceView(),
    );
  }
}

class _AddDeviceView extends StatefulWidget {
  const _AddDeviceView();

  @override
  State<_AddDeviceView> createState() => _AddDeviceViewState();
}

class _AddDeviceViewState extends State<_AddDeviceView> {
  final TextEditingController _nameController = TextEditingController();
  String? _sinkName;

  @override
  void initState() {
    super.initState();
    final controller = context.read<AddDeviceController>();
    final connectedName = controller.connectedDeviceName;
    if (connectedName != null) {
      _nameController.text = connectedName;
      controller.setDeviceName(connectedName);
    } else {
      // No connected device, close page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = context.watch<AppSession>();
    final controller = context.watch<AddDeviceController>();
    final isConnected = session.isBleConnected;

    _maybeShowError(context, controller.lastErrorCode);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await controller.disconnect();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: ReefColors.surfaceMuted,
        appBar: AppBar(
          backgroundColor: ReefColors.primary,
          foregroundColor: ReefColors.onPrimary,
          elevation: 0,
          titleTextStyle: ReefTextStyles.title2.copyWith(
            color: ReefColors.onPrimary,
          ),
          leading: TextButton(
            onPressed: () async {
              await controller.disconnect();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              l10n.actionSkip,
              style: TextStyle(color: ReefColors.onPrimary),
            ),
          ),
          title: Text(l10n.addDeviceTitle),
          actions: [
            TextButton(
              onPressed: controller.isLoading || !isConnected
                  ? null
                  : () => _handleAdd(context, controller, l10n),
              child: Text(
                l10n.actionAdd,
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
                  _buildNameSection(context, controller, l10n),
                  const SizedBox(height: ReefSpacing.lg),
                  _buildSinkPositionSection(context, controller, l10n),
                ],
              ),
      ),
    );
  }

  Widget _buildNameSection(
    BuildContext context,
    AddDeviceController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deviceName,
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.sm),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: l10n.deviceNameHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                controller.setDeviceName(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSinkPositionSection(
    BuildContext context,
    AddDeviceController controller,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ReefSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sinkPosition,
              style: ReefTextStyles.title3,
            ),
            const SizedBox(height: ReefSpacing.sm),
            ListTile(
              title: Text(_sinkName ?? l10n.sinkPositionNotSet),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _selectSinkPosition(context, controller, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectSinkPosition(
    BuildContext context,
    AddDeviceController controller,
    AppLocalizations l10n,
  ) async {
    final String? selectedSinkId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            SinkPositionPage(initialSinkId: controller.selectedSinkId),
      ),
    );

    if (selectedSinkId != null) {
      controller.setSelectedSinkId(selectedSinkId);
      final String? name = await controller.getSinkNameById(selectedSinkId);
      setState(() {
        _sinkName = name ?? l10n.sinkPositionNotSet;
      });
    } else if (selectedSinkId == '') {
      // "No" selected
      controller.setSelectedSinkId(null);
      setState(() {
        _sinkName = l10n.sinkPositionNotSet;
      });
    }
  }

  Future<void> _handleAdd(
    BuildContext context,
    AddDeviceController controller,
    AppLocalizations l10n,
  ) async {
    final bool success = await controller.addDevice();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addDeviceSuccess),
        ),
      );
      Navigator.of(context).pop(true);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addDeviceFailed)),
      );
    }
  }

  void _maybeShowError(BuildContext context, AppErrorCode? code) {
    if (code == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context);
      final message = describeAppError(l10n, code);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }
}
