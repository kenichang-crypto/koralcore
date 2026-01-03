import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../app/device/device_snapshot.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/reef_backgrounds.dart';
import '../../../../shared/assets/common_icon_helper.dart';
import '../../../device/presentation/controllers/device_list_controller.dart';

class BluetoothTabPage extends StatefulWidget {
  const BluetoothTabPage({super.key});

  @override
  State<BluetoothTabPage> createState() => _BluetoothTabPageState();
}

class _BluetoothTabPageState extends State<BluetoothTabPage> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DeviceListController>();
    final l10n = AppLocalizations.of(context);

    // NOTE (Correction Mode / UI parity only):
    // - 本頁不處理 BLE 掃描/權限/連線流程（僅 UI parity）
    // - toolbar 由 MainShellPage 負責，不在此建立 AppBar
    // - Page 本身不可捲動；只有列表區可捲動

    final savedDevices = controller.savedDevices;
    final discoveredDevices = controller.discoveredDevices;
    final bool isScanning = controller.isScanning;

    return ReefMainBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // (1) 已配對裝置區：rv_user_device（無標題）
            // PARITY: fragment_bluetooth.xml - rv_user_device marginTop 12dp, marginBottom 12dp
            if (savedDevices.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: _PairedDevicesList(devices: savedDevices),
              ),
              const SizedBox(height: 12),
            ],

            // (2) 其他裝置區：tv_other_device_title + btn_refresh/progress_scan + rv_other_device / layout_no_other_device
            _OtherDevicesHeader(l10n: l10n, isScanning: isScanning),
            Expanded(
              child: _OtherDevicesBody(devices: discoveredDevices, l10n: l10n),
            ),

            // PARITY: fragment_bluetooth.xml - rv_other_device/layout_no_other_device marginBottom 55dp
            const SizedBox(height: 55),
          ],
        ),
      ),
    );
  }
}

class _PairedDevicesList extends StatelessWidget {
  final List<DeviceSnapshot> devices;

  const _PairedDevicesList({required this.devices});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return _BtMyDeviceTile(
          device: devices[index],
          // Correction Mode (UI parity only): 不在本頁處理 connect/disconnect
          onTap: null,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
    );
  }
}

class _OtherDevicesHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isScanning;

  const _OtherDevicesHeader({required this.l10n, required this.isScanning});

  @override
  Widget build(BuildContext context) {
    // PARITY: fragment_bluetooth.xml
    // - tv_other_device_title: marginStart 16dp, marginTop 24dp, subheader_accent
    // - btn_refresh: marginEnd 16dp, paddingStart/End 5dp, paddingTop/Bottom 3dp
    // - progress_scan: overlaps btn_refresh, visibility gone by default
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.bluetoothOtherDevice, // @string/other_device
              style: AppTextStyles.subheaderAccent.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                child: Text(
                  l10n.bluetoothRearrangement, // @string/rearrangement
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.primaryStrong, // bg_primary
                  ),
                ),
              ),
              if (isScanning)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtherDevicesBody extends StatelessWidget {
  final List<DeviceSnapshot> devices;
  final AppLocalizations l10n;

  const _OtherDevicesBody({required this.devices, required this.l10n});

  @override
  Widget build(BuildContext context) {
    // PARITY: fragment_bluetooth.xml
    // - rv_other_device: background white, visibility gone by default, marginBottom 55dp
    // - layout_no_other_device: marginTop 55dp, marginBottom 55dp
    if (devices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 55, bottom: 55),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.bluetoothNoOtherDeviceTitle, // @string/text_no_other_device_title
                style: AppTextStyles.subheaderAccent.copyWith(
                  color: const Color(0xFFAAAAAA), // text_aaaa
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs), // dp_8
              Text(
                l10n.bluetoothNoOtherDeviceContent, // @string/text_no_other_device_content
                style: AppTextStyles.body.copyWith(
                  color: const Color(0xFFAAAAAA), // text_aaa
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: AppColors.surface, // white background
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return _BtDeviceTile(device: devices[index]);
        },
      ),
    );
  }
}

/// Bluetooth device tile matching adapter_ble_scan.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_ble_scan.xml structure:
/// - Outer ConstraintLayout with selectableItemBackground
/// - Inner ConstraintLayout with bg_aaaa background, padding 16/8dp
/// - tv_ble_type: caption2_accent, text_aa
/// - tv_ble_name: body_accent, text_aaaa
/// - MaterialDivider: 1dp, bg_press
class _BtDeviceTile extends StatelessWidget {
  final DeviceSnapshot device;

  const _BtDeviceTile({required this.device});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final _DeviceKind kind = _DeviceKindHelper.fromName(device.name);
    final String deviceType = kind == _DeviceKind.led
        ? l10n.led
        : ''; // TODO(android @string/drop): ARB 缺少 drop，依規則不可代寫文字

