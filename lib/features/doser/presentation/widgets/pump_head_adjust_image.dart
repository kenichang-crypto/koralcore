import 'package:flutter/material.dart';

/// Adjust image for pump head adjustment page.
///
/// PARITY: Mirrors reef-b-app's img_adjust.
class PumpHeadAdjustImage extends StatelessWidget {
  const PumpHeadAdjustImage({super.key});

  @override
  Widget build(BuildContext context) {
    // PARITY: img_adjust - marginTop 24dp
    return Center(
      child: Image.asset(
        'assets/images/img_adjust.png',
        width: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }
}

