import 'package:flutter/material.dart';

/// Loading overlay for pump head adjustment page.
///
/// PARITY: Mirrors reef-b-app's progress overlay.
class PumpHeadAdjustLoadingOverlay extends StatelessWidget {
  const PumpHeadAdjustLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

