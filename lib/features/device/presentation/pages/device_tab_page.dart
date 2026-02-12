import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../app/common/app_session.dart';
import '../../../../domain/sink/sink.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_backgrounds.dart';
import '../../../../app/device/device_snapshot.dart';
import '../controllers/device_list_controller.dart';
import '../widgets/device_card.dart';
import '../../../led/presentation/pages/led_main_page.dart';
import '../../../doser/presentation/pages/dosing_main_page.dart';
import 'add_device_page.dart';

class DeviceTabPage extends StatelessWidget {
  const DeviceTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DeviceListController>();
    final l10n = AppLocalizations.of(context);
    final devices = controller.savedDevices;

    // Correction Mode (UI parity only):
    // - toolbar 由 MainShellPage 負責，不在本頁建立 AppBar
    // - 本頁不處理 BLE 掃描/連線/刪除/刷新等行為（僅 UI parity）
    // - 僅裝置列表區可捲動
    if (devices.isEmpty) {
      return ReefMainBackground(
        child: SafeArea(child: _EmptyState(l10n: l10n)),
      );
    }

    // PARITY: fragment_device.xml - RecyclerView marginStart/End 10dp, marginTop/Bottom 8dp
    return ReefMainBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 10.0, // dp_10
            right: 10.0, // dp_10
            top: 8.0, // dp_8
            bottom: 8.0, // dp_8
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 0, // Card 本身有 dp_6 margin
              crossAxisSpacing: 0, // Card 本身有 dp_6 margin
              childAspectRatio: 1.0,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return _DeviceCardWithSink(
                device: device,
                controller: controller,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// DeviceCard wrapper that loads sink name and passes to DeviceCard.
/// PARITY: reef-b-app DeviceAdapter.bind() gets sink name from dbSink.getSinkById()
class _DeviceCardWithSink extends StatelessWidget {
  final DeviceSnapshot device;
  final DeviceListController controller;

  const _DeviceCardWithSink({
    required this.device,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final appContext = context.read<AppContext>();

    // PARITY: reef-b-app DeviceAdapter.bind() - dbSink.getSinkById(it)?.name ?: unassigned_device
    String? sinkName;
    if (device.sinkId != null && device.sinkId!.isNotEmpty) {
      final sinks = appContext.sinkRepository.getCurrentSinks();
      final sink = sinks.firstWhere(
        (s) => s.id == device.sinkId,
        orElse: () =>
            const Sink(id: '', name: '', type: SinkType.custom, deviceIds: []),
      );
      if (sink.id.isNotEmpty) {
        sinkName = sink.name;
      }
    }

    final selectionMode = controller.selectionMode;
    return DeviceCard(
      device: device,
      selectionMode: selectionMode,
      isSelected: controller.selectedIds.contains(device.id),
      onSelect: selectionMode
          ? () => controller.toggleSelection(device.id)
          : null,
      onTap: () => _navigateToDeviceMainPage(context, device),
      sinkName: sinkName,
    );
  }

  /// Navigate to device main page based on device type
  /// PARITY: reef-b-app DeviceFragment navigates to LedMainActivity or DropMainActivity
  void _navigateToDeviceMainPage(BuildContext context, DeviceSnapshot device) {
    final session = context.read<AppSession>();
    final String deviceNameLower = device.name.toLowerCase();
    final bool isLed = deviceNameLower.contains('led');

    // Set active device in session before navigation
    session.setActiveDevice(device.id);

    if (isLed) {
      // Navigate to LED main page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LedMainPage()),
      );
    } else {
      // Navigate to Dosing main page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DosingMainPage()),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    // PARITY: fragment_device.xml - layout_no_device
    // ImageView: 172x199dp, marginTop 39dp
    // MaterialButton: marginTop 8dp, marginBottom 8dp
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // PARITY: img_device_robot - 172x199dp (fragment_device.xml)
          SvgPicture.asset(
            'assets/icons/img_device_robot.svg',
            width: 172.0, // dp_172
            height: 199.0, // dp_199
            fit: BoxFit.contain,
          ),
          // PARITY: TextView - text_no_device_title, marginTop 39dp
          Padding(
            padding: const EdgeInsets.only(top: 39.0), // dp_39 marginTop
            child: Text(
              l10n.deviceEmptyTitle, // PARITY: text_no_device_title
              style: AppTextStyles.subheaderAccent.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // PARITY: MaterialButton - btn_add_device, marginTop 8dp, marginBottom 8dp
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0, // dp_8 marginTop
              bottom: 8.0, // dp_8 marginBottom
            ),
            child: FilledButton(
              // PARITY: btn_add_device → AddDevicePage (UX Parity P4)
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddDevicePage(),
                ),
              ),
              child: Text(
                l10n.deviceActionAdd,
              ), // PARITY: add_device (@string/add_device)
            ),
          ),
        ],
      ),
    );
  }
}