    // PARITY: adapter_ble_scan.xml structure
    return InkWell(
      // Correction Mode (UI parity only): 不在本頁處理 connect/disconnect
      onTap: null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Inner container (bg_aaaa background)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: AppSpacing.md, // dp_16
              top: AppSpacing.xs, // dp_8
              right: AppSpacing.md, // dp_16
              bottom: AppSpacing.xs, // dp_8
            ),
            decoration: BoxDecoration(
              color: AppColors.surface, // bg_aaaa
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Device type (tv_ble_type)
                // PARITY: caption2_accent, text_aa
                Text(
                  deviceType,
                  style: AppTextStyles.caption2Accent.copyWith(
                    color: AppColors.textSecondary, // text_aa
                  ),
                ),
                // Device name (tv_ble_name)
                // PARITY: body_accent, text_aaaa
                Text(
                  device.name,
                  style: AppTextStyles.bodyAccent.copyWith(
                    color: AppColors.textPrimary, // text_aaaa
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Divider (MaterialDivider)
          // PARITY: 1dp height, bg_press color
          Divider(
            height: 1, // dp_1
            thickness: 1, // dp_1
            color: AppColors.surfacePressed, // bg_press
          ),
        ],
      ),
    );
  }
}

enum _DeviceKind { led, doser }

/// BLE My Device tile matching adapter_ble_my_device.xml layout.
///
/// PARITY: Mirrors reef-b-app's adapter_ble_my_device.xml structure:
/// - ConstraintLayout: selectableItemBackground
/// - Inner: white background, padding 16/8/16/8dp
/// - tv_ble_type: caption2_accent, text_aa
/// - tv_name: body_accent, text_aa
/// - tv_position: caption2, text_aa
/// - tv_group: caption2, text_aa (visibility gone by default)
/// - img_led_master: 12×12dp (ic_master)
/// - img_ble: 48×32dp (ic_disconnect_background or ic_connect_background)
/// - Divider: bg_press
class _BtMyDeviceTile extends StatelessWidget {
  final DeviceSnapshot device;
  final VoidCallback? onTap;

  const _BtMyDeviceTile({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final _DeviceKind kind = _DeviceKindHelper.fromName(device.name);
    final String deviceType = kind == _DeviceKind.led
        ? l10n.led
        : ''; // TODO(android @string/drop): ARB 缺少 drop，依規則不可代寫文字

    // TODO: Get position and group from DeviceSnapshot when available
    final String? positionName = null; // TODO: Get from device.sinkId
    final String? groupName = null; // TODO: Get from device.group
    final bool isMaster = device.isMaster;
    final bool isConnected = device.isConnected;

    // PARITY: adapter_ble_my_device.xml structure
    return InkWell(
      // Correction Mode (UI parity only): 不在本頁處理 connect/disconnect
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Inner container (white background)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: AppSpacing.md, // dp_16 paddingStart
              top: AppSpacing.xs, // dp_8 paddingTop
              right: AppSpacing.md, // dp_16 paddingEnd
              bottom: AppSpacing.xs, // dp_8 paddingBottom
            ),
            decoration: BoxDecoration(
              color: AppColors.surface, // white background
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column (texts)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Device type (tv_ble_type) - caption2_accent, text_aa
                      Text(
                        deviceType,
                        style: AppTextStyles.caption2Accent.copyWith(
                          color: AppColors.textSecondary, // text_aa
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Device name (tv_name) - body_accent, text_aa or text_aaaa
                      // PARITY: adapter_ble_my_device.xml - textColor changes based on connection state
                      // - Connected: text_aaaa (AppColors.textPrimary)
                      // - Disconnected: text_aa (AppColors.textSecondary)
                      Text(
                        device.name,
                        style: AppTextStyles.bodyAccent.copyWith(
                          color: isConnected
                              ? AppColors
                                    .textPrimary // text_aaaa when connected
                              : AppColors
                                    .textSecondary, // text_aa when disconnected
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Position and group row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Position (tv_position) - caption2, text_aa
                          if (positionName != null) ...[
                            Text(
                              positionName,
                              style: AppTextStyles.caption2.copyWith(
                                color: AppColors.textSecondary, // text_aa
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(width: AppSpacing.xs), // dp_4 marginStart
                          // Group (tv_group) - caption2, text_aa (visibility gone by default)
                          if (groupName != null) ...[
                            Text(
                              groupName,
                              style: AppTextStyles.caption2.copyWith(
                                color: AppColors.textSecondary, // text_aa
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(width: AppSpacing.xs), // dp_4 marginStart
                          ],
                          // Master icon (img_led_master) - 12×12dp
                          // PARITY: adapter_ble_my_device.xml - ic_master
                          if (isMaster)
                            CommonIconHelper.getMasterIcon(size: 12),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.xs), // dp_4 marginEnd
                // BLE status icon (img_ble) - 48×32dp
                // PARITY: adapter_ble_my_device.xml - ic_connect_background or ic_disconnect_background
                isConnected
                    ? CommonIconHelper.getConnectBackgroundIcon(
                        width: 48,
                        height: 32,
                      )
                    : CommonIconHelper.getDisconnectBackgroundIcon(
                        width: 48,
                        height: 32,
                      ),
              ],
            ),
          ),
          // Divider (bg_press)
          Divider(
            height: 1, // dp_1
            thickness: 1, // dp_1
            color: AppColors.surfacePressed, // bg_press
          ),
        ],
      ),
    );
  }
}

class _DeviceKindHelper {
  static _DeviceKind fromName(String name) {
    final String lower = name.toLowerCase();
    if (lower.contains('led')) {
      return _DeviceKind.led;
    }
    return _DeviceKind.doser;
  }
}
