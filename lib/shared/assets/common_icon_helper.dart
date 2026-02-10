import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// CommonIconHelper
///
/// Helper class for getting common icons from reef-b-app.
/// PARITY: All icons are converted from reef-b-app's XML drawables.
class CommonIconHelper {
  const CommonIconHelper._();

  /// Get add icon (black)
  static SvgPicture getAddIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/ic_add_black.svg',
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
      'assets/icons/ic_back.svg',
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
      'assets/icons/ic_delete.svg',
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
      'assets/icons/ic_edit.svg',
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
      'assets/icons/ic_close.svg',
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
      'assets/icons/ic_minus.svg',
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
      'assets/icons/ic_play_enabled.svg',
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
      'assets/icons/ic_stop.svg',
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
      'assets/icons/ic_pause.svg',
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
      'assets/icons/ic_menu.svg',
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
      'assets/icons/ic_manager.svg',
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
      'assets/icons/ic_bluetooth.svg',
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
      'assets/icons/ic_disconnect.svg',
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
      'assets/icons/ic_device.svg',
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
      'assets/icons/ic_home.svg',
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
      'assets/icons/ic_warning.svg',
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
      'assets/icons/ic_reset.svg',
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
      'assets/icons/ic_connect_background.svg',
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
      'assets/icons/ic_disconnect_background.svg',
      width: width ?? 48,
      height: height ?? 32,
    );
  }

  /// Get master icon
  static SvgPicture getMasterIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/ic_master.svg',
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
      'assets/icons/ic_master_big.svg',
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
      'assets/icons/ic_zoom_in.svg',
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
      'assets/icons/ic_zoom_out.svg',
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
      'assets/icons/ic_calendar.svg',
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
      'assets/icons/ic_preview.svg',
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
      'assets/icons/ic_more_enable.svg',
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
      'assets/icons/ic_favorite_select.svg',
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
      'assets/icons/ic_favorite_unselect.svg',
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
      'assets/icons/ic_play_select.svg',
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
      'assets/icons/ic_play_unselect.svg',
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
      'assets/icons/ic_add_btn.svg',
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
      'assets/icons/ic_add_rounded.svg',
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
      'assets/icons/ic_add_white.svg',
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
      'assets/icons/ic_green_check.svg',
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
      'assets/icons/ic_more_disable.svg',
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
      'assets/icons/ic_play_disable.svg',
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
      'assets/icons/ic_down.svg',
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
      'assets/icons/ic_drop.svg',
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
      'assets/icons/ic_moon_round.svg',
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
      'assets/icons/icon_led.svg',
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
      'assets/icons/icon_dosing.svg',
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
      'assets/icons/ic_slow_start.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }
}
