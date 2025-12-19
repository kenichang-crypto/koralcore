import 'package:flutter/material.dart';

class LedSceneSummary {
  final String id;
  final String name;
  final String description;
  final List<Color> palette;
  final bool isEnabled;

  const LedSceneSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.palette,
    required this.isEnabled,
  });
}
