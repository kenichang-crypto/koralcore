import 'package:flutter/material.dart';

class LedSceneSummary {
  final String id;
  final String name;
  final String description;
  final List<Color> palette;
  final bool isEnabled;
  final bool isActive;

  const LedSceneSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.palette,
    required this.isEnabled,
    this.isActive = false,
  });

  LedSceneSummary copyWith({
    String? id,
    String? name,
    String? description,
    List<Color>? palette,
    bool? isEnabled,
    bool? isActive,
  }) {
    return LedSceneSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      palette: palette ?? this.palette,
      isEnabled: isEnabled ?? this.isEnabled,
      isActive: isActive ?? this.isActive,
    );
  }
}
