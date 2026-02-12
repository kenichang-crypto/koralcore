/// @Deprecated Material Icons fallback – use asset-based icons instead.
///
/// **Do not use.** Icons should come from reef-b-app res via [ReefIconAssets]
/// and [CommonIconHelper]. This file exists only for migration reference.
///
/// Replace: `Icon(ReefMaterialIcons.xxx)` → `CommonIconHelper.getXxxIcon()`
/// See [ReefIconAssets] and [CommonIconHelper] for reef parity icons.
@Deprecated(
  'Use CommonIconHelper / ReefIconAssets for reef-b-app parity. '
  'Material Icons are not reef-sourced.',
)
library;

import 'package:flutter/material.dart';

/// Material Icons equivalents for common reef-b-app drawable icons.
class ReefMaterialIcons {
  const ReefMaterialIcons._();

  // Basic actions
  static const IconData add = Icons.add;
  static const IconData addBlack = Icons.add;
  static const IconData addWhite = Icons.add;
  static const IconData addRounded = Icons.add_circle;
  static const IconData back = Icons.arrow_back;
  static const IconData check = Icons.check;
  static const IconData close = Icons.close;
  static const IconData delete = Icons.delete;
  static const IconData edit = Icons.edit;
  static const IconData down = Icons.keyboard_arrow_down;
  static const IconData up = Icons.keyboard_arrow_up;
  static const IconData next = Icons.arrow_forward;
  static const IconData menu = Icons.menu;
  static const IconData more = Icons.more_vert;
  static const IconData moreEnable = Icons.more_vert;
  static const IconData moreDisable = Icons.more_vert_outlined;

  // Playback controls
  static const IconData play = Icons.play_arrow;
  static const IconData playEnabled = Icons.play_arrow;
  static const IconData playDisabled = Icons.play_arrow_outlined;
  static const IconData playSelect = Icons.play_circle;
  static const IconData playUnselect = Icons.play_circle_outline;
  static const IconData pause = Icons.pause;
  static const IconData stop = Icons.stop;

  // Device and settings
  static const IconData device = Icons.devices;
  static const IconData bluetooth = Icons.bluetooth;
  static const IconData home = Icons.home;
  static const IconData warning = Icons.warning;
  static const IconData warningRobot = Icons.warning_amber_rounded;
  static const IconData settings = Icons.settings;
  static const IconData reset = Icons.refresh;

  // Light and scene
  static const IconData sun = Icons.wb_sunny;
  static const IconData sunrise = Icons.wb_twilight;
  static const IconData sunset = Icons.wb_twilight;
  static const IconData moon = Icons.nightlight_round;
  static const IconData moonRound = Icons.nightlight_round;
  static const IconData lightOff = Icons.lightbulb_outline;
  static const IconData preview = Icons.preview;
  static const IconData slowStart = Icons.timelapse;
  static const IconData strength = Icons.tune;
  static const IconData sunStrength = Icons.wb_sunny;

  // Weather icons (if needed)
  static const IconData sunny = Icons.wb_sunny;
  static const IconData cloudy = Icons.cloud;
  static const IconData rainy = Icons.grain;
  static const IconData dizzle = Icons.grain;
  static const IconData mist = Icons.blur_on;
  static const IconData thunder = Icons.flash_on;

  // Calendar and time
  static const IconData calendar = Icons.calendar_today;
  static const IconData time = Icons.access_time;

  // Favorite
  static const IconData favoriteSelect = Icons.favorite;
  static const IconData favoriteUnselect = Icons.favorite_border;

  // Master/Slave
  static const IconData master = Icons.star;
  static const IconData masterBig = Icons.star;

  // Zoom
  static const IconData zoomIn = Icons.zoom_in;
  static const IconData zoomOut = Icons.zoom_out;

  // Light channel thumbs (use color filters)
  static const IconData lightThumb = Icons.circle;
  static const IconData blueLightThumb = Icons.circle;
  static const IconData purpleLightThumb = Icons.circle;
  static const IconData royalBlueLightThumb = Icons.circle;
  static const IconData greenLightThumb = Icons.circle;
  static const IconData redLightThumb = Icons.circle;
  static const IconData coldWhiteLightThumb = Icons.circle;
  static const IconData warmWhiteLightThumb = Icons.circle;
  static const IconData uvLightThumb = Icons.circle;
  static const IconData moonLightThumb = Icons.circle;
  static const IconData strengthThumb = Icons.circle;

  // Weekday selection (use checkboxes or chips)
  static const IconData mondaySelect = Icons.check_circle;
  static const IconData mondayUnselect = Icons.radio_button_unchecked;
  static const IconData tuesdaySelect = Icons.check_circle;
  static const IconData tuesdayUnselect = Icons.radio_button_unchecked;
  static const IconData wednesdaySelect = Icons.check_circle;
  static const IconData wednesdayUnselect = Icons.radio_button_unchecked;
  static const IconData thursdaySelect = Icons.check_circle;
  static const IconData thursdayUnselect = Icons.radio_button_unchecked;
  static const IconData fridaySelect = Icons.check_circle;
  static const IconData fridayUnselect = Icons.radio_button_unchecked;
  static const IconData saturdaySelect = Icons.check_circle;
  static const IconData saturdayUnselect = Icons.radio_button_unchecked;
  static const IconData sundaySelect = Icons.check_circle;
  static const IconData sundayUnselect = Icons.radio_button_unchecked;

  // Other
  static const IconData none = Icons.block;
  static const IconData manager = Icons.manage_accounts;
  static const IconData solidAdd = Icons.add_circle;
}

/// Helper to get Material Icon with optional color.
Icon getReefIcon(
  IconData iconData, {
  Color? color,
  double? size,
}) {
  return Icon(
    iconData,
    color: color,
    size: size,
  );
}

