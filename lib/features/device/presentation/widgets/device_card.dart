import 'package:flutter/material.dart';
import 'package:koralcore/l10n/app_localizations.dart';
import 'package:koralcore/shared/assets/reef_icons.dart'; // TODO: 確認 assets 路徑

import '../../../../app/device/device_snapshot.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/assets/common_icon_helper.dart';

/// Device card widget matching reef-b-app's adapter_device_led.xml and adapter_device_drop.xml.
/// PARITY: 100% alignment with reef-b-app's device card layout.
class DeviceCard extends StatelessWidget {
  final DeviceSnapshot device;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onSelect;
  final VoidCallback? onTap; // PARITY: reef-b-app onClickDevice()
  final String? sinkName; // PARITY: reef-b-app dbSink.getSinkById(it)?.name

  const DeviceCard({
    super.key,
    required this.device,
    required this.selectionMode,
    required this.isSelected,
    this.onSelect,
    this.onTap,
    this.sinkName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool isConnected = device.isConnected;
    final _DeviceKind deviceKind = _resolveKind(device.type);
    
    // PARITY: adapter_device_led.xml - MaterialCardView with margin 6dp, cornerRadius 10dp, elevation 5dp
    return Card(
      margin: const EdgeInsets.all(6.0), // dp_6
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // dp_10
      ),
      elevation: 5.0, // dp_5
      child: InkWell(
        onTap: selectionMode ? onSelect : onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          // PARITY: paddingStart/End 12dp, paddingTop/Bottom 10dp
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0, // dp_12
            vertical: 10.0, // dp_10
          ),
          child: Stack(
            children: [
              // Main content
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Device icon with overlaid icons (Master, Favorite, BLE state)
                  // PARITY: img_led height 50dp, constraintTop_toTopOf="parent", constraintBottom_toTopOf="@id/tv_name"
                  Stack(
                    children: [
                      // Device icon (img_led/img_drop)
                      // PARITY: 50dp height, starts from parent top
                      Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          deviceKind == _DeviceKind.led
                              ? kDeviceLedIcon
                              : kDeviceDoserIcon,
                          width: double.infinity,
                          height: 50, // dp_50
                          fit: BoxFit.fitWidth,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Icon(
                                deviceKind == _DeviceKind.led
                                    ? CommonIconHelper.getLedIcon()
                                    : CommonIconHelper.getDropIcon(),
                                size: 32,
                                color: AppColors.primary,
                              ),
                            );
                          },
                        ),
                      ),
                      // Top-right icons row (aligned to top-right corner)
                      // PARITY: img_ble_state marginTop 12dp, constraintEnd_toEndOf="parent", constraintTop_toTopOf="parent"
                      // img_favorite: constraintBottom_toBottomOf="@id/img_ble_state", constraintEnd_toStartOf="@id/img_ble_state"
                      // img_led_master: marginStart 32dp (from parent start), marginEnd 4dp, constraintEnd_toStartOf="@id/img_favorite"
                      Positioned(
                        top: 12.0, // dp_12 marginTop for img_ble_state
                        right: 0, // constraintEnd_toEndOf="parent"
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Master icon (img_led_master) - PARITY: reef-b-app DeviceAdapter sets visibility based on data.master
                            // NOTE: In Flutter, we do NOT display the master icon (img_led_master) as per design requirements
                            // The master data is available (device.isMaster) but intentionally not rendered
                            // reef-b-app code: binding.imgLedMaster.visibility = View.GONE (commented code shows it should be based on data.master)
                            // if (device.isMaster) { ... } // Intentionally disabled in Flutter
                            // Favorite icon (img_favorite) - 14×14dp
                            // PARITY: reef-b-app uses @drawable/ic_favorite_select or @drawable/ic_favorite_unselect
                            // Using CommonIconHelper which loads SVG from assets/icons/ic_favorite_*.svg
                            device.favorite
                                ? CommonIconHelper.getFavoriteSelectIcon(
                                    size: 14,
                                    color: const Color(0xFFC00100), // PARITY: ic_favorite_select uses #C00100 (red)
                                  )
                                : CommonIconHelper.getFavoriteUnselectIcon(
                                    size: 14,
                                    color: const Color(0xFFC4C4C4), // PARITY: ic_favorite_unselect uses #C4C4C4 (grey)
                                  ),
                            // BLE state icon (img_ble_state) - 14×14dp, rightmost
                            // PARITY: reef-b-app uses @drawable/ic_connect or @drawable/ic_disconnect
                            // Using CommonIconHelper.getConnectIcon() / getDisconnectIcon() for 100% parity
                            isConnected
                                ? CommonIconHelper.getConnectIcon(
                                    size: 14,
                                    color: AppColors.textPrimary, // PARITY: ic_connect uses #000000 (black)
                                  )
                                : CommonIconHelper.getDisconnectIcon(
                                    size: 14,
                                    color: AppColors.textPrimary, // PARITY: ic_disconnect uses #000000 (black)
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Device name (tv_name)
                  // PARITY: constraintTop_toBottomOf="@id/img_led" (no spacing), marginEnd 4dp, constraintBottom_toTopOf="@id/tv_position"
                  Padding(
                    padding: EdgeInsets.only(
                      right: 4.0, // dp_4 marginEnd
                      top: 0, // No spacing between img_led and tv_name
                    ),
                    child: Text(
                      device.name,
                      style: AppTextStyles.caption1Accent.copyWith(
                        // PARITY: text_aaaa if connected (#000000), text_aa if disconnected (#80000000)
                        color: isConnected ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Position (tv_position)
                  // PARITY: constraintTop_toBottomOf="@id/tv_name" (no spacing), marginBottom 2dp, constraintBottom_toBottomOf="parent"
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 2.0, // dp_2 marginBottom
                      top: 0, // No spacing between tv_name and tv_position
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Position (tv_position) - Sink name or "未分配設備"
                        // PARITY: textAppearance caption2, textColor text_aa (#80000000)
                        Flexible(
                          child: Text(
                            sinkName ?? l10n.unassignedDevice,
                            style: AppTextStyles.caption2.copyWith(
                              color: AppColors.textTertiary, // text_aa (#80000000)
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Group label (tv_group) - PARITY: reef-b-app shows "｜群組 A" format
                        // NOTE: In Flutter, we do NOT display the group label (tv_group) as per design requirements
                        // The group data is available (device.group) but intentionally not rendered
                        // reef-b-app: binding.tvGroup.text = "｜${context.getString(R.string.group)} A" (when group is set)
                        // if (groupLabel != null) { ... } // Intentionally disabled in Flutter
                      ],
                    ),
                  ),
                ],
              ),
              // Check icon (img_check) - only in selection mode
              // PARITY: 20x20dp, constraintEnd_toEndOf="parent", constraintTop_toTopOf="@id/tv_name", constraintBottom_toBottomOf="parent"
              if (selectionMode && isSelected)
                Positioned(
                  right: 0,
                  top: 50.0, // Align with tv_name (after img_led 50dp)
                  bottom: 0,
                  child: CommonIconHelper.getCheckIcon(
                    size: 20.0, // dp_20
                    color: AppColors.info,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _DeviceKind _resolveKind(String? type) {
    if (type == null) return _DeviceKind.doser;
    final lower = type.toLowerCase();
    if (lower.contains('led')) {
      return _DeviceKind.led;
    }
    return _DeviceKind.doser;
  }
}

enum _DeviceKind { led, doser }
