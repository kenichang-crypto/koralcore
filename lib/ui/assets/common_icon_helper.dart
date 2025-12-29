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
      'assets/icons/common/ic_add_black.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get back icon
  static SvgPicture getBackIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_back.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get delete icon
  static SvgPicture getDeleteIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_delete.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get edit icon
  static SvgPicture getEditIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_edit.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get close icon
  static SvgPicture getCloseIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_close.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get minus icon
  static SvgPicture getMinusIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_minus.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get check icon
  static SvgPicture getCheckIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_check.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get play icon (enabled)
  static SvgPicture getPlayIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_play_enabled.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get stop icon
  static SvgPicture getStopIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_stop.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get pause icon
  static SvgPicture getPauseIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_pause.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get next icon
  static SvgPicture getNextIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_next.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get menu icon
  static SvgPicture getMenuIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_menu.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get bluetooth icon
  static SvgPicture getBluetoothIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_bluetooth.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get device icon
  static SvgPicture getDeviceIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_device.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get home icon
  static SvgPicture getHomeIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_home.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get warning icon
  static SvgPicture getWarningIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_warning.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get reset icon
  static SvgPicture getResetIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_reset.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get master icon
  static SvgPicture getMasterIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_master.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get master icon (big)
  static SvgPicture getMasterBigIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_master_big.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get zoom in icon
  static SvgPicture getZoomInIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_zoom_in.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get zoom out icon
  static SvgPicture getZoomOutIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_zoom_out.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get calendar icon
  static SvgPicture getCalendarIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_calendar.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get preview icon
  static SvgPicture getPreviewIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_preview.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get more icon (enable)
  static SvgPicture getMoreEnableIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_more_enable.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get favorite icon (selected)
  static SvgPicture getFavoriteSelectIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_favorite_select.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get favorite icon (unselected)
  static SvgPicture getFavoriteUnselectIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_favorite_unselect.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get play icon (selected)
  static SvgPicture getPlaySelectIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_play_select.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// Get play icon (unselected)
  static SvgPicture getPlayUnselectIcon({double? size, Color? color}) {
    return SvgPicture.asset(
      'assets/icons/common/ic_play_unselect.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}

