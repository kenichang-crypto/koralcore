import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('reef-b-app PNG assets load via Image.asset', (tester) async {
    final widget = MaterialApp(
      home: Column(
        children: [
          Image.asset('docs/reef_b_app_res/drawable-xxxhdpi/img_led.png'),
          Image.asset('docs/reef_b_app_res/drawable-xxxhdpi/img_drop.png'),
          Image.asset('docs/reef_b_app_res/drawable-hdpi/ic_splash_logo.png'),
        ],
      ),
    );

    await tester.pumpWidget(widget);

    // Pump once more to allow image resolution.
    await tester.pump();
  });
}
