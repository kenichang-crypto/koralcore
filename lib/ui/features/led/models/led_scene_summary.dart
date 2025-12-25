import 'package:flutter/material.dart';

class LedSceneSummary {
  final String id;
  final String name;
  final String description;
  final List<Color> palette;
  final bool isEnabled;
  final bool isActive;
  final bool isPreset;
  final bool isDynamic;
  final String? iconKey;
  final int? presetCode;
  final Map<String, int> channelLevels;

  const LedSceneSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.palette,
    required this.isEnabled,
    this.isActive = false,
    this.isPreset = false,
    this.isDynamic = false,
    this.iconKey,
    this.presetCode,
    required Map<String, int> channelLevels,
  }) : channelLevels = Map<String, int>.unmodifiable(channelLevels);

  LedSceneSummary copyWith({
    String? id,
    String? name,
    String? description,
    List<Color>? palette,
    bool? isEnabled,
    bool? isActive,
    bool? isPreset,
    bool? isDynamic,
    String? iconKey,
    int? presetCode,
    Map<String, int>? channelLevels,
  }) {
    return LedSceneSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      palette: palette ?? this.palette,
      isEnabled: isEnabled ?? this.isEnabled,
      isActive: isActive ?? this.isActive,
      isPreset: isPreset ?? this.isPreset,
      isDynamic: isDynamic ?? this.isDynamic,
      iconKey: iconKey ?? this.iconKey,
      presetCode: presetCode ?? this.presetCode,
      channelLevels: channelLevels ?? this.channelLevels,
    );
  }
}
