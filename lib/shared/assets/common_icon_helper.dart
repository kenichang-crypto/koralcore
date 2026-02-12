import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'reef_icon_assets.dart';

/// CommonIconHelper
///
/// Helper class for getting common icons from reef-b-app.
/// PARITY: All icons sourced from reef-b-app res/drawable (XML→SVG).
///
/// **Unified registry**: [ReefIconAssets] for path constants and reef source mapping.
class CommonIconHelper {
  const CommonIconHelper._();

  /// Get add icon (black)
  static SvgPicture getAddIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_add_black,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get back icon
  static SvgPicture getBackIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_back,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get delete icon
  static SvgPicture getDeleteIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_delete,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get edit icon
  static SvgPicture getEditIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_edit,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get close icon
  static SvgPicture getCloseIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_close,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get minus icon
  static SvgPicture getMinusIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_minus,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get check icon
  static SvgPicture getCheckIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/ic_check.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get play icon (enabled)
  static SvgPicture getPlayIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_play_enabled,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get stop icon
  static SvgPicture getStopIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_stop,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get pause icon
  static SvgPicture getPauseIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_pause,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get next icon
  static SvgPicture getNextIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/ic_next.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get menu icon
  static SvgPicture getMenuIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_menu,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get manager icon (PARITY: ic_manager.xml from reef-b-app)
  /// 30×30dp icon with rounded rectangle background and three horizontal lines
  static SvgPicture getManagerIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_manager,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get bluetooth icon
  static SvgPicture getBluetoothIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_bluetooth,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get connect icon (PARITY: ic_connect.xml from reef-b-app)
  /// 14×14dp icon for BLE connected state
  static SvgPicture getConnectIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/ic_connect.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get disconnect icon (PARITY: ic_disconnect.xml from reef-b-app)
  /// 14×14dp icon for BLE disconnected state
  static SvgPicture getDisconnectIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_disconnect,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get device icon
  static SvgPicture getDeviceIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_device,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get home icon
  static SvgPicture getHomeIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_home,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get warning icon
  static SvgPicture getWarningIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_warning,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get reset icon
  static SvgPicture getResetIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_reset,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get connect background icon (48×32dp)
  static SvgPicture getConnectBackgroundIcon({double? width, double? height}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_connect_background,
      width: width ?? 48,
      height: height ?? 32,
    );
  }

  /// Get disconnect background icon (48×32dp)
  static SvgPicture getDisconnectBackgroundIcon({
    double? width,
    double? height,
  }) {
    return SvgPicture.asset(
      ReefIconAssets.ic_disconnect_background,
      width: width ?? 48,
      height: height ?? 32,
    );
  }

  /// Get master icon
  static SvgPicture getMasterIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_master,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get master icon (big)
  static SvgPicture getMasterBigIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_master_big,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get zoom in icon
  static SvgPicture getZoomInIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_zoom_in,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get zoom out icon
  static SvgPicture getZoomOutIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_zoom_out,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get calendar icon
  static SvgPicture getCalendarIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_calendar,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get preview icon
  static SvgPicture getPreviewIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_preview,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get more icon (enable)
  static SvgPicture getMoreEnableIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_more_enable,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get favorite icon (selected)
  static SvgPicture getFavoriteSelectIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_favorite_select,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get favorite icon (unselected)
  static SvgPicture getFavoriteUnselectIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_favorite_unselect,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get play icon (selected)
  static SvgPicture getPlaySelectIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_play_select,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get play icon (unselected)
  static SvgPicture getPlayUnselectIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_play_unselect,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get add button icon (PARITY: ic_add_btn.xml from reef-b-app)
  /// 24×24dp icon
  static SvgPicture getAddBtnIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_add_btn,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get add rounded icon (PARITY: ic_add_rounded.xml from reef-b-app)
  /// 24×24dp icon
  static SvgPicture getAddRoundedIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_add_rounded,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get add white icon (PARITY: ic_add_white.xml from reef-b-app)
  /// 24×24dp icon
  static SvgPicture getAddWhiteIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_add_white,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get green check icon (PARITY: ic_green_check.xml from reef-b-app)
  /// Green checkmark icon
  static SvgPicture getGreenCheckIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_green_check,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get more disable icon (PARITY: ic_more_disable.xml from reef-b-app)
  /// 24×24dp disabled more button icon
  static SvgPicture getMoreDisableIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_more_disable,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get play disable icon (PARITY: ic_play_disable.xml from reef-b-app)
  /// 60×60dp disabled play button icon
  static SvgPicture getPlayDisableIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_play_disable,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get down icon (PARITY: ic_down.xml from reef-b-app)
  /// Dropdown arrow icon (used for spinners/dropdowns)
  static SvgPicture getDownIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_down,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get drop icon (PARITY: ic_drop.svg from reef-b-app)
  /// Water drop icon (used for dosing/pump head)
  static SvgPicture getDropIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_drop,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get moon round icon (PARITY: ic_moon_round.xml from reef-b-app)
  /// Moon icon (used for moon light/night mode)
  static SvgPicture getMoonRoundIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_moon_round,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get LED device icon (PARITY: icon_led.svg from reef-b-app)
  /// LED device type icon
  static SvgPicture getLedIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.icon_led,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get Dosing device icon (PARITY: icon_dosing.svg from reef-b-app)
  /// Dosing device type icon
  static SvgPicture getDosingIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.icon_dosing,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get none/block icon (PARITY: ic_none.xml from reef-b-app)
  /// Used for scene fallback, blocked state
  static SvgPicture getNoneIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_none,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get strength thumb icon (PARITY: ic_strength_thumb.xml from reef-b-app)
  /// Used for calibration/adjust UI
  static SvgPicture getStrengthThumbIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_strength_thumb,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// Get slow start icon (20×20dp)
  static SvgPicture getSlowStartIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      ReefIconAssets.ic_slow_start,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }
}
