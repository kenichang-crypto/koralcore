// ignore_for_file: constant_identifier_names

/// Unified Asset (Icon) registry for koralcore.
///
/// **Source**: reef-b-app `android/ReefB_Android/app/src/main/res/`
/// - Drawable vectors (XML) → converted to SVG in koralcore `assets/icons/`
/// - PNG/raster → from reef `drawable-hdpi` etc. or koralcore equivalents
///
/// **Usage**: Prefer [CommonIconHelper] for SVG icons (renders SvgPicture).
/// Use path constants below for Image.asset / direct asset loading.
library;

/// Reef icon/asset path constants with reef res source mapping.
///
/// PARITY: All paths align with reef-b-app drawable resources.
/// SVG icons: koralcore assets converted from reef XML vector drawables.
/// PNG icons: reef drawable-hdpi or koralcore assets (img_led/img_drop parity).
class ReefIconAssets {
  ReefIconAssets._();

  // ═══════════════════════════════════════════════════════════════════════════
  // PNG / Raster assets (reef: drawable-hdpi, drawable-xxhdpi, etc.)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Device type: LED
  /// Reef: @drawable/img_led (drawable-hdpi/img_led.png)
  static const String deviceLed = 'assets/icons/device_led.png';

  /// Device type: Dosing pump
  /// Reef: @drawable/img_drop (drawable-hdpi/img_drop.png)
  static const String deviceDoser = 'assets/icons/device_doser.png';

  /// Empty device placeholder
  static const String deviceEmpty = 'assets/icons/device_empty.png';

  /// Bluetooth main icon
  static const String bluetoothMain = 'assets/icons/bluetooth_main.png';

  /// Calibration / adjust image
  /// Reef: @drawable/img_adjust (drawable-hdpi/img_adjust.png)
  static const String imgAdjust =
      'docs/reef_b_app_res/drawable-hdpi/img_adjust.png';

  /// Splash logo
  /// Reef: @drawable/img_splash_logo, ic_splash_logo
  static const String splashLogo =
      'docs/reef_b_app_res/drawable-hdpi/img_splash_logo.png';
  static const String icSplashLogo =
      'docs/reef_b_app_res/drawable-hdpi/ic_splash_logo.png';

  // ═══════════════════════════════════════════════════════════════════════════
  // SVG path constants (reef: drawable/*.xml → koralcore assets/icons/*.svg)
  // Use CommonIconHelper.getXxxIcon() for rendering; paths for reference.
  // ═══════════════════════════════════════════════════════════════════════════

  /// Reef: ic_add_black.xml
  static const String ic_add_black = 'assets/icons/ic_add_black.svg';

  /// Reef: ic_add_btn.xml
  static const String ic_add_btn = 'assets/icons/ic_add_btn.svg';

  /// Reef: ic_add_rounded.xml
  static const String ic_add_rounded = 'assets/icons/ic_add_rounded.svg';

  /// Reef: ic_add_white.xml
  static const String ic_add_white = 'assets/icons/ic_add_white.svg';

  /// Reef: ic_back.xml
  static const String ic_back = 'assets/icons/ic_back.svg';

  /// Reef: ic_bluetooth.xml
  static const String ic_bluetooth = 'assets/icons/ic_bluetooth.svg';

  /// Reef: ic_calendar.xml
  static const String ic_calendar = 'assets/icons/ic_calendar.svg';

  /// Reef: ic_check.xml
  static const String ic_check = 'assets/icons/ic_check.svg';

  /// Reef: ic_close.xml
  static const String ic_close = 'assets/icons/ic_close.svg';

  /// Reef: ic_delete.xml
  static const String ic_delete = 'assets/icons/ic_delete.svg';

  /// Reef: ic_device.xml
  static const String ic_device = 'assets/icons/ic_device.svg';

  /// Reef: ic_down.xml
  static const String ic_down = 'assets/icons/ic_down.svg';

  /// Reef: ic_drop.xml
  static const String ic_drop = 'assets/icons/ic_drop.svg';

