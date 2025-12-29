import 'package:flutter/material.dart';

// Import preview functions
import 'feature_entry_card_preview.dart' show featureEntryCardPreview;
// import 'reef_device_card_preview.dart' show reefDeviceCardPreview;
// import 'home_page_layout_preview.dart' show homePageLayoutPreview;

/// Unified entry point for all widget previews.
///
/// This file allows you to easily switch between different previews
/// by changing the preview widget function call.
///
/// Usage:
/// 1. Change the function call to the preview you want to see
/// 2. Run: flutter run -t lib/ui/previews/all_previews.dart
void main() {
  // Change this to switch between different previews
  runApp(featureEntryCardPreview());
  // runApp(reefDeviceCardPreview());
  // runApp(homePageLayoutPreview());
}
