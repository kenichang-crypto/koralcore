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
import '../../../widgets/reef_app_bar.dart';
import '../../../assets/common_icon_helper.dart';
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
        disconnectDeviceUseCase: appContext.disconnectDeviceUseCase,
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
        appBar: ReefAppBar(
          backgroundColor: ReefColors.primary,
          foregroundColor: ReefColors.onPrimary,
          elevation: 0,
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
          title: Text(
            l10n.addDeviceTitle,
            style: ReefTextStyles.title2.copyWith(
              color: ReefColors.onPrimary,
            ),
          ),
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
            : Padding(
                // PARITY: activity_add_device.xml layout_add_device padding 16/12/16/12dp
                padding: EdgeInsets.only(
                  left: ReefSpacing.md, // dp_16 paddingStart
                  top: ReefSpacing.md, // dp_12 paddingTop
                  right: ReefSpacing.md, // dp_16 paddingEnd
                  bottom: ReefSpacing.md, // dp_12 paddingBottom
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isConnected) ...[
                      const BleGuardBanner(),
                      SizedBox(height: ReefSpacing.md), // dp_16 marginTop
                    ],
                    _buildNameSection(context, controller, l10n),
                    SizedBox(height: ReefSpacing.md), // dp_16 marginTop
                    _buildSinkPositionSection(context, controller, l10n),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNameSection(
    BuildContext context,
    AddDeviceController controller,
    AppLocalizations l10n,
  ) {
    // PARITY: activity_add_device.xml tv_device_name_title + layout_name
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PARITY: tv_device_name_title - caption1, 0dp width (constrained)
        Text(
          l10n.deviceName,
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.textSecondary,
          ),
        ),
        // PARITY: layout_name - marginTop 4dp, TextInputLayout style
        SizedBox(height: ReefSpacing.xs), // dp_4 marginTop
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            // PARITY: TextInputLayout style - bg_aaa, 4dp cornerRadius, no border
            filled: true,
            fillColor: ReefColors.surfaceMuted, // bg_aaa (#F7F7F7)
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ReefRadius.xs), // dp_4
              borderSide: BorderSide.none, // boxStrokeWidth 0dp
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ReefRadius.xs),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ReefRadius.xs),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ReefSpacing.md,
              vertical: ReefSpacing.sm,
            ),
          ),
          // PARITY: edt_name - body textAppearance
          style: ReefTextStyles.body.copyWith(
            color: ReefColors.textPrimary,
          ),
          onChanged: (value) {
            controller.setDeviceName(value);
          },
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildSinkPositionSection(
    BuildContext context,
    AddDeviceController controller,
    AppLocalizations l10n,
  ) {
    // PARITY: activity_add_device.xml tv_sink_position_title + layout_sink_position
    // layout_sink_position uses TextInputLayout with endIcon (ic_next) and enabled="false"
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PARITY: tv_sink_position_title - marginTop 16dp, caption1
        Text(
          l10n.sinkPosition,
          style: ReefTextStyles.caption1.copyWith(
            color: ReefColors.textSecondary,
          ),
        ),
        // PARITY: layout_sink_position - marginTop 4dp, TextInputLayout style with endIcon
        // view_sink_position - selectableItemBackground overlay
        SizedBox(height: ReefSpacing.xs), // dp_4 marginTop
        Stack(
          children: [
            TextField(
              controller: TextEditingController(
                text: _sinkName ?? l10n.sinkPositionNotSet,
              ),
              enabled: false, // enabled="false" in XML
              decoration: InputDecoration(
                // PARITY: TextInputLayout style - bg_aaa, 4dp cornerRadius, no border
                filled: true,
                fillColor: ReefColors.surfaceMuted, // bg_aaa (#F7F7F7)
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ReefRadius.xs), // dp_4
                  borderSide: BorderSide.none, // boxStrokeWidth 0dp
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ReefRadius.xs),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ReefRadius.xs),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ReefSpacing.md,
                  vertical: ReefSpacing.sm,
                ),
                // PARITY: endIcon (ic_next) - endIconMode="custom", endIconTint="text_aaa"
                suffixIcon: CommonIconHelper.getNextIcon(
                  size: 20,
                  color: ReefColors.textTertiary, // text_aaa
                ),
              ),
              // PARITY: edt_sink_position - body textAppearance, textColor="text_aaaa"
              style: ReefTextStyles.body.copyWith(
                color: ReefColors.textPrimary, // text_aaaa
              ),
              maxLines: 1,
            ),
            // PARITY: view_sink_position - selectableItemBackground overlay
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectSinkPosition(context, controller, l10n),
                  borderRadius: BorderRadius.circular(ReefRadius.xs),
                ),
              ),
            ),
          ],
        ),
      ],
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
