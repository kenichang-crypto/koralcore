import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/common/app_context.dart';
import '../../../../domain/sink/sink.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_backgrounds.dart';
import '../../../../app/device/device_snapshot.dart';
import '../controllers/device_list_controller.dart';
import '../widgets/device_card.dart';

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
              return _DeviceCardWithSink(device: device);
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

  const _DeviceCardWithSink({required this.device});

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

    return DeviceCard(
      device: device,
      selectionMode: false,
      isSelected: false,
      onSelect: null,
      onTap: null,
      sinkName: sinkName,
    );
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
          // PARITY: img_device_robot - 172x199dp
          // NOTE: Flutter 目前使用既有 assets 內的 device_empty.png 代替（結構對齊，視覺資源待補）
          // TODO(android @drawable/img_device_robot): 導入/轉換 Android img_device_robot 資源
          Image.asset(
            'assets/icons/device_empty.png',
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
              // Correction Mode (UI parity only): 僅保留結構，不接行為
              onPressed: null,
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