  /// Reef: ic_edit.xml
  static const String ic_edit = 'assets/icons/ic_edit.svg';

  /// Reef: ic_favorite_select.xml, ic_favorite_unselect.xml
  static const String ic_favorite_select = 'assets/icons/ic_favorite_select.svg';
  static const String ic_favorite_unselect =
      'assets/icons/ic_favorite_unselect.svg';

  /// Reef: ic_green_check.xml
  static const String ic_green_check = 'assets/icons/ic_green_check.svg';

  /// Reef: ic_home.xml
  static const String ic_home = 'assets/icons/ic_home.svg';

  /// Reef: ic_menu.xml
  static const String ic_menu = 'assets/icons/ic_menu.svg';

  /// Reef: ic_minus.xml
  static const String ic_minus = 'assets/icons/ic_minus.svg';

  /// Reef: ic_master.xml, ic_master_big.xml
  static const String ic_master = 'assets/icons/ic_master.svg';
  static const String ic_master_big = 'assets/icons/ic_master_big.svg';

  /// Reef: ic_next.xml
  static const String ic_next = 'assets/icons/ic_next.svg';

  /// Reef: ic_moon_round.xml
  static const String ic_moon_round = 'assets/icons/ic_moon_round.svg';

  /// Reef: ic_preview.xml
  static const String ic_preview = 'assets/icons/ic_preview.svg';

  /// Reef: ic_pause.xml, ic_play_*.xml, ic_stop.xml
  static const String ic_pause = 'assets/icons/ic_pause.svg';
  static const String ic_play_enabled = 'assets/icons/ic_play_enabled.svg';
  static const String ic_play_disable = 'assets/icons/ic_play_disable.svg';
  static const String ic_play_select = 'assets/icons/ic_play_select.svg';
  static const String ic_play_unselect = 'assets/icons/ic_play_unselect.svg';
  static const String ic_stop = 'assets/icons/ic_stop.svg';

  /// Reef: ic_reset.xml
  static const String ic_reset = 'assets/icons/ic_reset.svg';

  /// Reef: ic_sun.xml, ic_sunrise.xml, ic_sunset.xml, ic_sun_strength.xml
  static const String ic_sun = 'assets/icons/ic_sun.svg';
  static const String ic_sunrise = 'assets/icons/ic_sunrise.svg';
  static const String ic_sunset = 'assets/icons/ic_sunset.svg';

  /// Reef: ic_slow_start.xml
  static const String ic_slow_start = 'assets/icons/ic_slow_start.svg';

  /// Reef: ic_strength_thumb.xml
  static const String ic_strength_thumb = 'assets/icons/ic_strength_thumb.svg';

  /// Reef: ic_warning.xml
  static const String ic_warning = 'assets/icons/ic_warning.svg';

  /// Reef: ic_zoom_in.xml, ic_zoom_out.xml
  static const String ic_zoom_in = 'assets/icons/ic_zoom_in.svg';
  static const String ic_zoom_out = 'assets/icons/ic_zoom_out.svg';

  /// Reef: ic_connect.xml, ic_connect_background.xml, ic_disconnect*.xml
  static const String ic_connect = 'assets/icons/ic_connect.svg';
  static const String ic_connect_background =
      'assets/icons/ic_connect_background.svg';
  static const String ic_disconnect = 'assets/icons/ic_disconnect.svg';
  static const String ic_disconnect_background =
      'assets/icons/ic_disconnect_background.svg';

  /// Reef: ic_none.xml, ic_manager.xml, ic_more_enable.xml, ic_more_disable.xml
  static const String ic_none = 'assets/icons/ic_none.svg';
  static const String ic_manager = 'assets/icons/ic_manager.svg';
  static const String ic_more_enable = 'assets/icons/ic_more_enable.svg';
  static const String ic_more_disable = 'assets/icons/ic_more_disable.svg';

  /// Reef: ic_drop.xml, icon_led, icon_dosing (device type tabs)
  static const String icon_led = 'assets/icons/icon_led.svg';
  static const String icon_dosing = 'assets/icons/icon_dosing.svg';
}
